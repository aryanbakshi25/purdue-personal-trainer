import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/facility_usage.dart';
import 'api_provider.dart';

/// Fetches facility usage from the backend API.
final facilityUsageProvider =
    FutureProvider<List<FacilityUsageItem>>((ref) async {
  final api = ref.read(apiClientProvider);
  final response = await api.get<Map<String, dynamic>>('/api/facility-usage');
  final data = response.data!;
  final facilities = (data['facilities'] as List<dynamic>)
      .map((e) => FacilityUsageItem.fromJson(e as Map<String, dynamic>))
      .toList();
  return facilities;
});
