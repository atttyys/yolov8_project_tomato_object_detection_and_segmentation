import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_api_images/res/values.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';

class ApiPredict {
  String get baseApiUrl => apiIpNotifier.value;

  Future<Map<String, dynamic>> sendImageForPrediction(File imageFile) async {
    final uri = Uri.parse("$baseApiUrl/upload_and_predict");
    var request = http.MultipartRequest('POST', uri);

    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );

    try {
      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      final Map<String, dynamic> responseData =
          json.decode(respStr) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        summaryNotifier.value = responseData['summary'];
        preprocessTimeNotifier.value = responseData['preprocess_time'];
        inferenceTimeNotifier.value = responseData['inference_time'];
        postprocessTimeNotifier.value = responseData['postprocess_time'];

        return {
          "success": true,
          "message": responseData['message'],
          "summary": responseData['summary'],
          "preprocess_time": responseData['preprocess_time'],
          "inference_time": responseData['inference_time'],
          "postprocess_time": responseData['postprocess_time'],
        };
      } else {
        return {"success": false, "message": responseData['error']};
      }
    } catch (error) {
      return {"success": false, "message": "Failed to connect to API"};
    }
  }

  Future<File?> downloadPredictedImage() async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('predicted_images/last_predict.jpeg');
      final data = await ref.getData();
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/last_predict.jpeg');

      await file.writeAsBytes(data!);
      return file;
    } catch (e) {
      print(e);
      return null;
    }
  }
}
