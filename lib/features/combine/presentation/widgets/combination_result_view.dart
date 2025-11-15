import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:vezu/core/components/app_surface_card.dart';
import 'package:vezu/features/combine/domain/entities/combination_plan.dart';
import 'package:vezu/features/combine/domain/entities/combination_preference.dart';
import 'package:vezu/features/wardrobe/domain/entities/clothing_item.dart';

class CombinationResultView extends StatelessWidget {
  const CombinationResultView({
    super.key,
    required this.plan,
    required this.wardrobeMap,
    required this.preference,
    this.onSave,
    this.isSaving = false,
    this.hasSaved = false,
  });

  final CombinationPlan plan;
  final Map<String, ClothingItem> wardrobeMap;
  final CombinationPreference preference;
  final VoidCallback? onSave;
  final bool isSaving;
  final bool hasSaved;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PlanHeroCard(
          plan: plan,
          preference: preference,
          onSave: onSave,
          isSaving: isSaving,
          hasSaved: hasSaved,
        ),
        const SizedBox(height: 2),
        _CombinationItemsGalleryCard(
          plan: plan,
          wardrobeMap: wardrobeMap,
        ),
      ],
    );
  }
}

class _PlanHeroCard extends StatelessWidget {
  const _PlanHeroCard({
    required this.plan,
    required this.preference,
    this.onSave,
    this.isSaving = false,
    this.hasSaved = false,
  });

  final CombinationPlan plan;
  final CombinationPreference preference;
  final VoidCallback? onSave;
  final bool isSaving;
  final bool hasSaved;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final occasionLabel = _localizedLabel(
      context,
      _occasionLabelKeys,
      preference.occasion,
    );
    final dressLabel = _localizedLabel(
      context,
      _dressCodeLabelKeys,
      preference.dressCode,
    );
    final vibeLabel = _localizedLabel(context, _vibeLabelKeys, preference.vibe);
    final weatherLabel = _localizedLabel(
      context,
      _weatherLabelKeys,
      preference.weather,
    );

    final metaChips = [
      _buildMetaChip(
        icon: Icons.event_outlined,
        label: 'combineResultOccasion'.tr(),
        value: occasionLabel,
      ),
      _buildMetaChip(
        icon: Icons.workspace_premium_outlined,
        label: 'combineResultDressCode'.tr(),
        value: dressLabel,
      ),
      _buildMetaChip(
        icon: Icons.auto_fix_high_outlined,
        label: 'combineResultVibe'.tr(),
        value: vibeLabel,
      ),
      _buildMetaChip(
        icon: Icons.thermostat_auto_outlined,
        label: 'combineResultWeather'.tr(),
        value: weatherLabel,
      ),
    ]..removeWhere((chip) => chip == null);

    final themeLabel = _localizedTheme(context, plan.theme, preference.vibe);
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        gradient: const LinearGradient(
          colors: [Color(0xFF151515), Color(0xFF080808)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          left: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          right: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  themeLabel,
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
              if (onSave != null)
                _SaveIconButton(
                  onPressed: onSave!,
                  isSaving: isSaving,
                  isSaved: hasSaved,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            plan.summary,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
              height: 1.5,
            ),
          ),
          if (metaChips.isNotEmpty) ...[
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: metaChips.whereType<Widget>().toList(),
            ),
          ],
          if (preference.customPrompt.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text(
              'combineResultPrompt'.tr(),
              style: theme.textTheme.labelMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '“${preference.customPrompt}”',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget? _buildMetaChip({
    required IconData icon,
    required String label,
    required String? value,
  }) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return _PlanMetaChip(icon: icon, label: label, value: value);
  }
}

class _PlanMetaChip extends StatelessWidget {
  const _PlanMetaChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CombinationItemsGalleryCard extends StatelessWidget {
  const _CombinationItemsGalleryCard({
    required this.plan,
    required this.wardrobeMap,
  });

  final CombinationPlan plan;
  final Map<String, ClothingItem> wardrobeMap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final galleryTiles = plan.items
        .map(
          (item) => _GalleryItemTile(
            imageUrl: wardrobeMap[item.wardrobeItemId]?.imageUrl,
          ),
        )
        .toList();
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        border: Border(
          left: BorderSide(color: Colors.black.withValues(alpha: 0.5), width: 1.5),
          right: BorderSide(color: Colors.black.withValues(alpha: 0.5), width: 1.5),
          bottom: BorderSide(color: Colors.black.withValues(alpha: 0.5), width: 1.5),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(26, 20, 26, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'combineResultPieces'.tr(),
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: galleryTiles,
          ),
        ],
      ),
    );
  }
}

