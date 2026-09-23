import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/bible_api_service.dart';

final apiServiceProvider = Provider<BibleApiService>((ref) {
  return BibleApiService();
});
