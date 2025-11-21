import 'package:hive_flutter/hive_flutter.dart';
import 'models.dart';
import 'hive_adapters.dart';

class StorageServices {
  static const String goalsBoxName = 'goals';
  static const String settingsBoxName = 'settings';
  static late Box _preferencesBox;
  static late Box _sessionsBox;
  static late Box _goalsBox;
   static late Box<Goal> goalsBox;
   static late Box settingsBox;
  
  // Initialize Hive and register adapters
  static Future<void> initialize() async {
    await Hive.initFlutter();
    _preferencesBox = await Hive.openBox('preferences');
    _sessionsBox = await Hive.openBox('sessions');
    _goalsBox = await Hive.openBox('goals');
    
    // YENİ: Uzay ilerleme box'ı
    await Hive.openBox('space_progress');
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(GoalAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(SubTaskAdapter());
    }
    
    // Open boxes
    goalsBox = await Hive.openBox<Goal>(goalsBoxName);
    settingsBox = await Hive.openBox(settingsBoxName);
  }

  // Goals Operations
  static Future<List<Goal>> getAllGoals() async {
    return goalsBox.values.toList();
  }
  
  static Future<void> saveGoal(Goal goal) async {
    await goalsBox.put(goal.id, goal);
  }
  
  static Future<void> deleteGoal(String id) async {
    await goalsBox.delete(id);
  }
  
  static Future<void> updateGoal(Goal goal) async {
    await goalsBox.put(goal.id, goal);
  }
  
  static Goal? getGoal(String id) {
    return goalsBox.get(id);
  }
  
  static Future<void> clearAllGoals() async {
    await goalsBox.clear();
  }
  
  // Settings Operations
  static Future<void> saveSetting(String key, dynamic value) async {
    await settingsBox.put(key, value);
  }
  
  static dynamic getSetting(String key) {
    return settingsBox.get(key);
  }
  
  static Future<void> deleteSetting(String key) async {
    await settingsBox.delete(key);
  }
  
  // Listen to goals changes
  static Stream<BoxEvent> watchGoals() {
    return goalsBox.watch();
  }
}