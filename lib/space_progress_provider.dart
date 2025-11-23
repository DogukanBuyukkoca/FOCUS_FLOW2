import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:async';

// Space Progress Data Model
class SpaceProgressData {
  final int totalFocusSeconds;
  final int unspentFocusSeconds;
  final int currentStarIndex;
  final List<String> unlockedStars;
  final String currentRank;

  SpaceProgressData({
    required this.totalFocusSeconds,
    required this.unspentFocusSeconds,
    required this.currentStarIndex,
    required this.unlockedStars,
    required this.currentRank,
  });

  SpaceProgressData copyWith({
    int? totalFocusSeconds,
    int? unspentFocusSeconds,
    int? currentStarIndex,
    List<String>? unlockedStars,
    String? currentRank,
  }) {
    return SpaceProgressData(
      totalFocusSeconds: totalFocusSeconds ?? this.totalFocusSeconds,
      unspentFocusSeconds: unspentFocusSeconds ?? this.unspentFocusSeconds,
      currentStarIndex: currentStarIndex ?? this.currentStarIndex,
      unlockedStars: unlockedStars ?? this.unlockedStars,
      currentRank: currentRank ?? this.currentRank,
    );
  }
}

// Space Rank Model
class SpaceRank {
  final String name;
  final int requiredSeconds;
  final String description;

  const SpaceRank({
    required this.name,
    required this.requiredSeconds,
    required this.description,
  });
}

// Rank sistemi (Uzay Edebiyatı referansları)
const List<SpaceRank> spaceRanks = [
  SpaceRank(name: 'Cadet', requiredSeconds: 0, description: 'Yeni başlayan'),
  SpaceRank(name: 'Ensign', requiredSeconds: 36000, description: '10 saat odaklanma'),
  SpaceRank(name: 'Lieutenant', requiredSeconds: 90000, description: '25 saat odaklanma'),
  SpaceRank(name: 'Commander', requiredSeconds: 180000, description: '50 saat odaklanma'),
  SpaceRank(name: 'Captain', requiredSeconds: 360000, description: '100 saat odaklanma'),
  SpaceRank(name: 'Admiral', requiredSeconds: 900000, description: '250 saat odaklanma'),
  SpaceRank(name: 'Fleet Admiral', requiredSeconds: 1800000, description: '500 saat odaklanma'),
];

// Star System Model
class StarSystem {
  final String name;
  final int focusSecondsRequired; // Gerekli odaklanma süresi (saniye)
  final String spectralType;
  final String description;

  const StarSystem({
    required this.name,
    required this.focusSecondsRequired,
    required this.spectralType,
    required this.description,
  });
  
  // Süreyi formatlanmış string olarak döndür
  String get formattedDuration {
    final hours = focusSecondsRequired ~/ 3600;
    final minutes = (focusSecondsRequired % 3600) ~/ 60;
    
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }
}

