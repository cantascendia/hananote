import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hananote/app/theme/hana_colors.dart';
import 'package:hananote/app/theme/hana_gradients.dart';

/// A card for the next immediately upcoming medication dose.
class UpcomingDoseCard extends StatelessWidget {
  /// Creates a [UpcomingDoseCard].
  const UpcomingDoseCard({
    required this.name,
    required this.dosage,
    required this.time,
    required this.period,
    required this.takeLabel,
    this.onTake,
    super.key,
  });

  /// The name of the medication.
  final String name;

  /// The dosage amount.
  final String dosage;

  /// The exact time of the dose.
  final String time;

  /// The period label of the dose.
  final String period;

  /// The localized action label shown on the button.
  final String takeLabel;

  /// Callback when the take action is pressed.
  final VoidCallback? onTake;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: HanaColors.surfaceContainerLowestOf(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: HanaColors.tertiaryContainerOf(context)
              .withAlpha((255 * 0.3).round()),
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            // Animated-like background shape (tertiary/5%, blur-xl)
            Positioned(
              left: -16,
              top: -16,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: HanaColors.tertiaryOf(context)
                      .withAlpha((255 * 0.05).round()),
                  shape: BoxShape.circle,
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment
                        .start, // sm:items-center generally align
                    children: [
                      // Circular icon
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: HanaColors.tertiaryContainerOf(context)
                              .withAlpha((255 * 0.2).round()),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.calendar_month,
                            color: HanaColors.tertiaryOf(context),
                            size: 30,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Text info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Text(
                                  '$name $dosage',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: HanaColors.onSurfaceOf(context),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        HanaColors.tertiaryContainerOf(context)
                                            .withAlpha(
                                      (255 * 0.4).round(),
                                    ),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    period.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: HanaColors.onTertiaryContainerOf(
                                          context),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2), // small visual gap
                            Text(
                              time,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: HanaColors.onSurfaceVariantOf(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    // Wrapper child
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: HanaGradients.takeDoseOf(context),
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: HanaColors.tertiaryOf(context)
                                  .withAlpha((255 * 0.2).round()),
                              blurRadius: 16,
                              offset: const Offset(
                                0,
                                4,
                              ), // roughly matches shadow-lg
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: onTake,
                            borderRadius: BorderRadius.circular(999),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12,
                              ),
                              child: Text(
                                takeLabel,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
