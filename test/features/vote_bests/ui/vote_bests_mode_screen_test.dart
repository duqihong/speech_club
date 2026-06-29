import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_club/features/vote_bests/ui/vote_bests_mode_screen.dart';
import 'package:speech_club/l10n/app_localizations.dart';
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
    return true;
  }

  @override
  Future<void> restorePurchases({String? applicationUserName}) async {}

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async {}

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

class _ProHarness {
  _ProHarness({
    bool available = true,
    List<ProductDetails>? products,
  }) {
    store = _FakeProductStore(
      available: available,
      products: products ?? <ProductDetails>[_proProduct()],
    );
    service = ProEntitlementService(productStore: store);
  }

  late final _FakeProductStore store;
  late final ProEntitlementService service;

  Future<void> dispose() async {
    service.dispose();
    await store.dispose();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpModeScreen(
    WidgetTester tester, {
    Locale? locale,
    required ProEntitlementService proEntitlementService,
  }) async {
    tester.view.physicalSize = const Size(430, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: VoteBestsModeScreen(
          proEntitlementService: proEntitlementService,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('English mode selection shows both counting modes',
      (WidgetTester tester) async {
    final _ProHarness proHarness = _ProHarness();
    addTearDown(proHarness.dispose);

    await pumpModeScreen(
      tester,
      proEntitlementService: proHarness.service,
    );

    expect(find.text('Vote Bests'), findsOneWidget);
    expect(
      find.text('Choose how you want to count meeting award votes.'),
      findsOneWidget,
    );
    expect(find.text('Manual Count'), findsOneWidget);
    expect(find.text('Online Count'), findsOneWidget);
    expect(
      find.text('Count votes locally on this device.'),
      findsOneWidget,
    );
    expect(
      find.text('Create cloud voting rounds and collect online votes.'),
      findsOneWidget,
    );
  });

  testWidgets('Chinese mode selection shows both counting modes',
      (WidgetTester tester) async {
    final _ProHarness proHarness = _ProHarness();
    addTearDown(proHarness.dispose);

    await pumpModeScreen(
      tester,
      locale: const Locale('zh'),
      proEntitlementService: proHarness.service,
    );

    expect(find.text('最佳投票'), findsOneWidget);
    expect(find.text('选择本次例会奖项的计票方式。'), findsOneWidget);
    expect(find.text('手动计票'), findsOneWidget);
    expect(find.text('在线计票'), findsOneWidget);
    expect(find.text('在本机手动添加候选人和票数。'), findsOneWidget);
    expect(find.text('创建云端投票轮次并收集线上投票。'), findsOneWidget);
  });

  testWidgets('Manual Count opens the existing English tally flow',
      (WidgetTester tester) async {
    final _ProHarness proHarness = _ProHarness();
    addTearDown(proHarness.dispose);

    await pumpModeScreen(
      tester,
      proEntitlementService: proHarness.service,
    );

    await tester.tap(find.text('Manual Count'));
    await tester.pumpAndSettle();

    expect(find.text('Best Speaker'), findsOneWidget);
    expect(find.text('Best Table Topics Speaker'), findsOneWidget);
    expect(find.text('Best Evaluator'), findsOneWidget);
  });

  testWidgets('Manual Count opens the existing Chinese tally flow',
      (WidgetTester tester) async {
    final _ProHarness proHarness = _ProHarness();
    addTearDown(proHarness.dispose);

    await pumpModeScreen(
      tester,
      locale: const Locale('zh'),
      proEntitlementService: proHarness.service,
    );

    await tester.tap(find.text('手动计票'));
    await tester.pumpAndSettle();

    expect(find.text('最佳演讲者'), findsOneWidget);
    expect(find.text('最佳即席演讲者'), findsOneWidget);
    expect(find.text('最佳评论员'), findsOneWidget);
    expect(find.text('最佳点评者'), findsNothing);
  });

  testWidgets('English Online Count sends non-Pro users to Speech Club Pro',
      (WidgetTester tester) async {
    final _ProHarness proHarness = _ProHarness();
    addTearDown(proHarness.dispose);

    await pumpModeScreen(
      tester,
      proEntitlementService: proHarness.service,
    );

    await tester.tap(find.text('Online Count'));
    await tester.pumpAndSettle();

    expect(find.text('Speech Club Pro'), findsWidgets);
    expect(find.text('Start 3-Month Free Trial'), findsOneWidget);
    expect(find.text('Restore Purchases'), findsOneWidget);
    expect(find.text('Use Manual Count for Free'), findsOneWidget);
    expect(find.text('Online Club Setup'), findsNothing);
  });

  testWidgets('English Online Count opens admin MVP for Pro users',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      speechClubProEntitlementKey: true,
    });
    final _ProHarness proHarness = _ProHarness();
    addTearDown(proHarness.dispose);

    await pumpModeScreen(
      tester,
      proEntitlementService: proHarness.service,
    );

    await tester.tap(find.text('Online Count'));
    await tester.pumpAndSettle();

    expect(find.text('Online Count'), findsOneWidget);
    expect(find.text('Online Club Setup'), findsOneWidget);
    expect(find.text('Club Name'), findsOneWidget);
    expect(find.text('Club Code'), findsNothing);
    expect(find.text('Create Online Club'), findsOneWidget);
  });

  testWidgets('Chinese Online Count opens admin MVP for Pro users',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      speechClubProEntitlementKey: true,
    });
    final _ProHarness proHarness = _ProHarness();
    addTearDown(proHarness.dispose);

    await pumpModeScreen(
      tester,
      locale: const Locale('zh'),
      proEntitlementService: proHarness.service,
    );

    await tester.tap(find.text('在线计票'));
    await tester.pumpAndSettle();

    expect(find.text('在线计票'), findsOneWidget);
    expect(find.text('在线俱乐部设置'), findsOneWidget);
    expect(find.text('俱乐部名称'), findsOneWidget);
    expect(find.text('俱乐部代号'), findsNothing);
    expect(find.text('创建在线俱乐部'), findsOneWidget);
  });
}
