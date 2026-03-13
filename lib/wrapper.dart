import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quizapp/presentation/auth/pages/loginPage.dart';
import 'package:quizapp/presentation/pages/categories.dart';

// Ensure that the HomePage widget is defined in homePage.dart as below:
// class HomePage extends StatelessWidget { ... }

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        // User is logged in
        if (snapshot.hasData) {
          return const Categories();
        }

        // User is not logged in
        return const LoginPage();
      },
    );
  }
}
