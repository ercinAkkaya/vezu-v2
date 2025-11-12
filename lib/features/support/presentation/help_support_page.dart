import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:vezu/core/components/app_surface_card.dart";
import "package:vezu/core/components/primary_filled_button.dart";

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final email = 'helpContactEmailValue'.tr();

    final faqs = List.generate(4, (index) {
      final question = 'helpFaq${index + 1}Question'.tr();
      final answer = 'helpFaq${index + 1}Answer'.tr();
      return _FaqItem(question: question, answer: answer);
    });

    return Scaffold(
      appBar: AppBar(title: Text('helpTitle'.tr())),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          children: [
            Text(
              'helpSubtitle'.tr(),
              style: textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSecondary,
              ),
            ),
            const SizedBox(height: 24),
            AppSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'helpContactTitle'.tr(),
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'helpContactDescription'.tr(),
                    style: textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.alternate_email_rounded,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'helpContactEmailLabel'.tr(),
                                style: textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.onSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              SelectableText(
                                email,
                                style: textTheme.titleSmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  PrimaryFilledButton(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: email));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('helpContactEmailCopied'.tr()),
                          ),
                        );
                      }
                    },
                    label: 'helpContactEmailButton'.tr(),
                    icon: const Icon(Icons.copy_rounded),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'helpFaqTitle'.tr(),
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ...faqs.map(
              (faq) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppSurfaceCard(
                  padding: EdgeInsets.zero,
                  child: Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      title: Text(
                        faq.question,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      children: [
                        Text(
                          faq.answer,
                          style: textTheme.bodyMedium?.copyWith(height: 1.55),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqItem {
  const _FaqItem({required this.question, required this.answer});

  final String question;
  final String answer;
}
