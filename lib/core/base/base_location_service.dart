typedef LocationCoordinates = ({double latitude, double longitude});

abstract class BaseLocationService {
  Future<LocationCoordinates> getCurrentPosition();
  Future<bool> openAppSettings();
  Future<bool> openLocationSettings();
}

class LocationPermissionException implements Exception {
  LocationPermissionException({
    this.permanentlyDenied = false,
    this.serviceDisabled = false,
    this.message,
  });

  final bool permanentlyDenied;
  final bool serviceDisabled;
  final String? message;

  @override
  String toString() {
    final buffer = StringBuffer('LocationPermissionException');
    if (message != null) {
      buffer.write(': $message');
    }
    if (permanentlyDenied) {
      buffer.write(' (permanentlyDenied)');
    }
    if (serviceDisabled) {
      buffer.write(' (serviceDisabled)');
    }
    return buffer.toString();
  }
}

