class MockData {
  static final nextMatch = {
    'opponent': 'Rafael Nadal',
    'time': 'Tomorrow, 10:00 AM',
    'court': 'Court 1 (Clay)',
    'round': 'Semi-Final',
    'tournament': 'Summer Open 2025',
  };

  static final liveTournaments = [
    {
      'id': '1',
      'name': 'Summer Open 2025',
      'status': 'Live Now',
      'players': 32,
      'location': 'City Club',
      'image': 'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?auto=format&fit=crop&w=800&q=80',
      'description': 'The biggest summer event in the city. Join the best players for a weekend of intense matches.',
      'dates': 'Nov 24 - Nov 26',
    },
    {
      'id': '2',
      'name': 'Weekend Warrior Cup',
      'status': 'Registration Open',
      'players': 16,
      'location': 'Public Courts',
      'image': 'https://images.unsplash.com/photo-1595435934249-5df7ed86e1c0?auto=format&fit=crop&w=800&q=80',
      'description': 'A friendly tournament for casual players.',
      'dates': 'Dec 01 - Dec 03',
    },
    {
      'id': '3',
      'name': 'Mixed Doubles Blast',
      'status': 'Upcoming',
      'players': 24,
      'location': 'Riverside Club',
      'image': 'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?auto=format&fit=crop&w=800&q=80',
      'description': 'Grab a partner and join the fun!',
      'dates': 'Dec 10 - Dec 12',
    },
  ];

  static final bracket = [
    {
      'round': 'Quarter-Finals',
      'matches': [
        {'p1': 'Federer', 'p2': 'Djokovic', 'score': '6-4, 6-3', 'winner': 'Federer'},
        {'p1': 'Nadal', 'p2': 'Murray', 'score': '7-5, 6-4', 'winner': 'Nadal'},
        {'p1': 'Alcaraz', 'p2': 'Sinner', 'score': '6-2, 6-1', 'winner': 'Alcaraz'},
        {'p1': 'Tsitsipas', 'p2': 'Zverev', 'score': 'Pending', 'winner': ''},
      ]
    },
    {
      'round': 'Semi-Finals',
      'matches': [
        {'p1': 'Federer', 'p2': 'Nadal', 'score': 'Pending', 'winner': ''},
        {'p1': 'Alcaraz', 'p2': 'TBD', 'score': 'Pending', 'winner': ''},
      ]
    },
  ];
}
