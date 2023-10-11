import 'package:flutter/material.dart';
import 'package:flutter_api_images/res/values.dart';

class ShowDetail extends StatelessWidget {
  final Map<int, String> names = {
    0: "b_fully_ripened | มะเขือเทศลูกโตสุก",
    1: "b_green | มะเขือเทศลูกโตสีดิบ",
    2: "b_half_ripened | มะเขือเทศลูกโตใกล้สุก",
    3: "l_fully_ripened | มะเขือเทศลูกเล็กสุก",
    4: "l_green | มะเขือเทศลูกเล็กดิบ",
    5: "l_half_ripened | มะเขือเทศลูกเล็กใกล้สุก"
  };

  String getHarvestRecommendation(Map<String, dynamic> summary) {
    int totalDetected = 0;
    int ripeCount = 0;

    summary.forEach((key, value) {
      if (names.containsKey(int.parse(key))) {
        totalDetected += (value['count'] as num).toInt();
        if (key == '0' || key == '3') {
          ripeCount += (value['count'] as num).toInt();
        }
      }
    });

    if ((ripeCount / totalDetected) > 0.4) {
      return 'ควรเก็บเกี่ยว';
    } else {
      return 'ไม่ควรเก็บเกี่ยว';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prediction Details'),
      ),
      body: Column(
        mainAxisAlignment:
            MainAxisAlignment.center, // ใช้การจัดวางเนื้อหาตรงกลางแนวตั้ง
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              getHarvestRecommendation(summaryNotifier.value),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          ValueListenableBuilder<Map<String, dynamic>>(
            valueListenable: summaryNotifier,
            builder: (context, Map<String, dynamic> summary, _) {
              if (summary.isEmpty) {
                return Text("No data available");
              }

              Map<String, dynamic> updatedSummary = {};
              summary.forEach((key, value) {
                int intKey = int.parse(key);
                if (names.containsKey(intKey)) {
                  updatedSummary[key] = {
                    'name': names[intKey],
                    'count': value['count'],
                    'avg_confidence': value['avg_confidence']
                  };
                } else {
                  updatedSummary[key] = value;
                }
              });

              return Expanded(
                child: Center(
                  child: ListView.builder(
                    itemCount: updatedSummary.length,
                    itemBuilder: (context, index) {
                      String key = updatedSummary.keys.elementAt(index);
                      if (key != 'preprocess_time' &&
                          key != 'inference_time' &&
                          key != 'postprocess_time') {
                        Map<String, dynamic> value = updatedSummary[key];
                        return ListTile(
                          title: Text('ชื่อ class: ${value['name']}'),
                          subtitle: Text(
                              'มีจำนวน ${value['count']} วัตถุ มีความถูกต้องเฉลี่ยที่ ${(value['avg_confidence'] * 100).toStringAsFixed(2)} %'),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                ),
              );
            },
          ),
          Text("เวลาที่ใช้ในการทำนาย"),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('ก่อนทำนาย: ${preprocessTimeNotifier.value} ms'),
                Text('ทำนาย: ${inferenceTimeNotifier.value} ms'),
                Text('หลังทำนาย: ${postprocessTimeNotifier.value} ms'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
