import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Space Progress Data Model
class SpaceProgressData {
  final int totalFocusSeconds;
  final int unspentFocusSeconds;
  final double totalDistanceLightYears;
  final String currentRank;
  final int currentStarIndex;
  final List<String> unlockedStars;

  SpaceProgressData({
    required this.totalFocusSeconds,
    required this.unspentFocusSeconds,
    required this.totalDistanceLightYears,
    required this.currentRank,
    required this.currentStarIndex,
    required this.unlockedStars,
  });

  SpaceProgressData copyWith({
    int? totalFocusSeconds,
    int? unspentFocusSeconds,
    double? totalDistanceLightYears,
    String? currentRank,
    int? currentStarIndex,
    List<String>? unlockedStars,
  }) {
    return SpaceProgressData(
      totalFocusSeconds: totalFocusSeconds ?? this.totalFocusSeconds,
      unspentFocusSeconds: unspentFocusSeconds ?? this.unspentFocusSeconds,
      totalDistanceLightYears: totalDistanceLightYears ?? this.totalDistanceLightYears,
      currentRank: currentRank ?? this.currentRank,
      currentStarIndex: currentStarIndex ?? this.currentStarIndex,
      unlockedStars: unlockedStars ?? this.unlockedStars,
    );
  }
}

// Space Ranks based on total focus time (in hours)
class SpaceRank {
  final String name;
  final int requiredHours;
  final String description;

  const SpaceRank({
    required this.name,
    required this.requiredHours,
    required this.description,
  });
}

// Space Literature inspired ranks
const List<SpaceRank> spaceRanks = [
  SpaceRank(name: 'Cadet', requiredHours: 0, description: 'Just beginning the journey'),
  SpaceRank(name: 'Pilot', requiredHours: 10, description: 'Learning the basics'),
  SpaceRank(name: 'Navigator', requiredHours: 25, description: 'Charting the course'),
  SpaceRank(name: 'Lieutenant', requiredHours: 50, description: 'Gaining experience'),
  SpaceRank(name: 'Commander', requiredHours: 100, description: 'Leading missions'),
  SpaceRank(name: 'Captain', requiredHours: 200, description: 'Master of the ship'),
  SpaceRank(name: 'Commodore', requiredHours: 350, description: 'Fleet leadership'),
  SpaceRank(name: 'Admiral', requiredHours: 500, description: 'Strategic command'),
  SpaceRank(name: 'Grand Admiral', requiredHours: 750, description: 'Supreme authority'),
  SpaceRank(name: 'Fleet Marshal', requiredHours: 1000, description: 'Legendary status'),
  SpaceRank(name: 'Star Lord', requiredHours: 1500, description: 'Cosmic mastery'),
  SpaceRank(name: 'Celestial', requiredHours: 2000, description: 'Beyond mortal limits'),
];

// Provider for space progress
final spaceProgressProvider = StateNotifierProvider<SpaceProgressNotifier, SpaceProgressData>((ref) {
  return SpaceProgressNotifier(ref);
});

class SpaceProgressNotifier extends StateNotifier<SpaceProgressData> {
  final Ref ref;
  late Box _spaceBox;

  SpaceProgressNotifier(this.ref) : super(SpaceProgressData(
    totalFocusSeconds: 0,
    unspentFocusSeconds: 0,
    totalDistanceLightYears: 0.0,
    currentRank: 'Cadet',
    currentStarIndex: 0,
    unlockedStars: [],
  )) {
    _initializeSpace();
  }

  Future<void> _initializeSpace() async {
    _spaceBox = await Hive.openBox('space_progress');
    await _loadProgress();
  }

  Future<void> _loadProgress() async {
    final totalSeconds = _spaceBox.get('total_focus_seconds', defaultValue: 0);
    final unspentSeconds = _spaceBox.get('unspent_focus_seconds', defaultValue: 0);
    final distance = _spaceBox.get('total_distance_ly', defaultValue: 0.0);
    final starIndex = _spaceBox.get('current_star_index', defaultValue: 0);
    final unlockedStarsList = _spaceBox.get('unlocked_stars', defaultValue: <String>[]);

    state = SpaceProgressData(
      totalFocusSeconds: totalSeconds,
      unspentFocusSeconds: unspentSeconds,
      totalDistanceLightYears: distance,
      currentRank: _calculateRank(totalSeconds),
      currentStarIndex: starIndex,
      unlockedStars: List<String>.from(unlockedStarsList),
    );
  }

