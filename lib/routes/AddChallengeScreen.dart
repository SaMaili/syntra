// filepath: lib/routes/AddChallengeScreen.dart
import 'package:flutter/material.dart';
import '../Challenge.dart';
import '../database/challenge_database.dart';

class AddChallengeScreen extends StatefulWidget {
  const AddChallengeScreen({Key? key}) : super(key: key);

  @override
  _AddChallengeScreenState createState() => _AddChallengeScreenState();
}

class _AddChallengeScreenState extends State<AddChallengeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _auraController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _listScrollController = ScrollController();

  int _feeling = 2;
  int _perceived = 2;
  bool _exists = false;
  List<Challenge> _filteredChallenges = [];
  List<Challenge> _allChallenges = [];
  Challenge? _selectedChallenge;

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

  @override
  void initState() {
    super.initState();
    _loadChallenges();
    _searchController.addListener(_onSearch);
  }

  Future<void> _loadChallenges() async {
    final list = await ChallengeDatabase.instance.readAllChallenges();
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
    _auraController.dispose();
    _searchController.dispose();
    _listScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Custom Challenge')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Text('Add Challenge', style: Theme.of(context).textTheme.titleLarge),
                    //Divider(height: 32),
                    // checkbox to toggle existing challenge select mode
                    CheckboxListTile(
                      title: Text('Challenge already exists?'),
                      value: _exists,
                      onChanged: (v) => setState(() {
                        _exists = v!;
                        if (!_exists) {
                          _titleController.clear();
                          _descriptionController.clear();
                        }
                      }),
                    ),
                    SizedBox(height: 12),
                    if (_exists) ...{
                      TextFormField(
                        controller: _searchController,
                        decoration: InputDecoration(labelText: 'Search Challenge'),
                      ),
                      SizedBox(height: 8),
                      Container(
                        height: 150,
                        child: RawScrollbar(
                          thumbVisibility: true,
                          trackVisibility: true,
                          thickness: 8.0,
                          radius: Radius.circular(8.0),
                          thumbColor: Theme.of(context).primaryColor.withAlpha((0.7 * 255).round()),
                          trackColor: Theme.of(context).dividerColor.withAlpha((0.3 * 255).round()),
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
                                    _descriptionController.text = ch.description;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    },
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Challenge Name',
                        filled: true,
                        fillColor: Theme.of(context).dividerColor.withAlpha(30),
                      ),
                      enabled: !_exists,
                      validator: (value) => value == null || value.isEmpty ? 'Enter a name' : null,
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        alignLabelWithHint: true,
                        filled: true,
                        fillColor: Theme.of(context).dividerColor.withAlpha(30),
                      ),
                      maxLines: 3,
                      enabled: !_exists,
                      validator: (value) => value == null || value.isEmpty ? 'Enter a description' : null,
                    ),
                    SizedBox(height: 20),
                    Text('How do you feel?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        5,
                        (i) => IconButton(
                          icon: Icon(
                            _smileys[i],
                            size: 36,
                            color: _feeling == i ? _smileyColors[i] : Colors.grey,
                          ),
                          onPressed: () => setState(() => _feeling = i),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text('How do you think you will be perceived?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        5,
                        (i) => IconButton(
                          icon: Icon(
                            _smileys[i],
                            size: 36,
                            color: _perceived == i ? _smileyColors[i] : Colors.grey,
                          ),
                          onPressed: () => setState(() => _perceived = i),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _notesController,
                      decoration: InputDecoration(labelText: 'Notes'),
                      maxLines: 3,
                    ),],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: ElevatedButton.icon(
          icon: Icon(Icons.save, size: 20, color: Colors.white),
          label: Text('Save Entry', style: TextStyle(fontSize: 18, color: Colors.white)),
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            backgroundColor: Theme.of(context).colorScheme.primary,
            elevation: 4,
          ),
          onPressed: () async {
            if (_formKey.currentState?.validate() ?? false) {
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
                SnackBar(content: Text('Logbook entry saved')),
              );
              Navigator.of(context).pop();
            }
          },
        ),
      ),
    );
  }
}
