import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return const Center(child: Text('Not signed in'));
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
                title: const Text('Fitness Level'),
                subtitle: const Text('Beginner'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Edit fitness level
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.flag),
                title: const Text('Goals'),
                subtitle: const Text('Tap to set fitness goals'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Edit goals
                },
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
      ],
    );
  }
}
