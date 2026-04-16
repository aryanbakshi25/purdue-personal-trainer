import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/user_profile_provider.dart';

const _fitnessLevelLabels = {
  'beginner': 'Beginner',
  'intermediate': 'Intermediate',
  'advanced': 'Advanced',
  'athlete': 'Athlete',
};

const _goalLabels = {
  'lose_weight': 'Lose Weight',
  'build_muscle': 'Build Muscle',
  'improve_endurance': 'Improve Endurance',
  'stay_active': 'Stay Active',
  'improve_flexibility': 'Improve Flexibility',
};

const _splitLabels = {
  'ppl': 'Push / Pull / Legs',
  'upper_lower': 'Upper / Lower',
  'full_body': 'Full Body',
  'bro_split': 'Bro Split',
};

const _fitnessLevels = ['beginner', 'intermediate', 'advanced', 'athlete'];
const _goalIds = [
  'lose_weight',
  'build_muscle',
  'improve_endurance',
  'stay_active',
  'improve_flexibility',
];

String _fitnessLevelLabel(String id) => _fitnessLevelLabels[id] ?? id;
String _goalLabel(String id) => _goalLabels[id] ?? id;

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);
    final profileAsync = ref.watch(userProfileProvider);

    if (user == null) {
      return const Center(child: Text('Not signed in'));
    }

    return profileAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error loading profile: $error')),
      data: (profile) {
        final fitnessLevel = profile?.fitnessLevel ?? 'beginner';
        final goals = profile?.goals ?? <String>[];

        final fitnessLabel = _fitnessLevelLabels[fitnessLevel] ?? fitnessLevel;

        final goalsLabel = goals.isNotEmpty
            ? goals.map(_goalLabel).join(', ')
            : 'Tap to set fitness goals';

        final splitLabel = profile?.workoutSplit != null
            ? _splitLabels[profile!.workoutSplit!] ?? profile.workoutSplit!
            : 'Not set';

        final facilitiesLabel =
            profile != null && profile.preferredFacilities.isNotEmpty
                ? profile.preferredFacilities.join(', ')
                : 'None set';

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
                    title: const Text('Fitness Level'),
                    subtitle: Text(fitnessLabel),
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
                    leading: const Icon(Icons.flag),
                    title: const Text('Goals'),
                    subtitle: Text(goalsLabel),
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
                    leading: const Icon(Icons.calendar_view_week),
                    title: const Text('Workout Split'),
                    subtitle: Text(splitLabel),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Edit workout split
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.location_on),
                    title: const Text('Preferred Facilities'),
                    subtitle: Text(facilitiesLabel),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Edit preferred facilities
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Appearance
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 8),
              child: Text(
                'Appearance',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.palette_outlined),
                        SizedBox(width: 12),
                        Text('Theme Mode'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<ThemeMode>(
                        segments: const [
                          ButtonSegment(
                            value: ThemeMode.system,
                            label: Text('System'),
                            icon: Icon(Icons.brightness_auto),
                          ),
                          ButtonSegment(
                            value: ThemeMode.light,
                            label: Text('Light'),
                            icon: Icon(Icons.light_mode),
                          ),
                          ButtonSegment(
                            value: ThemeMode.dark,
                            label: Text('Dark'),
                            icon: Icon(Icons.dark_mode),
                          ),
                        ],
                        selected: {ref.watch(themeNotifierProvider)},
                        onSelectionChanged: (Set<ThemeMode> newSelection) {
                          ref
                              .read(themeNotifierProvider.notifier)
                              .setThemeMode(newSelection.first);
                        },
                      ),
                    ),
                  ],
                ),
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
            if (kDebugMode) ...[
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Development Only',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(102),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Reset Onboarding?'),
                      content: const Text(
                        'This will delete your profile and send you back to onboarding.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && user != null) {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .delete();
                  }
                },
                icon: const Icon(Icons.restart_alt),
                label: const Text('Re-run Onboarding'),
              ),
            ],
          ],
        );
      },
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
