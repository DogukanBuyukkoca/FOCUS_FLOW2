# Akıllı Bildirim Sistemi - Kullanım Kılavuzu

## 📋 İçindekiler
1. [Genel Bakış](#genel-bakış)
2. [Kurulum ve Entegrasyon](#kurulum-ve-entegrasyon)
3. [Kullanım Örnekleri](#kullanım-örnekleri)
4. [Bildirim Kuralları](#bildirim-kuralları)
5. [Psikolojik Analiz](#psikolojik-analiz)
6. [Platform Özgü Ayarlar](#platform-özgü-ayarlar)
7. [Debug ve Test](#debug-ve-test)

---

## 🎯 Genel Bakış

Bu akıllı bildirim sistemi, kullanıcı davranışlarını takip ederek **7 farklı bildirim kuralı** uygular. Her kural, belirli bir psikolojik prensibe dayanır ve kullanıcıyı uygulamaya geri döndürmeyi veya alışkanlık oluşturmayı hedefler.

### Temel Özellikler
- ✅ Kullanıcı davranış analizi (favori açılış saati, geçmiş aktiviteler)
- ✅ 7 farklı bildirim stratejisi
- ✅ Timezone desteği ile hassas zamanlama
- ✅ Android/iOS uyumlu
- ✅ Otomatik bildirim planlaması
- ✅ Psikolojik olarak optimize edilmiş mesajlar

---

## 🚀 Kurulum ve Entegrasyon

### 1. Paket Kurulumu

Gerekli paketler zaten `pubspec.yaml` dosyasına eklenmiştir:

```yaml
dependencies:
  flutter_local_notifications: ^17.2.1
  timezone: ^0.9.2
  hive_flutter: ^1.1.0
```

Terminalde çalıştırın:

```bash
flutter pub get
```

### 2. Platform Özgü Konfigürasyonlar

#### Android (android/app/src/main/AndroidManifest.xml)

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Bildirim izinleri -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
    <uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
    <uses-permission android:name="android.permission.WAKE_LOCK"/>
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>

    <application>
        <!-- Boot receiver - Telefon yeniden başladığında bildirimleri yeniden planlar -->
        <receiver android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver"
            android:exported="false">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED"/>
            </intent-filter>
        </receiver>
    </application>
</manifest>
```

#### iOS (ios/Runner/Info.plist)

```xml
<dict>
    <!-- Bildirim izinleri -->
    <key>UIBackgroundModes</key>
    <array>
        <string>remote-notification</string>
    </array>
</dict>
```

### 3. Main.dart'ta Başlatma

```dart
import 'package:flutter/material.dart';
import 'smart_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive'ı başlat (zaten var)
  await Hive.initFlutter();

  // Akıllı bildirim sistemini başlat
  await SmartNotificationService.init();

  runApp(MyApp());
}
```

### 4. Uygulama Açılışını Takip Etme

Her uygulama açıldığında, `main_shell.dart` veya ana widget'ınızda:

```dart
class _MainShellState extends State<MainShell> {
  @override
  void initState() {
    super.initState();

    // Kullanıcı davranışını takip et
    SmartNotificationService.trackAppOpen();
  }

  // ... rest of code
}
```

### 5. Pomodoro Başladığında Takip Etme

`timer_provider.dart` içinde, timer başladığında:

```dart
class TimerNotifier extends StateNotifier<TimerState> {
  Future<void> start() async {
    // Session başladığını kaydet
    await SmartNotificationService.trackSessionStart();

    // ... existing timer logic
  }
}
```

---

## 📱 Kullanım Örnekleri

### Örnek 1: Temel Kullanım

```dart
import 'smart_notification_service.dart';

// Uygulama başlangıcında
await SmartNotificationService.init();

// Kullanıcı giriş yaptığında
await SmartNotificationService.trackAppOpen();

// Pomodoro başlatıldığında
await SmartNotificationService.trackSessionStart();
```

### Örnek 2: Test Bildirimi Gönderme

Settings sayfasına bir test butonu ekleyebilirsiniz:

```dart
ElevatedButton(
  onPressed: () async {
    await SmartNotificationService.showTestNotification();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Test bildirimi gönderildi!')),
    );
  },
  child: Text('Test Bildirimi Gönder'),
)
```

### Örnek 3: Planlanmış Bildirimleri Görüntüleme (Debug)

```dart
ElevatedButton(
  onPressed: () async {
    final pending = await SmartNotificationService.getPendingNotifications();
    print('Planlanmış bildirim sayısı: ${pending.length}');

    for (var notification in pending) {
      print('ID: ${notification.id}, Başlık: ${notification.title}');
    }
  },
  child: Text('Planlanmış Bildirimleri Göster'),
)
```

### Örnek 4: Tüm Bildirimleri İptal Etme

Kullanıcı ayarlardan bildirimleri kapatırsa:

```dart
Future<void> disableNotifications() async {
  await SmartNotificationService.cancelAllScheduledNotifications();
  await StorageService.saveNotificationsEnabled(false);
}
```

---

## 📋 Bildirim Kuralları

### 1️⃣ 24 Saatlik Alışkanlık Hatırlatıcısı

**Tetiklenme Koşulu**: Kullanıcı uygulamayı açtığı saatten tam 24 saat sonra

**Hedef**: Günlük rutin oluşturma, aynı saatte alışkanlık pekiştirme

**Mesaj Örnekleri**:
- "Dün bu saatte harika bir seans yaptın. Bugün de aynı enerjiye hazır mısın?"
- "Alışkanlıkların bugün de devam etmeyi bekliyor. Başlamaya hazır mısın?"

**Kanal**: `habit_reminders` (Orta öncelikli)

**Kod**:
```dart
static Future<void> _schedule24HourReminder() async {
  final lastOpen = DateTime.parse(_behaviorBox.get('last_app_open'));
  final reminderTime = lastOpen.add(const Duration(hours: 24));

  await _notifications.zonedSchedule(
    _habitReminderId,
    '⏰ Günlük Odaklanma Zamanı',
    _get24HourReminderMessage(),
    tz.TZDateTime.from(reminderTime, tz.local),
    // ...
  );
}
```

---

### 2️⃣ 3 Gün Yokluk Uyarısı

**Tetiklenme Koşulu**: Kullanıcı 3 gün boyunca uygulamayı açmadıysa

**Hedef**: Duygusal bağ kurma, kayıp korkusu yaratma

**Ton**: Duygusal, samimi, hafif sert

**Mesaj Örnekleri**:
- "Sanırım ayrıldık... 3 gün oldu aramızda. Geri dönmeyi düşünür müsün?"
- "Hey, neredesin? 3 gündür yokluğunu hissediyoruz."

**Kanal**: `urgent_reminders` (Yüksek öncelikli)

**Psikolojik Etki**: Loss Aversion (Kayıp Korkusu)

---

### 3️⃣ 7 Gün Yokluk - Final Mesajı

**Tetiklenme Koşulu**: Kullanıcı 7 gün boyunca uygulamayı açmadıysa

**Hedef**: Ters psikoloji ile kullanıcının kontrolü geri alma arzusu

**Ton**: Saygılı mesafe, pasif-agresif

**Mesaj Örnekleri**:
- "Seni rahatsız etmeyi bırakıyorum. Belki de bu senin için doğru uygulama değildi."
- "Tamam, mesajı aldım. Senin kararına saygı duyuyorum. Elveda."

**Kanal**: `urgent_reminders` (Yüksek öncelikli)

**Psikolojik Etki**: Reverse Psychology, Autonomy Restoration

⚠️ **UYARI**: En riskli strateji. Bazı kullanıcılar gerçekten rahatsız olabilir.

---

### 4️⃣ Sabah Rutini (08:30 - 09:00)

**Tetiklenme Koşulu**: Her gün sabah 08:30-09:00 arası rastgele bir saatte

**Hedef**: Günün başında plan yapmayı hatırlatma

**Mesaj Örnekleri**:
- "Bugünün hedeflerini belirledin mi? İlk Pomodoro'yu başlat."
- "Sabahın altın saatleri. Bu enerjiyi değerlendirmeye ne dersin?"

**Kanal**: `motivation` (Düşük öncelikli, sessiz)

**Psikolojik Etki**: Fresh Start Effect, Temporal Landmark

---

### 5️⃣ Öğleden Sonra Çöküşü (14:00 - 15:00)

**Tetiklenme Koşulu**: Her gün öğleden sonra 14:00-15:00 arası

**Hedef**: Enerji düşüklüğü döneminde motive etme

**Mesaj Örnekleri**:
- "Öğle rehavetini atmanın en iyi yolu: Kısa bir odaklanma seansı."
- "Günün en zor saatleri. Ama sen bunun üstesinden gelebilirsin."

**Kanal**: `motivation` (Düşük öncelikli)

**Psikolojik Etki**: Enerji optimizasyonu, circadian rhythm desteği

---

### 6️⃣ Tehlike Bölgesi (21:00 - 22:00)

**Tetiklenme Koşulu**: Kullanıcı o gün hiç giriş yapmadıysa, akşam saatlerinde

**Hedef**: Seriyi kurtarma, son şans motivasyonu

**Mesaj Örnekleri**:
- "Günü verimsiz kapatma. Uyumadan önce son bir gayret!"
- "Serinini korumak için sadece 25 dakika yeterli. Hadi son bir seans!"

**Kanal**: `urgent_reminders` (Yüksek öncelikli)

**Psikolojik Etki**: Scarcity (Kıtlık), Deadline Effect

**Özel Özellik**: Sadece o gün uygulama açılmadıysa tetiklenir

```dart
static bool _wasAppOpenedToday() {
  final lastOpen = DateTime.parse(_behaviorBox.get('last_app_open'));
  final now = DateTime.now();

  return lastOpen.year == now.year &&
         lastOpen.month == now.month &&
         lastOpen.day == now.day;
}
```

---

### 7️⃣ Rastgele Motivasyon Mesajları

**Tetiklenme Koşulu**: Günde 4 kez, minimum 4 saat arayla

**Hedef**: Tahmin edilemez ödüller ile ilgi canlı tutma

**Mesaj Örnekleri**:
- "Küçük bir adım, büyük bir fark yaratır. Sadece 25 dakika ayıralım mı?"
- "Zihnin hazır, kahven hazırsa başlayalım ☕"
- "Gelecekteki sen, şimdi çalışmaya başladığın için sana teşekkür edecek."

**Kanal**: `motivation` (Düşük öncelikli, sessiz)

**Psikolojik Etki**: Variable Rewards (Operant Conditioning)

---

## 🧠 Psikolojik Analiz

### 1. Implementation Intention (Uygulama Niyeti)
24 saatlik hatırlatıcılar, "aynı yer, aynı zaman" prensibiyle alışkanlık oluşturur.

**Kaynak**: Gollwitzer & Sheeran (2006)

### 2. Loss Aversion (Kayıp Korkusu)
3 günlük yokluk mesajları, kullanıcının kaybettiği seri ve ilerlemeyi vurgular.

**Kaynak**: Kahneman & Tversky (1979)

### 3. Reverse Psychology (Ters Psikoloji)
7 günlük final mesajı, kullanıcının özerklik ihtiyacını tetikler.

**Risk**: Manipülatif görünebilir, dikkatli kullanılmalı.

### 4. Fresh Start Effect
Sabah, öğleden sonra ve akşam bildirimleri günün doğal dönüm noktalarını kullanır.

**Kaynak**: Dai, Milkman & Riis (2014)

### 5. Variable Rewards
Rastgele motivasyon mesajları, dopamin salınımını artırır.

**Kaynak**: Skinner (1953) - Operant Conditioning

### 6. Scarcity & Deadline Effect
Tehlike Bölgesi bildirimi, "son şans" mesajıyla aciliyet yaratır.

---

## 🛠 Platform Özgü Ayarlar

### Android API 33+ (Android 13+) İzin İsteme

Android 13'ten itibaren bildirimler için açık izin gerekiyor:

```dart
import 'package:permission_handler/permission_handler.dart';

Future<void> requestNotificationPermission() async {
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
}
```

### iOS Bildirim İzni

iOS'ta kullanıcıya açık izin istemi gösterilir:

```dart
final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
    IOSFlutterLocalNotificationsPlugin>();

await iosPlugin?.requestPermissions(
  alert: true,
  badge: true,
  sound: true,
);
```

---

## 🐛 Debug ve Test

### Test Bildirimi Gönderme

```dart
await SmartNotificationService.showTestNotification();
```

### Planlanmış Bildirimleri Görüntüleme

```dart
final pending = await SmartNotificationService.getPendingNotifications();

for (var notification in pending) {
  print('ID: ${notification.id}');
  print('Başlık: ${notification.title}');
  print('İçerik: ${notification.body}');
  print('---');
}
```

### Davranış Verilerini Kontrol Etme

```dart
final behaviorBox = await Hive.openBox('user_behavior');

print('Son açılış: ${behaviorBox.get('last_app_open')}');
print('Açılış geçmişi: ${behaviorBox.get('app_open_history')}');
print('Son session: ${behaviorBox.get('last_session_start')}');
```

### Tüm Bildirimleri İptal Etme

```dart
await SmartNotificationService.cancelAllScheduledNotifications();
```

---

## 📊 Veri Yapısı

### Hive Box: `user_behavior`

```dart
{
  'last_app_open': '2024-01-15T09:30:00.000',
  'app_open_history': [
    '2024-01-15T09:30:00.000',
    '2024-01-14T09:25:00.000',
    '2024-01-13T09:32:00.000',
  ],
  'last_session_start': '2024-01-15T09:35:00.000',
  'session_history': [
    '2024-01-15T09:35:00.000',
    '2024-01-14T14:20:00.000',
  ],
  'last_open_hour': 9,
}
```

---

## ⚙️ Gelişmiş Özelleştirme

### Bildirim Mesajlarını Özelleştirme

Mesajları değiştirmek isterseniz, ilgili fonksiyonları düzenleyin:

```dart
static String _get24HourReminderMessage() {
  final customMessages = [
    'Kendi mesajınız 1',
    'Kendi mesajınız 2',
  ];
  return customMessages[Random().nextInt(customMessages.length)];
}
```

### Bildirim Saatlerini Değiştirme

```dart
// Sabah rutini için 07:00 - 08:00 arası
var scheduledTime = DateTime(now.year, now.month, now.day, 7, minute);

// Tehlike bölgesi için 20:00 - 21:00 arası
var scheduledTime = DateTime(now.year, now.month, now.day, 20, minute);
```

### Favori Saat Algoritmasını İyileştirme

Daha gelişmiş makine öğrenimi algoritmaları kullanabilirsiniz:

```dart
static int _getFavoriteOpenHour() {
  // Weighted average, clustering, vs.
  // Mevcut kod basit frequency count kullanıyor
}
```

---

## 🚨 Önemli Notlar

1. **Timezone Ayarı**: Varsayılan `Europe/Istanbul` olarak ayarlanmış. Değiştirmek için:
   ```dart
   tz.setLocalLocation(tz.getLocation('America/New_York'));
   ```

2. **Bildirim Limitleri**: Android 13+ cihazlarda fazla bildirim gönderilirse kullanıcı bildirimleri kapatabilir.

3. **Background Restrictions**: Bazı cihazlar (Xiaomi, Huawei) arka plan kısıtlamaları uygular.

4. **Test Sırasında**: Debug sırasında bildirimlerin çalışması için cihazın "Do Not Disturb" modunda olmamasına dikkat edin.

---

## 🎨 Kullanıcı Deneyimi İyileştirmeleri

### 1. Bildirim Tercih Sayfası Ekleyin

```dart
class NotificationPreferencesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bildirim Tercihleri')),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('24 Saatlik Hatırlatıcılar'),
            value: true,
            onChanged: (value) {
              // Ayarı kaydet
            },
          ),
          SwitchListTile(
            title: Text('Sabah Rutini Bildirimleri'),
            value: true,
            onChanged: (value) {},
          ),
          // ... diğer seçenekler
        ],
      ),
    );
  }
}
```

### 2. A/B Testing

Farklı mesaj tonlarını test edin:

```dart
final userSegment = Random().nextInt(2); // 0 veya 1

