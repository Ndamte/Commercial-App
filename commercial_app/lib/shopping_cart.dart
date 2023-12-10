import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:commercial_app/checkout.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'Products.dart';

class ShoppingCartPage extends StatefulWidget {
  @override
  _ShoppingCartPageState createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage> {
  List<Product> cartProducts = [];
  String? userId;
  final CollectionReference cartCollection =
      FirebaseFirestore.instance.collection('carts');

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    firebase_auth.User? currentUser =
        firebase_auth.FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        userId = currentUser.uid;
      });
    }
  }

  Future<void> addToCart(Product product) async {
    firebase_auth.User? currentUser =
        firebase_auth.FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String userId = currentUser.uid;

      return cartCollection
          .doc(userId)
          .collection('cartItems')
          .doc(product.id.toString())
          .set(product.toJson());
    } else {
      throw Exception('No user logged in');
    }
  }

  Future<void> removeFromCart(Product product) async {
    firebase_auth.User? currentUser =
        firebase_auth.FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String userId = currentUser.uid;

      return cartCollection
          .doc(userId)
          .collection('cartItems')
          .doc(product.id.toString())
          .delete();
    } else {
      throw Exception('No user logged in');
    }
  }

  void updateQuantity(Product product, int newQuantity) async {
    if (newQuantity < 1) return;

    product.quantity = newQuantity;

    firebase_auth.User? currentUser =
        firebase_auth.FirebaseAuth.instance.currentUser;
    if (currentUser != null && product.id != null) {
      await FirebaseFirestore.instance
          .collection('carts')
          .doc(currentUser.uid)
          .collection('cartItems')
          .doc(product.id.toString())
          .update({'quantity': newQuantity});
    }
  }

  Stream<List<Product>> fetchCartItems() {
    firebase_auth.User? currentUser =
        firebase_auth.FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String userId = currentUser.uid;

      return cartCollection.doc(userId).collection('cartItems').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Product.fromJson(doc.data()))
              .toList());
    } else {
      return Stream.empty();
    }
  }

  /*
  Stream<List<Product>> updateCartProducts() {
  firebase_auth.User? currentUser = firebase_auth.FirebaseAuth.instance.currentUser;

  if (currentUser != null) {
    String userId = currentUser.uid;

    return cartCollection.doc(userId).collection('cartItems').snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => Product.fromJson(doc.data()))
          .toList());
  } else {
    
    return Stream.empty();
  }
}

*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Shopping Cart'),
      ),
      body: StreamBuilder<List<Product>>(
        stream: fetchCartItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            cartProducts = snapshot.data!;
            return ListView.builder(
              itemCount: cartProducts.length,
              itemBuilder: (context, index) {
                var product = cartProducts[index];
                return ShoppingCartItem(
                  product: product,
                  itemName: product.title,
                  itemPrice: product.price.toDouble(),
                  quantity: 1,
                  imageUrl: product.thumbnail,
                  onQuantityChanged: (newQuantity) {
                    updateQuantity(product, newQuantity);
                  },
                  onRemove: () {
                    removeFromCart(product);
                  },
                  cartCollection: cartCollection,
                );
              },
            );
          } else {
            return Center(child: Text('Your cart is empty.'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (cartProducts.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      'Your cart is empty. Add items before checking out.')),
            );
          } else if (userId != null) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => CheckoutPage(userId: userId!)));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('No user logged in')),
            );
          }
        },
        child: Icon(Icons.shopping_cart_checkout),
        tooltip: 'Go to Checkout',
      ),
    );
  }
}

class ShoppingCartItem extends StatefulWidget {
  final Product product;
  final String itemName;
  final double itemPrice;
  final String imageUrl;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;
  final CollectionReference cartCollection;

  const ShoppingCartItem({
    Key? key,
    required this.product,
    required this.itemName,
    required this.itemPrice,
    required this.imageUrl,
    required this.onQuantityChanged,
    required this.onRemove,
    required int quantity,
    required this.cartCollection,
  }) : super(key: key);

  @override
  _ShoppingCartItemState createState() => _ShoppingCartItemState();
}

class _ShoppingCartItemState extends State<ShoppingCartItem> {
  int quantity = 1;
  Future<void> removeFromCart(Product product) async {
    firebase_auth.User? currentUser =
        firebase_auth.FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No user logged in')),
      );
      return;
    }

    String userId = currentUser.uid;

    try {
      await widget.cartCollection
          .doc(userId)
          .collection('cartItems')
          .doc(product.id.toString())
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product.title} removed from cart')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove the item from the cart')),
      );
    }
  }

  void _incrementQuantity() {
    setState(() {
      quantity++;
      widget.onQuantityChanged(quantity);
    });
  }

  void _decrementQuantity() {
    if (quantity > 1) {
      setState(() {
        quantity--;
        widget.onQuantityChanged(quantity);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = quantity * widget.itemPrice;

    return Card(
      margin: EdgeInsets.all(2.0),
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: ListTile(
          leading: Image.network(
            widget.imageUrl,
            fit: BoxFit.cover,
          ),
          title: Text(widget.itemName),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Quantity:'),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: _decrementQuantity,
                  ),
                  Text('$quantity', textAlign: TextAlign.center),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: _incrementQuantity,
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('Remove:'),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      removeFromCart(widget.product);
                    },
                  ),
                ],
              ),
            ],
          ),
          trailing: Text('\$${totalPrice.toStringAsFixed(2)}'),
          isThreeLine: true,
          dense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          onTap: () {},
        ),
      ),
    );
  }
}
