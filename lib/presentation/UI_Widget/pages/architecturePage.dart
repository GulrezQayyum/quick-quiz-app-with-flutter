import 'package:flutter/material.dart';

class ArchitecturePage extends StatelessWidget {
  const ArchitecturePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF097EA2), // your app color
      appBar: AppBar(
        backgroundColor: const Color(0xFF097EA2), 
        elevation: 50,
        shadowColor: Colors.cyan,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center, // center row contents
          mainAxisSize: MainAxisSize.min, // shrink row to fit content
          children: const [
            Icon(Icons.account_balance),
            SizedBox(width: 2),
            Text(
              " World Architecture",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        centerTitle: true,
      ),
    );
  }
}
