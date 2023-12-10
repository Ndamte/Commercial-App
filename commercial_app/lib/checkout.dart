import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:commercial_app/bottom_nav.dart';
import 'package:commercial_app/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'products.dart';
import 'orders.dart';

class CheckoutPage extends StatefulWidget {
  final String userId;

  const CheckoutPage({Key? key, required this.userId}) : super(key: key);
  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? shippingAddress;
  Map<String, dynamic>? paymentMethod;
  List<Product>? cartItems;
  final CollectionReference cartCollection =
      FirebaseFirestore.instance.collection('carts');

  double subtotal = 0.0;
  static const double taxRate = 0.08;
  @override
  void initState() {
    super.initState();
    if (user != null) {
      fetchData();
    }
  }

  void fetchData() async {
    try {
      final userDocRef =
          FirebaseFirestore.instance.collection('users').doc(widget.userId);
      final userDocSnapshot = await userDocRef.get();
      final cartItemsSnapshot = await FirebaseFirestore.instance
          .collection('carts')
          .doc(widget.userId)
          .collection('cartItems')
          .get();

      if (userDocSnapshot.exists) {
        Map<String, dynamic> userData =
            userDocSnapshot.data() as Map<String, dynamic>;
        setState(() {
          shippingAddress = userData;
          paymentMethod = userData['paymentInfo'] as Map<String, dynamic>?;
          cartItems = cartItemsSnapshot.docs
              .map(
                  (doc) => Product.fromJson(doc.data() as Map<String, dynamic>))
              .toList();
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
    if (cartItems != null) {
      calculateOrderSummary();
    }
  }

  void calculateOrderSummary() {
    double tempSubtotal = 0.0;
    for (var item in cartItems!) {
      tempSubtotal += item.price * item.quantity;
      print('Item Price: ${item.price}, Quantity: ${item.quantity}');
    }

    print('Subtotal: $tempSubtotal');

    setState(() {
      subtotal = tempSubtotal;
    });
  }

  double get totalTax => subtotal * taxRate;

  double get orderTotal => subtotal + totalTax;

  Future<void> createOrder() async {
    if (cartItems == null || cartItems!.isEmpty) {
      print('Cart items are empty');
      return;
    }

    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      final userDocRef =
          FirebaseFirestore.instance.collection('users').doc(widget.userId);
      final userDocSnapshot = await userDocRef.get();

      if (userDocSnapshot.exists) {
        Map<String, dynamic> userData =
            userDocSnapshot.data() as Map<String, dynamic>;
        String orderId = firestore.collection('orders').doc().id;
        List<Map<String, dynamic>> items = cartItems!.map((Product product) {
          return {
            'productId': product.id,
            'productName': product.title,
            'unitPrice': product.price,
            'quantity': product.quantity,
            'totalPrice': product.price * product.quantity,
          };
        }).toList();

        double orderTotalPrice =
            items.fold(0, (sum, item) => sum + item['totalPrice']);

        double tax = orderTotalPrice * 0.08;

        orderTotalPrice += tax;

        await firestore.collection('orders').doc(orderId).set({
          'orderId': orderId,
          'userId': widget.userId,
          'items': items,
          'totalPrice': orderTotalPrice,
          'date': DateTime.now(),
          'shippedTo': "${userData['firstName']} ${userData?['lastName']}",
          'shippingAddress': {
            'addressLine1': ' ${shippingAddress!['addressLine1']}',
            'city': userData['city'],
            'state': userData['state'],
            'postalCode': userData['postalCode'],
            'country': userData['country'],
          },
          'paymentMethod': userData?['paymentInfo'],
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> clearAllCarts() async {
    firebase_auth.User? currentUser =
        firebase_auth.FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      throw Exception('No user logged in');
    }

    String userId = currentUser.uid;

    try {
      QuerySnapshot cartItemsSnapshot =
          await cartCollection.doc(userId).collection('cartItems').get();

      for (QueryDocumentSnapshot doc in cartItemsSnapshot.docs) {
        await cartCollection
            .doc(userId)
            .collection('cartItems')
            .doc(doc.id)
            .delete();
      }

      print('All items removed from the cart');
    } catch (error) {
      throw Exception('Failed to clear the cart: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Checkout')),
      body: user == null
          ? Center(child: Text('No user logged in'))
          : SingleChildScrollView(
              child: Column(
                children: [
                  Card(
                    margin: EdgeInsets.all(8),
                    child: Container(
                      padding: EdgeInsets.all(20),
                      child: shippingAddress != null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Shipping Address',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                Divider(),
                                Text(
                                    'Street Name: ${shippingAddress!['addressLine1']}'),
                                Text('City:${shippingAddress!['city']}'),
                                Text('State: ${shippingAddress!['state']} '),
                                Text('Zip: ${shippingAddress!['postalCode']}'),
                              ],
                            )
                          : Text('Shipping Address: Not available'),
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.all(8),
                    child: Container(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text('Payment Method',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          Divider(),
                          Text(
                            'Card ending in ****${paymentMethod?['cardNumber'].substring(paymentMethod?['cardNumber'].length - 4)}',
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.all(8),
                    child: Container(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            'Review Items',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Divider(),
                          ...?cartItems?.map((product) {
                            return ListTile(
                              leading: SizedBox(
                                height: 60,
                                width: 90,
                                child: Image.network(
                                  product.thumbnail,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              title: Text(product.title),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Quantity: ${product.quantity}'),
                                  Text(
                                      'Total Price: \$${(product.price * product.quantity).toStringAsFixed(2)}'),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.all(8),
                    child: Container(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Order Summary',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Items:'),
                              Text('\$${subtotal.toStringAsFixed(2)}'),
                            ],
                          ),
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Shipping & handling:'),
                              Text('\$0.00'),
                            ],
                          ),
                          SizedBox(height: 5),
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total before tax:'),
                              Text('\$${subtotal.toStringAsFixed(2)}'),
                            ],
                          ),
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Estimated tax to be collected:'),
                              Text('\$${totalTax.toStringAsFixed(2)}'),
                            ],
                          ),
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Order total:',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              Text('\$${orderTotal.toStringAsFixed(2)}',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        createOrder();
                        clearAllCarts();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Thank you for your order! Your order has been placed.')),
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BottomNav(),
                          ),
                        );
                      },
                      child: Text('Place Your Order'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
