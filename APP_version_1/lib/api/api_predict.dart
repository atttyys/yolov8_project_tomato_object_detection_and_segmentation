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

    Map names = {
      0: "b_fully_ripened",
      1: "b_green",
      2: "b_half_ripened",
      3: "l_fully_ripened",
      4: "l_green",
      5: "l_half_ripened"
    };

    try {
      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      final Map<String, dynamic> responseData = json.decode(respStr);

      if (response.statusCode == 200) {
        Map<String, dynamic> summary = responseData['summary'];

        // Adding the 'name' key-value pair into each entry in summary
        summary.forEach((key, value) {
          if (names.containsKey(int.parse(key))) {
            value['name'] = names[int.parse(key)];
          }
        });

        summaryNotifier.value =
            summary; // Assuming summaryNotifier is defined elsewhere in your code

        return {
          "success": true,
          "message": responseData['message'],
          "summary": summary
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
