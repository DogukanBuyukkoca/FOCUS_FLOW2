import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:math';

// ============================================================================
// SMART NOTIFICATION SERVICE
// Kullanıcı davranışlarına dayalı akıllı bildirim yönetim sistemi
// ============================================================================

class SmartNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static late Box _behaviorBox;
  static late Box _notificationBox;

  // Notification IDs
  static const int _habitReminderId = 100;
  static const int _threeDayWarningId = 101;
  static const int _sevenDayFinalId = 102;
  static const int _morningRoutineId = 103;
  static const int _afternoonSlumpId = 104;
  static const int _dangerZoneId = 105;
  static const int _randomMotivationBaseId = 200; // 200-299 arası

  // ============================================================================
  // INITIALIZATION
  // ============================================================================

  static Future<void> init() async {
    // Initialize timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));

    // Initialize Hive boxes
    _behaviorBox = await Hive.openBox('user_behavior');
    _notificationBox = await Hive.openBox('notifications');

    // Configure notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );

    // Request permissions
    await _requestPermissions();

    // Initialize notification channels
    await _createNotificationChannels();
  }

  static Future<void> _requestPermissions() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();

    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static Future<void> _createNotificationChannels() async {
    const habitChannel = AndroidNotificationChannel(
      'habit_reminders',
      'Alışkanlık Hatırlatıcıları',
      description: '24 saatlik düzenli hatırlatmalar',
      importance: Importance.defaultImportance,
      playSound: true,
    );

    const urgentChannel = AndroidNotificationChannel(
      'urgent_reminders',
      'Acil Hatırlatmalar',
      description: 'Seri kurtarma ve önemli bildirimler',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    const motivationChannel = AndroidNotificationChannel(
      'motivation',
      'Motivasyon Mesajları',
      description: 'Günlük motivasyon bildirimleri',
      importance: Importance.low,
      playSound: false,
    );

    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(habitChannel);
    await androidPlugin?.createNotificationChannel(urgentChannel);
    await androidPlugin?.createNotificationChannel(motivationChannel);
  }

  static void _handleNotificationTap(NotificationResponse details) {
    // Handle notification interaction
    // Bu fonksiyon bildirime tıklandığında tetiklenir
    // Gerekirse belirli sayfaya yönlendirme yapılabilir
  }

  // ============================================================================
  // USER BEHAVIOR TRACKING
  // ============================================================================

  /// Kullanıcı uygulamayı açtığında çağrılır
  static Future<void> trackAppOpen() async {
    final now = DateTime.now();

    // Son açılış zamanını kaydet
    await _behaviorBox.put('last_app_open', now.toIso8601String());

    // Açılış geçmişine ekle
    List<String> openHistory = List<String>.from(
      _behaviorBox.get('app_open_history', defaultValue: [])
    );
    openHistory.add(now.toIso8601String());

    // Son 30 günü tut
    if (openHistory.length > 90) {
      openHistory = openHistory.sublist(openHistory.length - 90);
    }
    await _behaviorBox.put('app_open_history', openHistory);

    // Favori saat analizi için
    await _behaviorBox.put('last_open_hour', now.hour);

    // Bildirimleri yeniden planla
    await scheduleAllNotifications();
  }

  /// Kullanıcı Pomodoro başlattığında çağrılır
  static Future<void> trackSessionStart() async {
    final now = DateTime.now();
    await _behaviorBox.put('last_session_start', now.toIso8601String());

    // Session geçmişi
    List<String> sessionHistory = List<String>.from(
      _behaviorBox.get('session_history', defaultValue: [])
    );
    sessionHistory.add(now.toIso8601String());
    await _behaviorBox.put('session_history', sessionHistory);
  }

  /// Son uygulama açılışından bu yana geçen süreyi hesaplar
  static Duration _timeSinceLastOpen() {
    final lastOpenStr = _behaviorBox.get('last_app_open');
    if (lastOpenStr == null) return Duration.zero;

    final lastOpen = DateTime.parse(lastOpenStr);
    return DateTime.now().difference(lastOpen);
  }

  /// Bugün uygulama açıldı mı?
  static bool _wasAppOpenedToday() {
    final lastOpenStr = _behaviorBox.get('last_app_open');
    if (lastOpenStr == null) return false;

    final lastOpen = DateTime.parse(lastOpenStr);
    final now = DateTime.now();

    return lastOpen.year == now.year &&
           lastOpen.month == now.month &&
           lastOpen.day == now.day;
  }

  /// Kullanıcının favori açılış saatini hesaplar
  static int _getFavoriteOpenHour() {
    List<String> history = List<String>.from(
      _behaviorBox.get('app_open_history', defaultValue: [])
    );

    if (history.isEmpty) return 9; // Default: 09:00

    // Son 7 günün saatlerini analiz et
    Map<int, int> hourFrequency = {};
    final now = DateTime.now();

    for (var timeStr in history) {
      final time = DateTime.parse(timeStr);
      final diff = now.difference(time);

      // Son 7 günü değerlendir
      if (diff.inDays <= 7) {
        hourFrequency[time.hour] = (hourFrequency[time.hour] ?? 0) + 1;
      }
    }

    if (hourFrequency.isEmpty) return 9;

    // En sık açılan saati bul
    int maxHour = 9;
    int maxCount = 0;

    hourFrequency.forEach((hour, count) {
      if (count > maxCount) {
        maxCount = count;
        maxHour = hour;
      }
    });

    return maxHour;
  }

  // ============================================================================
  // NOTIFICATION SCHEDULING - TÜM BİLDİRİMLERİ PLANLA
  // ============================================================================

  static Future<void> scheduleAllNotifications() async {
    // Önce tüm eski bildirimleri iptal et
    await cancelAllScheduledNotifications();

    final timeSinceOpen = _timeSinceLastOpen();
    final daysSinceOpen = timeSinceOpen.inDays;

    // 1. KURAL: 24 Saatlik Alışkanlık Hatırlatıcısı
    if (daysSinceOpen < 3) {
      await _schedule24HourReminder();
    }

    // 2. KURAL: 3 Gün Yokluk Uyarısı
    if (daysSinceOpen >= 3 && daysSinceOpen < 7) {
      await _scheduleThreeDayWarning();
    }

    // 3. KURAL: 7 Gün Yokluk - Final Mesajı
    if (daysSinceOpen >= 7) {
      await _scheduleSevenDayFinalMessage();
    }

    // 4-6. KURALLAR: Günlük Zaman Bazlı Bildirimler
    await _scheduleMorningRoutine();
    await _scheduleAfternoonSlump();
    await _scheduleDangerZone();

    // 7. KURAL: Rastgele Motivasyon Mesajları
    await _scheduleRandomMotivation();
  }

  // ============================================================================
  // 1. KURAL: 24 SAATLİK ALIŞKANLIK HATIRLATICISI
  // ============================================================================

  static Future<void> _schedule24HourReminder() async {
    final lastOpenStr = _behaviorBox.get('last_app_open');
    if (lastOpenStr == null) return;

    final lastOpen = DateTime.parse(lastOpenStr);
    final reminderTime = lastOpen.add(const Duration(hours: 24));

    // Geçmiş bir zaman ise, bir sonraki güne ertele
    if (reminderTime.isBefore(DateTime.now())) {
      return;
    }

    await _notifications.zonedSchedule(
      _habitReminderId,
      '⏰ Günlük Odaklanma Zamanı',
      _get24HourReminderMessage(),
      tz.TZDateTime.from(reminderTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'habit_reminders',
          'Alışkanlık Hatırlatıcıları',
          channelDescription: '24 saatlik düzenli hatırlatmalar',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          styleInformation: BigTextStyleInformation(''),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static String _get24HourReminderMessage() {
    final messages = [
      'Dün bu saatte harika bir seans yaptın. Bugün de aynı enerjiye hazır mısın?',
      'Günlük rutinin seni bekliyor. Küçük adımlar, büyük değişimler yaratır.',
      'Alışkanlıkların bugün de devam etmeyi bekliyor. Başlamaya hazır mısın?',
      'Her gün aynı saatte odaklanmak, başarının anahtarı. Devam edelim mi?',
      'Dünkü başarını bugün de tekrarlamak için mükemmel bir zaman.',
    ];
    return messages[Random().nextInt(messages.length)];
  }

  // ============================================================================
  // 2. KURAL: 3 GÜN YOKLUK UYARISI
  // ============================================================================

  static Future<void> _scheduleThreeDayWarning() async {
    final now = DateTime.now();
    final favoriteHour = _getFavoriteOpenHour();

    // Kullanıcının favori saatinde bildirim gönder
    var scheduledTime = DateTime(now.year, now.month, now.day, favoriteHour);

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      _threeDayWarningId,
      '💔 Özledik...',
      _getThreeDayWarningMessage(),
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'urgent_reminders',
          'Acil Hatırlatmalar',
          channelDescription: 'Seri kurtarma ve önemli bildirimler',
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(''),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static String _getThreeDayWarningMessage() {
    final messages = [
      'Sanırım ayrıldık... 3 gün oldu aramızda. Geri dönmeyi düşünür müsün?',
      'Serimiz yarım kaldı. Bunu birlikte bitirmek istemez misin?',
      'Hey, neredesin? 3 gündür yokluğunu hissediyoruz.',
      'Hedeflerine bu kadar yakınken bırakmak olmaz. Hadi, dön.',
      'Seni üç gündür bekliyorum. Belki küçük bir başlangıç yapabiliriz?',
    ];
    return messages[Random().nextInt(messages.length)];
  }

  // ============================================================================
  // 3. KURAL: 7 GÜN YOKLUK - FİNAL MESAJI (TERS PSİKOLOJİ)
  // ============================================================================

  static Future<void> _scheduleSevenDayFinalMessage() async {
    final now = DateTime.now();
    final favoriteHour = _getFavoriteOpenHour();

    var scheduledTime = DateTime(now.year, now.month, now.day, favoriteHour);

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      _sevenDayFinalId,
      '🤝 Son Mesaj',
      _getSevenDayFinalMessage(),
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'urgent_reminders',
          'Acil Hatırlatmalar',
          channelDescription: 'Seri kurtarma ve önemli bildirimler',
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(''),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static String _getSevenDayFinalMessage() {
    final messages = [
      'Seni rahatsız etmeyi bırakıyorum. Belki de bu senin için doğru uygulama değildi.',
      'Anladım. Artık bildirim göndermeyeceğim. Başarılar dilerim.',
      'Tamam, mesajı aldım. Senin kararına saygı duyuyorum. Elveda.',
      'Son bir kez daha deneyecek misin? Yoksa bu vedamız mı?',
      'Artık rahatsız etmeyeceğim. Ama kapı her zaman açık, hatırla.',
    ];
    return messages[Random().nextInt(messages.length)];
  }

  // ============================================================================
  // 4. KURAL: SABAH RUTİNİ (08:30 - 09:00)
  // ============================================================================

  static Future<void> _scheduleMorningRoutine() async {
    final now = DateTime.now();

    // Random saat seç: 08:30 - 09:00 arası
    final random = Random();
    final minute = 30 + random.nextInt(31); // 30-60 arası

    var scheduledTime = DateTime(now.year, now.month, now.day, 8, minute);

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      _morningRoutineId,
      '☀️ Günaydın!',
      _getMorningMessage(),
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'motivation',
          'Motivasyon Mesajları',
          channelDescription: 'Günlük motivasyon bildirimleri',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          styleInformation: BigTextStyleInformation(''),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: false,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static String _getMorningMessage() {
    final messages = [
      'Bugünün hedeflerini belirledin mi? İlk Pomodoro\'yu başlat.',
      'Güne odaklanarak başlamak, başarıya giden en kısa yol.',
      'Sabahın altın saatleri. Bu enerjiyi değerlendirmeye ne dersin?',
      'Yeni bir gün, yeni fırsatlar. İlk seansını planladın mı?',
      'Günün en produktif saatleri şimdi. Hazır mısın?',
    ];
    return messages[Random().nextInt(messages.length)];
  }

  // ============================================================================
  // 5. KURAL: ÖĞLEDEN SONRA ÇÖKÜŞÜ (14:00 - 15:00)
  // ============================================================================

  static Future<void> _scheduleAfternoonSlump() async {
    final now = DateTime.now();

    // Random saat seç: 14:00 - 15:00 arası
    final random = Random();
    final minute = random.nextInt(60);

    var scheduledTime = DateTime(now.year, now.month, now.day, 14, minute);

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      _afternoonSlumpId,
      '⚡ Enerji Takviyesi',
      _getAfternoonMessage(),
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'motivation',
          'Motivasyon Mesajları',
          channelDescription: 'Günlük motivasyon bildirimleri',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          styleInformation: BigTextStyleInformation(''),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: false,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static String _getAfternoonMessage() {
    final messages = [
      'Öğle rehavetini atmanın en iyi yolu: Kısa bir odaklanma seansı.',
      'Öğleden sonra enerjin düştü mü? Bir Pomodoro seni toparlayabilir.',
      'Günün en zor saatleri. Ama sen bunun üstesinden gelebilirsin.',
      'Kahve molası değil, odaklanma molası zamanı!',
      'Öğleden sonra yorgunluğunu 25 dakikalık fokusla yen.',
    ];
    return messages[Random().nextInt(messages.length)];
  }

  // ============================================================================
  // 6. KURAL: TEHLİKE BÖLGESİ (21:00 - 22:00) - SADECE BUGÜN AÇILMADIYSA
  // ============================================================================

  static Future<void> _scheduleDangerZone() async {
    // Bugün uygulama açıldıysa bu bildirimi gönderme
    if (_wasAppOpenedToday()) return;

    final now = DateTime.now();

    // Random saat seç: 21:00 - 22:00 arası
    final random = Random();
    final minute = random.nextInt(60);

    var scheduledTime = DateTime(now.year, now.month, now.day, 21, minute);

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      _dangerZoneId,
      '⚠️ Son Şans!',
      _getDangerZoneMessage(),
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'urgent_reminders',
          'Acil Hatırlatmalar',
          channelDescription: 'Seri kurtarma ve önemli bildirimler',
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(''),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static String _getDangerZoneMessage() {
    final messages = [
      'Günü verimsiz kapatma. Uyumadan önce son bir gayret!',
      'Serinini korumak için sadece 25 dakika yeterli. Hadi son bir seans!',
      'Gün bitmeden kendine bir hediye ver: Bir odaklanma seansı.',
      'Yarın sabah mutlu uyanmak için şimdi 25 dakika ayır.',
      'Günü boş geçirme. Uyumadan önce küçük bir çalışma yapalım mı?',
    ];
    return messages[Random().nextInt(messages.length)];
  }

  // ============================================================================
  // 7. KURAL: RASTGELE MOTİVASYON MESAJLARI (4+ SAAT ARAYLA)
  // ============================================================================

  static Future<void> _scheduleRandomMotivation() async {
    final now = DateTime.now();
    final random = Random();

    // 4 rastgele bildirim zamanla (en az 4 saat arayla)
    final scheduledHours = <int>[];

    // İlk bildirimi şu andan 4-6 saat sonraya planla
    int currentHour = now.hour + 4 + random.nextInt(3);

    for (int i = 0; i < 4; i++) {
      if (currentHour >= 24) currentHour -= 24;
      scheduledHours.add(currentHour);

      // Sonraki bildirimi 4-6 saat sonraya planla
      currentHour += 4 + random.nextInt(3);
    }

    for (int i = 0; i < scheduledHours.length; i++) {
      final hour = scheduledHours[i];
      final minute = random.nextInt(60);

      var scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);

      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      await _notifications.zonedSchedule(
        _randomMotivationBaseId + i,
        '💪 Motivasyon',
        _getRandomMotivationMessage(),
        tz.TZDateTime.from(scheduledTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'motivation',
            'Motivasyon Mesajları',
            channelDescription: 'Günlük motivasyon bildirimleri',
            importance: Importance.low,
            priority: Priority.low,
            styleInformation: BigTextStyleInformation(''),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: false,
            presentSound: false,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  static String _getRandomMotivationMessage() {
    final messages = [
      'Küçük bir adım, büyük bir fark yaratır. Sadece 25 dakika ayıralım mı?',
      'Zihnin hazır, kahven hazırsa başlayalım ☕',
      'Gelecekteki sen, şimdi çalışmaya başladığın için sana teşekkür edecek.',
      'Bugün kendin için bir şey yap: Odaklan.',
      'Başarı, küçük çabaların tekrarıdır. Bugünkü çabanı göster.',
      'Sadece 25 dakika. Şimdi başla, sonra teşekkür et.',
      'Hedeflerine her gün biraz daha yaklaş. Bugün ne yapacaksın?',
      'Odaklanmak bir kasıt. Sen bu kasları güçlendir.',
    ];
    return messages[Random().nextInt(messages.length)];
  }

  // ============================================================================
  // UTILITY FUNCTIONS
  // ============================================================================

  /// Tüm planlanmış bildirimleri iptal eder
  static Future<void> cancelAllScheduledNotifications() async {
    await _notifications.cancelAll();
  }

  /// Belirli bir bildirimi iptal eder
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Test amaçlı hemen bildirim göster
  static Future<void> showTestNotification() async {
    await _notifications.show(
      999,
      'Test Bildirimi',
      'Bildirimler düzgün çalışıyor!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'motivation',
          'Motivasyon Mesajları',
          channelDescription: 'Test bildirimi',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  /// Planlanmış bildirimlerin listesini al (debug amaçlı)
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
