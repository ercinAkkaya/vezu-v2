import 'dart:math';
import 'package:flutter/material.dart';
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
  late final PageController _pageController;
  late int _currentPage;

  static final _plans = <_PlanData>[
    const _PlanData(
      id: 'monthly_premium',
      cycle: PaywallBillingCycle.monthly,
      title: 'Premium',
      description: 'Yeni kombin önerileri için güçlü bir başlangıç yap.',
      priceLabel: '\$4',
      billingLabel: '/ay',
      badgeLabel: 'Başlangıç',
      ctaLabel: 'Premium’a geç',
      features: [
        PaywallFeatureData(
          label: '30 fotoğraf yükleme hakkı',
          isHighlighted: true,
        ),
        PaywallFeatureData(label: 'Sınırlı kombin hakları'),
        PaywallFeatureData(label: 'Tamamen reklamsız deneyim'),
      ],
    ),
    const _PlanData(
      id: 'monthly_pro',
      cycle: PaywallBillingCycle.monthly,
      title: 'Pro',
      description: 'Stil koçluğu ve gelişmiş gardırop yönetimi.',
      priceLabel: '\$6.99',
      billingLabel: '/ay',
      badgeLabel: 'En popüler',
      ctaLabel: 'Pro’ya yükselt',
      isPromoted: true,
      features: [
        PaywallFeatureData(
          label: '50 fotoğraf yükleme hakkı',
          isHighlighted: true,
        ),
        PaywallFeatureData(label: 'Genişletilmiş kombin hakları'),
        PaywallFeatureData(label: 'Tamamen reklamsız deneyim'),
        PaywallFeatureData(
          label: 'Gardırop analizi (yakında)',
          isComingSoon: true,
        ),
        PaywallFeatureData(
          label: 'AR ile kombin giydirme (yakında)',
          isComingSoon: true,
        ),
      ],
    ),
    const _PlanData(
      id: 'yearly_pro',
      cycle: PaywallBillingCycle.yearly,
      title: 'Pro Yıllık',
      description: 'Pro deneyiminin tüm ayrıcalıkları en iyi fiyatla.',
      priceLabel: '\$69.99',
      billingLabel: '/yıl',
      badgeLabel: 'En avantajlı',
      savingsLabel: 'Aylık \$5.83’e denk gelir',
      ctaLabel: 'Yıllık Pro’ya geç',
      isPromoted: true,
      footerNote:
          'Gardırop analizi ve AR deneyimi yayınlandığında hesabına otomatik eklenir.',
      features: [
        PaywallFeatureData(
          label: '70 fotoğraf yükleme hakkı',
          isHighlighted: true,
        ),
        PaywallFeatureData(label: 'Genişletilmiş kombin hakları'),
        PaywallFeatureData(label: 'Tamamen reklamsız deneyim'),
        PaywallFeatureData(
          label: 'Gardırop analizi (yakında)',
          isComingSoon: true,
        ),
        PaywallFeatureData(
          label: 'AR ile kombin giydirme (yakında)',
          isComingSoon: true,
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    const fallbackIndex = 1;
    final initialCycle = widget.initialCycle;
    var initialIndex = fallbackIndex;
    if (initialCycle != null) {
      final matchIndex =
          _plans.indexWhere((plan) => plan.cycle == initialCycle);
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
    final baseHeight = screenHeight * 0.74;
    final desiredHeight = max(540.0, baseHeight);
    final maxAllowed = screenHeight - 96;
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
                        'Kendine Uygun Planı Seç',
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Stil yolculuğunu hızlandıran abonelik planları. Yeni jenerasyon gardırop araçlarıyla tanış.',
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
    final planCount = _plans.length;

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
              final plan = _plans[index];
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
                  'Her plan reklamsız ve anında aktif. Dilediğin zaman iptal edebilirsin.',
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
          const _GuaranteeBullet(
            icon: Icons.shield_moon_rounded,
            label: 'Verilerin güvende, şifreli olarak saklanıyor.',
          ),
          const SizedBox(height: 12),
          const _GuaranteeBullet(
            icon: Icons.check_circle_outline_rounded,
            label: 'Yeni özellikler Pro planlara otomatik gelir.',
          ),
          const SizedBox(height: 12),
          const _GuaranteeBullet(
            icon: Icons.timer_outlined,
            label: 'Planını istediğin zaman değiştir ya da iptal et.',
          ),
        ],
      ),
    );
  }

  Widget _buildFooterNote(ThemeData theme) {
    return Text(
      'Abonelik ücretleri yerel vergiler nedeniyle değişiklik gösterebilir. Satın alma App Store veya Play Store hesaplarından tahsil edilir.',
      style: theme.textTheme.bodySmall?.copyWith(
        color: Colors.white.withOpacity(0.55),
        height: 1.3,
      ),
      textAlign: TextAlign.center,
    );
  }

  void _handleSubscribe(String planId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$planId planı için abonelik akışı yakında hazır olacak.'),
      ),
    );
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
