import 'package:flutter/material.dart';
import 'package:vezu/core/components/paywall_billing_toggle.dart';
import 'package:vezu/features/auth/presentation/auth_page.dart';
import 'package:vezu/features/auth/presentation/register_page.dart';
import 'package:vezu/features/combine/presentation/combine_page.dart';
import 'package:vezu/features/onboarding/presentation/onboarding_page.dart';
import 'package:vezu/features/shell/presentation/main_shell_page.dart';
import 'package:vezu/features/splash/presentation/splash_page.dart';
import 'package:vezu/features/subscription/presentation/subscription_page.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';
  static const String register = '/register';
  static const String main = '/main';
  static const String combinationCreate = '/combination/create';
  static const String subscription = '/subscription';
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute<void>(builder: (_) => const SplashPage());
      case AppRoutes.onboarding:
        return MaterialPageRoute<void>(builder: (_) => const OnboardingPage());
      case AppRoutes.auth:
        return MaterialPageRoute<void>(builder: (_) => const AuthPage());
      case AppRoutes.register:
        return MaterialPageRoute<void>(builder: (_) => const RegisterPage());
      case AppRoutes.main:
        return MaterialPageRoute<void>(builder: (_) => const MainShellPage());
      case AppRoutes.combinationCreate:
        return MaterialPageRoute<void>(
          builder: (_) => const CombinePage(),
          fullscreenDialog: true,
        );
      case AppRoutes.subscription:
        final initialCycle = settings.arguments;
        return MaterialPageRoute<void>(
          builder: (_) => SubscriptionPage(
            initialCycle:
                initialCycle is PaywallBillingCycle ? initialCycle : null,
          ),
          fullscreenDialog: true,
        );
      default:
        return MaterialPageRoute<void>(builder: (_) => const SplashPage());
    }
  }
}
