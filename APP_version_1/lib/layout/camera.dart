import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_api_images/api/api_predict.dart';
import 'package:flutter_api_images/widget/topbar.dart';
import 'package:image_picker/image_picker.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _image;
  final ApiPredict apiPredict = ApiPredict();
  bool isLoading = false;
  String message = "";

  Future<void> _imgFromCamera() async {
    final XFile? image = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );

    setState(() {
      if (image != null) {
        _image = File(image.path);
      } else {
        print('No image selected.');
      }
    });
  }

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
        message =
            "Prediction success: ${response['message']}\nTime taken: ${duration.inSeconds} seconds";
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
                      onPressed: _imgFromCamera,
                      child: Text('Camera'),
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
