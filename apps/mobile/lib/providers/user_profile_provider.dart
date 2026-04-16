import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_profile.dart';
import 'auth_provider.dart';

/// Stream of the current user's profile document (null if no doc exists).
final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(null);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((snap) =>
          snap.exists ? UserProfile.fromJson({...snap.data()!, 'uid': snap.id}) : null);
});

/// Service for creating / updating user profiles in Firestore.
final userProfileServiceProvider = Provider<UserProfileService>((ref) {
  return UserProfileService(ref);
});

class UserProfileService {
  UserProfileService(this._ref);

  final Ref _ref;

  DocumentReference<Map<String, dynamic>> _doc() {
    final user = _ref.read(currentUserProvider);
    if (user == null) throw StateError('User not authenticated');
    return FirebaseFirestore.instance.collection('users').doc(user.uid);
  }

  Future<void> createProfile(UserProfile profile) async {
    await _doc().set(profile.toJson());
  }

  Future<void> updateProfile(Map<String, dynamic> fields) async {
    fields['updatedAt'] = DateTime.now().toIso8601String();
    await _doc().update(fields);
  }
}
