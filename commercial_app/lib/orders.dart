import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrdersPage extends StatefulWidget {
  final String userId;

  const OrdersPage({Key? key, required this.userId}) : super(key: key);

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> fetchOrderStream() {
    return firestore
        .collection('orders')
        .where('userId', isEqualTo: widget.userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Order Details'),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: fetchOrderStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            List<Map<String, dynamic>> orders = snapshot.data!;
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                var order = orders[index];
                var shippingAddress = order['shippingAddress'] ?? {};
                var paymentMethod = order['paymentMethod'] ?? {};
                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(order['shippedTo'] ?? 'Unknown'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Street name: ${shippingAddress['addressLine1'] ?? 'Not provided'}'),
                        Text(
                            'City: ${shippingAddress['city'] ?? 'Not provided'}'),
                        Text(
                            'State: ${shippingAddress['state'] ?? 'Not provided'}'),
                        Text(
                            'Zip: ${shippingAddress['postalCode'] ?? 'Not provided'}'),
                        Text('Order ID: ${order['orderId']}'),
                        Text(
                            'Date: ${DateTime.fromMillisecondsSinceEpoch(order['date'].millisecondsSinceEpoch)}'),
                        Text(
                            'Payment Method: Ending in ****${paymentMethod['cardNumber']?.substring(paymentMethod['cardNumber'].length - 4) ?? 'Not provided'}'),
                        Text(
                            'Total Price: \$${order['totalPrice']?.toStringAsFixed(2) ?? '0.00'}'),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: order['items'].map<Widget>((item) {
                            return Text(
                                'Product: ${item['productName']} - Quantity: ${item['quantity']}');
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('No orders found'));
          }
        },
      ),
    );
  }
}
