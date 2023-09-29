import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckPermission {
  Future<void> checkPermissions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? hasVerified = prefs.getBool('has_verified');

    if (hasVerified != true) {
      // Request permission for camera and storage
      Map<Permission, PermissionStatus> statuses = await [
        Permission.camera,
        Permission.microphone,
        Permission.mediaLibrary,
      ].request();

      // Check if all permissions are granted
      if (statuses[Permission.camera]?.isGranted == true &&
          statuses[Permission.microphone]?.isGranted == true &&
          statuses[Permission.mediaLibrary]?.isGranted == true) {
        await prefs.setBool('has_verified', true);
      }
    }
  }
}
