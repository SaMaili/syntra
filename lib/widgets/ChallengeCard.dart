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
    return Card(
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[900]
          : cardColor ?? Colors.white,
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
                    color: Theme.of(context).brightness == Brightness.dark
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
                      color: xpColor ?? Colors.green[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            // Center section with the main text
            Expanded(
              child: Center(
                child: Text(
                  challenge.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: descriptionFontSize ?? 20,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.pinkAccent
                        : descriptionColor ?? AppStatic.textSecondary,
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
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.pinkAccent
                            : Colors.grey[700],
                      ),
                  onPressed:
                      onInfoPressed ??
                      () async {
                        await ChallengeInfoNotification.showLastNotesNotification(context, challenge.id);
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
