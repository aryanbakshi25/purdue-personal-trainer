/// Mirrors the UserProfile schema from @ppt/shared.
class UserProfile {
  UserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.fitnessLevel = 'beginner',
    this.goals = const [],
    this.workoutSplit,
    this.preferredFacilities = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] as String,
      displayName: json['displayName'] as String,
      email: json['email'] as String,
      photoUrl: json['photoUrl'] as String?,
      fitnessLevel: json['fitnessLevel'] as String? ?? 'beginner',
      workoutSplit: json['workoutSplit'] as String?,
      goals: (json['goals'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      preferredFacilities: (json['preferredFacilities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;
  final String fitnessLevel;
  final List<String> goals;
  final String? workoutSplit;
  final List<String> preferredFacilities;
  final String createdAt;
  final String updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'fitnessLevel': fitnessLevel,
      'goals': goals,
      'workoutSplit': workoutSplit,
      'preferredFacilities': preferredFacilities,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
