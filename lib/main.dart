
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:primefit/YogaMatsPage.dart';
import 'package:primefit/addtocart.dart';

import 'package:primefit/checkout.dart';
import 'package:primefit/homepage.dart';
import 'package:primefit/profilePage.dart';
import 'package:primefit/search.dart';
// import 'package:primefit/register.dart';
// import 'package:primefit/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:primefit/welcome.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Prime Fit',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const Welcome(), // Changed to Welcome page
      routes: {
        '/YogaMatsPage': (context) => Yogamatspage(),
        '/main': (context) => const MainNavigationPage(),
        '/checkout': (context) => CheckoutPage(),
        '/homepage': (context) => const HomePage(),
        '/search': (context) => ShopSearchPage(),
        '/profilePage':(context) => const ProfilePage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/addtocart') {
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => AddToCartPage(
              productId: args?['productId'] ?? '',
              productName: args?['productName'] ?? '',
              productPrice: args?['productPrice'] ?? 0.0,
              productImage: args?['productImage'] ?? '',
              selectedQuantity: args?['selectedQuantity'] ?? 1,
            ),
          );
        }
        return null;
      },
    );
  }
}




  