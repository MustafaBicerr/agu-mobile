import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_page/core/notification/notification_service.dart';

import 'package:home_page/main.dart';


void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // NotificationService oluştur
    final notificationService = NotificationService();
    await notificationService.initNotification();

    // MyApp widget'ını başlatırken NotificationService sağlayın
    await tester.pumpWidget(MyApp(notificationService: notificationService));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
