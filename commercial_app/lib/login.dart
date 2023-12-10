import 'package:commercial_app/bottom_nav.dart';
import 'package:commercial_app/home_screen.dart';
import 'package:commercial_app/product_tile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'signup.dart';
import 'main.dart';
import 'product_tile.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Login'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 275.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24.0),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 90),
                  child: ElevatedButton(
                    onPressed: _handleLogin,
                    child: Text('Login'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      primary: Colors.black,
                      onPrimary: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 50),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpPage()),
                      );
                    },
                    child: Text('Create an Account'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      primary: Colors.black,
                      onPrimary: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      try {
        await firebase_auth.FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => BottomNav()),
          (Route<dynamic> route) => false,
        );
      } on firebase_auth.FirebaseAuthException catch (e) {
        if (e.code == 'invalid-credential') {
          print("error code" + e.code);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Invalid username or password"),
          ));
        } else {
          print("error code in else" + e.code);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.message ?? "An error occurred."),
          ));
        }
      } catch (e) {
        print("Error code in catch: $e");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("An error occurred. Please try again."),
        ));
      }
    }
  }

  bool _validateEmail(String email) {
    return email.isNotEmpty && email.contains('@');
  }

  bool _validatePassword(String password) {
    return password.isNotEmpty && password.length >= 6;
  }
}
