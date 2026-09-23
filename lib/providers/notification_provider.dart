import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';
import '../main.dart'; // To access navigatorKey

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(
    onNotificationTap: () {
      navigatorKey.currentState?.popUntil((route) => route.isFirst);
    },
  );
});
