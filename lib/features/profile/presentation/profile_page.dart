import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vezu/core/components/app_surface_card.dart';
import 'package:vezu/core/components/info_stat_card.dart';
import 'package:vezu/core/components/outlined_button.dart';
import 'package:vezu/core/components/subscription_card.dart';
import 'package:vezu/features/auth/domain/entities/user_entity.dart';
import 'package:vezu/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:vezu/core/components/paywall_billing_toggle.dart';
import 'package:vezu/features/profile/presentation/widgets/edit_profile_sheet.dart';
import 'package:vezu/features/home/presentation/settings_page.dart';
import 'package:vezu/features/shell/presentation/cubit/bottom_nav_cubit.dart';
import 'package:vezu/features/legal/presentation/privacy_policy_page.dart';
import 'package:vezu/features/support/presentation/help_support_page.dart';

import 'package:vezu/core/navigation/app_router.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget buildTile({
      required IconData icon,
      required String title,
      Color? tint,
      VoidCallback? onTap,
    }) {
      final resolvedTint = tint ?? theme.colorScheme.primary;
      return AppSurfaceCard(
        borderRadius: 22,
        padding: EdgeInsets.zero,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(22),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: resolvedTint.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: resolvedTint),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    Future<void> confirmSignOut() async {
      if (context.read<AuthCubit>().state.status == AuthStatus.loading) {
        return;
      }

      final shouldSignOut = await showDialog<bool>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: Text('profileLogoutConfirmTitle'.tr()),
              content: Text('profileLogoutConfirmMessage'.tr()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text('profileLogoutConfirmCancel'.tr()),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: Text('profileLogoutConfirmConfirm'.tr()),
                ),
              ],
            ),
          ) ??
          false;

      if (!shouldSignOut || !context.mounted) {
        return;
      }
      await context.read<AuthCubit>().signOut();
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withOpacity(0.12),
              theme.colorScheme.surface,
            ],
            begin: Alignment.topCenter,
            end: Alignment.center,
          ),
        ),
        child: SafeArea(
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state.status == AuthStatus.unauthenticated) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.auth,
                  (route) => false,
                );
              } else if (state.status == AuthStatus.failure && state.hasError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.errorMessage ?? 'authErrorGeneric'.tr())),
                );
              }
            },
            builder: (context, authState) {
              final user = authState.user;
              final displayName = _resolveDisplayName(user) ?? 'profileSampleName'.tr();
              final email = user?.email ?? 'profileSampleEmail'.tr();
              final avatarUrl = user?.profilePhotoUrl;
              final outfitsCount = (user?.totalOutfitsCreated ?? 0).toString();
              final totalClothes = (user?.totalClothes ?? 0).toString();
              final subscriptionPlan = _subscriptionPlanFromString(user?.subscriptionPlan);
              final isAuthLoading = authState.status == AuthStatus.loading;

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'profileTitle'.tr(),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'profileSubtitle'.tr(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSecondary,
                      ),
                    ),
                    const SizedBox(height: 28),
                    AppSurfaceCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 38,
                                backgroundColor:
                                    theme.colorScheme.primary.withOpacity(0.16),
                                backgroundImage:
                                    avatarUrl != null ? NetworkImage(avatarUrl) : null,
                                child: avatarUrl == null
                                    ? Icon(
                                        Icons.person,
                                        size: 38,
                                        color: theme.colorScheme.primary,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      displayName,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      email,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.onSecondary,
                                      ),
                                    ),
                                if (user?.gender != null ||
                                    user?.age != null) ...[
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      if (user?.gender != null)
                                        _InfoChip(
                                          icon: Icons.transgender,
                                          label: _genderLabel(context, user!.gender!),
                                        ),
                                      if (user?.age != null)
                                        _InfoChip(
                                          icon: Icons.cake_outlined,
                                          label: 'profileAgeSuffix'.tr(
                                            args: ['${user!.age}'],
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.more_horiz_rounded,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: SecondaryOutlinedButton(
                              onPressed: () => _showEditProfileSheet(
                                context,
                                user: user,
                              ),
                              label: 'profileEditProfile'.tr(),
                              icon: Icon(
                                Icons.edit_outlined,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SubscriptionCard(
                            currentPlan: subscriptionPlan,
                            onUpgrade: (plan) {
                              final cycle = plan == SubscriptionPlan.yearly
                                  ? PaywallBillingCycle.yearly
                                  : PaywallBillingCycle.monthly;
                              Navigator.of(context).pushNamed(
                                AppRoutes.subscription,
                                arguments: cycle,
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () =>
                                        context.read<BottomNavCubit>().setIndex(1),
                                    child: InfoStatCard(
                                  value: totalClothes,
                                      label: 'profileStatItems'.tr(),
                                      icon: Icons.inventory_2_outlined,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FutureBuilder<
                                    QuerySnapshot<Map<String, dynamic>>>(
                                  future: user?.id == null
                                      ? null
                                      : FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(user!.id)
                                          .collection('saved_combinations')
                                          .get(),
                                  builder: (context, snapshot) {
                                    final count = snapshot.hasData
                                        ? snapshot.data!.docs.length
                                        : int.tryParse(outfitsCount) ?? 0;
                                    return Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(20),
                                        onTap: () => Navigator.of(context)
                                            .pushNamed(
                                          AppRoutes.history,
                                        ),
                                        child: InfoStatCard(
                                          value: count.toString(),
                                          label: 'profileStatOutfits'.tr(),
                                          icon: Icons.auto_awesome_outlined,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: InfoStatCard(
                                  value: '0',
                                  label: 'profileStatFavorites'.tr(),
                                  icon: Icons.favorite_border_rounded,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    buildTile(
                      icon: Icons.settings_outlined,
                      title: 'profileAccountSettings'.tr(),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const SettingsPage(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    buildTile(
                      icon: Icons.shield_outlined,
                      title: 'profilePrivacySecurity'.tr(),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const PrivacyPolicyPage(),
                        ),
                      ),
                      tint: Colors.teal,
                    ),
                    const SizedBox(height: 16),
                    buildTile(
                      icon: Icons.help_outline_rounded,
                      title: 'profileHelpSupport'.tr(),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const HelpSupportPage(),
                        ),
                      ),
                      tint: Colors.deepPurpleAccent,
                    ),
                    const SizedBox(height: 32),
                    GestureDetector(
                      onTap: isAuthLoading ? null : confirmSignOut,
                      behavior: HitTestBehavior.opaque,
                      child: AppSurfaceCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 18,
                        ),
                        backgroundColor: theme.colorScheme.error.withOpacity(0.12),
                        borderColor: theme.colorScheme.error.withOpacity(0.2),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.error.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                Icons.logout_rounded,
                                color: theme.colorScheme.error,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'profileLogout'.tr(),
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (isAuthLoading)
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: theme.colorScheme.error,
                                ),
                              )
                            else
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: theme.colorScheme.error,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  static String? _resolveDisplayName(UserEntity? user) {
    if (user == null) {
      return null;
    }

    final firstName = user.firstName?.trim() ?? '';
    final lastName = user.lastName?.trim() ?? '';
    final buffer = [firstName, lastName].where((part) => part.isNotEmpty).join(' ');

    if (buffer.isNotEmpty) {
      return buffer;
    }

    final email = user.email;
    if (email != null && email.isNotEmpty) {
      return email;
    }

    return null;
  }

  static SubscriptionPlan _subscriptionPlanFromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'monthly':
        return SubscriptionPlan.monthly;
      case 'yearly':
        return SubscriptionPlan.yearly;
      default:
        return SubscriptionPlan.free;
    }
  }

  static String _genderLabel(BuildContext context, String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return 'profileGenderMale'.tr();
      case 'female':
        return 'profileGenderFemale'.tr();
      case 'other':
        return 'profileGenderOther'.tr();
      default:
        return gender;
    }
  }

  Future<void> _showEditProfileSheet(
    BuildContext context, {
    required UserEntity? user,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditProfileSheet(
        user: user,
      ),
    );
    if (context.mounted && result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('profileEditSuccess'.tr())),
      );
    }
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
