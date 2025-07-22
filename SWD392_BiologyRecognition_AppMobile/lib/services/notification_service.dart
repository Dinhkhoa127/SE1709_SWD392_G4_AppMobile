import 'package:onesignal_flutter/onesignal_flutter.dart';

class NotificationService {
  static Future<void> initialize() async {
    try {
      // Initialize OneSignal
      OneSignal.initialize("b0b7c50d-82c9-48b7-9267-cd6cb7ff0be0");

      // Request permission và đợi response
      final accepted = await OneSignal.Notifications.requestPermission(true);
      print('🔔 Permission granted: $accepted');

      // Handle foreground notifications
      OneSignal.Notifications.addForegroundWillDisplayListener((event) {
        print('🔔 Foreground notification: ${event.notification.title}');
        event.notification.display();
      });

      // Handle notification click
      OneSignal.Notifications.addClickListener((event) {
        print('🔔 Notification clicked: ${event.notification.title}');
      });

      // Đợi lâu hơn để Player ID được tạo
      await Future.delayed(Duration(seconds: 5));

      final subscription = OneSignal.User.pushSubscription;
      final playerId = subscription.id;
      final isOptedIn = subscription.optedIn;

      print('📱 OneSignal Player ID: $playerId');
      print('✅ Opted In: $isOptedIn');
      print('🔔 Permission: $accepted');

      // Fix lỗi null check
      if (playerId != null && (isOptedIn == true)) {
        print('✅ Device registered successfully!');
      } else {
        print('❌ Device registration failed!');
        print('❌ Player ID: $playerId');
        print('❌ Opted In: $isOptedIn');
      }

      print('✅ OneSignal initialized successfully');
    } catch (e) {
      print('❌ Error: $e');
    }
  }
}
