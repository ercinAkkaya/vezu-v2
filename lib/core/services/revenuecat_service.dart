import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatService {
  RevenueCatService._internal();

  static final RevenueCatService instance = RevenueCatService._internal();

  Offerings? _cachedOfferings;
  CustomerInfo? _lastCustomerInfo;

  Future<Offerings?> getOfferings({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedOfferings != null) {
      return _cachedOfferings;
    }
    _cachedOfferings = await Purchases.getOfferings();
    return _cachedOfferings;
  }

  Future<CustomerInfo> getCustomerInfo({bool forceRefresh = false}) async {
    if (!forceRefresh && _lastCustomerInfo != null) {
      return _lastCustomerInfo!;
    }
    final info = await Purchases.getCustomerInfo();
    _lastCustomerInfo = info;
    return info;
  }

  void listenForCustomerInfoUpdates(void Function(CustomerInfo) onUpdate) {
    Purchases.addCustomerInfoUpdateListener((info) {
      _lastCustomerInfo = info;
      onUpdate(info);
    });
  }

  bool hasActiveEntitlement(String entitlementId) {
    final entitlements = _lastCustomerInfo?.entitlements.active;
    return entitlements?.containsKey(entitlementId) ?? false;
  }
}


