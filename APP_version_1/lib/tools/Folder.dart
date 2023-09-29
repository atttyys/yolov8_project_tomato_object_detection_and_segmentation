import 'dart:io';
import 'package:image_picker/image_picker.dart';

class Folder {
  Future<File?> pickImageFromGallery() async {
    final picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.gallery);
    if (photo != null) {
      return File(photo.path);
    }
    return null;
  }
}
