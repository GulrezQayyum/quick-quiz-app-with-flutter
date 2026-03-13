import 'package:flutter/material.dart';

class SportsPage extends StatelessWidget {
  const SportsPage({super.key});
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
            Icon(Icons.sports_soccer),
            SizedBox(width: 2),
            Text(
              " Sports & Games",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        centerTitle: true,
      ),
    );
  }
}