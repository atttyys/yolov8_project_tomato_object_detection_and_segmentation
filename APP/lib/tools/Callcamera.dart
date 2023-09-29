import 'package:image_picker/image_picker.dart';

class CallCamera {
  Future<XFile?> captureImage() async {
    final picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    return photo;
  }
}
