import 'package:geolocator/geolocator.dart';
import 'package:vezu/core/base/base_location_service.dart';

class LocationService implements BaseLocationService {
  @override
  Future<LocationCoordinates> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationPermissionException(serviceDisabled: true);
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw LocationPermissionException(
        message: 'Location permission denied by user.',
      );
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationPermissionException(permanentlyDenied: true);
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );

    return (latitude: position.latitude, longitude: position.longitude);
  }

  @override
  Future<bool> openAppSettings() {
    return Geolocator.openAppSettings();
  }

  @override
  Future<bool> openLocationSettings() {
    return Geolocator.openLocationSettings();
  }
}

