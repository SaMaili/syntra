import 'package:flutter/material.dart';
import 'package:syntra/Challenge.dart';
import 'package:syntra/static.dart';
import 'package:syntra/widgets/challenge_info_notification.dart';

import '../generated/l10n.dart';

class ChallengeCard extends StatefulWidget {
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
  State<ChallengeCard> createState() => _ChallengeCardState();
}

class _ChallengeCardState extends State<ChallengeCard>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Start subtle pulse animation
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;

    // Enhanced color scheme
    final primaryColor = isDark ? Colors.pinkAccent : AppStatic.grape;
    final accentColor = isDark ? Colors.cyanAccent : AppStatic.marianBlue;

    // Improved gradient for better contrast in light mode
    final cardGradient = isDark
        ? LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.grey[900]!.withValues(alpha: 0.95),
        Colors.grey[850]!.withValues(alpha: 0.9),
        Colors.grey[900]!.withValues(alpha: 0.95),
      ],
    )
        : LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white,
        Colors.grey[50]!,
        Colors.white,
      ],
      stops: [0.0, 0.5, 1.0],
    );

    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _pulseAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: MouseRegion(
            onEnter: (_) {
              setState(() => _isHovered = true);
              _hoverController.forward();
            },
            onExit: (_) {
              setState(() => _isHovered = false);
              _hoverController.reverse();
            },
            child: Container(
              height: widget.height,
              decoration: BoxDecoration(
                gradient: cardGradient,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow: [
                  // Primary shadow
                  BoxShadow(
                    color: primaryColor.withValues(
                        alpha: 0.2 + (_pulseAnimation.value * 0.1)),
                    blurRadius: 20 + (_pulseAnimation.value * 5),
                    spreadRadius: 2 + (_pulseAnimation.value * 1),
                    offset: Offset(0, 8 + (_pulseAnimation.value * 2)),
                  ),
                  // Secondary shadow for depth
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                    blurRadius: 15,
                    offset: Offset(0, 4),
                  ),
                  // Subtle inner glow
                  if (_isHovered)
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.1),
                      blurRadius: 30,
                      spreadRadius: -5,
                      offset: Offset(0, 0),
                    ),
                ],
                border: Border.all(
                  color: primaryColor.withValues(
                      alpha: 0.1 + (_pulseAnimation.value * 0.1)),
                  width: 1 + (_pulseAnimation.value * 0.5),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                child: Container(
                  padding: widget.contentPadding ?? const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Enhanced top section with title and XP
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          children: [
                            // Challenge title with enhanced styling
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    primaryColor.withValues(alpha: 0.1),
                                    primaryColor.withValues(alpha: 0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                widget.challenge.title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: widget.titleFontSize ?? 32,
                                  fontWeight: FontWeight.bold,
                                  color: widget.titleColor ?? primaryColor,
                                  letterSpacing: 0.5,
                                  height: 1.2,
                                ),
                              ),
                            ),

                            SizedBox(height: 12),

                            // Enhanced XP display
                            if (widget.showXP)
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.amber.withValues(alpha: 0.2),
                                      Colors.orange.withValues(alpha: 0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.amber.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Colors.amber[700],
                                      size: 20,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      '+${widget.challenge.xp} ${l10n
                                          .auraPoints}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: widget.xpColor ??
                                            Colors.amber[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),

                      SizedBox(height: 16),

                      // Enhanced center section with description
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: accentColor.withValues(alpha: 0.1),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: GestureDetector(
                              onTap: () =>
                                  _showDescriptionDialog(context, l10n, isDark),
                              child: Text(
                                widget.challenge.description,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: widget.descriptionFontSize ?? 18,
                                  color: widget.descriptionColor ??
                                      (isDark ? Colors.white.withValues(
                                          alpha: 0.9) : AppStatic
                                          .textSecondary),
                                  height: 1.4,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 16),

                      // Enhanced bottom section with info button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  accentColor.withValues(alpha: 0.1),
                                  accentColor.withValues(alpha: 0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: accentColor.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: IconButton(
                              icon: widget.infoIcon ??
                                  Icon(
                                    Icons.info_outline,
                                    color: accentColor,
                                    size: 24,
                                  ),
                              onPressed: widget.onInfoPressed ??
                                      () => _showChallengeInfo(context),
                              tooltip: 'Challenge Information',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDescriptionDialog(BuildContext context, S l10n, bool isDark) {
    final primaryColor = isDark ? Colors.pinkAccent : AppStatic.grape;

    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            backgroundColor: isDark ? Colors.grey[900] : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(Icons.description, color: primaryColor, size: 24),
                SizedBox(width: 8),
                Text(
                  l10n.description,
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Container(
              constraints: BoxConstraints(maxWidth: 400),
              child: Text(
                widget.challenge.description,
                style: TextStyle(
                  color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors
                      .black87,
                  height: 1.5,
                  fontSize: 16,
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  backgroundColor: primaryColor.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    l10n.closeDialog,
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _showChallengeInfo(BuildContext context) async {
    await ChallengeInfoNotification.showLastNotesNotification(
      context,
      widget.challenge.id,
    );
  }
}
