import 'dart:async';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vezu/core/navigation/app_router.dart';
import 'package:vezu/core/utils/app_constants.dart';
import 'package:vezu/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:vezu/features/onboarding/domain/usecases/is_onboarding_completed.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  static const _minSplashDisplay = Duration(milliseconds: 2000);

  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final DateTime _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final authCubit = context.read<AuthCubit>();
    final isOnboardingCompletedUseCase =
        context.read<IsOnboardingCompletedUseCase>();

    bool onboardingCompleted = false;
    try {
      onboardingCompleted = await isOnboardingCompletedUseCase();
    } catch (_) {
      onboardingCompleted = false;
    }

    AuthState authState = authCubit.state;
    if (authState.status == AuthStatus.loading ||
        authState.status == AuthStatus.initial) {
      authState = await authCubit.stream.firstWhere(
        (state) =>
            state.status != AuthStatus.loading &&
            state.status != AuthStatus.initial,
        orElse: () => authCubit.state,
      );
    }

    final elapsed = DateTime.now().difference(_startTime);
    final remaining = _minSplashDisplay - elapsed;
    if (remaining > Duration.zero) {
      await Future.delayed(remaining);
    }
    if (!mounted) return;

    if (!onboardingCompleted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
      return;
    }

    if (authState.status == AuthStatus.authenticated) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.main);
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.auth);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final grayscalePrimary = Colors.white.withOpacity(0.9);
    final grayscaleSecondary = Colors.white.withOpacity(0.6);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF050505),
              Color(0xFF0F0F0F),
              Color(0xFF1A1A1A),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -40,
              child: _GlowingOrb(color: Colors.white.withOpacity(0.15)),
            ),
            Positioned(
              bottom: -60,
              left: -20,
              child: _GlowingOrb(
                color: Colors.white.withOpacity(0.08),
                size: 200,
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: 240,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Color(0x33000000),
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(36),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.18),
                          ),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0x26FFFFFF),
                              Color(0x0DFFFFFF),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.45),
                              blurRadius: 40,
                              spreadRadius: 2,
                              offset: const Offset(0, 28),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Container(
                            padding: const EdgeInsets.all(22),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0x33000000),
                                  Color(0x12000000),
                                ],
                              ),
                            ),
                            child: Image.asset(
                              'assets/png/vezu.png',
                              width: 160,
                              height: 160,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        AppConstants.appName,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
                          color: grayscalePrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'loginSubtitle'.tr(),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: grayscaleSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 26),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _FeatureChip(
                            label: 'splashFeatureAiCombos'.tr(),
                          ),
                          _FeatureChip(
                            label: 'splashFeatureSmartWardrobe'.tr(),
                          ),
                          _FeatureChip(
                            label: 'splashFeatureStyleTips'.tr(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowingOrb extends StatelessWidget {
  const _GlowingOrb({
    required this.color,
    this.size = 260,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withOpacity(0.04),
        border: Border.all(
          color: Colors.white.withOpacity(0.16),
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white.withOpacity(0.85),
              letterSpacing: -0.2,
            ),
      ),
    );
  }
}

