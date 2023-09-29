import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_api_images/layout/camera.dart';
import 'package:flutter_api_images/layout/folder.dart';
import 'package:flutter_api_images/layout/showPredict.dart';
import 'package:flutter_api_images/provider/UserProvider.dart';
import 'package:provider/provider.dart';
import 'layout/login.dart';
import 'layout/homepage.dart';
import 'provider/AuthService.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    Provider(
      create: (context) => UserProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(
            authService:
                AuthService()), // สร้าง instance ของ AuthService ที่นี่
        '/homepage': (context) => HomePage(),
        '/camera': (context) => CameraScreen(),
        '/showPredict': (context) => ShowPredict(),
        '/folder': (context) => FolderScreen(),
      },
    );
  }
}
