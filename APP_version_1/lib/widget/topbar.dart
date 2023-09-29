import 'package:flutter/material.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final double height = 60.0;

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.deepOrange[400],
        width: double.infinity,
        height: height,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment
              .center, // ใช้ตัวเลือกนี้เพื่อจัดข้อความไปยังตรงกลาง
          children: [
            Text(
              'TOMATO SegmObJ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ));
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
