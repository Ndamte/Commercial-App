import 'package:commercial_app/bottom_nav.dart';
import 'package:commercial_app/personal_info.dart';
import 'package:commercial_app/transition_page.dart';

import 'product_tile.dart';
import 'Products.dart';
import 'remote_services.dart';
import 'package:flutter/material.dart';

//Text('${listOfProducts?.products.length.toString()}'),

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Products? listOfProducts;
  bool isLoaded = false;
  String searchTerm = '';
  String selectedCategory = 'All';
  List<String> categories = [
    "All",
    "smartphones",
    "laptops",
    "fragrances",
    "skincare",
    "groceries",
    "home-decoration",
    "furniture",
    "tops",
    "womens-dresses",
    "womens-shoes",
    "mens-shirts",
    "mens-shoes",
    "mens-watches",
    "womens-watches",
    "womens-bags",
    "womens-jewellery",
    "sunglasses",
    "automotive",
    "motorcycle",
    "lighting"
  ];

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    listOfProducts = await RemoteServices.fetchProducts();
    if (listOfProducts != null) {
      setState(() {
        isLoaded = true;
      });
    }
  }

  /*
  List<Product>? getFilteredProducts() {
    if (searchTerm.isEmpty) {
      return listOfProducts?.products;
    } else {
      return listOfProducts?.products
          .where((product) =>
              product.title.toLowerCase().contains(searchTerm.toLowerCase()))
          .toList();
    }
  }
  */
  List<Product>? getFilteredProducts() {
    if (selectedCategory == 'All') {
      return searchTerm.isEmpty
          ? listOfProducts?.products
          : listOfProducts?.products
              .where((product) => product.title
                  .toLowerCase()
                  .contains(searchTerm.toLowerCase()))
              .toList();
    }
    if (searchTerm.isEmpty && selectedCategory == 'All') {
      return listOfProducts?.products;
    } else if (searchTerm.isNotEmpty && selectedCategory == 'All') {
      return listOfProducts?.products
          .where((product) =>
              product.title.toLowerCase().contains(searchTerm.toLowerCase()))
          .toList();
    } else if (searchTerm.isEmpty && selectedCategory != 'All') {
      return listOfProducts?.products
          .where((product) => product.category == selectedCategory)
          .toList();
    } else {
      return listOfProducts?.products
          .where((product) =>
              product.title.toLowerCase().contains(searchTerm.toLowerCase()) &&
              product.category == selectedCategory)
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Shop',
                style: TextStyle(
                    fontFamily: 'avenir',
                    fontSize: 32,
                    fontWeight: FontWeight.w900))),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search Product',
                labelStyle: TextStyle(color: Colors.black),
                prefixIcon: Icon(Icons.search, color: Colors.black),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchTerm = value;
                });
              },
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Categories:'),
                ),
                ...categories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: selectedCategory == category,
                      onSelected: (selected) {
                        setState(() {
                          selectedCategory = selected ? category : 'All';
                        });
                      },
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: (2 / 3),
              ),
              itemCount: getFilteredProducts()?.length ?? 0,
              itemBuilder: (context, index) {
                //var product = listOfProducts?.products[index];
                var product = getFilteredProducts()?[index];
                if (product != null) {
                  return ProductTile(product: product);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
