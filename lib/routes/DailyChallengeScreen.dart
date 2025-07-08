import 'package:flutter/material.dart';
import '../Challenge.dart';
import '../logic/DailyChallengeLogic.dart';
import '../static.dart';
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
                        Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          color: cardColor,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _challenge!.title,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: titleColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  _challenge!.description,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: descColor,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 32),
                      if (!_accepted)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: titleColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            elevation: 4,
                          ),
                          onPressed: _acceptChallenge,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Accept Challenge'),
                        ),
                      if (_accepted && !_completed)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: titleColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            elevation: 4,
                          ),
                          onPressed: () async {
                            // Directly mark as completed (for fallback, not used in normal flow)
                            await DailyChallengeLogic().markAsCompleted();
                            setState(() {
                              _completed = true;
                            });
                          },
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('Mark as Completed'),
                        ),
                      const SizedBox(height: 24),
                      TextButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                backgroundColor: isDark ? Colors.grey[900] : null,
                                title: const Text('Need Inspiration?'),
                                content: const Text('Try to focus on your breath, your steps, and the environment around you. Notice the little things!'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text('Got it!'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.lightbulb_outline, color: Colors.amber),
                        label: const Text('Not sure what to do?'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.amber[800],
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