  String _calculateRank(int totalSeconds) {
    final totalHours = totalSeconds / 3600;
    
    // Find the highest rank the user has achieved
    SpaceRank currentRank = spaceRanks.first;
    for (final rank in spaceRanks) {
      if (totalHours >= rank.requiredHours) {
        currentRank = rank;
      } else {
        break;
      }
    }
    
    return currentRank.name;
  }

  // Add focus time (called when timer completes)
  Future<void> addFocusTime(int seconds) async {
    final newTotalSeconds = state.totalFocusSeconds + seconds;
    final newUnspentSeconds = state.unspentFocusSeconds + seconds;
    final newRank = _calculateRank(newTotalSeconds);

    state = state.copyWith(
      totalFocusSeconds: newTotalSeconds,
      unspentFocusSeconds: newUnspentSeconds,
      currentRank: newRank,
    );

    await _spaceBox.put('total_focus_seconds', newTotalSeconds);
    await _spaceBox.put('unspent_focus_seconds', newUnspentSeconds);
  }

  // Consume fuel (launch button pressed)
  Future<void> consumeFuel() async {
    if (state.unspentFocusSeconds <= 0) return;

    // Convert time to distance: 1 hour = 0.1 light years
    final hoursToConsume = state.unspentFocusSeconds / 3600.0;
    final distanceToAdd = hoursToConsume * 0.1;
    
    final newDistance = state.totalDistanceLightYears + distanceToAdd;
    
    // Check which star we've reached
    final starData = _checkStarProgress(newDistance);

    state = state.copyWith(
      unspentFocusSeconds: 0,
      totalDistanceLightYears: newDistance,
      currentStarIndex: starData['index'],
      unlockedStars: starData['unlocked'],
    );

    await _spaceBox.put('unspent_focus_seconds', 0);
    await _spaceBox.put('total_distance_ly', newDistance);
    await _spaceBox.put('current_star_index', starData['index']);
    await _spaceBox.put('unlocked_stars', starData['unlocked']);
  }

  Map<String, dynamic> _checkStarProgress(double currentDistance) {
    int newStarIndex = state.currentStarIndex;
    List<String> newUnlocked = List.from(state.unlockedStars);

    for (int i = 0; i < starSystems.length; i++) {
      if (currentDistance >= starSystems[i].distanceFromEarth) {
        if (i > newStarIndex) {
          newStarIndex = i;
        }
        if (!newUnlocked.contains(starSystems[i].name)) {
          newUnlocked.add(starSystems[i].name);
        }
      }
    }

    return {
      'index': newStarIndex,
      'unlocked': newUnlocked,
    };
  }

  // Get next rank info
  SpaceRank? getNextRank() {
    final currentHours = state.totalFocusSeconds / 3600;
    
    for (final rank in spaceRanks) {
      if (currentHours < rank.requiredHours) {
        return rank;
      }
    }
    
    return null; // Maximum rank achieved
  }

  // Get progress to next rank (0.0 to 1.0)
  double getProgressToNextRank() {
    final currentHours = state.totalFocusSeconds / 3600;
    
    SpaceRank? currentRankObj;
    SpaceRank? nextRankObj;
    
    for (int i = 0; i < spaceRanks.length; i++) {
      if (currentHours >= spaceRanks[i].requiredHours) {
        currentRankObj = spaceRanks[i];
        if (i + 1 < spaceRanks.length) {
          nextRankObj = spaceRanks[i + 1];
        }
      } else {
        break;
      }
    }
    
    if (currentRankObj == null || nextRankObj == null) {
      return 1.0; // Max rank
    }
    
    final progress = (currentHours - currentRankObj.requiredHours) /
        (nextRankObj.requiredHours - currentRankObj.requiredHours);
    
    return progress.clamp(0.0, 1.0);
  }

  // Get current star system
  StarSystem getCurrentStar() {
    if (state.currentStarIndex < starSystems.length) {
      return starSystems[state.currentStarIndex];
    }
    return starSystems.last;
  }

  // Get next star system
  StarSystem? getNextStar() {
    if (state.currentStarIndex + 1 < starSystems.length) {
      return starSystems[state.currentStarIndex + 1];
    }
    return null;
  }

  // Get progress to next star (0.0 to 1.0)
  double getProgressToNextStar() {
    final currentStar = getCurrentStar();
    final nextStar = getNextStar();
    
    if (nextStar == null) {
      return 1.0;
    }
    
    final progress = (state.totalDistanceLightYears - currentStar.distanceFromEarth) /
        (nextStar.distanceFromEarth - currentStar.distanceFromEarth);
    
    return progress.clamp(0.0, 1.0);
  }
}

