import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:vezu/core/models/subscription_plan_limits.dart';
import 'package:vezu/core/services/revenuecat_service.dart';

/// RevenueCat entitlement ID'leri
/// RevenueCat Dashboard'daki Entitlements bölümünden alınan gerçek ID'ler
/// Identifier'lar RevenueCat Dashboard'da görünen tam isimler
class SubscriptionEntitlements {
  static const premium = 'Vezu Aylık Premium'; // RevenueCat Identifier: "Vezu Aylık Premium"
  static const pro = 'Vezu Aylık Pro'; // RevenueCat Identifier: "Vezu Aylık Pro"
  static const proYearly = 'vezu_yearly'; // RevenueCat Identifier: "vezu_yearly"
}

/// Firebase'deki subscription plan ID'leri
class SubscriptionPlans {
  static const free = 'free';
  static const premium = 'premium';
  static const pro = 'pro';
  static const proYearly = 'pro_yearly';
}

class SubscriptionService {
  SubscriptionService._internal({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  static SubscriptionService? _instance;

  final FirebaseFirestore _firestore;

  factory SubscriptionService.instance({FirebaseFirestore? firestore}) {
    _instance ??= SubscriptionService._internal(
      firestore: firestore ?? FirebaseFirestore.instance,
    );
    return _instance!;
  }

  /// RevenueCat'ten aktif entitlement'ı kontrol edip Firebase'i günceller
  /// Kullanıcı giriş yaptığında veya abonelik değiştiğinde çağrılmalı
  Future<String> syncSubscriptionFromRevenueCat(String userId) async {
    try {
      debugPrint('[SubscriptionService] 🔄 Syncing subscription from RevenueCat for user: $userId');
      developer.log('[SubscriptionService] Syncing subscription from RevenueCat for user: $userId');
      
      final customerInfo = await RevenueCatService.instance.getCustomerInfo(
        forceRefresh: true,
      );

      debugPrint('[SubscriptionService] ✅ CustomerInfo received');
      debugPrint('[SubscriptionService] 📊 Active entitlements count: ${customerInfo.entitlements.active.length}');
      developer.log('[SubscriptionService] CustomerInfo received');
      developer.log('[SubscriptionService] Active entitlements count: ${customerInfo.entitlements.active.length}');
      
      // Tüm aktif entitlement'ları logla
      for (var entry in customerInfo.entitlements.active.entries) {
        debugPrint('[SubscriptionService] ✅ Active entitlement: ${entry.key}');
        developer.log('[SubscriptionService] Active entitlement: ${entry.key}');
      }
      
      // Tüm entitlement'ları logla (aktif olmayanlar dahil)
      debugPrint('[SubscriptionService] 📋 All entitlements count: ${customerInfo.entitlements.all.length}');
      developer.log('[SubscriptionService] All entitlements count: ${customerInfo.entitlements.all.length}');
      for (var entry in customerInfo.entitlements.all.entries) {
        debugPrint('[SubscriptionService] 📝 Entitlement: ${entry.key}, Active: ${entry.value.isActive}');
        developer.log('[SubscriptionService] Entitlement: ${entry.key}, Active: ${entry.value.isActive}');
      }

      String planId = SubscriptionPlans.free;
      DateTime? subscriptionStartDate;
      DateTime? subscriptionEndDate;

      // RevenueCat'ten aktif entitlement'ı kontrol et
      final activeEntitlements = customerInfo.entitlements.active;

      debugPrint('[SubscriptionService] 🔍 Checking for entitlement: ${SubscriptionEntitlements.proYearly}');
      developer.log('[SubscriptionService] Checking for entitlement: ${SubscriptionEntitlements.proYearly}');
      if (activeEntitlements.containsKey(SubscriptionEntitlements.proYearly)) {
        planId = SubscriptionPlans.proYearly;
        final entitlement = activeEntitlements[SubscriptionEntitlements.proYearly]!;
        subscriptionStartDate = _parseDate(entitlement.latestPurchaseDate);
        subscriptionEndDate = _parseDate(entitlement.expirationDate);
        debugPrint('[SubscriptionService] ✅ Found proYearly entitlement');
        developer.log('[SubscriptionService] ✅ Found proYearly entitlement');
      } else {
        debugPrint('[SubscriptionService] 🔍 Checking for entitlement: ${SubscriptionEntitlements.pro}');
        developer.log('[SubscriptionService] Checking for entitlement: ${SubscriptionEntitlements.pro}');
        if (activeEntitlements.containsKey(SubscriptionEntitlements.pro)) {
          planId = SubscriptionPlans.pro;
          final entitlement = activeEntitlements[SubscriptionEntitlements.pro]!;
          subscriptionStartDate = _parseDate(entitlement.latestPurchaseDate);
          subscriptionEndDate = _parseDate(entitlement.expirationDate);
          debugPrint('[SubscriptionService] ✅ Found pro entitlement');
          developer.log('[SubscriptionService] ✅ Found pro entitlement');
        } else {
          debugPrint('[SubscriptionService] 🔍 Checking for entitlement: ${SubscriptionEntitlements.premium}');
          developer.log('[SubscriptionService] Checking for entitlement: ${SubscriptionEntitlements.premium}');
          if (activeEntitlements.containsKey(SubscriptionEntitlements.premium)) {
            planId = SubscriptionPlans.premium;
            final entitlement = activeEntitlements[SubscriptionEntitlements.premium]!;
            subscriptionStartDate = _parseDate(entitlement.latestPurchaseDate);
            subscriptionEndDate = _parseDate(entitlement.expirationDate);
            debugPrint('[SubscriptionService] ✅ Found premium entitlement');
            developer.log('[SubscriptionService] ✅ Found premium entitlement');
          } else {
            debugPrint('[SubscriptionService] ⚠️ No active entitlement found, defaulting to free');
            developer.log('[SubscriptionService] ⚠️ No active entitlement found, defaulting to free');
          }
        }
      }

      debugPrint('[SubscriptionService] 📌 Determined plan: $planId');
      debugPrint('[SubscriptionService] 🔄 Updating Firebase for user: $userId');
      developer.log('[SubscriptionService] Determined plan: $planId');
      developer.log('[SubscriptionService] Updating Firebase for user: $userId');

      // Firebase'de planı güncelle
      await updateSubscriptionPlan(
        userId: userId,
        planId: planId,
        subscriptionStartDate: subscriptionStartDate,
        subscriptionEndDate: subscriptionEndDate,
      );

      debugPrint('[SubscriptionService] ✅ Firebase updated successfully with plan: $planId');
      developer.log('[SubscriptionService] ✅ Firebase updated successfully with plan: $planId');
      return planId;
    } catch (e, stackTrace) {
      debugPrint('[SubscriptionService] ❌ Error syncing subscription: $e');
      debugPrint('[SubscriptionService] Stack trace: $stackTrace');
      developer.log('[SubscriptionService] ❌ Error syncing subscription: $e');
      developer.log('[SubscriptionService] Stack trace: $stackTrace');
      // Hata durumunda mevcut planı koru veya free yap
      return SubscriptionPlans.free;
    }
  }

  /// Firebase'de subscription plan'ı günceller
  /// Dönem başlangıç/bitiş tarihlerini RevenueCat'ten gelen tarihlere göre ayarlar
  Future<void> updateSubscriptionPlan({
    required String userId,
    required String planId,
    DateTime? subscriptionStartDate,
    DateTime? subscriptionEndDate,
  }) async {
    debugPrint('[SubscriptionService] 🔧 updateSubscriptionPlan called');
    debugPrint('[SubscriptionService] 👤 userId: $userId');
    debugPrint('[SubscriptionService] 📦 planId: $planId');
    debugPrint('[SubscriptionService] 📅 subscriptionStartDate: $subscriptionStartDate');
    debugPrint('[SubscriptionService] 📅 subscriptionEndDate: $subscriptionEndDate');
    developer.log('[SubscriptionService] updateSubscriptionPlan called');
    developer.log('[SubscriptionService] userId: $userId');
    developer.log('[SubscriptionService] planId: $planId');
    developer.log('[SubscriptionService] subscriptionStartDate: $subscriptionStartDate');
    developer.log('[SubscriptionService] subscriptionEndDate: $subscriptionEndDate');
    
    final now = DateTime.now();
    
    final updateData = <String, dynamic>{
      'subscriptionPlan': planId,
    };

    // Free plan'a geçiş: Abonelik tarihlerini temizle
    if (planId == SubscriptionPlans.free) {
      updateData['subscriptionStartDate'] = FieldValue.delete();
      updateData['subscriptionEndDate'] = FieldValue.delete();
      updateData['subscriptionPeriodStartDate'] = FieldValue.delete();
      updateData['subscriptionPeriodEndDate'] = FieldValue.delete();
      updateData['subscriptionLastRenewalDate'] = FieldValue.delete();
      updateData['monthlyCombinationsUsed'] = 0;
      updateData['monthlyCombinationsResetDate'] = Timestamp.fromDate(now);
      debugPrint('[SubscriptionService] 🔄 Free plan\'a geçiş yapıldı, abonelik tarihleri temizlendi');
      developer.log('[SubscriptionService] Free plan\'a geçiş yapıldı, abonelik tarihleri temizlendi');
    } else {
      // Ücretli plan: Tarihleri kaydet
      if (subscriptionStartDate != null) {
        updateData['subscriptionStartDate'] = Timestamp.fromDate(subscriptionStartDate);
      }

      if (subscriptionEndDate != null) {
        updateData['subscriptionEndDate'] = Timestamp.fromDate(subscriptionEndDate);
      }
    }

    // Mevcut kullanıcının verilerini al
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final userData = userDoc.data();
    final previousPlanId = userData?['subscriptionPlan'] as String?;
    final previousPeriodStartDate = userData?['subscriptionPeriodStartDate'] as Timestamp?;
    final previousStartDate = userData?['subscriptionStartDate'] as Timestamp?;

    // Eğer plan değiştiyse veya dönem tarihleri yoksa/yeni dönem başladıysa hesapla
    bool shouldCalculatePeriod = false;

    // Free plan için dönem hesaplama yapma
    if (planId == SubscriptionPlans.free) {
      shouldCalculatePeriod = false;
    } else if (subscriptionStartDate != null) {
      // Yeni abonelik başladı veya plan değişti
      if (previousPlanId != planId || previousPeriodStartDate == null) {
        shouldCalculatePeriod = true;
      } else {
        // subscriptionStartDate değişti mi? (RevenueCat yenileme yaptıysa)
        if (previousStartDate != null) {
          final previousStart = previousStartDate.toDate();
          // Eğer yeni başlangıç tarihi eski tarihten sonraysa, yeni abonelik başlamış demektir
          if (subscriptionStartDate.isAfter(previousStart)) {
            debugPrint('[SubscriptionService] 🔄 Yeni abonelik başladı (subscriptionStartDate değişti)');
            developer.log('[SubscriptionService] Yeni abonelik başladı (subscriptionStartDate değişti)');
            shouldCalculatePeriod = true;
          }
        }
        
        // Mevcut dönem bitiş tarihini kontrol et
        final previousPeriodEndTimestamp = userData?['subscriptionPeriodEndDate'] as Timestamp?;
        if (previousPeriodEndTimestamp != null) {
          final previousPeriodEnd = previousPeriodEndTimestamp.toDate();
          // Eğer dönem bitiş tarihi geçmişte kalmışsa, yeni dönem başlamalı
          if (now.isAfter(previousPeriodEnd)) {
            debugPrint('[SubscriptionService] 🔄 Dönem bitti (subscriptionPeriodEndDate geçmişte)');
            developer.log('[SubscriptionService] Dönem bitti (subscriptionPeriodEndDate geçmişte)');
            shouldCalculatePeriod = true;
          }
        }
        
      }
    }

    if (shouldCalculatePeriod && subscriptionStartDate != null) {
      // Dönem başlangıç ve bitiş tarihlerini RevenueCat'ten gelen tarihlere göre ayarla
      // subscriptionStartDate: Abonelik başlangıç tarihi (RevenueCat'ten)
      // subscriptionEndDate: Abonelik bitiş tarihi (RevenueCat'ten - otomatik yenileme ile güncellenir)
      
      // Dönem tarihleri = RevenueCat tarihleri (AYNEN, saat bilgisi ile)
      // Bu hem test abonelikleri (5 dk) hem gerçek abonelikler (30 gün) için doğru çalışır
      final periodStart = subscriptionStartDate;
      
      // Dönem bitişi: RevenueCat'ten gelen expirationDate (AYNEN)
      // Eğer subscriptionEndDate yoksa, plan tipine göre hesapla
      final DateTime periodEnd;
      if (subscriptionEndDate != null) {
        // RevenueCat'ten gelen expirationDate'i AYNEN kullan (saat bilgisi ile)
        periodEnd = subscriptionEndDate;
      } else {
        // Fallback: Plan tipine göre hesapla (RevenueCat'ten gelmediyse)
        final isYearly = planId == SubscriptionPlans.proYearly;
        if (isYearly) {
          // Yıllık: 1 yıl sonra
          periodEnd = DateTime(
            subscriptionStartDate.year + 1,
            subscriptionStartDate.month,
            subscriptionStartDate.day,
            subscriptionStartDate.hour,
            subscriptionStartDate.minute,
            subscriptionStartDate.second,
          );
        } else {
          // Aylık: 30 gün sonra
          periodEnd = subscriptionStartDate.add(const Duration(days: 30));
        }
      }

      updateData['subscriptionPeriodStartDate'] = Timestamp.fromDate(periodStart);
      updateData['subscriptionPeriodEndDate'] = Timestamp.fromDate(periodEnd);
      
      debugPrint('[SubscriptionService] 📅 Dönem tarihleri: Başlangıç: $periodStart, Bitiş: $periodEnd');
      developer.log('[SubscriptionService] Dönem tarihleri: Başlangıç: $periodStart, Bitiş: $periodEnd');

      // Son yenileme tarihi: Eğer plan değiştiyse veya yeni dönem başladıysa
      if (previousPlanId != planId || 
          (previousStartDate != null && 
           previousStartDate.toDate().isBefore(subscriptionStartDate))) {
        updateData['subscriptionLastRenewalDate'] = Timestamp.fromDate(now);
      }
      
      // Yeni dönem başladıysa, aylık kombin sayacını sıfırla
      bool isNewPeriod = false;
      if (previousPlanId != planId) {
        // Plan değişti, yeni dönem
        isNewPeriod = true;
      } else if (previousPeriodStartDate != null) {
        final previousPeriodStart = previousPeriodStartDate.toDate();
        // Dönem başlangıç tarihi değiştiyse, yeni dönem
        if (periodStart.isAfter(previousPeriodStart)) {
          isNewPeriod = true;
        }
      } else {
        // Dönem tarihi yoktu, yeni dönem
        isNewPeriod = true;
      }
      
      if (isNewPeriod) {
        updateData['monthlyCombinationsUsed'] = 0;
        updateData['monthlyCombinationsResetDate'] = Timestamp.fromDate(now);
        debugPrint('[SubscriptionService] 🔄 Yeni dönem başladı, monthlyCombinationsUsed sıfırlandı');
        debugPrint('[SubscriptionService] 📊 Önceki dönem: ${previousPeriodStartDate?.toDate()}, Yeni dönem: $periodStart');
        developer.log('[SubscriptionService] Yeni dönem başladı, monthlyCombinationsUsed sıfırlandı');
        developer.log('[SubscriptionService] Önceki dönem: ${previousPeriodStartDate?.toDate()}, Yeni dönem: $periodStart');
      }
    }

    debugPrint('[SubscriptionService] 💾 Updating Firestore with data: $updateData');
    developer.log('[SubscriptionService] Updating Firestore with data: $updateData');
    await _firestore.collection('users').doc(userId).update(updateData);
    debugPrint('[SubscriptionService] ✅ Firestore update completed');
    developer.log('[SubscriptionService] ✅ Firestore update completed');
    
    // Güncellemeyi doğrula
    final updatedDoc = await _firestore.collection('users').doc(userId).get();
    final updatedData = updatedDoc.data();
    debugPrint('[SubscriptionService] ✅ Verification - Updated subscriptionPlan: ${updatedData?['subscriptionPlan']}');
    developer.log('[SubscriptionService] Verification - Updated subscriptionPlan: ${updatedData?['subscriptionPlan']}');
  }

  /// Kullanıcıya free plan atar (yeni kullanıcılar için)
  Future<void> initializeFreePlan(String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'subscriptionPlan': SubscriptionPlans.free,
      'monthlyCombinationsUsed': 0,
      'monthlyCombinationsResetDate': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// Plan limitlerini getirir
  SubscriptionPlanLimits getPlanLimits(String? planId) {
    return SubscriptionPlanLimits.fromPlanId(planId) ?? SubscriptionPlanLimits.free;
  }

  /// Kullanıcının kıyafet yükleme hakkı var mı kontrol eder
  Future<bool> canUploadClothes({
    required String userId,
    required int currentClothesCount,
  }) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final planId = userDoc.data()?['subscriptionPlan'] as String?;
    final limits = getPlanLimits(planId);

    return currentClothesCount < limits.maxClothes;
  }

  /// Kullanıcının kombin oluşturma hakkı var mı kontrol eder
  /// Dönem bazlı limit kontrolü yapar ve gerekirse reset eder
  /// Eğer dönem bitmişse RevenueCat'ten otomatik senkronizasyon yapar
  Future<bool> canCreateCombination({
    required String userId,
  }) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final userData = userDoc.data();

    if (userData == null) return false;

    final planId = userData['subscriptionPlan'] as String?;
    final limits = getPlanLimits(planId);

    // Firebase'den aylık kombin sayısını çek
    int monthlyCombinationsUsed =
        (userData['monthlyCombinationsUsed'] as num?)?.toInt() ?? 0;
    
    // Dönem başlangıç tarihini kontrol et
    final periodStartTimestamp = userData['subscriptionPeriodStartDate'] as Timestamp?;
    DateTime? periodStartDate = periodStartTimestamp?.toDate();
    
    final now = DateTime.now();

    // Eğer dönem başlangıç tarihi yoksa veya yeni dönem başladıysa, sıfırla
    bool shouldSyncFromRevenueCat = false;
    bool shouldReset = false;
    
    if (periodStartDate == null) {
      // Dönem tarihi yoksa, ay bazlı reset yap (geriye dönük uyumluluk)
      final resetDateTimestamp = userData['monthlyCombinationsResetDate'] as Timestamp?;
      DateTime? resetDate = resetDateTimestamp?.toDate();
      if (resetDate == null || _isNewMonth(resetDate, now)) {
        shouldReset = true;
      }
    } else {
      // Dönem bazlı kontrol
      final periodEndTimestamp = userData['subscriptionPeriodEndDate'] as Timestamp?;
      DateTime? periodEndDate = periodEndTimestamp?.toDate();
      
      if (periodEndDate != null) {
        // Mevcut tarih dönem dışındaysa (dönem bitti veya henüz başlamadı)
        if (now.isAfter(periodEndDate)) {
          // Dönem bitti! RevenueCat'ten yeni bilgileri çek
          // Çünkü RevenueCat otomatik yenileme yapmış olabilir
          debugPrint('[SubscriptionService] ⚠️ Dönem bitti, RevenueCat\'ten senkronizasyon yapılıyor...');
          developer.log('[SubscriptionService] Dönem bitti, RevenueCat\'ten senkronizasyon yapılıyor...');
          shouldSyncFromRevenueCat = true;
          shouldReset = true;
        } else if (now.isBefore(periodStartDate)) {
          // Dönem henüz başlamadı (garip durum, sync yap)
          shouldSyncFromRevenueCat = true;
          shouldReset = true;
        } else {
          // Dönem içindeyiz, reset tarihini kontrol et
          final resetDateTimestamp = userData['monthlyCombinationsResetDate'] as Timestamp?;
          DateTime? resetDate = resetDateTimestamp?.toDate();
          // Eğer reset tarihi dönem başlangıcından önceyse, yeni dönem başlamış demektir
          if (resetDate == null || resetDate.isBefore(periodStartDate)) {
            shouldReset = true;
          }
        }
      } else {
        // Dönem bitiş tarihi yoksa, ay bazlı kontrol yap
        final resetDateTimestamp = userData['monthlyCombinationsResetDate'] as Timestamp?;
        DateTime? resetDate = resetDateTimestamp?.toDate();
        if (resetDate == null || _isNewMonth(resetDate, now)) {
          shouldReset = true;
        }
      }
    }

    // Eğer dönem bitmişse, RevenueCat'ten güncel bilgileri çek
    if (shouldSyncFromRevenueCat) {
      try {
        debugPrint('[SubscriptionService] 🔄 RevenueCat\'ten abonelik senkronizasyonu yapılıyor...');
        developer.log('[SubscriptionService] RevenueCat\'ten abonelik senkronizasyonu yapılıyor...');
        await syncSubscriptionFromRevenueCat(userId);
        // Senkronizasyon sonrası Firebase'den tekrar oku
        final updatedDoc = await _firestore.collection('users').doc(userId).get();
        final updatedData = updatedDoc.data();
        if (updatedData != null) {
          monthlyCombinationsUsed = (updatedData['monthlyCombinationsUsed'] as num?)?.toInt() ?? 0;
          // Dönem tarihlerini güncelle
          final updatedPeriodStartTimestamp = updatedData['subscriptionPeriodStartDate'] as Timestamp?;
          final updatedPeriodEndTimestamp = updatedData['subscriptionPeriodEndDate'] as Timestamp?;
          periodStartDate = updatedPeriodStartTimestamp?.toDate();
          final updatedPeriodEndDate = updatedPeriodEndTimestamp?.toDate();
          
          // Yeni dönem başladıysa, kombin sayacını sıfırla
          if (updatedPeriodEndDate != null && now.isBefore(updatedPeriodEndDate) && now.isAfter(periodStartDate ?? DateTime(1970))) {
            shouldReset = true;
          }
        }
        debugPrint('[SubscriptionService] ✅ RevenueCat senkronizasyonu tamamlandı');
        developer.log('[SubscriptionService] RevenueCat senkronizasyonu tamamlandı');
      } catch (e) {
        debugPrint('[SubscriptionService] ⚠️ RevenueCat senkronizasyonu başarısız: $e');
        developer.log('[SubscriptionService] RevenueCat senkronizasyonu başarısız: $e');
        // Hata olsa bile devam et, mevcut bilgilerle kontrol yap
      }
    }

    if (shouldReset) {
      monthlyCombinationsUsed = 0;
      // Firebase'de güncelle
      await _firestore.collection('users').doc(userId).update({
        'monthlyCombinationsUsed': 0,
        'monthlyCombinationsResetDate': Timestamp.fromDate(now),
      });
      debugPrint('[SubscriptionService] ✅ Kombin sayacı sıfırlandı (yeni dönem başladı)');
      developer.log('[SubscriptionService] Kombin sayacı sıfırlandı (yeni dönem başladı)');
    }

    debugPrint('[SubscriptionService] 🔍 Kombin kontrolü: Kullanılan: $monthlyCombinationsUsed, Limit: ${limits.maxCombinationsPerMonth}');
    developer.log('[SubscriptionService] Kombin kontrolü: Kullanılan: $monthlyCombinationsUsed, Limit: ${limits.maxCombinationsPerMonth}');

    return monthlyCombinationsUsed < limits.maxCombinationsPerMonth;
  }

  /// Kombin oluşturulduğunda sayacı artırır
  /// Firebase'den mevcut değeri alıp artırır (dönem bazlı reset kontrolü yapar)
  /// Eğer dönem bitmişse RevenueCat'ten otomatik senkronizasyon yapar
  Future<void> incrementCombinationCount(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final userData = userDoc.data();

    if (userData == null) return;

    // Firebase'den mevcut değerleri al
    int monthlyCombinationsUsed =
        (userData['monthlyCombinationsUsed'] as num?)?.toInt() ?? 0;
    
    // Dönem başlangıç tarihini kontrol et
    final periodStartTimestamp = userData['subscriptionPeriodStartDate'] as Timestamp?;
    DateTime? periodStartDate = periodStartTimestamp?.toDate();
    
    final now = DateTime.now();
    bool shouldSyncFromRevenueCat = false;
    bool shouldReset = false;

    // Dönem bazlı reset kontrolü
    if (periodStartDate == null) {
      // Dönem tarihi yoksa, ay bazlı reset yap (geriye dönük uyumluluk)
      final resetDateTimestamp = userData['monthlyCombinationsResetDate'] as Timestamp?;
      DateTime? resetDate = resetDateTimestamp?.toDate();
      if (resetDate == null || _isNewMonth(resetDate, now)) {
        shouldReset = true;
      }
    } else {
      // Dönem bazlı kontrol
      final periodEndTimestamp = userData['subscriptionPeriodEndDate'] as Timestamp?;
      DateTime? periodEndDate = periodEndTimestamp?.toDate();
      
      if (periodEndDate != null) {
        if (now.isAfter(periodEndDate)) {
          // Dönem bitti! RevenueCat'ten yeni bilgileri çek
          // Çünkü RevenueCat otomatik yenileme yapmış olabilir
          debugPrint('[SubscriptionService] ⚠️ Dönem bitti (increment), RevenueCat\'ten senkronizasyon yapılıyor...');
          developer.log('[SubscriptionService] Dönem bitti (increment), RevenueCat\'ten senkronizasyon yapılıyor...');
          shouldSyncFromRevenueCat = true;
          shouldReset = true;
        } else if (now.isBefore(periodStartDate)) {
          // Dönem henüz başlamadı (garip durum, sync yap)
          shouldSyncFromRevenueCat = true;
          shouldReset = true;
        } else {
          // Dönem içindeyiz, reset tarihini kontrol et
          final resetDateTimestamp = userData['monthlyCombinationsResetDate'] as Timestamp?;
          DateTime? resetDate = resetDateTimestamp?.toDate();
          // Eğer reset tarihi dönem başlangıcından önceyse, yeni dönem başlamış demektir
          if (resetDate == null || resetDate.isBefore(periodStartDate)) {
            shouldReset = true;
          }
        }
      } else {
        // Dönem bitiş tarihi yoksa, ay bazlı kontrol yap
        final resetDateTimestamp = userData['monthlyCombinationsResetDate'] as Timestamp?;
        DateTime? resetDate = resetDateTimestamp?.toDate();
        if (resetDate == null || _isNewMonth(resetDate, now)) {
          shouldReset = true;
        }
      }
    }

    // Eğer dönem bitmişse, RevenueCat'ten güncel bilgileri çek
    if (shouldSyncFromRevenueCat) {
      try {
        debugPrint('[SubscriptionService] 🔄 RevenueCat\'ten abonelik senkronizasyonu yapılıyor (increment)...');
        developer.log('[SubscriptionService] RevenueCat\'ten abonelik senkronizasyonu yapılıyor (increment)...');
        await syncSubscriptionFromRevenueCat(userId);
        // Senkronizasyon sonrası Firebase'den tekrar oku
        final updatedDoc = await _firestore.collection('users').doc(userId).get();
        final updatedData = updatedDoc.data();
        if (updatedData != null) {
          monthlyCombinationsUsed = (updatedData['monthlyCombinationsUsed'] as num?)?.toInt() ?? 0;
          // Dönem tarihlerini güncelle
          final updatedPeriodStartTimestamp = updatedData['subscriptionPeriodStartDate'] as Timestamp?;
          final updatedPeriodEndTimestamp = updatedData['subscriptionPeriodEndDate'] as Timestamp?;
          periodStartDate = updatedPeriodStartTimestamp?.toDate();
          final updatedPeriodEndDate = updatedPeriodEndTimestamp?.toDate();
          
          // Yeni dönem başladıysa, kombin sayacını sıfırla
          if (updatedPeriodEndDate != null && now.isBefore(updatedPeriodEndDate) && now.isAfter(periodStartDate ?? DateTime(1970))) {
            shouldReset = true;
          }
        }
        debugPrint('[SubscriptionService] ✅ RevenueCat senkronizasyonu tamamlandı (increment)');
        developer.log('[SubscriptionService] RevenueCat senkronizasyonu tamamlandı (increment)');
      } catch (e) {
        debugPrint('[SubscriptionService] ⚠️ RevenueCat senkronizasyonu başarısız (increment): $e');
        developer.log('[SubscriptionService] RevenueCat senkronizasyonu başarısız (increment): $e');
        // Hata olsa bile devam et, mevcut bilgilerle kontrol yap
      }
    }

    if (shouldReset) {
      // Yeni dönem başladı, sıfırdan başla
      await _firestore.collection('users').doc(userId).update({
        'monthlyCombinationsUsed': 1,
        'monthlyCombinationsResetDate': Timestamp.fromDate(now),
        'totalOutfitsCreated': FieldValue.increment(1),
      });
      debugPrint('[SubscriptionService] ✅ Yeni dönem başladı, kombin sayacı sıfırlandı ve 1 yapıldı');
      developer.log('[SubscriptionService] Yeni dönem başladı, kombin sayacı sıfırlandı ve 1 yapıldı');
    } else {
      // Mevcut dönemde, sayacı artır
      await _firestore.collection('users').doc(userId).update({
        'monthlyCombinationsUsed': FieldValue.increment(1),
        'totalOutfitsCreated': FieldValue.increment(1),
      });
      debugPrint('[SubscriptionService] ✅ Kombin sayacı artırıldı: ${monthlyCombinationsUsed + 1}');
      developer.log('[SubscriptionService] Kombin sayacı artırıldı: ${monthlyCombinationsUsed + 1}');
    }
  }

  /// Kullanıcının mevcut plan bilgilerini getirir
  Future<Map<String, dynamic>> getUserSubscriptionInfo(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final userData = userDoc.data();

    if (userData == null) {
      return {
        'planId': SubscriptionPlans.free,
        'limits': SubscriptionPlanLimits.free,
        'totalClothes': 0,
        'monthlyCombinationsUsed': 0,
        'totalOutfitsCreated': 0,
      };
    }

    final planId = userData['subscriptionPlan'] as String? ?? SubscriptionPlans.free;
    final limits = getPlanLimits(planId);
    final totalClothes = (userData['totalClothes'] as num?)?.toInt() ?? 0;
    final monthlyCombinationsUsed =
        (userData['monthlyCombinationsUsed'] as num?)?.toInt() ?? 0;
    final totalOutfitsCreated =
        (userData['totalOutfitsCreated'] as num?)?.toInt() ?? 0;

    return {
      'planId': planId,
      'limits': limits,
      'totalClothes': totalClothes,
      'monthlyCombinationsUsed': monthlyCombinationsUsed,
      'totalOutfitsCreated': totalOutfitsCreated,
    };
  }

  /// Yeni ay kontrolü
  bool _isNewMonth(DateTime resetDate, DateTime now) {
    return resetDate.year < now.year ||
        (resetDate.year == now.year && resetDate.month < now.month);
  }

  /// RevenueCat'ten gelen tarih değerini DateTime'a çevirir
  /// SDK versiyonuna göre String veya DateTime dönebilir
  DateTime? _parseDate(dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is DateTime) return dateValue;
    if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (_) {
        return null;
      }
    }
    return null;
  }


}

