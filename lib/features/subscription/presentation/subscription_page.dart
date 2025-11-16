import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:vezu/core/components/app_surface_card.dart';
import 'package:vezu/core/components/paywall_plan_card.dart';

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

  late final PageController _pageController;
  late int _currentPage;

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
                  onSubscribe: () => _handleSubscribe(plan.title),
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

  void _handleSubscribe(String planTitle) {
    () async {
      try {
        await RevenueCatUI.presentPaywall();
        final info = await Purchases.getCustomerInfo();
        // Optionally: inspect info.entitlements.active here
      } on PurchasesErrorCode catch (e) {
        if (e == PurchasesErrorCode.purchaseCancelledError) {
          return;
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Subscription failed: $e')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unexpected error: $e')),
        );
      }
    }();
  }

  List<_PlanData> _buildPlans(BuildContext context) {
    return [
      _PlanData(
        id: 'monthly_premium',
        cycle: PaywallBillingCycle.monthly,
        title: 'subscriptionPlanPremiumTitle'.tr(),
        description: 'subscriptionPlanPremiumDescription'.tr(),
        priceLabel: 'subscriptionPlanPremiumPrice'.tr(),
        billingLabel: 'subscriptionPlanPremiumBilling'.tr(),
        badgeLabel: 'subscriptionPlanPremiumBadge'.tr(),
        ctaLabel: 'subscriptionPlanPremiumCta'.tr(),
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
        priceLabel: 'subscriptionPlanMonthlyProPrice'.tr(),
        billingLabel: 'subscriptionPlanMonthlyProBilling'.tr(),
        badgeLabel: 'subscriptionPlanMonthlyProBadge'.tr(),
        ctaLabel: 'subscriptionPlanMonthlyProCta'.tr(),
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
        priceLabel: 'subscriptionPlanYearlyProPrice'.tr(),
        billingLabel: 'subscriptionPlanYearlyProBilling'.tr(),
        badgeLabel: 'subscriptionPlanYearlyProBadge'.tr(),
        savingsLabel: 'subscriptionPlanYearlyProSavings'.tr(),
        ctaLabel: 'subscriptionPlanYearlyProCta'.tr(),
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
