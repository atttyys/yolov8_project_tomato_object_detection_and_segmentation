import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_api_images/api/api_predict.dart';
import 'package:flutter_api_images/res/values.dart'; // Import for ValueNotifiers
import 'package:flutter_api_images/widget/topbar.dart';
import 'package:flutter_api_images/widget/showDetail.dart';

class ShowPredict extends StatelessWidget {
  final ApiPredict apiPredict = ApiPredict();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              TopBar(),
              Expanded(
                child: FutureBuilder<File?>(
                  future: apiPredict.downloadPredictedImage(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return Image.file(snapshot.data!);
                    }
                  },
                ),
              ),
              Container(
                color: Colors.deepOrange[400],
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Back'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ShowDetail()),
                      ),
                      child: Text('Show Detail'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          ValueListenableBuilder<Map<String, dynamic>>(
            valueListenable: summaryNotifier,
            builder: (context, summary, _) {
              if (summary.isEmpty) {
                return Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else {
                return Container();
              }
            },
          ),
        ],
      ),
    );
  }
}
