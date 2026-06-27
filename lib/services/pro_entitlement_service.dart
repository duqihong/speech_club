import 'dart:async';

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
  purchaseStarted,
  purchaseStartFailed,
  restoreStarted,
}

enum ProPurchaseFlowState {
  idle,
  purchasing,
  pending,
  restoring,
  restoreRequested,
  active,
  unavailable,
  canceled,
  error,
}

abstract class ProProductStore {
  Stream<List<PurchaseDetails>> get purchaseStream;
  Future<bool> isAvailable();
  Future<ProductDetailsResponse> queryProductDetails(Set<String> identifiers);
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam});
  Future<void> restorePurchases({String? applicationUserName});
  Future<void> completePurchase(PurchaseDetails purchase);
}

class InAppPurchaseProProductStore implements ProProductStore {
  InAppPurchaseProProductStore({InAppPurchase? inAppPurchase})
      : _inAppPurchase = inAppPurchase;

  final InAppPurchase? _inAppPurchase;

  InAppPurchase get _store => _inAppPurchase ?? InAppPurchase.instance;

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => _store.purchaseStream;

  @override
  Future<bool> isAvailable() => _store.isAvailable();

  @override
  Future<ProductDetailsResponse> queryProductDetails(Set<String> identifiers) {
    return _store.queryProductDetails(identifiers);
  }

