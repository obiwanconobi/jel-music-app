import 'package:flutter_test/flutter_test.dart';
import 'package:jel_music/helpers/notification_permission_helper.dart';

void main() {
  group('shouldRequestNotificationPermission', () {
    test('returns false on non-Android platforms', () {
      expect(
        shouldRequestNotificationPermission(isAndroid: false, sdkInt: 34),
        isFalse,
      );
    });

    test('returns false on Android 12 and lower', () {
      expect(
        shouldRequestNotificationPermission(isAndroid: true, sdkInt: 32),
        isFalse,
      );
    });

    test('returns true on Android 13', () {
      expect(
        shouldRequestNotificationPermission(isAndroid: true, sdkInt: 33),
        isTrue,
      );
    });

    test('returns true on newer Android versions', () {
      expect(
        shouldRequestNotificationPermission(isAndroid: true, sdkInt: 36),
        isTrue,
      );
    });
  });
}
