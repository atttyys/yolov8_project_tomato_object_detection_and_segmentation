import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_api_images/provider/AuthService.dart';

class LoginScreen extends StatelessWidget {
  final AuthService authService;

  LoginScreen({Key? key, required this.authService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to Tomato App'),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            UserCredential? user = await authService.signInWithGoogle();
            if (user != null) {
              print(
                  "Successfully logged in with Google: ${user.user!.displayName}");
              Navigator.pushReplacementNamed(context, '/homepage');
            } else {
              print("Failed to log in with Google");
            }
          },
          child: Row(
            mainAxisSize:
                MainAxisSize.min, // set to min to make button wrap content
            children: [
              Image.asset('lib/assets/s.png',
                  height: 24), // your image asset here
              SizedBox(width: 8), // give a gap between image and text
              Text('Sign In with Google'),
            ],
          ),
        ),
      ),
    );
  }
}
