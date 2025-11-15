import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:vezu/core/components/primary_filled_button.dart";

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SettingsView();
  }
}

class _SettingsView extends StatefulWidget {
  const _SettingsView();

  @override
  State<_SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<_SettingsView> {
  Locale? _selectedLocale;
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _promoNotifications = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedLocale ??= context.locale;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('profileAccountSettings'.tr())),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          Text(
            'settingsLanguage'.tr(),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'settingsLanguageSubtitle'.tr(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSecondary,
            ),
          ),
          const SizedBox(height: 16),
          _buildLanguageOption(
            context: context,
            locale: const Locale('tr'),
            label: 'settingsLanguageTurkish'.tr(),
          ),
          const SizedBox(height: 12),
          _buildLanguageOption(
            context: context,
            locale: const Locale('en'),
            label: 'settingsLanguageEnglish'.tr(),
          ),
          const SizedBox(height: 32),
          Text(
            'settingsNotifications'.tr(),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'settingsNotificationSubtitle'.tr(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSecondary,
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile.adaptive(
            value: _emailNotifications,
            onChanged: (value) => setState(() => _emailNotifications = value),
            title: Text('settingsNotificationEmail'.tr()),
          ),
          SwitchListTile.adaptive(
            value: _pushNotifications,
            onChanged: (value) => setState(() => _pushNotifications = value),
            title: Text('settingsNotificationPush'.tr()),
          ),
          SwitchListTile.adaptive(
            value: _promoNotifications,
            onChanged: (value) => setState(() => _promoNotifications = value),
            title: Text('settingsNotificationPromotions'.tr()),
          ),
          const SizedBox(height: 32),
          PrimaryFilledButton(
            onPressed: () async {
              final locale = _selectedLocale ?? context.locale;
              if (locale != context.locale) {
                await context.setLocale(locale);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'settingsLanguageChanged'.tr(
                          namedArgs: {
                            'lang': locale.languageCode == 'tr'
                                ? 'Türkçe'
                                : 'English',
                          },
                        ),
                      ),
                    ),
                  );
                }
              }
            },
            label: 'settingsSave'.tr(),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required Locale locale,
    required String label,
  }) {
    final current = _selectedLocale ?? context.locale;
    final isSelected = current == locale;
    return InkWell(
      onTap: () => setState(() => _selectedLocale = locale),
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.08)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.12),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.language,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSecondary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}
