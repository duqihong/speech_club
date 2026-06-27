import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/pro_entitlement_service.dart';

class ProScreen extends StatefulWidget {
  const ProScreen({
    super.key,
    this.proEntitlementService,
  });

  final ProEntitlementService? proEntitlementService;

  @override
  State<ProScreen> createState() => _ProScreenState();
}

class _ProScreenState extends State<ProScreen> {
  late final ProEntitlementService _proEntitlementService;
  late final bool _ownsService;

  @override
  void initState() {
    super.initState();
    _ownsService = widget.proEntitlementService == null;
    _proEntitlementService =
        widget.proEntitlementService ?? ProEntitlementService();
    _loadProductDetails();
  }

  @override
  void dispose() {
    if (_ownsService) {
      _proEntitlementService.dispose();
    }
    super.dispose();
  }

  Future<void> _loadProductDetails() async {
    await _proEntitlementService.initialize();
    await _proEntitlementService.loadProducts();
  }

  Future<void> _purchasePro() async {
    await _proEntitlementService.purchasePro();
  }

  Future<void> _restorePurchases() async {
    await _proEntitlementService.restorePurchases();
  }

  void _returnToPreviousScreen(BuildContext context) {
    final NavigatorState navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    }
  }

  String _priceLine(AppLocalizations l10n) {
    final String? price = _proEntitlementService.proProductPriceText;
    if (price == null || price.isEmpty) {
      return l10n.proPriceLine;
    }

    return l10n.proPriceLineWithPrice(price);
  }

  Widget _buildSubscriptionStatus(AppLocalizations l10n) {
    if (_proEntitlementService.isProActive) {
      return _SubscriptionStatus(
        icon: const Icon(
          Icons.check_circle_outline,
          size: 20,
          color: Color(0xFF355E86),
        ),
        message: l10n.proActive,
      );
    }

    switch (_proEntitlementService.purchaseFlowState) {
      case ProPurchaseFlowState.purchasing:
        return _SubscriptionStatus(
          icon: SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Colors.blue.shade700,
            ),
          ),
          message: l10n.proPurchasing,
        );
      case ProPurchaseFlowState.pending:
        return _SubscriptionStatus(
          icon: const Icon(
            Icons.hourglass_empty,
            size: 20,
            color: Color(0xFF355E86),
          ),
          message: l10n.proPurchasePending,
        );
      case ProPurchaseFlowState.restoring:
        return _SubscriptionStatus(
          icon: SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Colors.blue.shade700,
            ),
          ),
          message: l10n.proRestoringPurchases,
        );
      case ProPurchaseFlowState.restoreRequested:
        return _SubscriptionStatus(
          icon: const Icon(
            Icons.info_outline,
            size: 20,
            color: Color(0xFF355E86),
          ),
          message: l10n.proRestoreRequestSent,
        );
      case ProPurchaseFlowState.unavailable:
        return _SubscriptionStatus(
          icon: const Icon(
            Icons.info_outline,
            size: 20,
            color: Color(0xFF355E86),
          ),
          message: l10n.proSubscriptionInfoUnavailable,
        );
      case ProPurchaseFlowState.canceled:
        return _SubscriptionStatus(
          icon: const Icon(
            Icons.info_outline,
            size: 20,
            color: Color(0xFF355E86),
          ),
          message: l10n.proPurchaseCancelled,
        );
      case ProPurchaseFlowState.error:
        return _SubscriptionStatus(
          icon: const Icon(
            Icons.error_outline,
            size: 20,
            color: Color(0xFFB3261E),
          ),
          message: l10n.proPurchaseFailed,
        );
      case ProPurchaseFlowState.idle:
      case ProPurchaseFlowState.active:
        break;
    }

    if (_proEntitlementService.isLoadingProduct) {
      return _SubscriptionStatus(
        icon: SizedBox.square(
          dimension: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.blue.shade700,
          ),
        ),
        message: l10n.proLoadingSubscription,
      );
    }

    if (_proEntitlementService.productLoadState ==
            ProProductLoadState.unavailable ||
        _proEntitlementService.productLoadState == ProProductLoadState.error) {
      return _SubscriptionStatus(
        icon: const Icon(
          Icons.info_outline,
          size: 20,
          color: Color(0xFF355E86),
        ),
        message: l10n.proSubscriptionUnavailable,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildFeatureTile(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(
            Icons.check_circle_outline,
            size: 22,
            color: Color(0xFF355E86),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  String _primaryButtonText(AppLocalizations l10n) {
    if (_proEntitlementService.purchaseFlowState ==
        ProPurchaseFlowState.purchasing) {
      return l10n.proPurchasing;
    }

    if (_proEntitlementService.purchaseFlowState ==
        ProPurchaseFlowState.pending) {
      return l10n.proPurchasePending;
    }

    return l10n.proStartTrialButton;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final List<String> features = <String>[
      l10n.proFeatureOnlineCount,
      l10n.proFeaturePermanentClubQr,
      l10n.proFeatureQrSharing,
      l10n.proFeatureLiveVoteCounter,
      l10n.proFeatureSendResultsByWhatsApp,
      l10n.proFeatureFutureOnlineTools,
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: Text(l10n.proTitle),
        centerTitle: true,
        backgroundColor: const Color(0xFFF6F7FB),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Icon(
                      Icons.workspace_premium_outlined,
                      size: 42,
                      color: Color(0xFF355E86),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      l10n.proTitle,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF355E86),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.proSubtitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.proBody,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      l10n.proIncludedTitle,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (final String feature in features)
                      _buildFeatureTile(feature),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            AnimatedBuilder(
              animation: _proEntitlementService,
              builder: (BuildContext context, Widget? child) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Text(
                      _priceLine(l10n),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  ),
                );
              },
            ),
            AnimatedBuilder(
              animation: _proEntitlementService,
              builder: (BuildContext context, Widget? child) {
                final Widget status = _buildSubscriptionStatus(l10n);
                if (status is SizedBox) {
                  return status;
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: status,
                );
              },
            ),
            const SizedBox(height: 16),
            AnimatedBuilder(
              animation: _proEntitlementService,
              builder: (BuildContext context, Widget? child) {
                final bool purchaseDisabled =
                    _proEntitlementService.isProActive ||
                        _proEntitlementService.isBusy;
                return FilledButton(
                  onPressed: purchaseDisabled ? null : _purchasePro,
                  child: Text(_primaryButtonText(l10n)),
                );
              },
            ),
            const SizedBox(height: 8),
            AnimatedBuilder(
              animation: _proEntitlementService,
              builder: (BuildContext context, Widget? child) {
                final bool restoreDisabled =
                    _proEntitlementService.isProActive ||
                        _proEntitlementService.isPurchasing ||
                        _proEntitlementService.isRestoring;
                return TextButton(
                  onPressed: restoreDisabled ? null : _restorePurchases,
                  child: Text(l10n.proRestorePurchasesButton),
                );
              },
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => _returnToPreviousScreen(context),
              child: Text(l10n.proUseManualCountButton),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.proManualCountFreeNote,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubscriptionStatus extends StatelessWidget {
  const _SubscriptionStatus({
    required this.icon,
    required this.message,
  });

  final Widget icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: icon,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
