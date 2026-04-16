import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/user_profile.dart';
import '../../providers/user_profile_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isSubmitting = false;

  // Step 1
  String? _fitnessLevel;

  // Step 2
  final List<String> _rankedGoals = [];

  // Step 3
  String? _workoutSplit;

  static const _fitnessLevels = [
    ('beginner', 'Beginner', 'New to fitness or getting back into it'),
    ('intermediate', 'Intermediate', 'Consistent training for 6+ months'),
    ('advanced', 'Advanced', '2+ years of structured training'),
    ('athlete', 'Athlete', 'Competitive or sport-specific training'),
  ];

  static const _goals = [
    ('lose_weight', 'Lose Weight', Icons.monitor_weight_outlined),
    ('build_muscle', 'Build Muscle', Icons.fitness_center),
    ('improve_endurance', 'Improve Endurance', Icons.directions_run),
    ('stay_active', 'Stay Active', Icons.self_improvement),
    ('improve_flexibility', 'Improve Flexibility', Icons.accessibility_new),
  ];

  static const _splits = [
    (
      'ppl',
      'Push / Pull / Legs',
      'Push: chest, shoulders, triceps\nPull: back, biceps\nLegs: quads, hamstrings, glutes',
    ),
    (
      'upper_lower',
      'Upper / Lower',
      'Alternate between upper body and lower body days',
    ),
    (
      'full_body',
      'Full Body',
      'Train all major muscle groups each session',
    ),
    (
      'bro_split',
      'Bro Split',
      'One muscle group per day (chest day, arm day, etc.)',
    ),
  ];

  bool get _canProceed {
    switch (_currentPage) {
      case 0:
        return _fitnessLevel != null;
      case 1:
        return _rankedGoals.isNotEmpty;
      case 2:
        return _workoutSplit != null;
      default:
        return false;
    }
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => _currentPage++);
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => _currentPage--);
  }

  void _toggleGoal(String goalId) {
    setState(() {
      if (_rankedGoals.contains(goalId)) {
        _rankedGoals.remove(goalId);
      } else {
        _rankedGoals.add(goalId);
      }
    });
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final now = DateTime.now().toIso8601String();
      final profile = UserProfile(
        uid: user.uid,
        displayName: user.displayName ?? user.email ?? 'Purdue Student',
        email: user.email ?? '',
        photoUrl: user.photoURL,
        fitnessLevel: _fitnessLevel!,
        goals: List.unmodifiable(_rankedGoals),
        workoutSplit: _workoutSplit,
        preferredFacilities: const [],
        createdAt: now,
        updatedAt: now,
      );

      final service = ref.read(userProfileServiceProvider);
      await service.createProfile(profile);
      // Router redirect will handle navigation to /home once the
      // userProfileProvider stream emits the new doc.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save profile: $e')),
        );
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: Row(
                children: List.generate(3, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: index <= _currentPage
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surfaceContainerHighest,
                      ),
                    ),
                  );
                }),
              ),
            ),
            // Step label
            Text(
              'Step ${_currentPage + 1} of 3',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(153),
              ),
            ),
            const SizedBox(height: 8),
            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildFitnessLevelStep(theme),
                  _buildGoalsStep(theme),
                  _buildSplitStep(theme),
                ],
              ),
            ),
            // Navigation buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: _isSubmitting ? null : _previousPage,
                      child: const Text('Back'),
                    ),
                  const Spacer(),
                  if (_currentPage < 2)
                    FilledButton(
                      onPressed: _canProceed && !_isSubmitting
                          ? _nextPage
                          : null,
                      child: const Text('Next'),
                    )
                  else
                    FilledButton(
                      onPressed: _canProceed && !_isSubmitting
                          ? _submit
                          : null,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Finish'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Step 1: Fitness Level ──────────────────────────────────────────

  Widget _buildFitnessLevelStep(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'Welcome!',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Let's start by understanding your fitness level.",
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(153),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              itemCount: _fitnessLevels.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final (value, label, description) = _fitnessLevels[index];
                final isSelected = _fitnessLevel == value;
                return _SelectableCard(
                  label: label,
                  description: description,
                  isSelected: isSelected,
                  onTap: () => setState(() => _fitnessLevel = value),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 2: Goals (numbered tap order) ─────────────────────────────

  Widget _buildGoalsStep(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'What are your fitness goals?',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap to select. Your first tap is your top priority.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(153),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              itemCount: _goals.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final (value, label, icon) = _goals[index];
                final rank = _rankedGoals.indexOf(value);
                final isSelected = rank != -1;

                return _GoalCard(
                  label: label,
                  icon: icon,
                  rank: isSelected ? rank + 1 : null,
                  isSelected: isSelected,
                  onTap: () => _toggleGoal(value),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 3: Workout Split ──────────────────────────────────────────

  Widget _buildSplitStep(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'How do you like to train?',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a workout split that fits your schedule.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(153),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              itemCount: _splits.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final (value, label, description) = _splits[index];
                final isSelected = _workoutSplit == value;
                return _SelectableCard(
                  label: label,
                  description: description,
                  isSelected: isSelected,
                  onTap: () => setState(() => _workoutSplit = value),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable card widgets ──────────────────────────────────────────────

class _SelectableCard extends StatelessWidget {
  const _SelectableCard({
    required this.label,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: isSelected ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant,
          width: isSelected ? 2 : 1,
        ),
      ),
      color: isSelected
          ? theme.colorScheme.primaryContainer.withAlpha(77)
          : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: theme.colorScheme.primary,
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(153),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.label,
    required this.icon,
    required this.rank,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final int? rank;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: isSelected ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant,
          width: isSelected ? 2 : 1,
        ),
      ),
      color: isSelected
          ? theme.colorScheme.primaryContainer.withAlpha(77)
          : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 28, color: theme.colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isSelected && rank != null)
                CircleAvatar(
                  radius: 14,
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    '$rank',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
