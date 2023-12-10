import 'Products.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'shopping_cart.dart';
import 'product_page.dart';

class ProductTile extends StatelessWidget {
  final Product product;
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ProductTile({Key? key, required this.product}) : super(key: key);

  void onAddToCart() async {
    try {
      firebase_auth.User? currentUser = _firebaseAuth.currentUser;
      if (currentUser != null) {
        String userId = currentUser.uid;

        await _firestore
            .collection('carts')
            .doc(userId)
            .collection('cartItems')
            .doc(product.id.toString())
            .set(product.toJson(), SetOptions(merge: true));

        print('product added to cart');
      } else {
        print('no user logged in');
      }
    } catch (e) {
      print('other error');
      print(e.toString());
    }
    print('error not caught');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProductPage(product: product)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  height: 120,
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(4)),
                  child: Image.network(product.thumbnail, fit: BoxFit.cover)),
              SizedBox(height: 4),
              Text(
                product.title,
                maxLines: 2,
                style: const TextStyle(
                    fontFamily: 'avenir', fontWeight: FontWeight.w800),
                overflow: TextOverflow.fade,
              ),
              Flexible(
                child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Row(
                      children: [
                        Text(
                          '${product.rating.toString()} / 5',
                          style: const TextStyle(color: Colors.white),
                        ),
                        const Icon(Icons.star, size: 16, color: Colors.white)
                      ],
                    )),
              ),
              SizedBox(height: 5),
              Flexible(
                child: Text(
                  '\$${product.price}',
                  style: const TextStyle(fontSize: 16, fontFamily: 'avenir'),
                ),
              ),
              SizedBox(height: 4),
              ElevatedButton(
                onPressed: () async {
                  onAddToCart();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ShoppingCartPage()),
                  );
                },
                child: const Text('Add to Cart'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.black,
                  onPrimary: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
