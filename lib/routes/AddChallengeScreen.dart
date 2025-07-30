// filepath: lib/routes/AddChallengeScreen.dart
import 'package:flutter/material.dart';

import '../Challenge.dart';
import '../database/challenge_database.dart';
import '../generated/l10n.dart';
import '../static.dart';

class AddChallengeScreen extends StatefulWidget {
  const AddChallengeScreen({Key? key}) : super(key: key);

  @override
  _AddChallengeScreenState createState() => _AddChallengeScreenState();
}

class _AddChallengeScreenState extends State<AddChallengeScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _listScrollController = ScrollController();

  int _feeling = 2;
  int _perceived = 2;
  bool _exists = false;
  bool _hasLoadedChallenges = false;
  bool _isLoading = false;
  List<Challenge> _filteredChallenges = [];
  List<Challenge> _allChallenges = [];
  Challenge? _selectedChallenge;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _staggerController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late List<Animation<double>> _staggerAnimations;

  final List<IconData> _smileys = [
    Icons.sentiment_very_dissatisfied,
    Icons.sentiment_dissatisfied,
    Icons.sentiment_neutral,
    Icons.sentiment_satisfied,
    Icons.sentiment_very_satisfied,
  ];

  final List<Color> _smileyColors = [
    Colors.red,
    Colors.orange,
    Colors.amber,
    Colors.lightGreen,
    Colors.green,
  ];

  final List<String> _emotionLabels = [
    'Very Bad',
    'Bad',
    'Neutral',
    'Good',
    'Very Good',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearch);

    // Initialize animation controllers
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Define animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Create stagger animations for each section
    _staggerAnimations = List.generate(6, (index) {
      final begin = index * 0.12;
      final end = (begin + 0.25).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(begin, end, curve: Curves.easeInOut),
        ),
      );
    });

    // Start animations
    _fadeController.forward();
    _scaleController.forward();
    _staggerController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoadedChallenges) {
      _loadChallenges();
      _hasLoadedChallenges = true;
    }
  }

  Future<void> _loadChallenges() async {
    // Get current locale
    final locale = Localizations.localeOf(context).languageCode;
    final list = await ChallengeDatabase.instance.readAllChallenges(locale);
    setState(() {
      _allChallenges = list;
      _filteredChallenges = list;
    });
  }

  void _onSearch() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _filteredChallenges = _allChallenges
          .where((c) => c.title.toLowerCase().contains(q))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearch);
    _titleController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    _searchController.dispose();
    _listScrollController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Beautiful gradient backgrounds
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
        ? Colors.grey[900]!.withValues(alpha: 0.95)
        : Colors.white.withValues(alpha: 0.95);
    final titleColor = isDark ? Colors.pinkAccent : AppStatic.grape;
    final accentColor = isDark ? Colors.cyanAccent : AppStatic.marianBlue;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: isDark ? 0.1 : 0.2),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_task, color: titleColor, size: 24),
              SizedBox(width: 8),
              Text(
                S.of(context).addCustomChallengeTitle,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                  fontSize: 18,
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
                child: AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _formKey,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                SizedBox(height: 20),

                                // Challenge Type Selection
                                AnimatedBuilder(
                                  animation: _staggerAnimations[0],
                                  builder: (context, child) {
                                    return Transform.translate(
                                      offset: Offset(0, 50 * (1 - _staggerAnimations[0].value)),
                                      child: Opacity(
                                        opacity: _staggerAnimations[0].value,
                                        child: _buildChallengeTypeCard(cardColor, titleColor, isDark),
                                      ),
                                    );
                                  },
                                ),

                                SizedBox(height: 20),

                                // Existing Challenge Search (if selected)
                                if (_exists) ...[
                                  AnimatedBuilder(
                                    animation: _staggerAnimations[1],
                                    builder: (context, child) {
                                      return Transform.translate(
                                        offset: Offset(0, 50 * (1 - _staggerAnimations[1].value)),
                                        child: Opacity(
                                          opacity: _staggerAnimations[1].value,
                                          child: _buildChallengeSearchCard(cardColor, accentColor, isDark),
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(height: 20),
                                ],

                                // Challenge Details
                                AnimatedBuilder(
                                  animation: _staggerAnimations[2],
                                  builder: (context, child) {
                                    return Transform.translate(
                                      offset: Offset(0, 50 * (1 - _staggerAnimations[2].value)),
                                      child: Opacity(
                                        opacity: _staggerAnimations[2].value,
                                        child: _buildChallengeDetailsCard(cardColor, accentColor, isDark),
                                      ),
                                    );
                                  },
                                ),

                                SizedBox(height: 20),

                                // Feelings Section
                                AnimatedBuilder(
                                  animation: _staggerAnimations[3],
                                  builder: (context, child) {
                                    return Transform.translate(
                                      offset: Offset(0, 50 * (1 - _staggerAnimations[3].value)),
                                      child: Opacity(
                                        opacity: _staggerAnimations[3].value,
                                        child: _buildFeelingsCard(cardColor, titleColor, isDark),
                                      ),
                                    );
                                  },
                                ),

                                SizedBox(height: 20),

                                // Perception Section
                                AnimatedBuilder(
                                  animation: _staggerAnimations[4],
                                  builder: (context, child) {
                                    return Transform.translate(
                                      offset: Offset(0, 50 * (1 - _staggerAnimations[4].value)),
                                      child: Opacity(
                                        opacity: _staggerAnimations[4].value,
                                        child: _buildPerceptionCard(cardColor, titleColor, isDark),
                                      ),
                                    );
                                  },
                                ),

                                SizedBox(height: 20),

                                // Notes Section
                                AnimatedBuilder(
                                  animation: _staggerAnimations[5],
                                  builder: (context, child) {
                                    return Transform.translate(
                                      offset: Offset(0, 50 * (1 - _staggerAnimations[5].value)),
                                      child: Opacity(
                                        opacity: _staggerAnimations[5].value,
                                        child: _buildNotesCard(cardColor, accentColor, isDark),
                                      ),
                                    );
                                  },
                                ),

                                SizedBox(height: 100), // Space for floating button
                              ],
                            ),
                          ),
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
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              titleColor,
              titleColor.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: titleColor.withValues(alpha: 0.4),
              blurRadius: 20,
              spreadRadius: 1,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: _isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Icon(Icons.save, color: Colors.white, size: 24),
          label: Text(
            S.of(context).saveEntry,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          onPressed: _isLoading ? null : _saveEntry,
        ),
      ),
    );
  }

  Widget _buildChallengeTypeCard(Color cardColor, Color titleColor, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).challengeType,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildChallengeTypeButton(
                  label: S.of(context).existingChallenge,
                  isSelected: _exists,
                  onTap: () {
                    setState(() {
                      _exists = true;
                      _titleController.clear();
                      _descriptionController.clear();
                    });
                  },
                  color: titleColor,
                ),
                _buildChallengeTypeButton(
                  label: S.of(context).newChallenge,
                  isSelected: !_exists,
                  onTap: () {
                    setState(() {
                      _exists = false;
                    });
                  },
                  color: titleColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeTypeButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildChallengeSearchCard(Color cardColor, Color accentColor, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).searchChallenge,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: S.of(context).searchForChallenge,
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: accentColor, width: 2),
                ),
              ),
              onChanged: (value) {
                _onSearch();
              },
            ),
            SizedBox(height: 12),
            Container(
              height: 150,
              child: RawScrollbar(
                thumbVisibility: true,
                trackVisibility: true,
                thickness: 8.0,
                radius: Radius.circular(8.0),
                thumbColor: Theme.of(
                  context,
                ).primaryColor.withAlpha((0.7 * 255).round()),
                trackColor: Theme.of(
                  context,
                ).dividerColor.withAlpha((0.3 * 255).round()),
                controller: _listScrollController,
                child: ListView.builder(
                  controller: _listScrollController,
                  itemCount: _filteredChallenges.length,
                  itemBuilder: (context, i) {
                    final ch = _filteredChallenges[i];
                    return ListTile(
                      title: Text(ch.title),
                      onTap: () {
                        setState(() {
                          _selectedChallenge = ch;
                          _titleController.text = ch.title;
                          _descriptionController.text =
                              ch.description;
                        });
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeDetailsCard(Color cardColor, Color accentColor, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).challengeDetails,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: S.of(context).challengeName,
                filled: true,
                fillColor: Theme.of(context).dividerColor.withAlpha(30),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: accentColor, width: 2),
                ),
              ),
              enabled: !_exists,
              validator: (value) => value == null || value.isEmpty
                  ? S.of(context).enterName
                  : null,
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: S.of(context).description,
                alignLabelWithHint: true,
                filled: true,
                fillColor: Theme.of(context).dividerColor.withAlpha(30),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: accentColor, width: 2),
                ),
              ),
              maxLines: 3,
              enabled: !_exists,
              validator: (value) => value == null || value.isEmpty
                  ? S.of(context).enterDescription
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeelingsCard(Color cardColor, Color titleColor, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).howDoYouFeel,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                5,
                (i) => GestureDetector(
                  onTap: () => setState(() => _feeling = i),
                  child: Column(
                    children: [
                      Icon(
                        _smileys[i],
                        size: 36,
                        color: _feeling == i
                            ? _smileyColors[i]
                            : Colors.grey,
                      ),
                      SizedBox(height: 4),
                      Text(
                        _emotionLabels[i],
                        style: TextStyle(
                          color: _feeling == i
                              ? _smileyColors[i]
                              : Colors.grey,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerceptionCard(Color cardColor, Color titleColor, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).howPerceivedThink,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                5,
                (i) => GestureDetector(
                  onTap: () => setState(() => _perceived = i),
                  child: Column(
                    children: [
                      Icon(
                        _smileys[i],
                        size: 36,
                        color: _perceived == i
                            ? _smileyColors[i]
                            : Colors.grey,
                      ),
                      SizedBox(height: 4),
                      Text(
                        _emotionLabels[i],
                        style: TextStyle(
                          color: _perceived == i
                              ? _smileyColors[i]
                              : Colors.grey,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard(Color cardColor, Color accentColor, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).notes,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                hintText: S.of(context).notesPlaceholder, // Use existing localization
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: accentColor, width: 2),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveEntry() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });
      final db = ChallengeDatabase.instance;
      final idValue = _exists && _selectedChallenge != null
          ? _selectedChallenge!.id
          : '9999';
      final earned = (_exists && _selectedChallenge != null)
          ? _selectedChallenge!.xp
          : 80;
      await db.addLogbookEntry({
        'user_id': null,
        'challenge_id': idValue,
        'custom_title': _exists ? null : _titleController.text,
        'earned': earned,
        'timestamp': DateTime.now().toIso8601String(),
        'status': _exists ? 'success' : 'custom',
        'feeling': _feeling,
        'perception': _perceived,
        'notes': _notesController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).logbookEntrySaved)),
      );
      Navigator.of(context).pop();
    }
    setState(() {
      _isLoading = false;
    });
  }
}
