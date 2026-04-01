class Challenge {
  String id; // unique identifier for the challenge starting from 90
  String title; // the title of the challenge
  String description; // the main text of the challenge
  String notSureWhatToSay; // default text if the user doesn't know what to say
  int xp; // experience points awarded for completing the challenge
  int time; // in seconds to complete the challenge
  String type; // is this a challenge for 'solo' or 'group' or 'both'
  bool flirt; // true or false is it a flirt challenge?
  double frequency;
  String environment; // 'street', 'public transport', 'home', 'work', 'other'

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    this.notSureWhatToSay = ' That\'s self explanatory, right?',
    required this.xp,
    this.type = 'both',
    this.flirt = false,
    this.frequency = 1.0,
    this.environment = 'all',
    this.time = 10, // Default to 5 minutes
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'notSureWhatToSay': notSureWhatToSay,
      'xp': xp,
      'timer': time,
      'type': type,
      'flirt': flirt ? 1 : 0,
      'frequency': frequency,
      'environment': environment,
    };
  }

  factory Challenge.fromMap(Map<String, dynamic> map) {
    return Challenge(
      id: map['id'].toString(),
      title: map['title'] ?? '',
      description: map['description'],
      notSureWhatToSay: map['notSureWhatToSay'] ?? "its self explanatory.",
      xp: map['xp'] ?? 0,
      time: map['timer'] ?? 0,
      type: map['type'] ?? 'both',
      flirt: (map['flirt'] ?? 0) == 1,
      frequency: map['frequency'] != null ? map['frequency'].toDouble() : 1.0,
      environment: map['environment'] ?? 'all',
    );
  }
}
