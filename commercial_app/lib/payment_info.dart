import 'package:commercial_app/login.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'login.dart';

class PaymentInfoPage extends StatefulWidget {
  final String userId;
  PaymentInfoPage({required this.userId});
  @override
  _PaymentInfoPageState createState() => _PaymentInfoPageState();
}

class _PaymentInfoPageState extends State<PaymentInfoPage> {
  final _formKey = GlobalKey<FormState>();
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvv = '';

  void _submitPaymentInfo() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      FirebaseFirestore firestore = FirebaseFirestore.instance;

      try {
        await firestore.collection('users').doc(widget.userId).set({
          'paymentInfo': {
            'cardNumber': cardNumber,
            'expiryDate': expiryDate,
            'cardHolderName': cardHolderName,
            'cvv': cvv,
          },
        }, SetOptions(merge: true));

        print("Payment Information Added");
        // Navigate to next page or show success message
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginPage()),
          (Route<dynamic> route) =>
              false, // This condition ensures all previous routes are removed
        );
      } catch (error) {
        print("Failed to add payment information: $error");
        // Handle any errors here
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Enter Payment Information'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Card Number'),
                keyboardType: TextInputType.number,
                onSaved: (value) => cardNumber = value!,
                validator: _validateCardNumber,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Expiry Date (MM/YY)'),
                keyboardType: TextInputType.datetime,
                inputFormatters: [ExpiryDateInputFormatter()],
                onSaved: (value) => expiryDate = value!,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter expiry date';
                  } else if (!_isValidExpiryDate(value)) {
                    return 'Invalid or expired date';
                  }
                  // Additional validation can be added here
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Card Holder Name'),
                onSaved: (value) => cardHolderName = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter card holder name' : null,
              ),
              TextFormField(
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

                      _submitPaymentInfo();
                    }
                  },
                  child: Text('Submit'),
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
