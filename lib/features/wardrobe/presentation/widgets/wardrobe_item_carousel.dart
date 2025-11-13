import "dart:async";
import "dart:math";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:vezu/features/auth/presentation/cubit/auth_cubit.dart";
import "package:vezu/features/wardrobe/data/models/clothing_metadata_model.dart";
import "package:vezu/features/wardrobe/domain/entities/clothing_item.dart";

class WardrobeItemCarousel extends StatefulWidget {
  const WardrobeItemCarousel({
    super.key,
    required this.title,
    this.onSeeAll,
  });

  final String title;
  final VoidCallback? onSeeAll;

  @override
  State<WardrobeItemCarousel> createState() => _WardrobeItemCarouselState();
}

class _WardrobeItemCarouselState extends State<WardrobeItemCarousel> {
  static const _autoScrollInterval = Duration(milliseconds: 25);
  static const _maxItems = 10;

  final ScrollController _scrollController = ScrollController();
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;
  Timer? _autoScrollTimer;
  List<ClothingItem> _items = const [];
  String? _currentUid;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final uid = context.read<AuthCubit>().state.user?.id;
    if (uid != _currentUid) {
      _subscribe(uid);
    }
  }

  void _subscribe(String? uid) {
    _subscription?.cancel();
    _autoScrollTimer?.cancel();
    _currentUid = uid;
    _items = const [];

    if (uid == null) {
      setState(() {});
      return;
    }

    _subscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('clothes_metadata')
        .orderBy('createdAt', descending: true)
        .limit(_maxItems)
        .snapshots()
        .listen((snapshot) {
      final docs = snapshot.docs;
      final random = Random(uid.hashCode ^ docs.hashCode);
      final items = docs
          .map((doc) {
            final data = doc.data();
            final imageUrl = data['imageUrl'] as String?;
            if (imageUrl == null || imageUrl.isEmpty) {
              return null;
            }
            final metadata = ClothingMetadataModel.fromMap(data);
            return ClothingItem(
              id: doc.id,
              imageUrl: imageUrl,
              category: (data['category'] as String?) ?? '-',
              type: (data['type'] as String?) ?? '-',
              metadata: metadata,
            );
          })
          .whereType<ClothingItem>()
          .toList();
      items.shuffle(random);
      if (!mounted) return;
      setState(() {
        _items = items.take(_maxItems).toList();
      });
      _startAutoScroll();
    });
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    if (_items.length <= 1) return;
    _autoScrollTimer = Timer.periodic(_autoScrollInterval, (_) {
      if (!_scrollController.hasClients) return;
      final nextOffset = _scrollController.offset + 0.8;
      final maxExtent = _scrollController.position.maxScrollExtent;
      if (nextOffset >= maxExtent) {
        _scrollController.jumpTo(0);
      } else {
        _scrollController.jumpTo(nextOffset);
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _autoScrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (widget.onSeeAll != null)
              TextButton(
                onPressed: widget.onSeeAll,
                child: Text('homeSeeAllWardrobe'.tr()),
              ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView.separated(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = _items[index];
              return _SpotlightItemCard(item: item);
            },
          ),
        ),
      ],
    );
  }
}

class _SpotlightItemCard extends StatelessWidget {
  const _SpotlightItemCard({
    required this.item,
  });

  final ClothingItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.02),
            theme.colorScheme.surface.withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.12),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.network(
              item.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  color: theme.colorScheme.surface,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(
                      theme.colorScheme.primary,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) => Container(
                color: theme.colorScheme.surfaceVariant,
                alignment: Alignment.center,
                child: Icon(
                  Icons.broken_image_outlined,
                  color: theme.colorScheme.outline,
                  size: 28,
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.05),
                  Colors.black.withOpacity(0.55),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.local_fire_department_rounded,
                    size: 14,
                    color: Colors.deepOrangeAccent,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    "Spotlight",
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      letterSpacing: -0.05,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 14,
            right: 14,
            bottom: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.type.replaceAll("_", " "),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: -0.15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.category.replaceAll("_", " "),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