  @override
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}) {
    return _store.buyNonConsumable(purchaseParam: purchaseParam);
  }

  @override
  Future<void> restorePurchases({String? applicationUserName}) {
    return _store.restorePurchases(applicationUserName: applicationUserName);
  }

  @override
  Future<void> completePurchase(PurchaseDetails purchase) {
    return _store.completePurchase(purchase);
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
      : _productStore = productStore ?? InAppPurchaseProProductStore() {
    _startPurchaseListener();
  }

  static const Set<String> productIds = <String>{
    speechClubProAnnualProductId,
  };

  static const String _cachedProActivePrefsKey = speechClubProEntitlementKey;

  final ProProductStore _productStore;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  bool _disposed = false;

  bool _isProActive = false;
  bool _isStoreAvailable = false;
  bool _isPurchasing = false;
  bool _isRestoring = false;
  bool _isPurchasePending = false;
  ProProductLoadState _productLoadState = ProProductLoadState.idle;
  ProPurchaseFlowState _purchaseFlowState = ProPurchaseFlowState.idle;
  ProductDetails? _proProductDetails;
  String? _productLoadErrorMessage;
  String? _purchaseErrorMessage;

  bool get isProActive => _isProActive;
  bool get isStoreAvailable => _isStoreAvailable;
  bool get isPurchasing => _isPurchasing;
  bool get isRestoring => _isRestoring;
  bool get isPurchasePending => _isPurchasePending;
  bool get isLoadingProduct => _productLoadState == ProProductLoadState.loading;
  ProProductLoadState get productLoadState => _productLoadState;
  ProPurchaseFlowState get purchaseFlowState => _purchaseFlowState;
  ProductDetails? get proProductDetails => _proProductDetails;
  ProductDetails? get proProduct => _proProductDetails;
  String? get proProductPriceText => _proProductDetails?.price;
  String? get productLoadErrorMessage => _productLoadErrorMessage;
  String? get purchaseErrorMessage => _purchaseErrorMessage;

  bool get isBusy =>
      isLoadingProduct || isPurchasing || isRestoring || isPurchasePending;

  @override
  void dispose() {
    _disposed = true;
    _purchaseSubscription?.cancel();
    super.dispose();
  }

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  void _startPurchaseListener() {
    if (_purchaseSubscription != null) {
      return;
    }

    _purchaseSubscription = _productStore.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (Object error) {
        _isPurchasing = false;
        _isRestoring = false;
        _isPurchasePending = false;
        _purchaseFlowState = ProPurchaseFlowState.error;
        _purchaseErrorMessage = error.toString();
        _notify();
      },
    );
  }

  Future<void> initialize() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _isProActive = prefs.getBool(_cachedProActivePrefsKey) ?? false;
    if (_isProActive) {
      _purchaseFlowState = ProPurchaseFlowState.active;
    }
    _notify();
  }

  Future<ProProductLoadResult> loadProducts() async {
    _productLoadState = ProProductLoadState.loading;
    _productLoadErrorMessage = null;
    _notify();

    try {
      final bool isAvailable = await _productStore.isAvailable();
      _isStoreAvailable = isAvailable;

      if (!isAvailable) {
        _proProductDetails = null;
        _productLoadState = ProProductLoadState.unavailable;
        _productLoadErrorMessage = 'StoreKit is not available.';
        _notify();
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

      _notify();
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
      _notify();
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
    _purchaseErrorMessage = null;

    if (_proProductDetails == null) {
      await loadProducts();
    }

    if (_proProductDetails == null) {
      _isPurchasing = false;
      _isPurchasePending = false;
      _purchaseFlowState = ProPurchaseFlowState.unavailable;
      _purchaseErrorMessage = 'Subscription information is unavailable.';
      _notify();
      return ProPurchaseActionResult.productNotLoaded;
    }

    _isPurchasing = true;
    _isRestoring = false;
    _isPurchasePending = false;
    _purchaseFlowState = ProPurchaseFlowState.purchasing;
    _notify();

    try {
      final bool started = await _productStore.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: _proProductDetails!),
      );

      if (!started) {
        _isPurchasing = false;
        _purchaseFlowState = ProPurchaseFlowState.error;
        _purchaseErrorMessage = 'Purchase could not be started.';
        _notify();
        return ProPurchaseActionResult.purchaseStartFailed;
      }

      return ProPurchaseActionResult.purchaseStarted;
    } catch (error) {
      _isPurchasing = false;
      _purchaseFlowState = ProPurchaseFlowState.error;
      _purchaseErrorMessage = error.toString();
      _notify();
      return ProPurchaseActionResult.purchaseStartFailed;
    }
  }

  Future<ProPurchaseActionResult> restorePurchases() async {
    _purchaseErrorMessage = null;
    _isPurchasing = false;
    _isRestoring = true;
    _isPurchasePending = false;
    _purchaseFlowState = ProPurchaseFlowState.restoring;
    _notify();

    try {
      await _productStore.restorePurchases();

      _isRestoring = false;
      if (!_isProActive &&
          _purchaseFlowState == ProPurchaseFlowState.restoring) {
        _purchaseFlowState = ProPurchaseFlowState.restoreRequested;
      }
      _notify();
      return ProPurchaseActionResult.restoreStarted;
    } catch (error) {
      _isRestoring = false;
      _purchaseFlowState = ProPurchaseFlowState.error;
      _purchaseErrorMessage = error.toString();
      _notify();
      return ProPurchaseActionResult.purchaseStartFailed;
    }
  }

  Future<void> refreshEntitlement() async {
    await initialize();
  }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final PurchaseDetails purchase in purchases) {
      await _handlePurchaseUpdate(purchase);
    }
  }

  Future<void> _handlePurchaseUpdate(PurchaseDetails purchase) async {
    if (purchase.productID != speechClubProAnnualProductId) {
      return;
    }

    switch (purchase.status) {
      case PurchaseStatus.pending:
        _isPurchasing = false;
        _isRestoring = false;
        _isPurchasePending = true;
        _purchaseFlowState = ProPurchaseFlowState.pending;
        _purchaseErrorMessage = null;
        _notify();
        break;
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        await _activateProFromPurchase();
        await _completePurchaseIfNeeded(purchase);
        break;
      case PurchaseStatus.error:
        _isPurchasing = false;
        _isRestoring = false;
        _isPurchasePending = false;
        _purchaseFlowState = ProPurchaseFlowState.error;
        _purchaseErrorMessage =
            purchase.error?.message ?? 'Purchase could not be completed.';
        await _completePurchaseIfNeeded(purchase);
        _notify();
        break;
      case PurchaseStatus.canceled:
        _isPurchasing = false;
        _isRestoring = false;
        _isPurchasePending = false;
        _purchaseFlowState = ProPurchaseFlowState.canceled;
        _purchaseErrorMessage = null;
        await _completePurchaseIfNeeded(purchase);
        _notify();
        break;
    }
  }

  Future<void> _activateProFromPurchase() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_cachedProActivePrefsKey, true);

    _isProActive = true;
    _isPurchasing = false;
    _isRestoring = false;
    _isPurchasePending = false;
    _purchaseFlowState = ProPurchaseFlowState.active;
    _purchaseErrorMessage = null;
    _notify();
  }

  Future<void> _completePurchaseIfNeeded(PurchaseDetails purchase) async {
    if (!purchase.pendingCompletePurchase ||
        purchase.status == PurchaseStatus.pending) {
      return;
    }

    try {
      await _productStore.completePurchase(purchase);
    } catch (error) {
      _purchaseErrorMessage ??= error.toString();
      _notify();
    }
  }
}
