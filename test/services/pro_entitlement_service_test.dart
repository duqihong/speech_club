import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_club/services/pro_entitlement_service.dart';
import 'package:speech_club/services/pro_product_ids.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('Pro constants use the planned product and entitlement IDs', () {
    expect(speechClubProAnnualProductId, 'speech_club_pro_annual');
    expect(speechClubProEntitlementKey, 'speechClubPro');
    expect(
      ProEntitlementService.productIds,
      contains(speechClubProAnnualProductId),
    );
  });

  test('Pro entitlement defaults to inactive', () async {
    final ProEntitlementService service = ProEntitlementService();

    await service.initialize();

    expect(service.isProActive, isFalse);
  });

  test('Pro entitlement can load cached active state', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      speechClubProEntitlementKey: true,
    });
    final ProEntitlementService service = ProEntitlementService();

    await service.initialize();

    expect(service.isProActive, isTrue);
  });
}
