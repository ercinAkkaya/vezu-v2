abstract class BaseNotificationService {
  Future<void> initialize();
  Future<void> requestPermission();
  Future<void> sendNotification({required String title, required String body});
}
