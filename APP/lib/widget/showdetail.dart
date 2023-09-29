import 'package:flutter/material.dart';
import 'package:flutter_api_images/res/values.dart';

class ShowDetail extends StatelessWidget {
  // Class name mapping
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prediction Details'),
      ),
      body: ValueListenableBuilder<Map<String, dynamic>>(
        valueListenable: summaryNotifier,
        builder: (context, summary, _) {
          return ListView.builder(
            itemCount: summary.length,
            itemBuilder: (context, index) {
              String key = summary.keys.elementAt(index);
              Map<String, dynamic> value = summary[key];
              return ListTile(
                title: Text('ชื่อ class: ${value['name']}'),
                subtitle: Text(
                    'มีจำนวน ${value['count']} วัตถุ มีความถูกต้องเฉลี่ยที่ ${(value['avg_confidence'] * 100).toStringAsFixed(2)} %'),
              );
            },
          );
        },
      ),
    );
  }
}
