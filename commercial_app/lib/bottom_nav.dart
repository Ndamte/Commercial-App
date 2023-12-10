import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:commercial_app/checkout.dart';
import 'package:commercial_app/orders.dart';
import 'package:commercial_app/transition_page.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import 'home_screen.dart';
import 'package:flutter/material.dart';
import 'shopping_cart.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({Key? key}) : super(key: key);

  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;
  String? userId;
  @override
  void initState() {
    super.initState();
    fetchUserId();
  }

  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void fetchUserId() async {
    firebase_auth.User? currentUser =
        firebase_auth.FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userSnapshot.exists) {
        setState(() {
          userId = userSnapshot.id;
        });
      } else {
        print('User document does not exist');
      }
    } else {
      print('No user logged in');
    }
  }

  List<Widget> get _pages {
    return [
      const HomeScreen(),
      ShoppingCartPage(),
      if (userId != null) OrdersPage(userId: userId!),
      TransitionPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white,
            currentIndex: _selectedIndex,
            onTap: _navigateBottomBar,
            type: BottomNavigationBarType.shifting,
            items: [
              BottomNavigationBarItem(
                  icon: const Icon(Icons.home),
                  label: "Shopping",
                  backgroundColor: Colors.black),
              BottomNavigationBarItem(
                  icon: const Icon(Icons.shopping_cart),
                  label: 'Your Cart',
                  backgroundColor: Colors.black),
              BottomNavigationBarItem(
                  icon: const Icon(Icons.list),
                  label: 'Orders',
                  backgroundColor: Colors.black),
              BottomNavigationBarItem(
                  icon: const Icon(Icons.settings),
                  label: 'Settings',
                  backgroundColor: Colors.black),

              /*
          BottomNavigationBarItem(
            icon: const Icon(Icons.lock_clock_rounded), 
            label: 'Shopping History',
            backgroundColor: Colors.grey[350]
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings), 
            label: 'Settings',
            backgroundColor: Colors.grey[350]
          ),
          */
            ]));
  }
}
