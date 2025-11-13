import 'package:flutter/material.dart';
import 'package:vezu/features/wardrobe/domain/entities/clothing_item.dart';
import 'package:vezu/features/wardrobe/presentation/widgets/wardrobe_item_card.dart';
import 'package:vezu/features/wardrobe/presentation/widgets/wardrobe_upload_sheet.dart';

class WardrobeItemGrid extends StatelessWidget {
  const WardrobeItemGrid({
    super.key,
    required this.visibleItems,
    required this.isLoading,
    required this.searchQuery,
    required this.activeFilterKey,
    required this.isProcessing,
    required this.onAddPressed,
  });

  final List<ClothingItem> visibleItems;
  final bool isLoading;
  final String searchQuery;
  final String? activeFilterKey;
  final bool isProcessing;
  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (visibleItems.isEmpty) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: WardrobeUploadSheet.emptyState(
            isProcessing: isProcessing,
            onAddPressed: onAddPressed,
          ),
        ),
      );
    }

    return GridView.builder(
      key: ValueKey('${activeFilterKey ?? 'all'}_$searchQuery'),
      padding: EdgeInsets.zero,
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.74,
      ),
      itemCount: visibleItems.length,
      itemBuilder: (context, index) {
        final item = visibleItems[index];
        return WardrobeItemCard(item: item);
      },
    );
  }
}

