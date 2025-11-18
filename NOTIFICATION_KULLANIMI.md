# 🔔 Firebase Notification Kullanım Kılavuzu

## ✅ Yapılan Kurulumlar

### 1. **Paketler Eklendi**
- `flutter_local_notifications: ^17.2.3` - Foreground notifications için

### 2. **NotificationService Oluşturuldu**
- `lib/core/services/notification_service.dart`
- Singleton pattern ile çalışıyor
- Foreground, background ve terminated state'lerinde bildirimleri yönetiyor

### 3. **Android Konfigürasyonu**
- ✅ `AndroidManifest.xml` - FCM metadata eklendi
- ✅ `colors.xml` - Notification rengi eklendi
- ✅ Icon: `@mipmap/ic_launcher` (Vezu icon'u)
- ✅ Channel ID: `vezu_notifications`

### 4. **iOS Konfigürasyonu**
- ✅ `Info.plist` - Notification permission description eklendi
- ✅ `AppDelegate.swift` - Zaten doğru yapılandırılmış
- ✅ Background modes aktif

### 5. **main.dart Güncellemesi**
- ✅ NotificationService initialize ediliyor
- ✅ Background message handler aktif

---

## 📱 Kullanım

### Bildirim Tıklamalarını Dinleme

Herhangi bir sayfada (örneğin `home_page.dart` veya `shell.dart`):

```dart
import 'package:vezu/core/services/notification_service.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late StreamSubscription<RemoteMessage> _notificationSubscription;

  @override
  void initState() {
    super.initState();
    
    // Notification tıklamalarını dinle
    _notificationSubscription = NotificationService.instance.onNotificationTap.listen(
      (RemoteMessage message) {
        debugPrint('Bildirime tıklandı: ${message.data}');
        
        // Notification data'sına göre navigasyon yap
        if (message.data['route'] == 'wardrobe') {
          // Navigator.pushNamed(context, '/wardrobe');
        } else if (message.data['route'] == 'combine') {
          // Navigator.pushNamed(context, '/combine');
        }
      },
    );
  }

  @override
  void dispose() {
    _notificationSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(...);
  }
}
```

---

## 🧪 Test Etme

### 1. **Firebase Console'dan Test Bildirimi Gönderme**

1. Firebase Console → Cloud Messaging
2. "Send your first message" tıklayın
3. **Notification** kısmını doldurun:
   - **Notification title**: Test Bildirim
   - **Notification text**: Bu bir test bildirimidir
4. **Target** → Select app → Vezu seçin
5. **Additional options** (opsiyonel):
   - **Custom data** ekleyebilirsiniz:
     ```
     Key: route
     Value: wardrobe
     ```
6. "Review" → "Publish"

### 2. **Uygulama Durumlarında Test**

#### **Foreground (Uygulama açık)**
- ✅ Bildirim ekranda görünür (local notification ile)
- ✅ Tıklanınca `onNotificationTap` stream tetiklenir

#### **Background (Uygulama arka planda)**
- ✅ Sistem bildirimi otomatik gösterilir
- ✅ Tıklanınca `onNotificationTap` stream tetiklenir

#### **Terminated (Uygulama kapalı)**
- ✅ Sistem bildirimi gösterilir
- ✅ Bildirime tıklanarak açıldığında `onNotificationTap` stream tetiklenir

---

## 🎨 Bildirim Görünümü

### Android
- **Icon**: Vezu app icon (`@mipmap/ic_launcher`)
- **Renk**: #293049 (Vezu brand color)
- **Channel**: Vezu Bildirimleri
- **Öncelik**: High (Importance.high)
- **Titreşim**: Aktif
- **Ses**: Aktif

### iOS
- **Icon**: Uygulama icon'u otomatik
- **Badge**: Aktif
- **Ses**: Aktif
- **Banner**: Aktif

---

## 🔧 İleri Düzey Kullanım

### Custom Notification Data ile Navigasyon

Firebase'den gönderirken `data` payload'ına ekleyin:

```json
{
  "notification": {
    "title": "Yeni Kombin Önerisi",
    "body": "Bugün için harika bir kombin hazırladık!"
  },
  "data": {
    "route": "combine",
    "itemId": "123456",
    "action": "view"
  }
}
```

Uygulamada:

```dart
NotificationService.instance.onNotificationTap.listen((message) {
  final data = message.data;
  
  switch (data['route']) {
    case 'combine':
      Navigator.pushNamed(
        context,
        '/combine',
        arguments: {'itemId': data['itemId']},
      );
      break;
    case 'wardrobe':
      Navigator.pushNamed(context, '/wardrobe');
      break;
    case 'profile':
      Navigator.pushNamed(context, '/profile');
      break;
  }
});
```

### Permission Kontrolü

```dart
// Permission durumunu kontrol et
final hasPermission = await NotificationService.instance.hasPermission();

if (!hasPermission) {
  // Permission iste
  final granted = await NotificationService.instance.requestPermission();
  
  if (granted) {
    debugPrint('Notification permission verildi');
  } else {
    debugPrint('Notification permission reddedildi');
  }
}
```

---

## 🐛 Sorun Giderme

### Bildirimler Görünmüyor

#### Android
1. **Permissions kontrol et**: `POST_NOTIFICATIONS` (API 33+)
2. **Google Play Services**: Yüklü olmalı
3. **Logcat**: `[NotificationService]` filtresi ile kontrol et

#### iOS
1. **Simulator'da**: Push notifications çalışmaz (gerçek cihaz gerekli)
2. **Permission**: Settings → Vezu → Notifications aktif olmalı
3. **Console**: `[NotificationService]` logları kontrol et

### FCM Token Alınamıyor
- Google Play Services'in güncel olduğundan emin olun
- `google-services.json` doğru yerinde mi kontrol edin
- Firebase Console'da SHA-1 fingerprint ekli mi kontrol edin

---

## 📊 Log Çıktıları

Başarılı kurulumda görmemiz gereken loglar:

```
[NotificationService] 🔔 Initializing...
[NotificationService] 📱 FCM Token: AbC123XyZ...
[NotificationService] ✅ Initialization completed
```

Bildirim geldiğinde:

```
[NotificationService] 📨 Foreground message received
[NotificationService] Title: Test Bildirim
[NotificationService] Body: Bu bir test bildirimidir
[NotificationService] ✅ Local notification displayed
```

Bildirime tıklandığında:

```
[NotificationService] 👆 Notification tapped
[NotificationService] Payload: ...
```

---

## 🚀 Sonraki Adımlar

1. ✅ **Test edin**: Firebase Console'dan test bildirimi gönderin
2. ✅ **Navigasyon ekleyin**: `onNotificationTap` stream'ini dinleyin
3. ✅ **Backend**: FCM token'ları backend'e kaydedin
4. ✅ **Segmentasyon**: Kullanıcı gruplarına özel bildirimler gönderin

---

## 📞 Destek

Sorun yaşarsanız:
1. Logları kontrol edin (`[NotificationService]` filtresi)
2. `flutter clean && flutter pub get` deneyin
3. Android: `./gradlew clean` çalıştırın

