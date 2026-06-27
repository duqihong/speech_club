import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pro_product_ids.dart';

enum ProProductLoadState {
  idle,
  loading,
  loaded,
  unavailable,
  error,
}

enum ProPurchaseActionResult {
  notStarted,
  productNotLoaded,
}

abstract class ProProductStore {
  Future<bool> isAvailable();
  Future<ProductDetailsResponse> queryProductDetails(Set<String> identifiers);
}

class InAppPurchaseProProductStore implements ProProductStore {
  InAppPurchaseProProductStore({InAppPurchase? inAppPurchase})
      : _inAppPurchase = inAppPurchase;

  final InAppPurchase? _inAppPurchase;

  InAppPurchase get _store => _inAppPurchase ?? InAppPurchase.instance;

  @override
  Future<bool> isAvailable() => _store.isAvailable();

  @override
  Future<ProductDetailsResponse> queryProductDetails(Set<String> identifiers) {
    return _store.queryProductDetails(identifiers);
  }
}

class ProProductLoadResult {
  const ProProductLoadResult({
    required this.state,
    required this.isStoreAvailable,
    required this.products,
    required this.notFoundProductIds,
    this.errorMessage,
  });

  final ProProductLoadState state;
  final bool isStoreAvailable;
  final List<ProductDetails> products;
  final List<String> notFoundProductIds;
  final String? errorMessage;

  bool get hasProProduct => products.any(
      (ProductDetails product) => product.id == speechClubProAnnualProductId);
}

class ProEntitlementService extends ChangeNotifier {
  ProEntitlementService({ProProductStore? productStore})
      : _productStore = productStore ?? InAppPurchaseProProductStore();

  static const Set<String> productIds = <String>{
    speechClubProAnnualProductId,
  };

  static const String _cachedProActivePrefsKey = speechClubProEntitlementKey;

  final ProProductStore _productStore;

  bool _isProActive = false;
  bool _isStoreAvailable = false;
  ProProductLoadState _productLoadState = ProProductLoadState.idle;
  ProductDetails? _proProductDetails;
  String? _productLoadErrorMessage;

  bool get isProActive => _isProActive;
  bool get isStoreAvailable => _isStoreAvailable;
  bool get isLoadingProduct => _productLoadState == ProProductLoadState.loading;
  ProProductLoadState get productLoadState => _productLoadState;
  ProductDetails? get proProductDetails => _proProductDetails;
  ProductDetails? get proProduct => _proProductDetails;
  String? get proProductPriceText => _proProductDetails?.price;
  String? get productLoadErrorMessage => _productLoadErrorMessage;

  Future<void> initialize() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _isProActive = prefs.getBool(_cachedProActivePrefsKey) ?? false;
    notifyListeners();
  }

  Future<ProProductLoadResult> loadProducts() async {
    _productLoadState = ProProductLoadState.loading;
    _productLoadErrorMessage = null;
    notifyListeners();

    try {
      final bool isAvailable = await _productStore.isAvailable();
      _isStoreAvailable = isAvailable;

      if (!isAvailable) {
        _proProductDetails = null;
        _productLoadState = ProProductLoadState.unavailable;
        _productLoadErrorMessage = 'StoreKit is not available.';
        notifyListeners();
        return ProProductLoadResult(
          state: _productLoadState,
          isStoreAvailable: false,
          products: const <ProductDetails>[],
          notFoundProductIds: const <String>[],
          errorMessage: _productLoadErrorMessage,
        );
      }

      final ProductDetailsResponse response =
          await _productStore.queryProductDetails(productIds);
      _proProductDetails = response.productDetails
          .where((ProductDetails product) =>
              product.id == speechClubProAnnualProductId)
          .firstOrNull;

      if (_proProductDetails != null) {
        _productLoadState = ProProductLoadState.loaded;
        _productLoadErrorMessage = null;
      } else if (response.error != null) {
        _productLoadState = ProProductLoadState.error;
        _productLoadErrorMessage = response.error!.message;
      } else {
        _productLoadState = ProProductLoadState.unavailable;
        _productLoadErrorMessage = 'Speech Club Pro product was not found.';
      }

      notifyListeners();
      return ProProductLoadResult(
        state: _productLoadState,
        isStoreAvailable: true,
        products: response.productDetails,
        notFoundProductIds: response.notFoundIDs,
        errorMessage: _productLoadErrorMessage,
      );
    } catch (error) {
      _isStoreAvailable = false;
      _proProductDetails = null;
      _productLoadState = ProProductLoadState.error;
      _productLoadErrorMessage = error.toString();
      notifyListeners();
      return ProProductLoadResult(
        state: _productLoadState,
        isStoreAvailable: false,
        products: const <ProductDetails>[],
        notFoundProductIds: const <String>[],
        errorMessage: _productLoadErrorMessage,
      );
    }
  }

  Future<ProPurchaseActionResult> purchasePro() async {
    if (_proProductDetails == null) {
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
