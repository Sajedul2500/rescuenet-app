import 'package:RescueNetBD/features/resource_sharing/data/local/resource_share_history_storage.dart';
import 'package:RescueNetBD/features/resource_sharing/domain/models/resource_share_history_item.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ResourceShareHistoryStorage', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('saves latest entries first and respects limit', () async {
      final storage = ResourceShareHistoryStorage();

      await storage.saveShare(
        ResourceShareHistoryItem(
          requestType: 'Flood',
          requestedBy: 'User A',
          location: 'Sylhet',
          sharedAt: DateTime(2026, 1, 1, 10),
        ),
      );

      await storage.saveShare(
        ResourceShareHistoryItem(
          requestType: 'Cyclone',
          requestedBy: 'User B',
          location: 'Chattogram',
          sharedAt: DateTime(2026, 1, 1, 11),
        ),
      );

      final history = await storage.getHistory(limit: 1);
      expect(history, hasLength(1));
      expect(history.first.requestType, 'Cyclone');
    });
  });
}
