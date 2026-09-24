import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';
import '../router.dart'; // To access navigatorKey

import 'package:go_router/go_router.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(
    onNotificationTap: () {
      final context = navigatorKey.currentContext;
      if (context != null) {
        context.go('/reading');
      }
    },
  );
});
