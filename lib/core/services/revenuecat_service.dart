import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatService {
  RevenueCatService._internal();

  static final RevenueCatService instance = RevenueCatService._internal();

  Offerings? _cachedOfferings;
  CustomerInfo? _lastCustomerInfo;

  Future<Offerings?> getOfferings({bool forceRefresh = false}) async {
    try {
      if (!forceRefresh && _cachedOfferings != null) {
        debugPrint('[RevenueCatService] Using cached offerings');
        return _cachedOfferings;
      }
      debugPrint('[RevenueCatService] Fetching offerings (forceRefresh: $forceRefresh)...');
      _cachedOfferings = await Purchases.getOfferings();
      
      if (_cachedOfferings == null) {
        debugPrint('[RevenueCatService] ❌ Offerings is null');
        return null;
      }
      
      debugPrint('[RevenueCatService] ✅ Offerings fetched successfully');
      debugPrint('[RevenueCatService] Current offering: ${_cachedOfferings!.current?.identifier ?? "null"}');
      debugPrint('[RevenueCatService] All offerings count: ${_cachedOfferings!.all.length}');
      
      if (_cachedOfferings!.all.isNotEmpty) {
        for (var offering in _cachedOfferings!.all.values) {
          debugPrint('[RevenueCatService]   - Offering: ${offering.identifier}, Packages: ${offering.availablePackages.length}');
        }
      } else {
        debugPrint('[RevenueCatService] ⚠️ No offerings found in all map');
      }
      
      return _cachedOfferings;
    } catch (e, stackTrace) {
      debugPrint('[RevenueCatService] ❌ Error fetching offerings: $e');
      debugPrint('[RevenueCatService] Stack trace: $stackTrace');
      return null;
    }
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


