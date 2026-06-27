import 'dart:async';

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
  final StreamController<List<PurchaseDetails>> _purchaseController =
      StreamController<List<PurchaseDetails>>.broadcast();

  int buyCallCount = 0;
  int restoreCallCount = 0;
  int completeCallCount = 0;
  PurchaseParam? lastPurchaseParam;

  @override
  Stream<List<PurchaseDetails>> get purchaseStream =>
      _purchaseController.stream;

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

  @override
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}) async {
    buyCallCount += 1;
    lastPurchaseParam = purchaseParam;
    return true;
  }

  @override
  Future<void> restorePurchases({String? applicationUserName}) async {
    restoreCallCount += 1;
  }

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async {
    completeCallCount += 1;
  }

  void emitPurchase(PurchaseDetails purchase) {
    _purchaseController.add(<PurchaseDetails>[purchase]);
  }

  Future<void> dispose() async {
    unawaited(_purchaseController.close());
    await Future<void>.delayed(Duration.zero);
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

PurchaseDetails _purchase({
  required PurchaseStatus status,
  String productId = speechClubProAnnualProductId,
  bool pendingCompletePurchase = true,
  IAPError? error,
}) {
  final PurchaseDetails purchase = PurchaseDetails(
    purchaseID: 'purchase-id',
    productID: productId,
    verificationData: PurchaseVerificationData(
      localVerificationData: 'local',
      serverVerificationData: 'server',
      source: 'test',
    ),
    transactionDate: '1234567890',
    status: status,
  );
  purchase.pendingCompletePurchase = pendingCompletePurchase;
  purchase.error = error;
  return purchase;
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
    final _FakeProductStore store = _FakeProductStore(available: true);
    final ProEntitlementService service = ProEntitlementService(
      productStore: store,
    );

    await service.initialize();

    expect(service.isProActive, isFalse);
    service.dispose();
    await store.dispose();
  });

  test('Pro entitlement can load cached active state', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      speechClubProEntitlementKey: true,
    });
    final _FakeProductStore store = _FakeProductStore(available: true);
    final ProEntitlementService service = ProEntitlementService(
      productStore: store,
    );

    await service.initialize();

    expect(service.isProActive, isTrue);
    service.dispose();
    await store.dispose();
  });

  test('loadProducts stores localized product price without unlocking Pro',
      () async {
    final _FakeProductStore store = _FakeProductStore(
      available: true,
      products: <ProductDetails>[_proProduct()],
    );
    final ProEntitlementService service = ProEntitlementService(
      productStore: store,
    );

    await service.initialize();
    final ProProductLoadResult result = await service.loadProducts();

    expect(result.state, ProProductLoadState.loaded);
    expect(service.isStoreAvailable, isTrue);
    expect(service.proProductPriceText, 'S\$12.34');
    expect(service.isProActive, isFalse);
    service.dispose();
    await store.dispose();
  });

  test('loadProducts handles unavailable store without unlocking Pro',
      () async {
    final _FakeProductStore store = _FakeProductStore(available: false);
    final ProEntitlementService service = ProEntitlementService(
      productStore: store,
    );

    await service.initialize();
    final ProProductLoadResult result = await service.loadProducts();

    expect(result.state, ProProductLoadState.unavailable);
    expect(service.isStoreAvailable, isFalse);
    expect(service.proProductDetails, isNull);
    expect(service.productLoadErrorMessage, isNotEmpty);
    expect(service.isProActive, isFalse);
    service.dispose();
    await store.dispose();
  });

  test('purchasePro starts purchase but does not unlock without stream',
      () async {
    final _FakeProductStore store = _FakeProductStore(
      available: true,
      products: <ProductDetails>[_proProduct()],
    );
    final ProEntitlementService service = ProEntitlementService(
      productStore: store,
    );

    await service.initialize();
    await service.loadProducts();
    final ProPurchaseActionResult result = await service.purchasePro();

    expect(result, ProPurchaseActionResult.purchaseStarted);
    expect(store.buyCallCount, 1);
    expect(store.lastPurchaseParam?.productDetails.id,
        speechClubProAnnualProductId);
    expect(service.purchaseFlowState, ProPurchaseFlowState.purchasing);
    expect(service.isProActive, isFalse);
    service.dispose();
    await store.dispose();
  });

  test('valid purchased transaction unlocks Pro and is completed', () async {
    final _FakeProductStore store = _FakeProductStore(available: true);
    final ProEntitlementService service = ProEntitlementService(
      productStore: store,
    );

    await service.initialize();
    store.emitPurchase(_purchase(status: PurchaseStatus.purchased));
    await Future<void>.delayed(const Duration(milliseconds: 10));

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    expect(service.isProActive, isTrue);
    expect(prefs.getBool(speechClubProEntitlementKey), isTrue);
    expect(service.purchaseFlowState, ProPurchaseFlowState.active);
    expect(store.completeCallCount, 1);
    service.dispose();
    await store.dispose();
  });

  test('valid restored transaction unlocks Pro and is completed', () async {
    final _FakeProductStore store = _FakeProductStore(available: true);
    final ProEntitlementService service = ProEntitlementService(
      productStore: store,
    );

    await service.initialize();
    store.emitPurchase(_purchase(status: PurchaseStatus.restored));
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(service.isProActive, isTrue);
    expect(service.purchaseFlowState, ProPurchaseFlowState.active);
    expect(store.completeCallCount, 1);
    service.dispose();
    await store.dispose();
  });

  test('unknown product purchase does not unlock Pro', () async {
    final _FakeProductStore store = _FakeProductStore(available: true);
    final ProEntitlementService service = ProEntitlementService(
      productStore: store,
    );

    await service.initialize();
    store.emitPurchase(
      _purchase(status: PurchaseStatus.purchased, productId: 'other_product'),
    );
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(service.isProActive, isFalse);
    expect(store.completeCallCount, 0);
    service.dispose();
    await store.dispose();
  });

  test('error transaction does not unlock Pro and completes if required',
      () async {
    final _FakeProductStore store = _FakeProductStore(available: true);
    final ProEntitlementService service = ProEntitlementService(
      productStore: store,
    );

    await service.initialize();
    store.emitPurchase(
      _purchase(
        status: PurchaseStatus.error,
        error: IAPError(
          source: 'test',
          code: 'store_error',
          message: 'Store error',
        ),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(service.isProActive, isFalse);
    expect(service.purchaseFlowState, ProPurchaseFlowState.error);
    expect(store.completeCallCount, 1);
    service.dispose();
    await store.dispose();
  });

  test('restorePurchases sends restore request without direct unlock',
      () async {
    final _FakeProductStore store = _FakeProductStore(available: true);
    final ProEntitlementService service = ProEntitlementService(
      productStore: store,
    );

    await service.initialize();
    final ProPurchaseActionResult result = await service.restorePurchases();

    expect(result, ProPurchaseActionResult.restoreStarted);
    expect(store.restoreCallCount, 1);
    expect(service.purchaseFlowState, ProPurchaseFlowState.restoreRequested);
    expect(service.isProActive, isFalse);
    service.dispose();
    await store.dispose();
  });
}
