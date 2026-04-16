import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/daily_plan.dart';
import 'api_provider.dart';

/// Manages today's [DailyPlan] — loads from Firestore on init,
/// and generates a new plan via the backend API on demand.
final planProvider =
    AsyncNotifierProvider<PlanNotifier, DailyPlan?>(PlanNotifier.new);

class PlanNotifier extends AsyncNotifier<DailyPlan?> {
  static final _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  Future<DailyPlan?> build() async {
    return _loadFromFirestore();
  }

  /// Loads today's plan from Firestore if one already exists.
  Future<DailyPlan?> _loadFromFirestore() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final today = _dateFormat.format(DateTime.now());
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('plans')
        .doc(today)
        .get();

    if (!doc.exists) return null;
    return DailyPlan.fromJson(doc.data()!);
  }

  /// Calls POST /api/plan/generate, persists result to Firestore,
  /// and updates state.
  Future<void> generatePlan() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('User not signed in.');

      final api = ref.read(apiClientProvider);
      final response = await api.post<Map<String, dynamic>>(
        '/api/plan/generate',
      );

      final plan = DailyPlan.fromJson(response.data!);

      // Persist to Firestore at users/{uid}/plans/{date}.
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('plans')
          .doc(plan.date)
          .set(plan.toJson());

      return plan;
    });
  }
}
