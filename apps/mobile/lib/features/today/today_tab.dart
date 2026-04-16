import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/daily_plan.dart';
import '../../providers/facility_provider.dart';
import '../../providers/plan_provider.dart';

class TodayTab extends ConsumerWidget {
  const TodayTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final today = DateFormat.yMMMMEEEEd().format(DateTime.now());
    final facilityUsage = ref.watch(facilityUsageProvider);
    final planAsync = ref.watch(planProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(facilityUsageProvider);
        ref.invalidate(planProvider);
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

          // Today's plan card
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
                        "Today's Plan",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  planAsync.when(
                    data: (plan) => plan != null
                        ? _PlanItemList(plan: plan)
                        : _EmptyPlanView(
                            onGenerate: () =>
                                ref.read(planProvider.notifier).generatePlan(),
                          ),
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (error, _) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Failed to load plan: $error',
                          style: TextStyle(
                            color: theme.colorScheme.error,
                          ),
                        ),
                        const SizedBox(height: 8),
                        FilledButton.tonal(
                          onPressed: () =>
                              ref.read(planProvider.notifier).generatePlan(),
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
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

/// Shown when no plan exists yet.
class _EmptyPlanView extends StatelessWidget {
  const _EmptyPlanView({required this.onGenerate});

  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'No plan generated yet. Add your schedule and '
          'generate a personalized workout plan.',
        ),
        const SizedBox(height: 12),
        FilledButton.tonal(
          onPressed: onGenerate,
          child: const Text('Generate Plan'),
        ),
      ],
    );
  }
}

/// Renders a [DailyPlan] as a list of [_PlanItemCard] widgets.
class _PlanItemList extends StatelessWidget {
  const _PlanItemList({required this.plan});

  final DailyPlan plan;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...plan.items.map((item) => _PlanItemCard(item: item)),
        const SizedBox(height: 8),
        Text(
          plan.disclaimer,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
        ),
      ],
    );
  }
}

/// Displays a single [PlanItem].
class _PlanItemCard extends StatelessWidget {
  const _PlanItemCard({required this.item});

  final PlanItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 56,
            child: Text(
              item.time,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.activity,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${item.duration} min'
                  '${item.location != null ? ' · ${item.location}' : ''}',
                  style: theme.textTheme.bodySmall,
                ),
                if (item.notes != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.notes!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
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

    final Color progressColor;
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
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
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
