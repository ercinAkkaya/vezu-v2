import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:vezu/core/models/subscription_plan_limits.dart';
import 'package:vezu/core/services/revenuecat_service.dart';

/// RevenueCat entitlement ID'leri
/// RevenueCat Dashboard'daki Entitlements bölümünden kontrol edin
/// Product ID'ler: vezu_monthly_premium, vezu_monthly_pro, vezu_yearly
/// Eğer Entitlement ID'ler farklıysa burayı güncelleyin
class SubscriptionEntitlements {
  static const premium = 'vezu_monthly_premium'; // RevenueCat'teki entitlement ID
  static const pro = 'vezu_monthly_pro'; // RevenueCat'teki entitlement ID
  static const proYearly = 'vezu_yearly'; // RevenueCat'teki entitlement ID
  
  // Alternatif: Eğer Entitlement ID'ler farklıysa (örn: premium, pro, pro_yearly)
  // Yukarıdaki değerleri güncelleyin
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
      final customerInfo = await RevenueCatService.instance.getCustomerInfo(
        forceRefresh: true,
      );

      String planId = SubscriptionPlans.free;
      DateTime? subscriptionStartDate;
      DateTime? subscriptionEndDate;

      // RevenueCat'ten aktif entitlement'ı kontrol et
      final activeEntitlements = customerInfo.entitlements.active;

      if (activeEntitlements.containsKey(SubscriptionEntitlements.proYearly)) {
        planId = SubscriptionPlans.proYearly;
        final entitlement = activeEntitlements[SubscriptionEntitlements.proYearly]!;
        // RevenueCat SDK'da latestPurchaseDate ve expirationDate String dönüyor olabilir
        // Şimdilik null bırakıyoruz, gerekirse parse edilebilir
        subscriptionStartDate = _parseDate(entitlement.latestPurchaseDate);
        subscriptionEndDate = _parseDate(entitlement.expirationDate);
      } else if (activeEntitlements.containsKey(SubscriptionEntitlements.pro)) {
        planId = SubscriptionPlans.pro;
        final entitlement = activeEntitlements[SubscriptionEntitlements.pro]!;
        subscriptionStartDate = _parseDate(entitlement.latestPurchaseDate);
        subscriptionEndDate = _parseDate(entitlement.expirationDate);
      } else if (activeEntitlements.containsKey(SubscriptionEntitlements.premium)) {
        planId = SubscriptionPlans.premium;
        final entitlement = activeEntitlements[SubscriptionEntitlements.premium]!;
        subscriptionStartDate = _parseDate(entitlement.latestPurchaseDate);
        subscriptionEndDate = _parseDate(entitlement.expirationDate);
      }

      // Firebase'de planı güncelle
      await updateSubscriptionPlan(
        userId: userId,
        planId: planId,
        subscriptionStartDate: subscriptionStartDate,
        subscriptionEndDate: subscriptionEndDate,
      );

