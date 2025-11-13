import 'package:flutter/material.dart';
import 'package:vezu/features/auth/presentation/auth_page.dart';
import 'package:vezu/features/auth/presentation/register_page.dart';
import 'package:vezu/features/onboarding/presentation/onboarding_page.dart';
import 'package:vezu/features/splash/presentation/splash_page.dart';
import 'package:vezu/features/shell/presentation/main_shell_page.dart';
import 'package:vezu/features/combination/presentation/combination_create_page.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';
  static const String register = '/register';
  static const String main = '/main';
  static const String combinationCreate = '/combination/create';
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
          builder: (_) => const CombinationCreatePage(),
          fullscreenDialog: true,
        );
      default:
        return MaterialPageRoute<void>(builder: (_) => const SplashPage());
    }
  }
}
