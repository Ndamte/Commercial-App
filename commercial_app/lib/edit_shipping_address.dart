import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";

class EditShippingAddress extends StatefulWidget {
  const EditShippingAddress({Key? key}) : super(key: key);

  @override
  _EditShippingAddressState createState() => _EditShippingAddressState();
}

class _EditShippingAddressState extends State<EditShippingAddress> {
  FirebaseAuth auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String addressLine1 = '';
  String state = '';
  String city = '';
  String postalCode = '';
  String country = '';

  // Text editing controllers
  final TextEditingController _addressLine1Controller = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  @override
  void dispose() {
    // Dispose controllers when the widget is disposed
    _addressLine1Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _storeShippingAddress() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      await firestore.collection('users').doc(auth.currentUser?.uid).update({
        'name': name,
        'addressLine1': addressLine1,
        'city': city,
        'state': state,
        'postalCode': postalCode,
        'country': country,
      });

      print("Shipping Address Updated");
      // Clear the controllers after successful update
      _addressLine1Controller.clear();
      _cityController.clear();
      _stateController.clear();
      _postalCodeController.clear();
      _countryController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Shipping Address Updated'),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (error) {
      print("Failed to add shipping address: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light(),
      child: Scaffold(
        backgroundColor: ThemeData.light().canvasColor,
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(
            color: Colors.white, //change your color here
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                Text('Enter New Shipping Address Info',
                    style: TextStyle(
                        fontFamily: 'avenir',
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.black)),
                TextFormField(
                  controller: _addressLine1Controller,
                  style: const TextStyle(color: Colors.black),
                  decoration:
                      const InputDecoration(labelText: 'Address Line 1'),
                  onSaved: (value) => addressLine1 = value!,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your address' : null,
                ),
                TextFormField(
                  controller: _cityController,
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(labelText: 'City'),
                  onSaved: (value) => city = value!,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your city' : null,
                ),
                TextFormField(
                  controller: _stateController,
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(labelText: 'State'),
                  onSaved: (value) => state = value!,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your state' : null,
                ),
                TextFormField(
                  controller: _postalCodeController,
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(labelText: 'Postal Code'),
                  onSaved: (value) => postalCode = value!,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your postal code' : null,
                ),
                TextFormField(
                  controller: _countryController,
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(labelText: 'Country'),
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
