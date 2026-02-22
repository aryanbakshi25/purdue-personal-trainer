import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/api_client.dart';

/// Global API client provider.
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});
