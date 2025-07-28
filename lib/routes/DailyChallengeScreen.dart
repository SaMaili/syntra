import 'package:flutter/material.dart';

import '../Challenge.dart';
import '../logic/DailyChallengeLogic.dart';
import '../static.dart';
import '../widgets/ChallengeCard.dart';
import '../generated/l10n.dart';
import 'ChallengeDoneScreen.dart';

class DailyChallengeScreen extends StatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen> {
  Challenge? _challenge;
  bool _accepted = false;
  bool _completed = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final logic = DailyChallengeLogic();
    final challenge = await logic.getTodayChallenge();
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
  }

  Future<void> _acceptChallenge() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).challengeStartQuestion),
        content: Text(S.of(context).startChallengeQuestion),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(S.of(context).cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(S.of(context).yesChallengeStart),
          ),
        ],
      ),
    );
    if (confirmed == true && _challenge != null) {
      await DailyChallengeLogic().markAsCompleted();
      setState(() {
        _completed = true;
      });
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ChallengeDoneScreen(
            challenge: _challenge!,
            rewardFactor: 1.0,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgGradient = isDark
        ? const LinearGradient(
            colors: [Color(0xFF232526), Color(0xFF414345)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Color(0xFFe0c3fc), Color(0xFF8ec5fc)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
    final cardColor = isDark
        ? Colors.grey[900]!.withOpacity(0.98)
        : Colors.white.withOpacity(0.95);
    final titleColor = isDark ? Colors.pinkAccent : AppStatic.grape;
    final descColor = isDark ? Colors.pinkAccent[100] : AppStatic.marianBlue;
    final completedTextColor = isDark ? Color(0xFF7ED957) : Color(0xFF4BB543); // sanftes Grün
    final completedBgColor = isDark ? Color(0xFF232526) : Color(0xFFF0FFF4); // sanftes hellgrün
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          S.of(context).dailyChallenge,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
        ),
      ),
      backgroundColor: isDark ? Colors.black : AppStatic.grapeLight,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: _completed
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: completedBgColor,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 16,
                              offset: Offset(0, 8),
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
                                  colors: [completedTextColor, completedTextColor.withOpacity(0.7)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: completedTextColor.withOpacity(0.3),
                                    blurRadius: 24,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(18),
                              child: Icon(
                                Icons.emoji_events_rounded,
                                color: Colors.white,
                                size: 64,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              S.of(context).challengeCompletedDaily,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: completedTextColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              S.of(context).greatJobDaily,
                              style: TextStyle(
                                fontSize: 18,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                  child: Column(
                    children: [
                      if (_challenge != null)
                        Expanded(
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
                            elevation: 10,
                            borderRadius: 24,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 18,
                            ),
                          ),
                        ),
                      if (_challenge != null) ...[
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: _acceptChallenge,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: titleColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              textStyle: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: Text(S.of(context).acceptChallenge),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
