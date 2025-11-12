import 'dart:io';

import 'package:permission_handler/permission_handler.dart'
    as permission_handler;
import 'package:vezu/core/base/base_permission_service.dart';

class PermissionService implements BasePermissionService {
  @override
  Future<bool> requestPhotos() async {
    if (Platform.isIOS) {
      return _request(permission_handler.Permission.photos);
    }

    if (await _request(permission_handler.Permission.photos)) {
      return true;
    }

    return _request(permission_handler.Permission.storage);
  }

  @override
  Future<bool> openAppSettings() {
    return permission_handler.openAppSettings();
  }

  Future<bool> _request(permission_handler.Permission permission) async {
    final status = await permission.status;
    if (status.isGranted || status.isLimited) {
      return true;
    }

    final result = await permission.request();
    return result.isGranted || result.isLimited;
  }
}
