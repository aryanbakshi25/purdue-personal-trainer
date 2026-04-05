import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';

/// Realtime `users/{uid}` document for profile fields used in this tab.
final userProfileDocProvider =
    StreamProvider<DocumentSnapshot<Map<String, dynamic>>?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Stream<DocumentSnapshot<Map<String, dynamic>>?>.value(null);
  }
  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots();
});

const _fitnessLevels = ['beginner', 'intermediate', 'advanced'];

/// Stored values align with shared schema / UX copy (lose fat, build muscle, …).
const _goalIds = ['lose_fat', 'build_muscle', 'maintain', 'recomp'];

String _fitnessLevelLabel(String id) {
  switch (id) {
    case 'beginner':
      return 'Beginner';
    case 'intermediate':
      return 'Intermediate';
    case 'advanced':
      return 'Advanced';
    default:
      return id;
  }
}

String _goalLabel(String id) {
  switch (id) {
    case 'lose_fat':
      return 'Lose fat';
    case 'build_muscle':
      return 'Build muscle';
    case 'maintain':
      return 'Maintain';
    case 'recomp':
      return 'Recomp';
    default:
      return id;
  }
}

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);
    final profileAsync = ref.watch(userProfileDocProvider);

    if (user == null) {
      return const Center(child: Text('Not signed in'));
    }

    final fitnessLevel = profileAsync.maybeWhen(
      data: (doc) {
        if (doc == null || !doc.exists) return 'beginner';
        final v = doc.data()?['fitnessLevel'] as String?;
        return (v != null && _fitnessLevels.contains(v)) ? v : 'beginner';
      },
      orElse: () => 'beginner',
    );

    final goals = profileAsync.maybeWhen(
      data: (doc) {
        if (doc == null || !doc.exists) return <String>[];
        final raw = doc.data()?['goals'];
        if (raw is! List) return <String>[];
        return raw
            .map((e) => e as String)
            .where(_goalIds.contains)
            .toList();
      },
      orElse: () => <String>[],
    );

    String goalsSubtitle;
    if (goals.isEmpty) {
      goalsSubtitle = 'Tap to set fitness goals';
    } else {
      goalsSubtitle = goals.map(_goalLabel).join(', ');
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Profile header
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: user.photoURL != null
                    ? NetworkImage(user.photoURL!)
                    : null,
                child: user.photoURL == null
                    ? Text(
                        (user.displayName ?? 'U')[0].toUpperCase(),
                        style: theme.textTheme.headlineMedium,
                      )
                    : null,
              ),
              const SizedBox(height: 12),
              Text(
                user.displayName ?? 'Unknown',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                user.email ?? '',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(153),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Settings cards
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.fitness_center),
                title: const Text('Fitness & goals'),
                subtitle: Text(
                  '${_fitnessLevelLabel(fitnessLevel)} · $goalsSubtitle',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showFitnessGoalsSheet(
                  context,
                  ref,
                  initialFitnessLevel: fitnessLevel,
                  initialGoals: goals,
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.location_on),
                title: const Text('Preferred Facilities'),
                subtitle: const Text('CoRec'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Edit preferred facilities
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // UPlate integration placeholder
        Card(
          child: ListTile(
            leading: const Icon(Icons.restaurant_menu),
            title: const Text('UPlate Integration'),
            subtitle: const Text('Coming soon – dining recommendations'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Deep-link to UPlate when available
            },
          ),
        ),
        const SizedBox(height: 24),

        // Sign out
        OutlinedButton.icon(
          onPressed: () async {
            final authService = ref.read(authServiceProvider);
            await authService.signOut();
          },
          icon: const Icon(Icons.logout),
          label: const Text('Sign Out'),
        ),
      ],
    );
  }
}

Future<void> _showFitnessGoalsSheet(
  BuildContext context,
  WidgetRef ref, {
  required String initialFitnessLevel,
  required List<String> initialGoals,
}) async {
  final user = ref.read(currentUserProvider);
  if (user == null) return;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) {
      return _FitnessGoalsSheet(
        uid: user.uid,
        initialFitnessLevel: initialFitnessLevel,
        initialGoals: initialGoals,
      );
    },
  );
}

class _FitnessGoalsSheet extends StatefulWidget {
  const _FitnessGoalsSheet({
    required this.uid,
    required this.initialFitnessLevel,
    required this.initialGoals,
  });

  final String uid;
  final String initialFitnessLevel;
  final List<String> initialGoals;

  @override
  State<_FitnessGoalsSheet> createState() => _FitnessGoalsSheetState();
}

class _FitnessGoalsSheetState extends State<_FitnessGoalsSheet> {
  late String _fitnessLevel;
  late Set<String> _goals;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _fitnessLevel = widget.initialFitnessLevel;
    _goals = Set<String>.from(widget.initialGoals);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.uid).set(
        {
          'fitnessLevel': _fitnessLevel,
          'goals': _goals.toList(),
          'updatedAt': DateTime.now().toUtc().toIso8601String(),
        },
        SetOptions(merge: true),
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 8,
        bottom: bottomInset + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Fitness level',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _fitnessLevels.map((id) {
              return ChoiceChip(
                label: Text(_fitnessLevelLabel(id)),
                selected: _fitnessLevel == id,
                onSelected: (_) {
                  setState(() => _fitnessLevel = id);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text(
            'Goals',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select one or more',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(153),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _goalIds.map((id) {
              final selected = _goals.contains(id);
              return ChoiceChip(
                label: Text(_goalLabel(id)),
                selected: selected,
                onSelected: (value) {
                  setState(() {
                    if (value) {
                      _goals.add(id);
                    } else {
                      _goals.remove(id);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
    );
  }
}
