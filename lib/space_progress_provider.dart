import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Space Progress Data Model
class SpaceProgressData {
  final int totalFocusSeconds; // Hiç sıfırlanmayan toplam odaklanma süresi
  final int unspentFocusSeconds; // Harcanmamış yakıt (launch'tan sonra sıfırlanır)
  final double totalDistanceLightYears; // Toplam kat edilen mesafe
  final String currentRank; // Mevcut rütbe
  final int currentStarIndex; // Hangi yıldıza ulaşıldı
  final List<String> unlockedStars; // Kilidi açılan yıldızlar

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

// Space Rank Model
class SpaceRank {
  final String name;
  final double requiredHours;
  final String description;

  const SpaceRank({
    required this.name,
    required this.requiredHours,
    required this.description,
  });
}

// Rank sistemi (Uzay Edebiyatı referansları)
const List<SpaceRank> spaceRanks = [
  SpaceRank(name: 'Cadet', requiredHours: 0, description: 'Yeni başlayan'),
  SpaceRank(name: 'Ensign', requiredHours: 10, description: '10 saat odaklanma'),
  SpaceRank(name: 'Lieutenant', requiredHours: 25, description: '25 saat odaklanma'),
  SpaceRank(name: 'Commander', requiredHours: 50, description: '50 saat odaklanma'),
  SpaceRank(name: 'Captain', requiredHours: 100, description: '100 saat odaklanma'),
  SpaceRank(name: 'Admiral', requiredHours: 250, description: '250 saat odaklanma'),
  SpaceRank(name: 'Fleet Admiral', requiredHours: 500, description: '500 saat odaklanma'),
];

// Star System Model
class StarSystem {
  final String name;
  final double distanceFromEarth; // Light years
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

// Yıldız sistemleri (1 saat = 0.1 light year)
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
    description: 'En yakın yıldız - 42.4 saat odaklanma',
    focusHoursRequired: 42,
  ),
  StarSystem(
    name: 'Sirius',
    distanceFromEarth: 8.6,
    spectralType: 'A1V',
    description: 'Gökyüzünün en parlak yıldızı - 86 saat',
    focusHoursRequired: 86,
  ),
  StarSystem(
    name: 'Vega',
    distanceFromEarth: 25,
    spectralType: 'A0Va',
    description: 'Lyra takımyıldızı - 250 saat',
    focusHoursRequired: 250,
  ),
  StarSystem(
    name: 'Arcturus',
    distanceFromEarth: 37,
    spectralType: 'K0III',
    description: 'Kırmızı dev yıldız - 370 saat',
    focusHoursRequired: 370,
  ),
  StarSystem(
    name: 'Betelgeuse',
    distanceFromEarth: 642,
    spectralType: 'M1-2Ia-ab',
    description: 'Süper dev yıldız - 6420 saat',
    focusHoursRequired: 6420,
  ),
];

// Space Progress Provider
final spaceProgressProvider = StateNotifierProvider<SpaceProgressNotifier, SpaceProgressData>((ref) {
  return SpaceProgressNotifier();
});

class SpaceProgressNotifier extends StateNotifier<SpaceProgressData> {
  late Box _spaceBox;

  SpaceProgressNotifier() : super(SpaceProgressData(
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

  // Timer'dan her saniye çağrılacak - SADECE ekleme yapar
  Future<void> addFocusTime(int seconds) async {
    final newTotalSeconds = state.totalFocusSeconds + seconds;
    final newUnspentSeconds = state.unspentFocusSeconds + seconds;
    final newRank = _calculateRank(newTotalSeconds);

    state = state.copyWith(
      totalFocusSeconds: newTotalSeconds,
      unspentFocusSeconds: newUnspentSeconds,
      currentRank: newRank,
    );

    // Hive'a kaydet
    await _spaceBox.put('total_focus_seconds', newTotalSeconds);
    await _spaceBox.put('unspent_focus_seconds', newUnspentSeconds);
  }

  // Launch butonu için - Animasyonlu yakıt tüketimi
  Future<void> consumeFuelAnimated(Function(int) onUpdate) async {
    if (state.unspentFocusSeconds <= 0) return;

    final startingFuel = state.unspentFocusSeconds;
    final hoursToConsume = startingFuel / 3600.0;
    final distanceToAdd = hoursToConsume * 0.1;
    
    // 5 saniye boyunca animasyon (60 FPS = 300 frame)
    const int totalFrames = 300;
    const int frameDurationMs = 16; // ~60 FPS
    
    for (int i = 0; i <= totalFrames; i++) {
      await Future.delayed(const Duration(milliseconds: frameDurationMs));
      
      // Ease-out cubic easing function
      double progress = i / totalFrames;
      progress = 1 - (1 - progress) * (1 - progress) * (1 - progress);
      
      // Kalan yakıtı hesapla
      int remainingFuel = (startingFuel * (1 - progress)).round();
      
      // State'i güncelle (sadece UI için, henüz Hive'a kaydetme)
      state = state.copyWith(
        unspentFocusSeconds: remainingFuel,
      );
      
      // Callback ile UI'ı bilgilendir
      onUpdate(remainingFuel);
    }
    
    // Animasyon bittiğinde final değerleri kaydet
    final newDistance = state.totalDistanceLightYears + distanceToAdd;
    final starData = _checkStarProgress(newDistance);

    state = state.copyWith(
      unspentFocusSeconds: 0,
      totalDistanceLightYears: newDistance,
      currentStarIndex: starData['index'],
      unlockedStars: starData['unlocked'],
    );

    // Hive'a son durumu kaydet
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

  // Sonraki rütbeyi getir
  SpaceRank? getNextRank() {
    final currentHours = state.totalFocusSeconds / 3600;
    
    for (final rank in spaceRanks) {
      if (currentHours < rank.requiredHours) {
        return rank;
      }
    }
    
    return null; // Maksimum rütbeye ulaşıldı
  }

  // Sonraki rütbeye ilerleme (0.0 - 1.0)
  double getProgressToNextRank() {
    final currentHours = state.totalFocusSeconds / 3600;
    
    SpaceRank? currentRankObj;
    SpaceRank? nextRank;
    
    for (int i = 0; i < spaceRanks.length; i++) {
      if (currentHours >= spaceRanks[i].requiredHours) {
        currentRankObj = spaceRanks[i];
      } else {
        nextRank = spaceRanks[i];
        break;
      }
    }
    
    if (nextRank == null) return 1.0; // Maksimum rütbe
    if (currentRankObj == null) return 0.0;
    
    final rangeHours = nextRank.requiredHours - currentRankObj.requiredHours;
    final progressHours = currentHours - currentRankObj.requiredHours;
    
    return (progressHours / rangeHours).clamp(0.0, 1.0);
  }

  // Mevcut yıldız sistemini getir
  StarSystem getCurrentStar() {
    if (state.currentStarIndex < starSystems.length) {
      return starSystems[state.currentStarIndex];
    }
    return starSystems.last;
  }

  // Sonraki yıldıza mesafe
  StarSystem? getNextStar() {
    if (state.currentStarIndex >= starSystems.length - 1) {
      return null; // Son yıldızdasın
    }
    return starSystems[state.currentStarIndex + 1];
  }

  // Sonraki yıldıza ilerleme
  double getProgressToNextStar() {
    final nextStar = getNextStar();
    if (nextStar == null) return 1.0;
    
    final currentStar = starSystems[state.currentStarIndex];
    final range = nextStar.distanceFromEarth - currentStar.distanceFromEarth;
    final progress = state.totalDistanceLightYears - currentStar.distanceFromEarth;
    
    return (progress / range).clamp(0.0, 1.0);
  }
}