class _GalleryItemTile extends StatelessWidget {
  const _GalleryItemTile({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final placeholderColor = Colors.white.withValues(alpha: 0.08);
    final child = ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: imageUrl == null || imageUrl!.isEmpty
            ? Container(
                color: placeholderColor,
                alignment: Alignment.center,
                child: Icon(
                  Icons.image_outlined,
                  color: Colors.white.withValues(alpha: 0.5),
                  size: 28,
                ),
              )
            : Image.network(
                imageUrl!,
                fit: BoxFit.cover,
              ),
      ),
    );
    return SizedBox(
      width: 100,
      child: child,
    );
  }
}

class _SaveIconButton extends StatelessWidget {
  const _SaveIconButton({
    required this.onPressed,
    required this.isSaving,
    required this.isSaved,
  });

  final VoidCallback onPressed;
  final bool isSaving;
  final bool isSaved;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = isSaved
        ? theme.colorScheme.secondaryContainer
        : Colors.white.withValues(alpha: 0.15);
    final iconColor =
        isSaved ? theme.colorScheme.onSecondaryContainer : Colors.white;
    return Tooltip(
      message: isSaved
          ? 'combineSaveButton'.tr()
          : 'combineSaveButton'.tr(),
      child: InkResponse(
        onTap: isSaving ? null : onPressed,
        radius: 24,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: background,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: isSaving
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: iconColor,
                  ),
                )
              : Icon(
                  isSaved ? Icons.bookmark_added_rounded : Icons.bookmark_add_outlined,
                  color: iconColor,
                  size: 20,
                ),
        ),
      ),
    );
  }
}

String? _localizedLabel(
  BuildContext context,
  Map<String, String> dictionary,
  String value,
) {
  if (value.isEmpty) {
    return null;
  }
  final key = dictionary[value];
  if (key == null || key.isEmpty) {
    return value;
  }
  return key.tr(context: context);
}

const Map<String, String> _occasionLabelKeys = {
  'office': 'combinationEventOffice',
  'dinner': 'combinationEventDinner',
  'social': 'combinationEventSocial',
  'casual': 'combinationEventCasual',
  'night_out': 'combinationEventNightOut',
  'date': 'combinationEventDate',
  'travel': 'combinationEventTravel',
  'wedding': 'combinationEventWedding',
  'weekend': 'combineEventWeekend',
  'brunch': 'combineEventBrunch',
  'workshop': 'combineEventWorkshop',
  'photoshoot': 'combineEventPhotoshoot',
  'concert': 'combineEventConcert',
  'workout': 'combineEventWorkout',
};

const Map<String, String> _dressCodeLabelKeys = {
  'casual': 'combineDressCasual',
  'smart_casual': 'combineDressSmart',
  'formal': 'combineDressFormal',
  'semi_formal': 'combineDressSemiFormal',
  'business': 'combineDressBusiness',
  'creative': 'combineDressCreative',
  'black_tie': 'combineDressBlackTie',
};

const Map<String, String> _vibeLabelKeys = {
  'minimal_elegant': 'combineVibeMinimal',
  'sporty_clean': 'combineVibeSporty',
  'street_luxe': 'combineVibeStreet',
  'bold_editorial': 'combineVibeBold',
  'romantic_poetic': 'combineVibeRomantic',
  'retro_future': 'combineVibeRetro',
  'chill_relaxed': 'combineVibeChill',
  'edgy_structured': 'combineVibeEdgy',
  'playful_color': 'combineVibePlayful',
};

const Map<String, String> _weatherLabelKeys = {
  'cool': 'combineWeatherCool',
  'mild': 'combineWeatherMild',
  'warm': 'combineWeatherWarm',
  'spring': 'combinationSeasonSpring',
  'summer': 'combinationSeasonSummer',
  'autumn': 'combinationSeasonAutumn',
  'winter': 'combinationSeasonWinter',
};

const Map<String, String> _themeLabelKeys = {
  'retro_futurism_fusion': 'combineThemeRetroFuturismFusion',
};

String _localizedTheme(
  BuildContext context,
  String theme,
  String vibeKey,
) {
  final normalized = _normalizeTheme(theme);
  final themeKey = _themeLabelKeys[normalized];
  if (themeKey != null) {
    return themeKey.tr(context: context);
  }
  final vibeTranslation = _vibeLabelKeys[vibeKey];
  if (vibeTranslation != null) {
    return vibeTranslation.tr(context: context);
  }
  return theme;
}

String _normalizeTheme(String value) {
  return value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
}
