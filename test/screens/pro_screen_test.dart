import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:speech_club/app_routes.dart';
import 'package:speech_club/l10n/app_localizations.dart';
import 'package:speech_club/screens/pro/pro_screen.dart';
import 'package:speech_club/screens/settings/settings_screen.dart';
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
  return purchase;
}

Future<void> _pumpSettingsApp(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
  required ProEntitlementService service,
}) async {
  tester.view.physicalSize = const Size(430, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const SettingsScreen(),
      routes: <String, WidgetBuilder>{
        AppRoutes.pro: (_) => ProScreen(proEntitlementService: service),
      },
    ),
  );
  await tester.pump(const Duration(milliseconds: 350));
}

Future<void> _pumpProApp(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
  required ProEntitlementService service,
}) async {
  tester.view.physicalSize = const Size(430, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: ProScreen(proEntitlementService: service),
    ),
  );
  await tester.pump(const Duration(seconds: 1));
}

void _disposeProScreenTestHarness(ProEntitlementService service) {
  service.dispose();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('Settings opens Speech Club Pro screen with StoreKit price',
      (WidgetTester tester) async {
    final _FakeProductStore store = _FakeProductStore(
      available: true,
      products: <ProductDetails>[_proProduct()],
    );
    final ProEntitlementService service = ProEntitlementService(
      productStore: store,
    );

    await _pumpSettingsApp(tester, service: service);

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Speech Club Pro'), findsOneWidget);
    expect(find.text('Online voting subscription'), findsOneWidget);

    await _pumpProApp(tester, service: service);

    expect(find.text('Speech Club Pro'), findsWidgets);
    expect(
      find.text('First 3 months free. Then S\$12.34 per year. Cancel anytime.'),
      findsOneWidget,
    );
    expect(service.isProActive, isFalse);

    expect(
      find.text('Manual Count and all offline tools remain free.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Start 3-Month Free Trial'));
    await tester.pump();

    expect(store.buyCallCount, 1);
    expect(find.text('Purchasing...'), findsWidgets);
    expect(service.isProActive, isFalse);

    store.emitPurchase(_purchase(status: PurchaseStatus.purchased));
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Speech Club Pro is active.'), findsOneWidget);
    expect(service.isProActive, isTrue);
    expect(store.completeCallCount, 1);
    _disposeProScreenTestHarness(service);
  });

  testWidgets('Pro screen shows safe fallback when subscription is unavailable',
      (WidgetTester tester) async {
    final _FakeProductStore store = _FakeProductStore(available: false);
    final ProEntitlementService service = ProEntitlementService(
      productStore: store,
    );

    await _pumpProApp(tester, service: service);

    expect(
      find.text(
          'First 3 months free. Then yearly subscription. Cancel anytime.'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Subscription information is temporarily unavailable. You can still use Manual Count for free.',
      ),
      findsOneWidget,
    );
    expect(service.isProActive, isFalse);
    _disposeProScreenTestHarness(service);
  });

  testWidgets('Restore Purchases sends restore request without direct unlock',
      (WidgetTester tester) async {
    final _FakeProductStore store = _FakeProductStore(
      available: true,
      products: <ProductDetails>[_proProduct()],
    );
    final ProEntitlementService service = ProEntitlementService(
      productStore: store,
    );

    await _pumpProApp(tester, service: service);

    await tester.tap(find.text('Restore Purchases'));
    await tester.pump();

    expect(store.restoreCallCount, 1);
    expect(
      find.text(
        'If you have an active subscription, it will be restored after Apple confirms it.',
      ),
      findsOneWidget,
    );
    expect(service.isProActive, isFalse);

    store.emitPurchase(_purchase(status: PurchaseStatus.restored));
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Speech Club Pro is active.'), findsOneWidget);
    expect(service.isProActive, isTrue);
    _disposeProScreenTestHarness(service);
  });

  testWidgets('Chinese Pro screen uses localized fallback copy',
      (WidgetTester tester) async {
    final _FakeProductStore store = _FakeProductStore(available: false);
    final ProEntitlementService service = ProEntitlementService(
      productStore: store,
    );

    await _pumpProApp(
      tester,
      locale: const Locale('zh'),
      service: service,
    );

    expect(
      find.text('使用一个永久俱乐部二维码，进行现场在线投票。'),
      findsOneWidget,
    );
    expect(find.text('前 3 个月免费。之后按年订阅。可随时取消。'), findsOneWidget);
    expect(
      find.text('订阅信息暂时不可用。您仍然可以免费使用手动计票。'),
      findsOneWidget,
    );
    expect(find.text('免费使用手动计票'), findsOneWidget);
    expect(find.text('手动计票和所有离线工具永久免费。'), findsOneWidget);
    expect(service.isProActive, isFalse);
    _disposeProScreenTestHarness(service);
  });
}
