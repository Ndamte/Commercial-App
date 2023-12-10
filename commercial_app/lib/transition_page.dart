import 'package:commercial_app/edit_payment.dart';
import 'package:commercial_app/edit_shipping_address.dart';
import 'package:commercial_app/personal_info.dart';
import 'package:flutter/material.dart';
import 'package:commercial_app/login.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navigation Demo',
      home: TransitionPage(),
    );
  }
}

class TransitionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Settings'),
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.only(
          top: 16.0,
          left: 0.0,
          right: 0.0,
          bottom: 16.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => PersonalInfoPage())),
              child: Text('Update Personal Info'),
              style: ElevatedButton.styleFrom(
                primary: Colors.black,
                onPrimary: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
            SizedBox(height: 7),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => EditShippingAddress())),
              child: Text('Update Shipping Address'),
              style: ElevatedButton.styleFrom(
                primary: Colors.black,
                onPrimary: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
            SizedBox(height: 7),
            ElevatedButton(
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => EditPayment())),
              child: Text('Update Payment Method'),
              style: ElevatedButton.styleFrom(
                primary: Colors.black,
                onPrimary: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
            SizedBox(height: 7),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (Route<dynamic> route) => false,
                );
              },
              child: Text('Log Out'),
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
                onPrimary: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
