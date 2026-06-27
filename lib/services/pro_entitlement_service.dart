import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pro_product_ids.dart';

enum ProPurchaseActionResult {
  notStarted,
  productNotLoaded,
}

class ProProductLoadResult {
  const ProProductLoadResult({
    required this.isStoreAvailable,
    required this.products,
    required this.notFoundProductIds,
    this.errorMessage,
  });

  final bool isStoreAvailable;
  final List<ProductDetails> products;
  final List<String> notFoundProductIds;
  final String? errorMessage;

  bool get hasProProduct => products.any(
      (ProductDetails product) => product.id == speechClubProAnnualProductId);
}

class ProEntitlementService {
  ProEntitlementService({InAppPurchase? inAppPurchase})
      : _inAppPurchase = inAppPurchase;

  static const Set<String> productIds = <String>{
    speechClubProAnnualProductId,
  };

  static const String _cachedProActivePrefsKey = speechClubProEntitlementKey;

  final InAppPurchase? _inAppPurchase;

  bool _isProActive = false;
  ProductDetails? _proProduct;

  bool get isProActive => _isProActive;
  ProductDetails? get proProduct => _proProduct;

  InAppPurchase get _store => _inAppPurchase ?? InAppPurchase.instance;

  Future<void> initialize() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _isProActive = prefs.getBool(_cachedProActivePrefsKey) ?? false;
  }

  Future<ProProductLoadResult> loadProducts() async {
    final InAppPurchase store = _store;
    final bool isAvailable = await store.isAvailable();

    if (!isAvailable) {
      _proProduct = null;
      return const ProProductLoadResult(
        isStoreAvailable: false,
        products: <ProductDetails>[],
        notFoundProductIds: <String>[],
        errorMessage: 'StoreKit is not available.',
      );
    }

    final ProductDetailsResponse response =
        await store.queryProductDetails(productIds);
    _proProduct = response.productDetails
        .where((ProductDetails product) =>
            product.id == speechClubProAnnualProductId)
        .firstOrNull;

    return ProProductLoadResult(
      isStoreAvailable: true,
      products: response.productDetails,
      notFoundProductIds: response.notFoundIDs,
      errorMessage: response.error?.message,
    );
  }

  Future<ProPurchaseActionResult> purchasePro() async {
    if (_proProduct == null) {
      return ProPurchaseActionResult.productNotLoaded;
    }

    return ProPurchaseActionResult.notStarted;
  }

  Future<ProPurchaseActionResult> restorePurchases() async {
    return ProPurchaseActionResult.notStarted;
  }

  Future<void> refreshEntitlement() async {
    await initialize();
  }
}
