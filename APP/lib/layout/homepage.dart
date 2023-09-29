import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              "lib/assets/s.png",
              height: 250,
              width: 250,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context,
                    '/folder'); // สร้างหน้า folder และใส่ route ใน main.dart
              },
              child: Text('Go to Folder'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context,
                    '/camera'); // สร้างหน้า camera และใส่ route ใน main.dart
              },
              child: Text('Go to Camera'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                await _auth.signOut();
                Navigator.pushReplacementNamed(context, '/');
              },
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