if (userSegment == 0) {
  // Nazik ton
  message = 'Seni özledik, geri döner misin?';
} else {
  // Sert ton
  message = 'Sanırım ayrıldık...';
}
```

---

## 📈 Metrik ve Analytics

İleride ekleyebileceğiniz özellikler:

- Hangi bildirimlerin daha çok tıklandığını takip etme
- Bildirim sonrası uygulama açılma oranı
- En etkili mesaj tonunu belirleme
- Kullanıcı segmentasyonu (aktif, pasif, kayıp)

---

## ✅ Checklist: Sistemi Entegre Etmek İçin

- [ ] `pubspec.yaml` dosyasına `timezone` paketini ekle
- [ ] `flutter pub get` komutunu çalıştır
- [ ] `AndroidManifest.xml` dosyasına izinleri ekle
- [ ] `main.dart` içinde `SmartNotificationService.init()` çağır
- [ ] `main_shell.dart` veya ana widget'ta `trackAppOpen()` çağır
- [ ] `timer_provider.dart` içinde `trackSessionStart()` çağır
- [ ] Test bildirimi gönder ve çalıştığını doğrula
- [ ] Gerçek cihazda test et (emulator her zaman güvenilir değil)

---

## 🎓 Sonuç

Bu sistem, davranışsal psikoloji prensiplerini kullanarak kullanıcıları uygulamaya geri döndürmeyi ve alışkanlık oluşturmayı hedefler.

**En önemli püf noktası**: Bildirimleri aşırıya kaçırmamak. Kullanıcı rahatsız olursa tüm bildirimleri kapatabilir. Dengeli bir strateji izleyin.

Başarılar!
