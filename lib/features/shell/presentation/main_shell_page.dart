import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vezu/features/home/presentation/home_page.dart';
import 'package:vezu/features/profile/presentation/profile_page.dart';
import 'package:vezu/features/shell/presentation/cubit/bottom_nav_cubit.dart';
import 'package:vezu/features/wardrobe/presentation/wardrobe_page.dart';

class MainShellPage extends StatelessWidget {
  const MainShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BottomNavCubit(),
      child: const _MainShellView(),
    );
  }
}

class _MainShellView extends StatelessWidget {
  const _MainShellView();

  static const _pages = <Widget>[HomePage(), WardrobePage(), ProfilePage()];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BottomNavCubit, int>(
      builder: (context, index) {
        final theme = Theme.of(context);
        final destinations = <NavigationDestination>[
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: 'navHome'.tr(),
          ),
          NavigationDestination(
            icon: const Icon(Icons.checkroom_outlined),
            selectedIcon: const Icon(Icons.checkroom_rounded),
            label: 'navWardrobe'.tr(),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: 'navProfile'.tr(),
          ),
        ];

        const backgroundColor = Color(0xFF0F0F0F);
        const selectedColor = Colors.white;
        const unselectedColor = Color(0x99FFFFFF);

        return Scaffold(
          body: IndexedStack(index: index, children: _pages),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withOpacity(0.04),
                  width: 0.6,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 32,
                    offset: const Offset(0, 18),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: NavigationBarTheme(
                  data: NavigationBarThemeData(
                    backgroundColor: Colors.transparent,
                    surfaceTintColor: Colors.transparent,
                    indicatorColor: Colors.white.withOpacity(0.14),
                    labelTextStyle: MaterialStateProperty.resolveWith((states) {
                      final baseStyle = theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      );
                      if (states.contains(MaterialState.selected)) {
                        return baseStyle?.copyWith(color: selectedColor);
                      }
                      return baseStyle?.copyWith(color: unselectedColor);
                    }),
                    iconTheme: MaterialStateProperty.resolveWith((states) {
                      if (states.contains(MaterialState.selected)) {
                        return const IconThemeData(color: selectedColor);
                      }
                      return const IconThemeData(color: unselectedColor);
                    }),
                  ),
                  child: NavigationBar(
                    backgroundColor: Colors.transparent,
                    surfaceTintColor: Colors.transparent,
                    height: 70,
                    labelBehavior:
                        NavigationDestinationLabelBehavior.alwaysShow,
                    selectedIndex: index,
                    onDestinationSelected: context
                        .read<BottomNavCubit>()
                        .setIndex,
                    destinations: destinations,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
