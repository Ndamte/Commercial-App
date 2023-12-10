import 'dart:async';
import 'package:commercial_app/bottom_nav.dart';
import 'package:commercial_app/home_screen.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with WidgetsBindingObserver {
  bool shouldNavigate = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Timer(Duration(seconds: 3), navigateBasedOnAuthState);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void navigateBasedOnAuthState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => LoginPage()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => BottomNav()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6448FE), Color(0xFF5FC6FF)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FlutterLogo(size: 100.0),
              SizedBox(height: 24.0),
              Text(
                'Commerce App',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