      return planId;
    } catch (e) {
      // Hata durumunda mevcut planı koru veya free yap
      return SubscriptionPlans.free;
    }
  }

  /// Firebase'de subscription plan'ı günceller
  /// Dönem başlangıç/bitiş tarihlerini hesaplayıp ekler
  Future<void> updateSubscriptionPlan({
    required String userId,
    required String planId,
    DateTime? subscriptionStartDate,
    DateTime? subscriptionEndDate,
  }) async {
    final updateData = <String, dynamic>{
      'subscriptionPlan': planId,
    };

    if (subscriptionStartDate != null) {
      updateData['subscriptionStartDate'] = Timestamp.fromDate(subscriptionStartDate);
    }

    if (subscriptionEndDate != null) {
      updateData['subscriptionEndDate'] = Timestamp.fromDate(subscriptionEndDate);
    }

    // Mevcut kullanıcının verilerini al
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final userData = userDoc.data();
    final previousPlanId = userData?['subscriptionPlan'] as String?;
    final previousPeriodStartDate = userData?['subscriptionPeriodStartDate'] as Timestamp?;
    final previousStartDate = userData?['subscriptionStartDate'] as Timestamp?;

    // Eğer plan değiştiyse veya dönem tarihleri yoksa/yeni dönem başladıysa hesapla
    final now = DateTime.now();
    bool shouldCalculatePeriod = false;

    if (subscriptionStartDate != null) {
      // Yeni abonelik başladı veya plan değişti
      if (previousPlanId != planId || previousPeriodStartDate == null) {
        shouldCalculatePeriod = true;
      } else {
        // Mevcut dönemi kontrol et
        final previousPeriodStart = previousPeriodStartDate.toDate();
        final isNewPeriod = _isNewSubscriptionPeriod(
          planId: planId,
          previousPeriodStart: previousPeriodStart,
          currentDate: now,
        );
        if (isNewPeriod) {
          shouldCalculatePeriod = true;
        }
      }
    }

    if (shouldCalculatePeriod && subscriptionStartDate != null) {
      // Dönem başlangıç ve bitiş tarihlerini hesapla
      final periodDates = _calculateSubscriptionPeriodDates(
        planId: planId,
        subscriptionStartDate: subscriptionStartDate,
        currentDate: now,
      );

      updateData['subscriptionPeriodStartDate'] =
          Timestamp.fromDate(periodDates['start'] as DateTime);
      updateData['subscriptionPeriodEndDate'] =
          Timestamp.fromDate(periodDates['end'] as DateTime);

      // Son yenileme tarihi: Eğer plan değiştiyse veya yeni dönem başladıysa
      if (previousPlanId != planId || 
          (previousStartDate != null && 
           previousStartDate.toDate().isBefore(subscriptionStartDate))) {
        updateData['subscriptionLastRenewalDate'] = Timestamp.fromDate(now);
      }
    }

    await _firestore.collection('users').doc(userId).update(updateData);
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
  /// Aylık limit kontrolü yapar ve gerekirse reset eder
  Future<bool> canCreateCombination({
    required String userId,
  }) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final userData = userDoc.data();

    if (userData == null) return false;

    final planId = userData['subscriptionPlan'] as String?;
    final limits = getPlanLimits(planId);

    // Aylık kombin sayısını kontrol et
    int monthlyCombinationsUsed =
        (userData['monthlyCombinationsUsed'] as num?)?.toInt() ?? 0;
    final resetDateTimestamp = userData['monthlyCombinationsResetDate'] as Timestamp?;
    DateTime? resetDate = resetDateTimestamp?.toDate();

    final now = DateTime.now();

    // Eğer reset tarihi yoksa veya geçtiyse, sıfırla
    if (resetDate == null || _isNewMonth(resetDate, now)) {
      monthlyCombinationsUsed = 0;
      resetDate = now;

      // Firebase'de güncelle
      await _firestore.collection('users').doc(userId).update({
        'monthlyCombinationsUsed': 0,
        'monthlyCombinationsResetDate': Timestamp.fromDate(now),
      });
    }

    return monthlyCombinationsUsed < limits.maxCombinationsPerMonth;
  }

  /// Kombin oluşturulduğunda sayacı artırır
  Future<void> incrementCombinationCount(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final userData = userDoc.data();

    if (userData == null) return;

    int monthlyCombinationsUsed =
        (userData['monthlyCombinationsUsed'] as num?)?.toInt() ?? 0;
    final resetDateTimestamp = userData['monthlyCombinationsResetDate'] as Timestamp?;
    DateTime? resetDate = resetDateTimestamp?.toDate();

    final now = DateTime.now();

    // Eğer yeni ay ise sıfırla
    if (resetDate == null || _isNewMonth(resetDate, now)) {
      monthlyCombinationsUsed = 1;
      await _firestore.collection('users').doc(userId).update({
        'monthlyCombinationsUsed': 1,
        'monthlyCombinationsResetDate': Timestamp.fromDate(now),
        'totalOutfitsCreated': FieldValue.increment(1),
      });
    } else {
      // Sadece sayacı artır
      await _firestore.collection('users').doc(userId).update({
        'monthlyCombinationsUsed': FieldValue.increment(1),
        'totalOutfitsCreated': FieldValue.increment(1),
      });
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

  /// Abonelik dönemi başlangıç ve bitiş tarihlerini hesaplar
  /// Aylık abonelik için: Bu ayın 1'i - Bu ayın son günü
  /// Yıllık abonelik için: Bu yılın 1 Ocak'ı - Bu yılın 31 Aralık'ı (veya abonelik başlangıç günü bazlı)
  Map<String, DateTime> _calculateSubscriptionPeriodDates({
    required String planId,
    required DateTime subscriptionStartDate,
    required DateTime currentDate,
  }) {
    final isYearly = planId == SubscriptionPlans.proYearly;

    DateTime periodStart;
    DateTime periodEnd;

    if (isYearly) {
      // Yıllık abonelik: Abonelik başlangıç günü bazlı veya yıl başı
      // Örnek: 15 Mart'ta başladıysa, her yıl 15 Mart'ta yenilenir
      final startYear = subscriptionStartDate.year;
      final startMonth = subscriptionStartDate.month;
      final startDay = subscriptionStartDate.day;

      // Mevcut yılı kontrol et
      if (currentDate.year == startYear ||
          (currentDate.year > startYear && 
           (currentDate.month > startMonth || 
            (currentDate.month == startMonth && currentDate.day >= startDay)))) {
        // Bu yılın başlangıç günü
        periodStart = DateTime(currentDate.year, startMonth, startDay);
        // Bir sonraki yılın başlangıç gününden 1 gün önce
        periodEnd = DateTime(currentDate.year + 1, startMonth, startDay)
            .subtract(const Duration(days: 1));
      } else {
        // Geçen yılın dönemi
        periodStart = DateTime(currentDate.year - 1, startMonth, startDay);
        periodEnd = DateTime(currentDate.year, startMonth, startDay)
            .subtract(const Duration(days: 1));
      }
    } else {
      // Aylık abonelik: Bu ayın 1'i - Bu ayın son günü
      periodStart = DateTime(currentDate.year, currentDate.month, 1);
      // Bir sonraki ayın 1'inden 1 gün önce (bu ayın son günü)
      periodEnd = DateTime(currentDate.year, currentDate.month + 1, 1)
          .subtract(const Duration(days: 1));
    }

    // Saati gece yarısına ayarla
    periodStart = DateTime(periodStart.year, periodStart.month, periodStart.day);
    periodEnd = DateTime(
      periodEnd.year,
      periodEnd.month,
      periodEnd.day,
      23,
      59,
      59,
    );

    return {
      'start': periodStart,
      'end': periodEnd,
    };
  }

  /// Yeni abonelik dönemi başladı mı kontrol eder
  bool _isNewSubscriptionPeriod({
    required String planId,
    required DateTime previousPeriodStart,
    required DateTime currentDate,
  }) {
    final isYearly = planId == SubscriptionPlans.proYearly;

    if (isYearly) {
      // Yıllık: Önceki dönem başlangıcından 1 yıl geçti mi?
      final nextPeriodStart = DateTime(
        previousPeriodStart.year + 1,
        previousPeriodStart.month,
        previousPeriodStart.day,
      );
      return currentDate.isAfter(nextPeriodStart) || currentDate.isAtSameMomentAs(nextPeriodStart);
    } else {
      // Aylık: Yeni ay mı?
      return previousPeriodStart.year < currentDate.year ||
          (previousPeriodStart.year == currentDate.year &&
           previousPeriodStart.month < currentDate.month);
    }
  }
}

