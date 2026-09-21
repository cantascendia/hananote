// HoYo · Quote card — surface-container-low background with a
// large 40%-opacity format_quote glyph and italic body text.
// Mirrors preview/19-quote-card.html.
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

import 'package:hananote/app/theme/hana_colors.dart';
import 'package:hananote/app/theme/hana_typography.dart';

class HoyoQuoteCard extends StatelessWidget {
  const HoyoQuoteCard({
    required this.quote,
    super.key,
    this.author,
  });

  final String quote;
  final String? author;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
        decoration: BoxDecoration(
          color: HanaColors.surfaceContainerLowOf(context),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -8,
              left: -2,
              child: Icon(
                Icons.format_quote,
                size: 64,
                color: HanaColors.primaryOf(context).withValues(alpha: 0.4),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 36, top: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    quote,
                    style: HanaTypography.bodyLg.copyWith(
                      color: HanaColors.onSurfaceOf(context),
                      fontStyle: FontStyle.italic,
                      height: 1.7,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (author != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      '— $author',
                      style: HanaTypography.labelMd.copyWith(
                        color: HanaColors.onSurfaceVariantOf(context),
                        letterSpacing: 0.56,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
