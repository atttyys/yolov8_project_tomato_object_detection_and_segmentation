import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_api_images/res/values.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? selectedIP;

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
            DropdownButton<String>(
              value: selectedIP,
              hint: Text("Select an IP"),
              onChanged: (newValue) {
                setState(() {
                  selectedIP = newValue!;
                  apiIpNotifier.value = selectedIP!; // Update the ValueNotifier
                });
              },
              items: [
                DropdownMenuItem<String>(
                  value: "http://192.168.31.144:5000/",
                  child: Text("192.168.31.144"),
                ),
                DropdownMenuItem<String>(
                  value: "http://172.20.10.3:5000/",
                  child: Text("172.20.10.3"),
                ),
                DropdownMenuItem<String>(
                  value: "http://192.168.137.1:5000/",
                  child: Text("192.168.137.1"),
                ),
                DropdownMenuItem<String>(
                  value: "http://10.96.27.72:5000/",
                  child: Text("10.96.27.72"),
                ),
                DropdownMenuItem<String>(
                  value: "http://10.0.2.2:5000/",
                  child: Text("Emulator (10.0.2.2)"),
                ), // เพิ่ม IP อื่นๆ ที่นี่
              ],
            ),
            SizedBox(height: 10),
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
