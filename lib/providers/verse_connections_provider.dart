import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/verse_connections_service.dart';

final verseConnectionsProvider = Provider<VerseConnectionService>((ref) {
  return VerseConnectionService.instance;
});
