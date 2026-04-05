import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
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
        final fitnessLabel = _fitnessLevelLabels[profile?.fitnessLevel] ??
            profile?.fitnessLevel ??
            'Not set';

        final goalsLabel = profile != null && profile.goals.isNotEmpty
            ? profile.goals
                .map((g) => _goalLabels[g] ?? g)
                .join(', ')
            : 'No goals set';

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
                    onTap: () {
                      // TODO: Edit fitness level
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.flag),
                    title: const Text('Goals'),
                    subtitle: Text(goalsLabel),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Edit goals
                    },
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
      },
    );
  }
}
