import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Notification Service - Firebase Cloud Messaging ve Local Notifications yönetimi
class NotificationService {
  NotificationService._();
  
  static final NotificationService _instance = NotificationService._();
  static NotificationService get instance => _instance;

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Notification tap callback'leri için stream
  final StreamController<RemoteMessage> _notificationTapController =
      StreamController<RemoteMessage>.broadcast();
  
  Stream<RemoteMessage> get onNotificationTap => _notificationTapController.stream;

  bool _isInitialized = false;

  /// Notification Service'i başlat
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('[NotificationService] Already initialized');
      return;
    }

    try {
      debugPrint('[NotificationService] 🔔 Initializing...');
      
      // iOS için özel ayarlar
      if (Platform.isIOS) {
        await _requestIOSPermissions();
      }

      // Local notifications initialize
      await _initializeLocalNotifications();

      // FCM token al
      await _getFCMToken();

      // FCM listeners'ları kur
      _setupFCMListeners();

      // Initial message kontrolü (uygulama kapalıyken gelen bildirime tıklanarak açıldıysa)
      _checkInitialMessage();

      _isInitialized = true;
      debugPrint('[NotificationService] ✅ Initialization completed');
    } catch (e, stackTrace) {
      debugPrint('[NotificationService] ❌ Initialization error: $e');
      debugPrint('[NotificationService] Stack trace: $stackTrace');
    }
  }

  /// iOS için notification permission iste
  Future<void> _requestIOSPermissions() async {
    await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    
    // iOS foreground notifications için
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// Local notifications initialize
  Future<void> _initializeLocalNotifications() async {
    // Android settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
      onDidReceiveBackgroundNotificationResponse: _onNotificationTapped,
    );

    // Android notification channel oluştur
    if (Platform.isAndroid) {
      await _createAndroidNotificationChannel();
    }
  }

  /// Android notification channel oluştur
  Future<void> _createAndroidNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      'vezu_notifications', // id
      'Vezu Bildirimleri', // name
      description: 'Vezu uygulaması bildirimleri',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
      showBadge: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// FCM token al ve logla
  Future<void> _getFCMToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        debugPrint('[NotificationService] 📱 FCM Token: ${token.substring(0, 20)}...');
      }

      // Token yenilendiğinde
      _messaging.onTokenRefresh.listen((newToken) {
        debugPrint('[NotificationService] 🔄 Token refreshed: ${newToken.substring(0, 20)}...');
        // TODO: Token'ı backend'e gönder
      });
    } catch (e) {
      debugPrint('[NotificationService] ❌ Error getting FCM token: $e');
    }
  }

  /// FCM listeners kur
  void _setupFCMListeners() {
    // Foreground messages (uygulama açıkken)
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Background/terminated'dan bildirime tıklanarak açıldığında
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  /// Uygulama kapalıyken gelen bildirime tıklanarak açıldıysa kontrol et
  Future<void> _checkInitialMessage() async {
    try {
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('[NotificationService] 📬 App opened from terminated state via notification');
        _handleNotificationTap(initialMessage);
      }
    } catch (e) {
      debugPrint('[NotificationService] Error checking initial message: $e');
    }
  }

  /// Foreground message handler (uygulama açıkken gelen bildirimler)
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('[NotificationService] 📨 Foreground message received');
    debugPrint('[NotificationService] Title: ${message.notification?.title}');
    debugPrint('[NotificationService] Body: ${message.notification?.body}');
    debugPrint('[NotificationService] Data: ${message.data}');

    // Local notification ile göster (çünkü foreground'da otomatik gösterilmiyor)
    await _showLocalNotification(message);
  }

  /// Local notification göster
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) {
      debugPrint('[NotificationService] No notification payload, skipping display');
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'vezu_notifications',
      'Vezu Bildirimleri',
      channelDescription: 'Vezu uygulaması bildirimleri',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      playSound: true,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      details,
      payload: _encodePayload(message),
    );

    debugPrint('[NotificationService] ✅ Local notification displayed');
  }

  /// Notification tap handler
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('[NotificationService] 👆 Notification tapped');
    debugPrint('[NotificationService] Payload: ${response.payload}');

    if (response.payload != null) {
      try {
        final message = _decodePayload(response.payload!);
        _notificationTapController.add(message);
      } catch (e) {
        debugPrint('[NotificationService] Error decoding payload: $e');
      }
    }
  }

  /// Bildirime tıklandığında (background/terminated'dan)
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('[NotificationService] 👆 Notification opened app');
    debugPrint('[NotificationService] Data: ${message.data}');
    
    _notificationTapController.add(message);
  }

  /// RemoteMessage'ı string payload'a encode et
  String _encodePayload(RemoteMessage message) {
    return '${message.messageId ?? ''}|${message.data.toString()}';
  }

  /// String payload'u RemoteMessage'a decode et
  RemoteMessage _decodePayload(String payload) {
    // Basit bir decode, gerçek implementasyonda daha detaylı olabilir
    final parts = payload.split('|');
    return RemoteMessage(
      messageId: parts.isNotEmpty ? parts[0] : null,
      data: {}, // Data'yı parse etmek gerekirse eklenebilir
    );
  }

  /// Notification permission durumunu kontrol et
  Future<bool> hasPermission() async {
    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// Notification permission iste
  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// Service'i temizle
  void dispose() {
    _notificationTapController.close();
  }
}

/// Background message handler (top-level function olmalı)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[NotificationService] 🌙 Background message received');
  debugPrint('[NotificationService] Title: ${message.notification?.title}');
  debugPrint('[NotificationService] Body: ${message.notification?.body}');
  debugPrint('[NotificationService] Data: ${message.data}');
  
  // Burada background'da özel işlemler yapılabilir
  // Örnek: Local database'e kaydet, counter güncelle, vb.
}

