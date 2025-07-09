import 'package:flutter/material.dart';
import 'package:syntra/Challenge.dart';
import 'package:syntra/static.dart';
import 'package:syntra/widgets/challenge_info_notification.dart';

class ChallengeCard extends StatelessWidget {
  final Challenge challenge;
  final VoidCallback? onInfoPressed;
  final double height;
  final double elevation;
  final double borderRadius;
  final Color? cardColor;
  final Color? titleColor;
  final double? titleFontSize;
  final Color? xpColor;
  final bool showXP;
  final Color? descriptionColor;
  final double? descriptionFontSize;
  final EdgeInsetsGeometry? contentPadding;
  final Icon? infoIcon;

  const ChallengeCard({
    super.key,
    required this.challenge,
    this.onInfoPressed,
    this.height = 300,
    this.elevation = 8,
    this.borderRadius = 20,
    this.cardColor,
    this.titleColor,
    this.titleFontSize,
    this.xpColor,
    this.showXP = true,
    this.descriptionColor,
    this.descriptionFontSize,
    this.contentPadding,
    this.infoIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      color: isDark ? Colors.grey[900] : cardColor ?? Colors.white,
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Container(
        height: height,
        padding: contentPadding ?? const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Top section with title and XP
            Column(
              children: [
                Text(
                  challenge.title,
                  style: TextStyle(
                    fontSize: titleFontSize ?? 40,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? Colors.pinkAccent
                        : titleColor ?? AppStatic.textPrimary,
                  ),
                ),
                SizedBox(height: 6),
                if (showXP)
                  Text(
                    '+${challenge.xp} Aura',
                    style: TextStyle(
                      fontSize: 18,
                      color:
                          xpColor ??
                          (isDark ? Colors.greenAccent : Colors.green[700]),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            // Center section with the main text
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: isDark ? Colors.grey[900] : null,
                        title: Text(
                          'Challenge Description',
                          style: TextStyle(color: isDark ? Colors.white : null),
                        ),
                        content: Text(
                          challenge.description,
                          style: TextStyle(color: isDark ? Colors.white : null),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(
                              'Close',
                              style: TextStyle(
                                color: isDark ? Colors.pinkAccent : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text(
                    challenge.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: descriptionFontSize ?? 20,
                      color: isDark
                          ? Colors.pinkAccent
                          : descriptionColor ?? AppStatic.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
            // Bottom section with info button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon:
                      infoIcon ??
                      Icon(
                        Icons.info_outline,
                        color: isDark ? Colors.pinkAccent : Colors.grey[700],
                      ),
                  onPressed:
                      onInfoPressed ??
                      () async {
                        await ChallengeInfoNotification.showLastNotesNotification(
                          context,
                          challenge.id,
                        );
                      },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
