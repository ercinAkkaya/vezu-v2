import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:vezu/core/components/app_surface_card.dart';
import 'package:vezu/features/combination/presentation/components/combination_section_header.dart';
import 'package:vezu/features/combination/presentation/components/combination_selectable_pill.dart';
import 'package:vezu/features/combine/domain/entities/combination_preference.dart';

class CombinationPreferenceSection extends StatelessWidget {
  const CombinationPreferenceSection({
    super.key,
    required this.preference,
    required this.onOccasionChanged,
    required this.onDressCodeChanged,
    required this.onVibeChanged,
    required this.onAccessoriesChanged,
    required this.onBoldColorsChanged,
    required this.onPromptChanged,
  });

  final CombinationPreference preference;
  final ValueChanged<String> onOccasionChanged;
  final ValueChanged<String> onDressCodeChanged;
  final ValueChanged<String> onVibeChanged;
  final ValueChanged<bool> onAccessoriesChanged;
  final ValueChanged<bool> onBoldColorsChanged;
  final ValueChanged<String> onPromptChanged;

  static const _occasionOptions = [
    _PreferenceOption(labelKey: 'combinationEventOffice', value: 'office'),
    _PreferenceOption(labelKey: 'combinationEventDinner', value: 'dinner'),
    _PreferenceOption(labelKey: 'combinationEventSocial', value: 'social'),
    _PreferenceOption(labelKey: 'combinationEventCasual', value: 'casual'),
    _PreferenceOption(labelKey: 'combinationEventNightOut', value: 'night_out'),
    _PreferenceOption(labelKey: 'combinationEventDate', value: 'date'),
    _PreferenceOption(labelKey: 'combinationEventTravel', value: 'travel'),
    _PreferenceOption(labelKey: 'combinationEventWedding', value: 'wedding'),
    _PreferenceOption(labelKey: 'combineEventWeekend', value: 'weekend'),
    _PreferenceOption(labelKey: 'combineEventBrunch', value: 'brunch'),
    _PreferenceOption(labelKey: 'combineEventWorkshop', value: 'workshop'),
    _PreferenceOption(labelKey: 'combineEventPhotoshoot', value: 'photoshoot'),
    _PreferenceOption(labelKey: 'combineEventConcert', value: 'concert'),
    _PreferenceOption(labelKey: 'combineEventWorkout', value: 'workout'),
  ];

  static const _dressCodeOptions = [
    _PreferenceOption(labelKey: 'combineDressCasual', value: 'casual'),
    _PreferenceOption(labelKey: 'combineDressSmart', value: 'smart_casual'),
    _PreferenceOption(labelKey: 'combineDressFormal', value: 'formal'),
    _PreferenceOption(labelKey: 'combineDressSemiFormal', value: 'semi_formal'),
    _PreferenceOption(labelKey: 'combineDressBusiness', value: 'business'),
    _PreferenceOption(labelKey: 'combineDressCreative', value: 'creative'),
    _PreferenceOption(labelKey: 'combineDressBlackTie', value: 'black_tie'),
  ];

  static const _vibeOptions = [
    _PreferenceOption(labelKey: 'combineVibeMinimal', value: 'minimal_elegant'),
    _PreferenceOption(labelKey: 'combineVibeSporty', value: 'sporty_clean'),
    _PreferenceOption(labelKey: 'combineVibeStreet', value: 'street_luxe'),
    _PreferenceOption(labelKey: 'combineVibeBold', value: 'bold_editorial'),
    _PreferenceOption(
      labelKey: 'combineVibeRomantic',
      value: 'romantic_poetic',
    ),
    _PreferenceOption(labelKey: 'combineVibeRetro', value: 'retro_future'),
    _PreferenceOption(labelKey: 'combineVibeChill', value: 'chill_relaxed'),
    _PreferenceOption(labelKey: 'combineVibeEdgy', value: 'edgy_structured'),
    _PreferenceOption(labelKey: 'combineVibePlayful', value: 'playful_color'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppSurfaceCard(
      padding: const EdgeInsets.all(22),
      borderRadius: 34,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CombinationSectionHeader(
            titleKey: 'combinationEventTitle',
            subtitleKey: 'combinationEventSubtitle',
          ),
          const SizedBox(height: 14),
          _buildPillWrap(
            context: context,
            options: _occasionOptions,
            selectedValue: preference.occasion,
            onSelected: onOccasionChanged,
          ),
          const SizedBox(height: 24),
          CombinationSectionHeader(
            titleKey: 'combineDressCodeTitle',
            subtitleKey: 'combineDressCodeSubtitle',
          ),
          const SizedBox(height: 14),
          _buildPillWrap(
            context: context,
            options: _dressCodeOptions,
            selectedValue: preference.dressCode,
            onSelected: onDressCodeChanged,
          ),
          const SizedBox(height: 24),
          CombinationSectionHeader(
            titleKey: 'combineVibeTitle',
            subtitleKey: 'combineVibeSubtitle',
          ),
          const SizedBox(height: 14),
          _buildPillWrap(
            context: context,
            options: _vibeOptions,
            selectedValue: preference.vibe,
            onSelected: onVibeChanged,
          ),
          const SizedBox(height: 24),
          _buildSwitchTile(
            context: context,
            label: 'combineAccessoriesToggle'.tr(),
            value: preference.includeAccessories,
            onChanged: onAccessoriesChanged,
          ),
          const SizedBox(height: 10),
          _buildSwitchTile(
            context: context,
            label: 'combineBoldColorsToggle'.tr(),
            value: preference.allowBoldColors,
            onChanged: onBoldColorsChanged,
          ),
          const SizedBox(height: 24),
          CombinationSectionHeader(
            titleKey: 'combinePromptTitle',
            subtitleKey: 'combinePromptSubtitle',
          ),
          const SizedBox(height: 12),
          _PromptInputField(
            value: preference.customPrompt,
            onChanged: onPromptChanged,
            hintText: 'combinePromptHint'.tr(),
          ),
          const SizedBox(height: 8),
          Text(
            'combinePromptHelper'.tr(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSecondary.withValues(alpha: 0.8),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildPillWrap({
    required BuildContext context,
    required List<_PreferenceOption> options,
    required String selectedValue,
    required ValueChanged<String> onSelected,
  }) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: options
          .map(
            (option) => CombinationSelectablePill(
              label: option.labelKey.tr(),
              isSelected: selectedValue == option.value,
              onTap: () => onSelected(option.value),
            ),
          )
          .toList(),
    );
  }

  Widget _buildSwitchTile({
    required BuildContext context,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.35,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _PreferenceOption {
  const _PreferenceOption({required this.labelKey, required this.value});

  final String labelKey;
  final String value;
}

class _PromptInputField extends StatefulWidget {
  const _PromptInputField({
    required this.value,
    required this.onChanged,
    required this.hintText,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final String hintText;

  @override
  State<_PromptInputField> createState() => _PromptInputFieldState();
}

class _PromptInputFieldState extends State<_PromptInputField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _PromptInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
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
    return TextField(
      controller: _controller,
      minLines: 2,
      maxLines: 4,
      onChanged: widget.onChanged,
      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: widget.hintText,
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.45,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.25),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(
            color: theme.colorScheme.primary.withValues(alpha: 0.6),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
      ),
    );
  }
}
