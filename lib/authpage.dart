// Authpage.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:primefit/profilePage.dart';
import 'package:primefit/register.dart'; // Make sure ProfilePage is exported from here

class Authpage extends StatelessWidget {
  const Authpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Handle loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // Handle errors
          if (snapshot.hasError) {
            return const Center(
              child: Text('Something went wrong. Please try again.'),
            );
          }
          
          // Check if user is signed in
          if (snapshot.hasData && snapshot.data != null) {
            return const ProfilePage();
          } else {
            return const RegistrationPage();
          }
        },
      ),
    );
  }
}