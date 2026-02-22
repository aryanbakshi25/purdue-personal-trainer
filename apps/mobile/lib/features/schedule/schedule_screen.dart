import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'schedule_tab.dart';

/// Full-page schedule screen (accessible via /schedule route).
/// Wraps the ScheduleTab with its own AppBar for standalone navigation.
class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Schedule'),
      ),
      body: const ScheduleTab(),
    );
  }
}
