import 'Products.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class ProductPage extends StatefulWidget {
  final Product product;
  const ProductPage({Key? key, required this.product}) : super(key: key);

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  String selectedImage = '';
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  void initState() {
    super.initState();
    selectedImage = widget.product.thumbnail;
  }

  void onAddToCart() async {
    try {
      firebase_auth.User? currentUser = _firebaseAuth.currentUser;
      if (currentUser != null) {
        String userId = currentUser.uid;

        await _firestore
            .collection('carts')
            .doc(userId)
            .collection('cartItems')
            .doc(widget.product.id.toString())
            .set(widget.product.toJson(), SetOptions(merge: true));

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Product Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 250,
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
              ),
              child: Image.network(
                selectedImage,
                fit: BoxFit.fitHeight,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.title,
                    style: const TextStyle(
                      fontFamily: 'avenir',
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RatingBar.builder(
                    initialRating: widget.product.rating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: 20,
                    ignoreGestures: true,
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.black,
                    ),
                    onRatingUpdate: (rating) {
                      print(rating);
                    },
                  ),
                  const SizedBox(height: 5),
                  IntrinsicWidth(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 20,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.product.rating.toString()} / 5',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '\$${widget.product.price}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontFamily: 'avenir',
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text(
                        'Brand: ',
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'avenir',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        widget.product.brand,
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'avenir',
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Description:',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'avenir',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.description,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'avenir',
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.product.images.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedImage =
                                  widget.product.images[index] == selectedImage
                                      ? widget.product.thumbnail
                                      : widget.product.images[index];
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Stack(
                              children: [
                                Image.network(
                                  widget.product.images[index],
                                  height: 80,
                                  width: 80,
                                  fit: BoxFit.cover,
                                ),
                                if (widget.product.images[index] ==
                                    selectedImage)
                                  Container(
                                    height: 80,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 3,
                                      ),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 75),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        height: 50,
        margin: const EdgeInsets.all(10),
        child: ElevatedButton(
          onPressed: () {
            onAddToCart();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                //TODO: Add to actual shopping cart
                content: Text('Product added to your cart'),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12))),
          child: const Center(
            child: Text(
              'Add To Cart',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
