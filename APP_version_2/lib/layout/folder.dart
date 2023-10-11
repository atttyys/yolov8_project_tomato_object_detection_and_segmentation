import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_api_images/api/api_predict.dart';
import 'package:flutter_api_images/widget/topbar.dart';
import 'package:flutter_api_images/tools/Folder.dart';

class FolderScreen extends StatefulWidget {
  @override
  _FolderScreenState createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  File? _image;
  final ApiPredict apiPredict = ApiPredict();
  bool isLoading = false;
  String message = "";
  final Folder folder = Folder();

  Future<void> _imgFromGallery() async {
    final File? image = await folder.pickImageFromGallery();

    setState(() {
      if (image != null) {
        _image = image;
      } else {
        print('No image selected.');
      }
    });
  }

  // ฟังก์ชันส่งไปยัง API และโค้ดอื่น ๆ คงเหมือนเดิม
  Future<void> _sendToApi() async {
    setState(() {
      isLoading = true;
    });

    if (_image == null) {
      print("No image to send.");
      setState(() {
        isLoading = false;
      });
      return;
    }

    final startTime = DateTime.now();
    final response = await apiPredict.sendImageForPrediction(_image!);
    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);

    if (response['success']) {
      setState(() {
        message = "Prediction success: ${response['message']}\n" +
            "Preprocess Time: ${response['preprocess_time']} ms\n" +
            "Inference Time: ${response['inference_time']} ms\n" +
            "Postprocess Time: ${response['postprocess_time']} ms\n" +
            "Total Time taken: ${duration.inSeconds} seconds";
      });
    } else {
      setState(() {
        message = "Prediction failed: ${response['message']}";
      });
    }

    setState(() {
      isLoading = false;
    });

    _showResultDialog();
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Result'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/showPredict');
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              TopBar(),
              // Content
              Expanded(
                child: Center(
                  child: _image == null
                      ? Image.asset(
                          "lib/assets/s.png",
                          height: 200,
                          width: 200,
                        )
                      : Image.file(_image!),
                ),
              ),
              // Bottom bar
              Container(
                color: Colors.deepOrange[400],
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/homepage'),
                      child: Text('Home'),
                    ),
                    ElevatedButton(
                      onPressed: _imgFromGallery,
                      child: Text('Gallery'), // แค่เปลี่ยนชื่อปุ่ม
                    ),
                    ElevatedButton(
                      onPressed: isLoading ? null : _sendToApi,
                      child: Text('Send to API'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          isLoading
              ? Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
