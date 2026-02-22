/// Mirrors the FacilityUsageItem schema from @ppt/shared.
class FacilityUsageItem {
  FacilityUsageItem({
    required this.facilityName,
    required this.currentCount,
    required this.maxCapacity,
    required this.lastUpdated,
  });

  factory FacilityUsageItem.fromJson(Map<String, dynamic> json) {
    return FacilityUsageItem(
      facilityName: json['facilityName'] as String,
      currentCount: json['currentCount'] as int,
      maxCapacity: json['maxCapacity'] as int,
      lastUpdated: json['lastUpdated'] as String,
    );
  }

  final String facilityName;
  final int currentCount;
  final int maxCapacity;
  final String lastUpdated;

  double get usagePercent =>
      maxCapacity > 0 ? currentCount / maxCapacity : 0.0;

  Map<String, dynamic> toJson() {
    return {
      'facilityName': facilityName,
      'currentCount': currentCount,
      'maxCapacity': maxCapacity,
      'lastUpdated': lastUpdated,
    };
  }
}
