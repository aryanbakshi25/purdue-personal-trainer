import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/schedule_provider.dart';

class ScheduleTab extends ConsumerWidget {
  const ScheduleTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final blocks = ref.watch(scheduleBlocksProvider);

    return Scaffold(
      body: blocks.when(
        data: (blockList) {
          if (blockList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_month_outlined,
                    size: 64,
                    color: theme.colorScheme.onSurface.withAlpha(77),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No schedule blocks yet',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text('Add your classes, work, and other commitments.'),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => context.go('/schedule/new'),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Schedule Block'),
                  ),
                ],
              ),
            );
          }

          // Group blocks by day
          final grouped = <String, List<dynamic>>{};
          for (final block in blockList) {
            grouped.putIfAbsent(block.dayOfWeek, () => []).add(block);
          }

          final days = [
            'monday', 'tuesday', 'wednesday', 'thursday',
            'friday', 'saturday', 'sunday',
          ];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final day in days)
                if (grouped.containsKey(day)) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 4),
                    child: Text(
                      day[0].toUpperCase() + day.substring(1),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...grouped[day]!.map(
                    (block) => Card(
                      margin: const EdgeInsets.only(bottom: 4),
                      child: ListTile(
                        leading: _categoryIcon(block.category),
                        title: Text(block.title),
                        subtitle: Text(
                          '${block.startTime} - ${block.endTime}'
                          '${block.location != null ? ' @ ${block.location}' : ''}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () =>
                              context.go('/schedule/edit/${block.id}'),
                        ),
                      ),
                    ),
                  ),
                ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('Error loading schedule: $error'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/schedule/new'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _categoryIcon(String category) {
    switch (category) {
      case 'class':
        return const Icon(Icons.school);
      case 'work':
        return const Icon(Icons.work);
      case 'gym':
        return const Icon(Icons.fitness_center);
      case 'meal':
        return const Icon(Icons.restaurant);
      default:
        return const Icon(Icons.event);
    }
  }
}
