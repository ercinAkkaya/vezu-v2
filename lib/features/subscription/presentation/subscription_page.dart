import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:vezu/core/components/app_surface_card.dart';
import 'package:vezu/core/components/paywall_plan_card.dart';
import 'package:vezu/core/services/revenuecat_service.dart';
import 'package:vezu/core/services/subscription_service.dart';

import '../../../core/components/paywall_billing_toggle.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({
    super.key,
    this.initialCycle,
  });

  final PaywallBillingCycle? initialCycle;

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  static const _planOrder = [
    'monthly_premium',
    'monthly_pro',
    'yearly_pro',
  ];

  static const Map<String, PaywallBillingCycle> _planCycleMap = {
    'monthly_premium': PaywallBillingCycle.monthly,
    'monthly_pro': PaywallBillingCycle.monthly,
    'yearly_pro': PaywallBillingCycle.yearly,
  };
  
  // RevenueCat package identifier mapping
  static const Map<String, String> _planToPackageId = {
    'monthly_premium': 'vezu_monthly_premium',
    'monthly_pro': 'vezu_monthly_pro',
    'yearly_pro': 'vezu_yearly',
  };

  late final PageController _pageController;
  late int _currentPage;
  
  Offerings? _offerings;
  bool _isLoadingPrices = true;
  Map<String, Package> _packagesMap = {};

  @override
  void initState() {
    super.initState();
    const fallbackIndex = 1;
    final initialCycle = widget.initialCycle;
    var initialIndex = fallbackIndex;
    if (initialCycle != null) {
      final matchIndex = _planOrder.indexWhere(
        (planId) => _planCycleMap[planId] == initialCycle,
      );
      if (matchIndex != -1) {
        initialIndex = matchIndex;
      }
    }
    _currentPage = initialIndex;
    _pageController = PageController(
      viewportFraction: 0.75,
      initialPage: _currentPage,
    );
    _loadPrices();
  }
  
  Future<void> _loadPrices() async {
    setState(() {
      _isLoadingPrices = true;
    });
    
    debugPrint('[SubscriptionPage] Starting to load prices...');
    
    try {
      // Cache'i temizle ve offerings'leri yeniden yükle
      debugPrint('[SubscriptionPage] Fetching offerings from RevenueCat...');
      final offerings = await RevenueCatService.instance.getOfferings(forceRefresh: true);
      
      if (offerings == null) {
        debugPrint('[SubscriptionPage] ❌ Offerings is null - RevenueCat connection may have failed');
        debugPrint('[SubscriptionPage] Possible causes:');
        debugPrint('  1. Invalid API key');
        debugPrint('  2. No offerings configured in RevenueCat Dashboard');
        debugPrint('  3. Test API key may not have sandbox offerings configured');
        debugPrint('  4. Network connection issue');
        setState(() {
          _isLoadingPrices = false;
        });
        return;
      }
      
      debugPrint('[SubscriptionPage] ✅ Offerings fetched: ${offerings.all.length} total offerings');
      
      if (offerings != null) {
        // Önce current offering'i dene, yoksa tüm offering'leri kontrol et
        Offering? offeringToUse = offerings.current;
        
        if (offeringToUse == null && offerings.all.isNotEmpty) {
          // Current offering yoksa, tüm offering'lerden "Vezu Default Offering" veya "default" ara
          for (var offering in offerings.all.values) {
            if (offering.identifier.toLowerCase().contains('default') ||
                offering.identifier.toLowerCase().contains('vezu')) {
              offeringToUse = offering;
              debugPrint('Using offering: ${offering.identifier}');
              break;
            }
          }
          // Eğer hala bulunamazsa, ilk offering'i kullan
          if (offeringToUse == null) {
            offeringToUse = offerings.all.values.first;
            debugPrint('Using first available offering: ${offeringToUse.identifier}');
          }
        }
        
        if (offeringToUse != null) {
          debugPrint('Current offering: ${offeringToUse.identifier}');
          debugPrint('Available packages count: ${offeringToUse.availablePackages.length}');
          
          final packagesMap = <String, Package>{};
          for (var package in offeringToUse.availablePackages) {
            // Package identifier ile eşleştir (vezu_monthly_premium gibi)
            packagesMap[package.identifier] = package;
            
            // Debug: Package bilgilerini logla
            debugPrint('Package found: ${package.identifier}');
            debugPrint('  Product ID: ${package.storeProduct?.identifier}');
            debugPrint('  Price: ${package.storeProduct?.priceString}');
            debugPrint('  Currency Code: ${package.storeProduct?.currencyCode}');
            debugPrint('  Package Type: ${package.packageType}');
            
            // Product ID formatı: "vezu_monthly_premium:vezu-monthly-premium" şeklinde olabilir
            // Eğer öyleyse, ilk kısmı (package identifier) kullan
            final productId = package.storeProduct?.identifier ?? '';
            if (productId.contains(':')) {
              final parts = productId.split(':');
              if (parts.isNotEmpty) {
                final extractedId = parts[0];
                debugPrint('  Extracted Package ID from Product ID: $extractedId');
                // Product ID'den package identifier çıkar ve map'e ekle
                packagesMap[extractedId] = package;
                
                // Ayrıca product ID'nin ikinci kısmını da kontrol et (vezu-yearly-pro-v2 gibi)
                if (parts.length > 1) {
                  final googlePlayProductId = parts[1];
                  debugPrint('  Google Play Product ID: $googlePlayProductId');
                  // Google Play Product ID'yi underscore'lı versiyona çevir
                  final normalizedId = googlePlayProductId.replaceAll('-', '_');
                  if (normalizedId != extractedId) {
                    debugPrint('  Normalized ID: $normalizedId');
                    packagesMap[normalizedId] = package;
                  }
                }
              }
            }
          }
          
          setState(() {
            _offerings = offerings;
            _packagesMap = packagesMap;
            _isLoadingPrices = false;
          });
        } else {
          debugPrint('[SubscriptionPage] ❌ No offering found to use');
          debugPrint('[SubscriptionPage] Available offerings: ${offerings.all.keys.toList()}');
          setState(() {
            _isLoadingPrices = false;
          });
        }
      } else {
        debugPrint('[SubscriptionPage] ❌ Offerings is null after fetch');
        setState(() {
          _isLoadingPrices = false;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('[SubscriptionPage] ❌ Error loading prices: $e');
      debugPrint('[SubscriptionPage] Stack trace: $stackTrace');
      setState(() {
        _isLoadingPrices = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  double _carouselHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final baseHeight = screenHeight * 0.56;
    final desiredHeight = max(420.0, baseHeight);
    final maxAllowed = screenHeight - 140;
    return min(desiredHeight, maxAllowed);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF050505),
              Color(0xFF0B0B0B),
              Color(0xFF000000),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context, theme),
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'subscriptionHeroTitle'.tr(),
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'subscriptionHeroDescription'.tr(),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.72),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 28),
                      _buildPlanCarousel(theme),
                      const SizedBox(height: 32),
                      _buildGuaranteeCard(theme),
                      const SizedBox(height: 22),
                      _buildFooterNote(theme),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCarousel(ThemeData theme) {
    final plans = _buildPlans(context);
    final planCount = plans.length;

    return Column(
      children: [
        SizedBox(
          height: _carouselHeight(context),
          child: PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: planCount,
            itemBuilder: (context, index) {
              final plan = plans[index];
              final isActive = _currentPage == index;

              return AnimatedPadding(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.only(
                  right: index == planCount - 1 ? 0 : 16,
                  top: isActive ? 0 : 14,
                  bottom: isActive ? 0 : 14,
                ),
                child: PaywallPlanCard(
                  title: plan.title,
                  description: plan.description,
                  priceLabel: plan.priceLabel,
                  billingLabel: plan.billingLabel,
                  badgeLabel: plan.badgeLabel,
                  savingsLabel: plan.savingsLabel,
                  footerNote: plan.footerNote,
                  features: plan.features,
                  ctaLabel: plan.ctaLabel,
                  onSubscribe: () => _handleSubscribe(plan.id),
                  isPromoted: plan.isPromoted,
                  isActive: isActive,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 22),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            planCount,
            (index) {
              final isActive = _currentPage == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.symmetric(horizontal: 6),
                height: 8,
                width: isActive ? 26 : 12,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isActive
                      ? Colors.white
                      : Colors.white.withOpacity(0.24),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGuaranteeCard(ThemeData theme) {
    return AppSurfaceCard(
      borderRadius: 28,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      backgroundColor: Colors.white.withOpacity(0.06),
      borderColor: Colors.white.withOpacity(0.08),
      shadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 26,
          offset: const Offset(0, 18),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFFFFF), Color(0xFFE0E0E0)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'subscriptionGuaranteeBody'.tr(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _GuaranteeBullet(
            icon: Icons.shield_moon_rounded,
            label: 'subscriptionGuaranteeSafe'.tr(),
          ),
          const SizedBox(height: 12),
          _GuaranteeBullet(
            icon: Icons.check_circle_outline_rounded,
            label: 'subscriptionGuaranteeUpdates'.tr(),
          ),
          const SizedBox(height: 12),
          _GuaranteeBullet(
            icon: Icons.timer_outlined,
            label: 'subscriptionGuaranteeFlexible'.tr(),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterNote(ThemeData theme) {
    return Text(
      'subscriptionFooterNote'.tr(),
      style: theme.textTheme.bodySmall?.copyWith(
        color: Colors.white.withOpacity(0.55),
        height: 1.3,
      ),
      textAlign: TextAlign.center,
    );
  }

  Future<void> _handleSubscribe(String planId) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kullanıcı bilgisi bulunamadı')),
        );
        return;
      }

      final package = _getPackageForPlan(planId);
      if (package != null) {
        await Purchases.purchasePackage(package);
        // Satın alma başarılı, subscription'ı senkronize et
        await SubscriptionService.instance().syncSubscriptionFromRevenueCat(userId);
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        // Fallback: RevenueCat UI kullan
        await RevenueCatUI.presentPaywall();
        // Satın alma başarılı, subscription'ı senkronize et
        await SubscriptionService.instance().syncSubscriptionFromRevenueCat(userId);
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } on PurchasesErrorCode catch (e) {
      if (e == PurchasesErrorCode.purchaseCancelledError) {
        return;
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Abonelik işlemi başarısız: $e')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Beklenmeyen hata: $e')),
      );
    }
  }

  String _getPriceFromPackage(String planId, String fallbackPrice) {
    if (_isLoadingPrices) return fallbackPrice;
    
    // Önce plan ID'den package identifier'ı al
    final packageId = _planToPackageId[planId] ?? planId;
    final package = _packagesMap[packageId];
    if (package != null && package.storeProduct != null) {
      // priceString zaten yerel para birimine göre formatlanmış olmalı
      return package.storeProduct!.priceString;
    }
    
    // Eğer package bulunamazsa, tüm package'ları kontrol et
    // Product ID formatı: "vezu_monthly_pro:vezu-monthly-pro" şeklinde olabilir
    for (var entry in _packagesMap.entries) {
      final pkg = entry.value;
      final productId = pkg.storeProduct?.identifier ?? '';
      
      // Product ID'den package identifier'ı çıkar (eğer ":" varsa)
      String? extractedPackageId;
      if (productId.contains(':')) {
        extractedPackageId = productId.split(':').first;
      }
      
      // Package identifier veya Product ID'de plan ID'yi ara
      if (entry.key.contains(planId) ||
          entry.key == packageId ||
          extractedPackageId == packageId ||
          productId.contains(packageId) ||
          productId.contains(planId.replaceAll('_', '-'))) {
        return pkg.storeProduct!.priceString;
      }
    }
    
    debugPrint('Package not found for plan: $planId (packageId: $packageId)');
    debugPrint('Available packages: ${_packagesMap.keys.toList()}');
    // Tüm package'ları ve product ID'lerini göster
    for (var entry in _packagesMap.entries) {
      debugPrint('  - ${entry.key} -> Product ID: ${entry.value.storeProduct?.identifier}');
    }
    return fallbackPrice;
  }
  
  String _getBillingPeriod(String planId, String fallbackBilling) {
    // Önce plan ID'den package identifier'ı al
    final packageId = _planToPackageId[planId] ?? planId;
    final package = _packagesMap[packageId];
    if (package != null && package.packageType == PackageType.monthly) {
      return '/ay';
    } else if (package != null && package.packageType == PackageType.annual) {
      return '/yıl';
    }
    
    // Fallback olarak plan cycle'dan al
    final cycle = _planCycleMap[planId];
    if (cycle == PaywallBillingCycle.monthly) {
      return '/ay';
    } else if (cycle == PaywallBillingCycle.yearly) {
      return '/yıl';
    }
    
    return fallbackBilling;
  }
  
  Package? _getPackageForPlan(String planId) {
    // Önce plan ID'den package identifier'ı al
    final packageId = _planToPackageId[planId] ?? planId;
    
    debugPrint('Looking for package: planId=$planId, packageId=$packageId');
    
    // Identifier ile direkt eşleştir
    if (_packagesMap.containsKey(packageId)) {
      debugPrint('Found package by direct match: $packageId');
      return _packagesMap[packageId];
    }
    
    // Eğer bulunamazsa, tüm package'ları kontrol et
    // Product ID formatı: "vezu_monthly_pro:vezu-monthly-pro" şeklinde olabilir
    for (var entry in _packagesMap.entries) {
      final pkg = entry.value;
      final productId = pkg.storeProduct?.identifier ?? '';
      final packageType = pkg.packageType;
      
      // Product ID'den package identifier'ı çıkar (eğer ":" varsa)
      String? extractedPackageId;
      String? googlePlayProductId;
      if (productId.contains(':')) {
        final parts = productId.split(':');
        extractedPackageId = parts.isNotEmpty ? parts[0] : null;
        googlePlayProductId = parts.length > 1 ? parts[1] : null;
      }
      
      // Plan cycle'a göre package type kontrolü
      final cycle = _planCycleMap[planId];
      final isYearlyPlan = cycle == PaywallBillingCycle.yearly;
      final isMonthlyPlan = cycle == PaywallBillingCycle.monthly;
      final isYearlyPackage = packageType == PackageType.annual;
      final isMonthlyPackage = packageType == PackageType.monthly;
      
      // Package identifier veya Product ID'de plan ID'yi ara
      bool matches = entry.key.contains(planId) ||
          entry.key == packageId ||
          extractedPackageId == packageId ||
          productId.contains(packageId) ||
          productId.contains(planId.replaceAll('_', '-'));
      
      // Yearly plan için annual package, monthly plan için monthly package kontrolü
      if (isYearlyPlan && isYearlyPackage && productId.contains('yearly')) {
        matches = true;
      }
      
      // Package identifier "Yearly" veya yıllık içeren şeyler için kontrol
      if (isYearlyPlan && 
          (entry.key.toLowerCase().contains('yearly') ||
           entry.key.toLowerCase() == 'yearly' ||
           packageType == PackageType.annual)) {
        // Product ID'de de yearly_pro_v2 varsa kesin eşleşme
        if (productId.contains('yearly_pro_v2') || productId.contains('yearly-pro-v2')) {
          matches = true;
          debugPrint('  Match found via yearly package type and yearly_pro_v2!');
        }
      }
      if (isMonthlyPlan && isMonthlyPackage && !productId.contains('yearly')) {
        // Monthly için zaten yukarıdaki kontroller yeterli
      }
      
      // Google Play Product ID'yi normalize et ve kontrol et
      if (googlePlayProductId != null) {
        final normalizedId = googlePlayProductId.replaceAll('-', '_');
        debugPrint('  Checking normalized ID: $normalizedId vs packageId: $packageId');
        if (normalizedId == packageId || normalizedId.contains(planId)) {
          matches = true;
          debugPrint('  Match found via normalized ID!');
        }
      }
      
      // Yearly pro v2 için özel kontrol
      if (planId == 'yearly_pro' && productId.contains('yearly_pro_v2')) {
        matches = true;
        debugPrint('  Match found via yearly_pro_v2 in product ID!');
      }
      
      if (matches) {
        debugPrint('✅ Found package by search: ${entry.key} -> Product ID: $productId, Type: $packageType');
        return pkg;
      } else {
        debugPrint('  ❌ No match: ${entry.key} -> Product ID: $productId');
      }
    }
    
    debugPrint('Package not found for planId: $planId, packageId: $packageId');
    return null;
  }

  List<_PlanData> _buildPlans(BuildContext context) {
    return [
      _PlanData(
        id: 'monthly_premium',
        cycle: PaywallBillingCycle.monthly,
        title: 'subscriptionPlanPremiumTitle'.tr(),
        description: 'subscriptionPlanPremiumDescription'.tr(),
        priceLabel: _getPriceFromPackage(
          'monthly_premium',
          'subscriptionPlanPremiumPrice'.tr(),
        ),
        billingLabel: _getBillingPeriod(
          'monthly_premium',
          'subscriptionPlanPremiumBilling'.tr(),
        ),
        badgeLabel: 'subscriptionPlanPremiumBadge'.tr(),
        ctaLabel: 'subscriptionPlanPremiumCta'.tr(),
        package: _getPackageForPlan('monthly_premium'),
        features: [
          PaywallFeatureData(
            label: 'subscriptionPlanPremiumFeaturePhotos'.tr(),
            isHighlighted: true,
          ),
          PaywallFeatureData(
            label: 'subscriptionPlanPremiumFeatureCombos'.tr(),
          ),
          PaywallFeatureData(
            label: 'subscriptionPlanFeatureAdFree'.tr(),
          ),
        ],
      ),
      _PlanData(
        id: 'monthly_pro',
        cycle: PaywallBillingCycle.monthly,
        title: 'subscriptionPlanMonthlyProTitle'.tr(),
        description: 'subscriptionPlanMonthlyProDescription'.tr(),
        priceLabel: _getPriceFromPackage(
          'monthly_pro',
          'subscriptionPlanMonthlyProPrice'.tr(),
        ),
        billingLabel: _getBillingPeriod(
          'monthly_pro',
          'subscriptionPlanMonthlyProBilling'.tr(),
        ),
        badgeLabel: 'subscriptionPlanMonthlyProBadge'.tr(),
        ctaLabel: 'subscriptionPlanMonthlyProCta'.tr(),
        package: _getPackageForPlan('monthly_pro'),
        isPromoted: true,
        features: [
          PaywallFeatureData(
            label: 'subscriptionPlanMonthlyProFeaturePhotos'.tr(),
            isHighlighted: true,
          ),
          PaywallFeatureData(
            label: 'subscriptionPlanMonthlyProFeatureCombos'.tr(),
          ),
          PaywallFeatureData(
            label: 'subscriptionPlanFeatureAdFree'.tr(),
          ),
          PaywallFeatureData(
            label: 'subscriptionPlanFeatureWardrobeAnalysisSoon'.tr(),
            isComingSoon: true,
          ),
          PaywallFeatureData(
            label: 'subscriptionPlanFeatureArTryOnSoon'.tr(),
            isComingSoon: true,
          ),
        ],
      ),
      _PlanData(
        id: 'yearly_pro',
        cycle: PaywallBillingCycle.yearly,
        title: 'subscriptionPlanYearlyProTitle'.tr(),
        description: 'subscriptionPlanYearlyProDescription'.tr(),
        priceLabel: _getPriceFromPackage(
          'yearly_pro',
          'subscriptionPlanYearlyProPrice'.tr(),
        ),
        billingLabel: _getBillingPeriod(
          'yearly_pro',
          'subscriptionPlanYearlyProBilling'.tr(),
        ),
        badgeLabel: 'subscriptionPlanYearlyProBadge'.tr(),
        savingsLabel: 'subscriptionPlanYearlyProSavings'.tr(),
        ctaLabel: 'subscriptionPlanYearlyProCta'.tr(),
        package: _getPackageForPlan('yearly_pro'),
        isPromoted: true,
        footerNote: 'subscriptionPlanYearlyProFooter'.tr(),
        features: [
          PaywallFeatureData(
            label: 'subscriptionPlanYearlyProFeaturePhotos'.tr(),
            isHighlighted: true,
          ),
          PaywallFeatureData(
            label: 'subscriptionPlanMonthlyProFeatureCombos'.tr(),
          ),
          PaywallFeatureData(
            label: 'subscriptionPlanFeatureAdFree'.tr(),
          ),
          PaywallFeatureData(
            label: 'subscriptionPlanFeatureWardrobeAnalysisSoon'.tr(),
            isComingSoon: true,
          ),
          PaywallFeatureData(
            label: 'subscriptionPlanFeatureArTryOnSoon'.tr(),
            isComingSoon: true,
          ),
        ],
      ),
    ];
  }

}

class _PlanData {
  const _PlanData({
    required this.id,
    required this.cycle,
    required this.title,
    required this.priceLabel,
    required this.billingLabel,
    required this.features,
    required this.ctaLabel,
    this.description,
    this.badgeLabel,
    this.savingsLabel,
    this.footerNote,
    this.isPromoted = false,
    this.package,
  });

  final String id;
  final PaywallBillingCycle cycle;
  final String title;
  final String priceLabel;
  final String billingLabel;
  final List<PaywallFeatureData> features;
  final String ctaLabel;
  final String? description;
  final String? badgeLabel;
  final String? savingsLabel;
  final String? footerNote;
  final bool isPromoted;
  final Package? package;
}

class _GuaranteeBullet extends StatelessWidget {
  const _GuaranteeBullet({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.82),
            ),
          ),
        ),
      ],
    );
  }
}