// Star System Data Model
class StarSystem {
  final String name;
  final double distanceFromEarth; // in light years
  final String spectralType;
  final String description;
  final int focusHoursRequired;

  const StarSystem({
    required this.name,
    required this.distanceFromEarth,
    required this.spectralType,
    required this.description,
    required this.focusHoursRequired,
  });
}

// Real astronomical data with focus time conversion
// 1 Focus Hour = 0.1 Light Years
const List<StarSystem> starSystems = [
  StarSystem(
    name: 'Earth (Sol)',
    distanceFromEarth: 0,
    spectralType: 'G2V',
    description: 'Our home in the cosmos',
    focusHoursRequired: 0,
  ),
  StarSystem(
    name: 'Proxima Centauri',
    distanceFromEarth: 4.24,
    spectralType: 'M5.5Ve',
    description: 'Closest star to our solar system',
    focusHoursRequired: 42,
  ),
  StarSystem(
    name: 'Barnard\'s Star',
    distanceFromEarth: 5.96,
    spectralType: 'M4Ve',
    description: 'Second closest star system',
    focusHoursRequired: 60,
  ),
  StarSystem(
    name: 'Wolf 359',
    distanceFromEarth: 7.86,
    spectralType: 'M6V',
    description: 'One of the faintest stars',
    focusHoursRequired: 79,
  ),
  StarSystem(
    name: 'Sirius',
    distanceFromEarth: 8.6,
    spectralType: 'A1V',
    description: 'The brightest star in Earth\'s night sky',
    focusHoursRequired: 86,
  ),
  StarSystem(
    name: 'Epsilon Eridani',
    distanceFromEarth: 10.5,
    spectralType: 'K2V',
    description: 'Sun-like star with planetary system',
    focusHoursRequired: 105,
  ),
  StarSystem(
    name: 'Tau Ceti',
    distanceFromEarth: 11.9,
    spectralType: 'G8V',
    description: 'Similar to our Sun, potential habitable planets',
    focusHoursRequired: 119,
  ),
  StarSystem(
    name: 'Procyon',
    distanceFromEarth: 11.46,
    spectralType: 'F5IV-V',
    description: 'Eighth brightest star in the night sky',
    focusHoursRequired: 115,
  ),
  StarSystem(
    name: 'Vega',
    distanceFromEarth: 25.04,
    spectralType: 'A0Va',
    description: 'Brightest star in Lyra constellation',
    focusHoursRequired: 250,
  ),
  StarSystem(
    name: 'Altair',
    distanceFromEarth: 16.73,
    spectralType: 'A7V',
    description: 'One of the vertices of the Summer Triangle',
    focusHoursRequired: 167,
  ),
  StarSystem(
    name: 'Fomalhaut',
    distanceFromEarth: 25.13,
    spectralType: 'A3V',
    description: 'The loneliest star, has a debris disk',
    focusHoursRequired: 251,
  ),
  StarSystem(
    name: 'Arcturus',
    distanceFromEarth: 36.7,
    spectralType: 'K0III',
    description: 'Fourth brightest star, red giant',
    focusHoursRequired: 367,
  ),
  StarSystem(
    name: 'Aldebaran',
    distanceFromEarth: 65.3,
    spectralType: 'K5III',
    description: 'The eye of Taurus, orange giant',
    focusHoursRequired: 653,
  ),
  StarSystem(
    name: 'Pollux',
    distanceFromEarth: 33.78,
    spectralType: 'K0III',
    description: 'Brighter twin of Gemini, has a planet',
    focusHoursRequired: 338,
  ),
  StarSystem(
    name: 'Betelgeuse',
    distanceFromEarth: 548,
    spectralType: 'M1-2Ia-ab',
    description: 'Red supergiant in Orion, may go supernova',
    focusHoursRequired: 5480,
  ),
  StarSystem(
    name: 'Rigel',
    distanceFromEarth: 860,
    spectralType: 'B8Ia',
    description: 'Blue supergiant, brightest star in Orion',
    focusHoursRequired: 8600,
  ),
  StarSystem(
    name: 'Antares',
    distanceFromEarth: 550,
    spectralType: 'M1.5Iab-Ib',
    description: 'Red supergiant, heart of Scorpius',
    focusHoursRequired: 5500,
  ),
  StarSystem(
    name: 'Deneb',
    distanceFromEarth: 2615,
    spectralType: 'A2Ia',
    description: 'One of the most luminous stars known',
    focusHoursRequired: 26150,
  ),
];