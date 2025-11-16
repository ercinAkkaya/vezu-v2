import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:vezu/core/components/outlined_button.dart';
import 'package:vezu/core/components/primary_filled_button.dart';
import 'package:vezu/core/navigation/app_router.dart';

class WardrobeTopBar extends StatelessWidget {
  const WardrobeTopBar({
    super.key,
    required this.itemCount,
    required this.isProcessing,
    required this.onAddPressed,
    required this.searchController,
  });

  final int itemCount;
  final bool isProcessing;
  final VoidCallback onAddPressed;
  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'wardrobeTitle'.tr(),
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          'wardrobeItemsCount'.tr(namedArgs: {'count': '$itemCount'}),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: PrimaryFilledButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.combinationCreate);
                },
                label: 'createCombination'.tr(),
                icon: const Icon(Icons.auto_fix_high_outlined),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SecondaryOutlinedButton(
                onPressed: isProcessing ? null : onAddPressed,
                label: 'wardrobeAddItem'.tr(),
                icon: const Icon(Icons.add_photo_alternate_outlined),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'searchHint'.tr(),
            prefixIcon: const Icon(Icons.search),
          ),
        ),
      ],
    );
  }
}

