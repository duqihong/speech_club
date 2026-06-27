import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_club/services/pro_entitlement_service.dart';
import 'package:speech_club/services/pro_product_ids.dart';

class _FakeProductStore implements ProProductStore {
  _FakeProductStore({
    required this.available,
    this.products = const <ProductDetails>[],
  });

  final bool available;
  final List<ProductDetails> products;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<ProductDetailsResponse> queryProductDetails(
    Set<String> identifiers,
  ) async {
    return ProductDetailsResponse(
      productDetails: products,
      notFoundIDs: identifiers
          .where(
            (String identifier) => !products
                .any((ProductDetails product) => product.id == identifier),
          )
          .toList(),
    );
  }
}

ProductDetails _proProduct({String price = 'S\$12.34'}) {
  return ProductDetails(
    id: speechClubProAnnualProductId,
    title: 'Speech Club Pro Annual',
    description: 'Annual subscription',
    price: price,
    rawPrice: 12.34,
    currencyCode: 'SGD',
    currencySymbol: 'S\$',
  );
}

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

  test('loadProducts stores localized product price without unlocking Pro',
      () async {
    final ProEntitlementService service = ProEntitlementService(
      productStore: _FakeProductStore(
        available: true,
        products: <ProductDetails>[_proProduct()],
      ),
    );

    await service.initialize();
    final ProProductLoadResult result = await service.loadProducts();

    expect(result.state, ProProductLoadState.loaded);
    expect(service.isStoreAvailable, isTrue);
    expect(service.proProductPriceText, 'S\$12.34');
    expect(service.isProActive, isFalse);
  });

  test('loadProducts handles unavailable store without unlocking Pro',
      () async {
    final ProEntitlementService service = ProEntitlementService(
      productStore: _FakeProductStore(available: false),
    );

    await service.initialize();
    final ProProductLoadResult result = await service.loadProducts();

    expect(result.state, ProProductLoadState.unavailable);
    expect(service.isStoreAvailable, isFalse);
    expect(service.proProductDetails, isNull);
    expect(service.productLoadErrorMessage, isNotEmpty);
    expect(service.isProActive, isFalse);
  });
}
