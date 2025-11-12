import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final sections = <_PolicySection>[
      _PolicySection(
        title: 'privacySection1Title'.tr(),
        points: [
          'privacySection1Point1'.tr(),
          'privacySection1Point2'.tr(),
          'privacySection1Point3'.tr(),
        ],
      ),
      _PolicySection(
        title: 'privacySection2Title'.tr(),
        points: ['privacySection2Point1'.tr()],
      ),
      _PolicySection(
        title: 'privacySection3Title'.tr(),
        points: [
          'privacySection3Point1'.tr(),
          'privacySection3Point2'.tr(),
          'privacySection3Point3'.tr(),
        ],
      ),
      _PolicySection(
        title: 'privacySection4Title'.tr(),
        points: [
          'privacySection4Point1'.tr(),
          'privacySection4Point2'.tr(),
          'privacySection4Point3'.tr(),
          'privacySection4Point4'.tr(),
        ],
      ),
      _PolicySection(
        title: 'privacySection5Title'.tr(),
        points: [
          'privacySection5Point1'.tr(),
          'privacySection5Point2'.tr(),
          'privacySection5Point3'.tr(),
          'privacySection5Point4'.tr(),
        ],
      ),
      _PolicySection(
        title: 'privacySection6Title'.tr(),
        points: ['privacySection6Point1'.tr()],
      ),
      _PolicySection(
        title: 'privacySection7Title'.tr(),
        points: ['privacySection7Point1'.tr()],
      ),
      _PolicySection(
        title: 'privacySection8Title'.tr(),
        points: ['privacySection8Point1'.tr()],
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text('privacyTitle'.tr())),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'privacyTitle'.tr(),
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'privacyUpdated'.tr(),
                style: textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'privacyIntro'.tr(),
                style: textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
              const SizedBox(height: 24),
              for (final section in sections) ...[
                Text(
                  section.title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                for (final point in section.points)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      point,
                      style: textTheme.bodyMedium?.copyWith(height: 1.55),
                    ),
                  ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PolicySection {
  const _PolicySection({required this.title, required this.points});

  final String title;
  final List<String> points;
}
