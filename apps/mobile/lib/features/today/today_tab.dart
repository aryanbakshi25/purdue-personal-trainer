import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/facility_provider.dart';

class TodayTab extends ConsumerWidget {
  const TodayTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final today = DateFormat.yMMMMEEEEd().format(DateTime.now());
    final facilityUsage = ref.watch(facilityUsageProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(facilityUsageProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Date header
          Text(
            today,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Today's plan placeholder
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Today\'s Plan',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No plan generated yet. Add your schedule and '
                    'generate a personalized workout plan.',
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonal(
                    onPressed: () {
                      // TODO: Navigate to plan generation
                    },
                    child: const Text('Generate Plan'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Facility usage
          Text(
            'Facility Usage',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          facilityUsage.when(
            data: (facilities) {
              if (facilities.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No facility data available.'),
                  ),
                );
              }
              return Column(
                children: facilities
                    .map((f) => _FacilityUsageCard(facility: f))
                    .toList(),
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, _) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.error_outline, size: 32),
                    const SizedBox(height: 8),
                    Text('Failed to load facility data: $error'),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => ref.invalidate(facilityUsageProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FacilityUsageCard extends StatelessWidget {
  const _FacilityUsageCard({required this.facility});

  final dynamic facility;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = facility.maxCapacity > 0
        ? facility.currentCount / facility.maxCapacity
        : 0.0;

    Color progressColor;
    if (percent < 0.5) {
      progressColor = Colors.green;
    } else if (percent < 0.8) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.red;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    facility.facilityName as String,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                Text(
                  '${facility.currentCount}/${facility.maxCapacity}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percent as double,
                backgroundColor:
                    theme.colorScheme.surfaceContainerHighest,
                color: progressColor,
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