// Yıldız sistemleri - Progresif zorluk sistemi
// Başlangıç: 30dk-2 saat
// Orta: 3-8 saat  
// İleri: 10-12 saat
const List<StarSystem> starSystems = [
  StarSystem(
    name: 'Earth (Sol)',
    focusSecondsRequired: 0,
    spectralType: 'G2V',
    description: 'Our home in the cosmos',
  ),
  StarSystem(
    name: 'Moon',
    focusSecondsRequired: 1800, // 30 dakika
    spectralType: 'Satellite',
    description: 'First small step',
  ),
  StarSystem(
    name: 'Mars',
    focusSecondsRequired: 3600, // 1 saat
    spectralType: 'Red Planet',
    description: 'The red frontier',
  ),
  StarSystem(
    name: 'Jupiter',
    focusSecondsRequired: 5400, // 1.5 saat
    spectralType: 'Gas Giant',
    description: 'Giant leap forward',
  ),
  StarSystem(
    name: 'Saturn',
    focusSecondsRequired: 7200, // 2 saat
    spectralType: 'Ringed Beauty',
    description: 'Ring of discipline',
  ),
  StarSystem(
    name: 'Uranus',
    focusSecondsRequired: 10800, // 3 saat
    spectralType: 'Ice Giant',
    description: 'Pushing boundaries',
  ),
  StarSystem(
    name: 'Neptune',
    focusSecondsRequired: 12600, // 3.5 saat
    spectralType: 'Deep Blue',
    description: 'Deep commitment',
  ),
  StarSystem(
    name: 'Pluto',
    focusSecondsRequired: 14400, // 4 saat
    spectralType: 'Dwarf Planet',
    description: 'Beyond the ordinary',
  ),
  StarSystem(
    name: 'Proxima Centauri',
    focusSecondsRequired: 18000, // 5 saat
    spectralType: 'M5.5Ve',
    description: 'Nearest star reached',
  ),
  StarSystem(
    name: 'Alpha Centauri A',
    focusSecondsRequired: 21600, // 6 saat
    spectralType: 'G2V',
    description: 'Sister sun discovered',
  ),
  StarSystem(
    name: 'Barnard\'s Star',
    focusSecondsRequired: 23400, // 6.5 saat
    spectralType: 'M4Ve',
    description: 'Red dwarf mastered',
  ),
  StarSystem(
    name: 'Sirius',
    focusSecondsRequired: 25200, // 7 saat
    spectralType: 'A1V',
    description: 'Brightest star unlocked',
  ),
  StarSystem(
    name: 'Epsilon Eridani',
    focusSecondsRequired: 27000, // 7.5 saat
    spectralType: 'K2V',
    description: 'Young star reached',
  ),
  StarSystem(
    name: 'Vega',
    focusSecondsRequired: 28800, // 8 saat
    spectralType: 'A0V',
    description: 'Blue-white beauty',
  ),
  StarSystem(
    name: 'Arcturus',
    focusSecondsRequired: 30600, // 8.5 saat
    spectralType: 'K0III',
    description: 'Orange giant achieved',
  ),
  StarSystem(
    name: 'Betelgeuse',
    focusSecondsRequired: 32400, // 9 saat
    spectralType: 'M1-2Ia-Iab',
    description: 'Red supergiant',
  ),
  StarSystem(
    name: 'Rigel',
    focusSecondsRequired: 34200, // 9.5 saat
    spectralType: 'B8Ia',
    description: 'Blue supergiant reached',
  ),
  StarSystem(
    name: 'Polaris',
    focusSecondsRequired: 36000, // 10 saat
    spectralType: 'F7Ib',
    description: 'North Star found',
  ),
  StarSystem(
    name: 'Deneb',
    focusSecondsRequired: 43200, // 12 saat
    spectralType: 'A2Ia',
    description: 'Distant supergiant',
  ),
];

// Provider
final spaceProgressProvider = StateNotifierProvider<SpaceProgressNotifier, SpaceProgressData>((ref) {
  return SpaceProgressNotifier();
});

class SpaceProgressNotifier extends StateNotifier<SpaceProgressData> {
  late Box _spaceBox;
  
  SpaceProgressNotifier() : super(SpaceProgressData(
    totalFocusSeconds: 0,
    unspentFocusSeconds: 0,
    currentStarIndex: 0,
    unlockedStars: ['Earth (Sol)'],
    currentRank: 'Cadet',
  )) {
    _initializeData();
  }

  Future<void> _initializeData() async {
    _spaceBox = await Hive.openBox('space_progress');
    
    final totalFocus = _spaceBox.get('total_focus_seconds', defaultValue: 0) as int;
    final unspentFocus = _spaceBox.get('unspent_focus_seconds', defaultValue: 0) as int;
    final starIndex = _spaceBox.get('current_star_index', defaultValue: 0) as int;
    final unlocked = (_spaceBox.get('unlocked_stars', defaultValue: ['Earth (Sol)']) as List).cast<String>();
    
    state = SpaceProgressData(
      totalFocusSeconds: totalFocus,
      unspentFocusSeconds: unspentFocus,
      currentStarIndex: starIndex,
      unlockedStars: unlocked,
      currentRank: _calculateRank(totalFocus),
    );
  }

  String _calculateRank(int totalSeconds) {
    String rankName = 'Cadet';
    
    for (final rank in spaceRanks.reversed) {
      if (totalSeconds >= rank.requiredSeconds) {
        rankName = rank.name;
        break;
      }
    }
    
    return rankName;
  }

