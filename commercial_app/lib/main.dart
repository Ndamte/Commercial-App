import 'package:commercial_app/SplashScreen.dart';

import 'firebase_options.dart';
import 'login.dart';
import 'package:firebase_core/firebase_core.dart';

import 'bottom_nav.dart';
import 'on_generate_routes.dart';
import 'home_screen.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'COMMERCIA',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      onGenerateRoute: onGenerateRoute,
      home: SplashScreen(),
    );
  }
}
