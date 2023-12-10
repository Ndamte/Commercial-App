import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';

class PersonalInfoPage extends StatefulWidget {
  @override
  _PersonalInfoPageState createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _firstName = '';
  String _lastName = '';
  String _password = '';
  bool _isFirstNameLoading = false;
  bool _isLastNameLoading = false;
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light(),
      child: Scaffold(
        appBar:
            AppBar(backgroundColor: Colors.black, title: Text('Personal Info')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _firstNameController,
                    decoration: InputDecoration(labelText: 'First Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                    onSaved: (value) => _firstName = value!,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _updateFirstName();
                    },
                    child: Text('Update First Name'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.black,
                      onPrimary: Colors.white,
                    ),
                  ),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: InputDecoration(labelText: 'Last Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your last name';
                      }
                      return null;
                    },
                    onSaved: (value) => _lastName = value!,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _updateLastName();
                    },
                    child: Text('Update Last Name'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.black,
                      onPrimary: Colors.white,
                    ),
                  ),
                  TextFormField(
                    controller: _newPasswordController,
                    decoration: InputDecoration(labelText: 'New Password'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      return null;
                    },
                    onSaved: (value) => _password = value!,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _attemptUpdatePassword();
                    },
                    child: Text('Update Info'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.black,
                      onPrimary: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _updateFirstName() async {
    setState(() {
      _isFirstNameLoading = true;
    });

    String newFirstName = _firstNameController.text.trim();

    if (newFirstName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('First name cannot be empty')),
      );
      setState(() {
        _isFirstNameLoading = false;
      });
      return;
    }

    final user = firebase_auth.FirebaseAuth.instance.currentUser;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({'firstName': newFirstName});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('First name updated successfully!')),
      );
      _firstNameController.clear();
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating first name: ${e.message}')),
      );
    } finally {
      setState(() {
        _isFirstNameLoading = false;
      });
    }
  }

  void _updateLastName() async {
    setState(() {
      _isLastNameLoading = true;
    });

    String newLastName = _lastNameController.text.trim();

    if (newLastName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Last name cannot be empty')),
      );
      setState(() {
        _isLastNameLoading = false;
      });
      return;
    }

    final user = firebase_auth.FirebaseAuth.instance.currentUser;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({'lastName': newLastName});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Last name updated successfully!')),
      );
      _lastNameController.clear();
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating last name: ${e.message}')),
      );
    } finally {
      setState(() {
        _isLastNameLoading = false;
      });
    }
  }

  void _attemptUpdatePassword() async {
    try {
      await user?.updatePassword(_newPasswordController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password updated successfully')),
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        _promptForReauthentication();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating password: ${e.message}')),
        );
      }
    }
  }

  void _updatePassword() async {
    try {
      await user?.updatePassword(_newPasswordController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password updated successfully')),
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Re-authentication required to update password.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating password: ${e.message}')),
        );
      }
    }
  }

  void reauthenticateAndChangePassword(
      String currentPassword, String newPassword) async {
    final user = firebase_auth.FirebaseAuth.instance.currentUser;

    if (user != null && currentPassword.isNotEmpty && newPassword.isNotEmpty) {
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      try {
        await user.reauthenticateWithCredential(credential);

        await user.updatePassword(newPassword);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password updated successfully')),
        );
        _newPasswordController.clear();
      } on firebase_auth.FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid credentials')),
      );
    }
  }

  void _promptForReauthentication() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Re-authentication Required"),
          content: TextField(
            controller: _currentPasswordController,
            decoration: InputDecoration(labelText: 'Current Password'),
            obscureText: true,
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Re-authenticate'),
              onPressed: () {
                reauthenticateAndChangePassword(_currentPasswordController.text,
                    _newPasswordController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
