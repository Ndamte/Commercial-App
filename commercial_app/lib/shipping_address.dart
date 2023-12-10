import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'payment_info.dart';
import 'signup.dart';

class ShippingAddressPage extends StatefulWidget {
  final String userId;

  ShippingAddressPage({required this.userId});

  @override
  _ShippingAddressPageState createState() => _ShippingAddressPageState();
}

class _ShippingAddressPageState extends State<ShippingAddressPage> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String addressLine1 = '';
  String state = '';
  String city = '';
  String postalCode = '';
  String country = '';

  Future<void> _storeShippingAddress() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      await firestore.collection('users').doc(widget.userId).set({
        'name': name,
        'addressLine1': addressLine1,
        'city': city,
        'state': state,
        'postalCode': postalCode,
        'country': country,
      }, SetOptions(merge: true));

      print("Shipping Address Added");

      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => PaymentInfoPage(userId: widget.userId)));
    } catch (error) {
      print("Failed to add shipping address: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Enter Shipping Address'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Address Line 1'),
                onSaved: (value) => addressLine1 = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your address' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'City'),
                onSaved: (value) => city = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your city' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'State'),
                onSaved: (value) => state = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your state' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Postal Code'),
                onSaved: (value) => postalCode = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your postal code' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Country'),
                onSaved: (value) => country = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your country' : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      _storeShippingAddress();
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
