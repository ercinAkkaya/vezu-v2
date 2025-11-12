import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:vezu/core/components/empty_state_card.dart";
import "package:vezu/core/components/weather_summary_card.dart";
import "package:vezu/core/components/welcome_header.dart";
import "package:vezu/features/auth/domain/entities/user_entity.dart";
import "package:vezu/features/auth/presentation/cubit/auth_cubit.dart";
import "package:vezu/features/shell/presentation/cubit/bottom_nav_cubit.dart";

import "cubit/home_cubit.dart";

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit()..loadDashboard(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth * 0.06;
            final verticalPadding = constraints.maxHeight * 0.02;

            return BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) {
                final authState = context.watch<AuthCubit>().state;
                final user = authState.user;
                final displayName = _resolveDisplayName(user) ?? state.userName;
                final avatarUrl = user?.profilePhotoUrl ?? state.avatarUrl;

                return RefreshIndicator(
                  onRefresh: context.read<HomeCubit>().refreshWeather,
                  child: ListView(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding.clamp(16, 32),
                      vertical: verticalPadding.clamp(12, 24),
                    ),
                    children: [
                      WelcomeHeader(
                        userName: displayName,
                        avatarUrl: avatarUrl,
                      ),
                      const SizedBox(height: 24),
                      WeatherSummaryCard(
                        temperature: state.temperature,
                        condition: state.condition,
                        humidity: state.humidity,
                        wind: state.wind,
                        icon: Icons.cloud_outlined,
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'homeEmptySectionTitle'.tr(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      EmptyStateCard(
                        onAction: () =>
                            context.read<BottomNavCubit>().setIndex(1),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  static String? _resolveDisplayName(UserEntity? user) {
    if (user == null) {
      return null;
    }

    final parts = <String>[
      if ((user.firstName ?? '').trim().isNotEmpty) user.firstName!.trim(),
      if ((user.lastName ?? '').trim().isNotEmpty) user.lastName!.trim(),
    ];
    if (parts.isNotEmpty) {
      return parts.join(' ');
    }

    final email = user.email;
    if (email != null && email.isNotEmpty) {
      return email;
    }

    return null;
  }
}
