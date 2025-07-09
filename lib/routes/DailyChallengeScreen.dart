import 'package:flutter/material.dart';
import '../Challenge.dart';
import '../logic/DailyChallengeLogic.dart';
import '../static.dart';
import '../widgets/ChallengeCard.dart';
import 'ActiveChallengeScreen.dart';

class DailyChallengeScreen extends StatefulWidget {
  const DailyChallengeScreen({Key? key}) : super(key: key);

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
    await DailyChallengeLogic().acceptChallenge();
    setState(() {
      _accepted = true;
    });
    if (_challenge != null) {
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ActiveChallengeScreen(challenge: _challenge!),
        ),
      );
      if (result != null) {
        await DailyChallengeLogic().markAsCompleted();
        setState(() {
          _completed = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
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
    final cardColor = isDark ? Colors.grey[900]!.withOpacity(0.98) : Colors.white.withOpacity(0.95);
    final titleColor = isDark ? Colors.pinkAccent : AppStatic.grape;
    final descColor = isDark ? Colors.pinkAccent[100] : AppStatic.marianBlue;
    final completedTextColor = isDark ? Colors.greenAccent : Colors.green[700];
    return Scaffold(
      backgroundColor: isDark ? Colors.black : AppStatic.grapeLight,
      body: Container(
        decoration: BoxDecoration(
          gradient: bgGradient,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: _completed
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 120),
                      const SizedBox(height: 32),
                      Text('Challenge completed!',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: completedTextColor,
                                fontWeight: FontWeight.bold,
                              )),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 18),
                      Text(
                        'Daily Challenge',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: titleColor,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      if (_challenge != null)
                        Expanded(
                          child: ChallengeCard(
                            challenge: _challenge!,
                            showXP: true,
                            cardColor: cardColor,
                            titleColor: titleColor,
                            xpColor: isDark ? Colors.greenAccent : Colors.green[700],
                            descriptionColor: descColor,
                            onInfoPressed: null,
                            height: double.infinity,
                            elevation: 10,
                            borderRadius: 24,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
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
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            child: const Text('Accept Challenge'),
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