  // Odaklanma süresi ekle
  Future<void> addFocusTime(int seconds) async {
    final newTotal = state.totalFocusSeconds + seconds;
    final newUnspent = state.unspentFocusSeconds + seconds;
    final newRank = _calculateRank(newTotal);
    
    // Yıldız ilerlemesini kontrol et
    final starData = _checkStarProgress(newTotal);

    state = state.copyWith(
      totalFocusSeconds: newTotal,
      unspentFocusSeconds: newUnspent,
      currentRank: newRank,
      currentStarIndex: starData['index'],
      unlockedStars: starData['unlocked'],
    );

    await _spaceBox.put('total_focus_seconds', newTotal);
    await _spaceBox.put('unspent_focus_seconds', newUnspent);
    await _spaceBox.put('current_star_index', starData['index']);
    await _spaceBox.put('unlocked_stars', starData['unlocked']);
  }

  // Yakıt harca (roket fırlatma)
  Future<void> consumeFuelAnimated(Function(int) onUpdate) async {
    final startingFuel = state.unspentFocusSeconds;
    
    if (startingFuel <= 0) return;

    // 5 saniyelik animasyon
    const totalFrames = 60;
    const frameDurationMs = 83; // ~60 FPS
    
    for (int i = 0; i <= totalFrames; i++) {
      await Future.delayed(const Duration(milliseconds: frameDurationMs));
      
      // Ease-out cubic easing
      double progress = i / totalFrames;
      progress = 1 - (1 - progress) * (1 - progress) * (1 - progress);
      
      int remainingFuel = (startingFuel * (1 - progress)).round();
      
      state = state.copyWith(unspentFocusSeconds: remainingFuel);
      onUpdate(remainingFuel);
    }
    
    // Animasyon bittiğinde final değerleri kaydet
    state = state.copyWith(unspentFocusSeconds: 0);
    await _spaceBox.put('unspent_focus_seconds', 0);
  }

  Map<String, dynamic> _checkStarProgress(int currentFocusSeconds) {
    int newStarIndex = state.currentStarIndex;
    List<String> newUnlocked = List.from(state.unlockedStars);

    for (int i = 0; i < starSystems.length; i++) {
      if (currentFocusSeconds >= starSystems[i].focusSecondsRequired) {
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

  // Sonraki rütbeyi getir
  SpaceRank? getNextRank() {
    final currentSeconds = state.totalFocusSeconds;
    
    for (final rank in spaceRanks) {
      if (currentSeconds < rank.requiredSeconds) {
        return rank;
      }
    }
    
    return null; // Maksimum rütbeye ulaşıldı
  }

  // Sonraki rütbeye ilerleme (0.0 - 1.0)
  double getProgressToNextRank() {
    final currentSeconds = state.totalFocusSeconds;
    
    SpaceRank? currentRankObj;
    SpaceRank? nextRank;
    
    for (int i = 0; i < spaceRanks.length; i++) {
      if (currentSeconds >= spaceRanks[i].requiredSeconds) {
        currentRankObj = spaceRanks[i];
      } else {
        nextRank = spaceRanks[i];
        break;
      }
    }
    
    if (nextRank == null || currentRankObj == null) {
      return 1.0; // Maksimum seviyede
    }
    
    final rangeSeconds = nextRank.requiredSeconds - currentRankObj.requiredSeconds;
    final progressSeconds = currentSeconds - currentRankObj.requiredSeconds;
    
    return (progressSeconds / rangeSeconds).clamp(0.0, 1.0);
  }

  // Sonraki yıldıza ilerleme (0.0 - 1.0)
  double getProgressToNextStar() {
    if (state.currentStarIndex >= starSystems.length - 1) {
      return 1.0; // Son yıldıza ulaşıldı
    }

    final currentStar = starSystems[state.currentStarIndex];
    final nextStar = starSystems[state.currentStarIndex + 1];
    
    final rangeSeconds = nextStar.focusSecondsRequired - currentStar.focusSecondsRequired;
    final progressSeconds = state.totalFocusSeconds - currentStar.focusSecondsRequired;
    
    return (progressSeconds / rangeSeconds).clamp(0.0, 1.0);
  }

  // Data'yı sıfırla (test için)
  Future<void> resetProgress() async {
    state = SpaceProgressData(
      totalFocusSeconds: 0,
      unspentFocusSeconds: 0,
      currentStarIndex: 0,
      unlockedStars: ['Earth (Sol)'],
      currentRank: 'Cadet',
    );

    await _spaceBox.clear();
    await _spaceBox.put('total_focus_seconds', 0);
    await _spaceBox.put('unspent_focus_seconds', 0);
    await _spaceBox.put('current_star_index', 0);
    await _spaceBox.put('unlocked_stars', ['Earth (Sol)']);
  }
}