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

Future<void> _pumpSettingsApp(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
  required ProEntitlementService service,
}) async {
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
      initialRoute: AppRoutes.settings,
      routes: <String, WidgetBuilder>{
        AppRoutes.settings: (_) => const SettingsScreen(),
        AppRoutes.pro: (_) => ProScreen(proEntitlementService: service),
      },
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('Settings opens Speech Club Pro screen with StoreKit price',
      (WidgetTester tester) async {
    final ProEntitlementService service = ProEntitlementService(
      productStore: _FakeProductStore(
        available: true,
        products: <ProductDetails>[_proProduct()],
      ),
    );

    await _pumpSettingsApp(tester, service: service);

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Speech Club Pro'), findsOneWidget);
    expect(find.text('Online voting subscription'), findsOneWidget);

    await tester.tap(find.text('Speech Club Pro'));
    await tester.pumpAndSettle();

    expect(find.text('Speech Club Pro'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('First 3 months free. Then S\$12.34 per year. Cancel anytime.'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(
      find.text('First 3 months free. Then S\$12.34 per year. Cancel anytime.'),
      findsOneWidget,
    );
    expect(service.isProActive, isFalse);

    await tester.scrollUntilVisible(
      find.text('Manual Count and all offline tools remain free.'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Manual Count and all offline tools remain free.'),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.text('Start 3-Month Free Trial'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start 3-Month Free Trial'));
    await tester.pump();

    expect(
      find.text('Purchase will be enabled in a later test phase.'),
      findsOneWidget,
    );
    expect(service.isProActive, isFalse);
  });

  testWidgets('Pro screen shows safe fallback when subscription is unavailable',
      (WidgetTester tester) async {
    final ProEntitlementService service = ProEntitlementService(
      productStore: _FakeProductStore(available: false),
    );

    await _pumpSettingsApp(tester, service: service);
    await tester.tap(find.text('Speech Club Pro'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text(
          'First 3 months free. Then yearly subscription. Cancel anytime.'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
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
  });

  testWidgets('Chinese Pro screen uses localized fallback copy',
      (WidgetTester tester) async {
    final ProEntitlementService service = ProEntitlementService(
      productStore: _FakeProductStore(available: false),
    );

    await _pumpSettingsApp(
      tester,
      locale: const Locale('zh'),
      service: service,
    );
    await tester.tap(find.text('Speech Club Pro'));
    await tester.pumpAndSettle();

    expect(
      find.text('使用一个永久俱乐部二维码，进行现场在线投票。'),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.text('前 3 个月免费。之后按年订阅。可随时取消。'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('前 3 个月免费。之后按年订阅。可随时取消。'), findsOneWidget);
    expect(
      find.text('订阅信息暂时不可用。您仍然可以免费使用手动计票。'),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.text('免费使用手动计票'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('免费使用手动计票'), findsOneWidget);
    expect(find.text('手动计票和所有离线工具永久免费。'), findsOneWidget);
    expect(service.isProActive, isFalse);
  });
}
