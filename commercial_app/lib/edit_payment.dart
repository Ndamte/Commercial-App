import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditPayment extends StatefulWidget {
  const EditPayment({Key? key}) : super(key: key);

  @override
  _EditPaymentState createState() => _EditPaymentState();
}

class _EditPaymentState extends State<EditPayment> {
  final _formKey = GlobalKey<FormState>();
  FirebaseAuth auth = FirebaseAuth.instance;
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvv = '';

  final cardNumberController = TextEditingController();
  final cardNameController = TextEditingController();
  final expiryDateController = TextEditingController();
  final cardHolderNameController = TextEditingController();
  final cvvController = TextEditingController();

  @override
  void dispose() {
    cardNumberController.dispose();
    expiryDateController.dispose();
    cardHolderNameController.dispose();
    cvvController.dispose();
    super.dispose();
  }

  bool _isValidExpiryDate(String? value) {
    final RegExp exp = RegExp(r'^(0[1-9]|1[0-2])\/([0-9]{2})$');

    if (!exp.hasMatch(value ?? '')) {
      return false;
    }

    final List<String> parts = value!.split('/');
    final int month = int.parse(parts[0]);
    final int year = int.parse('20${parts[1]}');

    final DateTime expiryDate = DateTime(year, month + 1, 0);
    final DateTime currentDate = DateTime.now();

    return currentDate.isBefore(expiryDate);
  }

  void _updatePaymentInfo() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      FirebaseFirestore firestore = FirebaseFirestore.instance;

      try {
        await firestore.collection('users').doc(auth.currentUser?.uid).update({
          'paymentInfo': {
            'cardNumber': cardNumber,
            'expiryDate': expiryDate,
            'cardHolderName': cardHolderName,
            'cvv': cvv,
          },
        });

        print("Payment Information Updated");
        cardNumberController.clear();
        expiryDateController.clear();
        cardHolderNameController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment Information Updated'),
            duration: Duration(seconds: 3),
          ),
        );
        cvvController.clear();
      } catch (error) {
        print("Failed to update payment information: $error");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update payment information'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  String? _validateCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your card number';
    } else if (value.length != 16 || !RegExp(r'^\d+$').hasMatch(value)) {
      return 'Card number should be 16 digits';
    }
    return null;
  }

  String? _validateCVV(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your CVV';
    } else if (value.length != 3 || !RegExp(r'^\d+$').hasMatch(value)) {
      return 'CVV should be 3 digits';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                Text('Update Payment Information',
                    style: TextStyle(
                        fontFamily: 'avenir',
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.black)),
                TextFormField(
                  controller: cardNumberController,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(labelText: 'Card Number'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => cardNumber = value!,
                  validator: _validateCardNumber,
                ),
                TextFormField(
                  controller: expiryDateController,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(labelText: 'Expiry Date (MM/YY)'),
                  keyboardType: TextInputType.datetime,
                  inputFormatters: [ExpiryDateInputFormatter()],
                  onSaved: (value) => expiryDate = value!,
                  validator: (value) {
                    if (value!.isEmpty || value == null) {
                      return 'Please enter expiry date';
                    } else if (!_isValidExpiryDate(value)) {
                      return 'Invalid or expired date';
                    }

                    return null;
                  },
                ),
                TextFormField(
                  controller: cardHolderNameController,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(labelText: 'Card Holder Name'),
                  onSaved: (value) => cardHolderName = value!,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter card holder name' : null,
                ),
                TextFormField(
                  controller: cvvController,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(labelText: 'CVV'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => cvv = value!,
                  validator: _validateCVV,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();

                        _updatePaymentInfo();
                      }
                    },
                    child:
                        Text('Update', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
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
}

class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final newText = newValue.text;
    if (newText.length > 5) {
      return oldValue;
    }
    if (newText.length == 2 && oldValue.text.length == 1) {
      return TextEditingValue(
        text: '$newText/',
        selection: TextSelection.collapsed(offset: 3),
      );
    }
    return newValue;
  }
}
