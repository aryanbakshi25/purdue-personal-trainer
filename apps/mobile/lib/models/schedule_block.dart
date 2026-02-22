/// Mirrors the ScheduleBlock schema from @ppt/shared.
class ScheduleBlock {
  ScheduleBlock({
    required this.id,
    required this.title,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.location,
    this.category = 'other',
    this.isRecurring = true,
  });

  factory ScheduleBlock.fromJson(Map<String, dynamic> json) {
    return ScheduleBlock(
      id: json['id'] as String,
      title: json['title'] as String,
      dayOfWeek: json['dayOfWeek'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      location: json['location'] as String?,
      category: json['category'] as String? ?? 'other',
      isRecurring: json['isRecurring'] as bool? ?? true,
    );
  }

  final String id;
  final String title;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String? location;
  final String category;
  final bool isRecurring;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'location': location,
      'category': category,
      'isRecurring': isRecurring,
    };
  }

  ScheduleBlock copyWith({
    String? id,
    String? title,
    String? dayOfWeek,
    String? startTime,
    String? endTime,
    String? location,
    String? category,
    bool? isRecurring,
  }) {
    return ScheduleBlock(
      id: id ?? this.id,
      title: title ?? this.title,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      category: category ?? this.category,
      isRecurring: isRecurring ?? this.isRecurring,
    );
  }
}
