import 'package:flutter/material.dart';

import '../Challenge.dart';
import '../generated/l10n.dart';
import '../logic/DailyChallengeLogic.dart';
import '../main.dart';
import '../static.dart';
import '../widgets/ChallengeCard.dart';
import 'ChallengeDoneScreen.dart';

class DailyChallengeScreen extends StatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen>
    with TickerProviderStateMixin {
  Challenge? _challenge;
  bool _accepted = false;
  bool _completed = false;
  bool _loading = true;
  String _currentLanguage = 'en';

  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _currentLanguage = localeNotifier.value.languageCode;

    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _loadState();

    // Listen for language changes
    localeNotifier.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _pulseController.dispose();
    localeNotifier.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    final newLanguage = localeNotifier.value.languageCode;
    if (newLanguage != _currentLanguage) {
      _currentLanguage = newLanguage;
      _loadState(); // Reload the daily challenge in the new language
    }
  }

  Future<void> _loadState() async {
    setState(() {
      _loading = true;
    });

    final logic = DailyChallengeLogic();
    final challenge = await logic.getTodayChallenge(_currentLanguage);
    // Only allow solo challenges
    if (challenge != null && challenge.type != 'solo') {
      setState(() {
        _challenge = null;
        _accepted = false;
        _completed = false;
        _loading = false;
      });
      return;
    }
    final accepted = await logic.isAccepted();
    final completed = await logic.isCompleted();
    setState(() {
      _challenge = challenge;
      _accepted = accepted;
      _completed = completed;
      _loading = false;
    });

    // Start animations when content is loaded
    if (!_loading) {
      _fadeController.forward();
      _scaleController.forward();
      if (_completed) {
        _pulseController.repeat(reverse: true);
      }
    }
  }

  Future<void> _acceptChallenge() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.rocket_launch, color: AppStatic.grape, size: 28),
            const SizedBox(width: 12),
            Expanded(child: Text(S.of(context).challengeStartQuestion)),
          ],
        ),
        content: Text(S.of(context).startChallengeQuestion),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(S.of(context).cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppStatic.grape,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(S.of(context).yesChallengeStart, style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true && _challenge != null) {
      await DailyChallengeLogic().markAsCompleted();
      setState(() {
        _completed = true;
      });
      _pulseController.repeat(reverse: true);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              ChallengeDoneScreen(challenge: _challenge!, rewardFactor: 1.0),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_loading) {
      return Scaffold(
        backgroundColor: isDark ? Color(0xFF1a1a2e) : Color(0xFFe0c3fc), // Match gradient start color for both themes
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                ? [Color(0xFF1a1a2e), Color(0xFF16213e)]
                : [Color(0xFFe0c3fc), Color(0xFF8ec5fc)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppStatic.grape),
                    strokeWidth: 3,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'Loading your daily challenge...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final bgGradient = isDark
        ? const LinearGradient(
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Color(0xFFe0c3fc), Color(0xFF8ec5fc), Color(0xFF74b9ff)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
    final cardColor = isDark
        ? Colors.grey[900]!.withOpacity(0.95)
        : Colors.white.withOpacity(0.95);
    final titleColor = isDark ? Colors.pinkAccent : AppStatic.grape;
    final descColor = isDark ? Colors.pinkAccent[100] : AppStatic.marianBlue;
    final completedTextColor = isDark
        ? Color(0xFF7ED957)
        : Color(0xFF4BB543);
    final completedBgColor = isDark
        ? Color(0xFF1a1a2e).withOpacity(0.95)
        : Color(0xFFF0FFF4).withOpacity(0.95);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(isDark ? 0.1 : 0.2),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_today,
                color: titleColor,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                S.of(context).dailyChallenge,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: isDark ? Colors.black : AppStatic.grapeLight,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: _completed
                    ? Center(
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(32),
                                    decoration: BoxDecoration(
                                      color: completedBgColor,
                                      borderRadius: BorderRadius.circular(32),
                                      boxShadow: [
                                        BoxShadow(
                                          color: completedTextColor.withOpacity(0.3),
                                          blurRadius: 30,
                                          spreadRadius: 5,
                                          offset: Offset(0, 15),
                                        ),
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 20,
                                          offset: Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: LinearGradient(
                                              colors: [
                                                completedTextColor,
                                                completedTextColor.withOpacity(0.7),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: completedTextColor.withOpacity(0.4),
                                                blurRadius: 30,
                                                spreadRadius: 3,
                                              ),
                                            ],
                                          ),
                                          padding: const EdgeInsets.all(20),
                                          child: Icon(
                                            Icons.emoji_events_rounded,
                                            color: Colors.white,
                                            size: 72,
                                          ),
                                        ),
                                        const SizedBox(height: 28),
                                        Text(
                                          S.of(context).challengeCompletedDaily,
                                          style: Theme.of(context).textTheme.headlineSmall
                                              ?.copyWith(
                                                color: completedTextColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 24,
                                              ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          S.of(context).greatJobDaily,
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: isDark ? Colors.white70 : Colors.black87,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 12),
                                        // Decorative stars
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: List.generate(5, (index) {
                                            return Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 4),
                                              child: Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                                size: 20,
                                              ),
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      )
                    : AnimatedBuilder(
                        animation: _scaleAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scaleAnimation.value,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 20,
                              ),
                              child: Column(
                                children: [
                                  if (_challenge != null)
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(28),
                                          boxShadow: [
                                            BoxShadow(
                                              color: titleColor.withOpacity(0.2),
                                              blurRadius: 25,
                                              spreadRadius: 2,
                                              offset: Offset(0, 12),
                                            ),
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 15,
                                              offset: Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: ChallengeCard(
                                          challenge: _challenge!,
                                          showXP: true,
                                          cardColor: cardColor,
                                          titleColor: titleColor,
                                          xpColor: isDark
                                              ? Colors.greenAccent
                                              : Colors.green[700],
                                          descriptionColor: descColor,
                                          onInfoPressed: null,
                                          height: double.infinity,
                                          elevation: 0,
                                          borderRadius: 28,
                                          contentPadding: const EdgeInsets.all(24),
                                        ),
                                      ),
                                    ),
                                  if (_challenge != null) ...[
                                    const SizedBox(height: 28),
                                    Container(
                                      width: double.infinity,
                                      height: 65,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        gradient: LinearGradient(
                                          colors: [
                                            titleColor,
                                            titleColor.withOpacity(0.8),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: titleColor.withOpacity(0.4),
                                            blurRadius: 20,
                                            spreadRadius: 1,
                                            offset: Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        onPressed: _acceptChallenge,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 32,
                                            vertical: 16,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.play_arrow_rounded,
                                              size: 28,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 12),
                                            Text(
                                              S.of(context).acceptChallenge,
                                              style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                  if (_challenge == null) ...[
                                    Expanded(
                                      child: Center(
                                        child: Container(
                                          padding: EdgeInsets.all(32),
                                          decoration: BoxDecoration(
                                            color: cardColor,
                                            borderRadius: BorderRadius.circular(28),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.1),
                                                blurRadius: 20,
                                                offset: Offset(0, 10),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.schedule,
                                                size: 64,
                                                color: titleColor.withOpacity(0.6),
                                              ),
                                              SizedBox(height: 20),
                                              Text(
                                                'No Daily Challenge Available',
                                                style: TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                  color: titleColor,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              SizedBox(height: 12),
                                              Text(
                                                'Check back tomorrow for a new challenge!',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: descColor,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              );
            },
          ),
        ),
      ),
    );
  }
}
