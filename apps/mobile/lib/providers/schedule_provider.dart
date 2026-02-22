import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/schedule_block.dart';
import 'auth_provider.dart';

/// Provides the user's schedule blocks from Firestore (realtime).
final scheduleBlocksProvider =
    StreamProvider<List<ScheduleBlock>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('scheduleBlocks')
      .orderBy('dayOfWeek')
      .orderBy('startTime')
      .snapshots()
      .map((snap) => snap.docs
          .map((doc) => ScheduleBlock.fromJson({...doc.data(), 'id': doc.id}))
          .toList());
});

/// CRUD operations for schedule blocks.
final scheduleServiceProvider = Provider<ScheduleService>((ref) {
  return ScheduleService(ref);
});

class ScheduleService {
  ScheduleService(this._ref);

  final Ref _ref;

  CollectionReference<Map<String, dynamic>> _collection() {
    final user = _ref.read(currentUserProvider);
    if (user == null) throw StateError('User not authenticated');
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('scheduleBlocks');
  }

  Future<void> addBlock(ScheduleBlock block) async {
    await _collection().doc(block.id).set(block.toJson());
  }

  Future<void> updateBlock(ScheduleBlock block) async {
    await _collection().doc(block.id).set(block.toJson());
  }

  Future<void> deleteBlock(String blockId) async {
    await _collection().doc(blockId).delete();
  }
}
