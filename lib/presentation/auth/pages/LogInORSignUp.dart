import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:quizapp/presentation/auth/pages/loginPage.dart';
import 'package:quizapp/presentation/auth/pages/signupPage.dart';

class SignuporLoginPage extends StatefulWidget {
  const SignuporLoginPage({super.key});

  @override
  State<SignuporLoginPage> createState() => _SignuporLoginPageState();
}

class _SignuporLoginPageState extends State<SignuporLoginPage> {
  bool _isLoginPressed = false;
  bool _isSignupPressed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF097ea2),
      body: SafeArea(
        child: Stack(
          children: [
            // Top right pattern
            Positioned(
              top: 0,
              right: 0,
              child: Image.asset(
                'assets/images/topPattern.png',
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            
            // Bottom left pattern
            Positioned(
              bottom: 0,
              left: 0,
              child: Image.asset(
                'assets/images/bottomPattern.png',
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            
            // Main content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  
                  // App Logo/Title
                  const Text(
                    'QuickQuiz',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Test your knowledge',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  
                  const Spacer(flex: 1),
                  
                  // Login Section
                  Column(
                    children: [
                      Text(
                        'Already have an account?',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 14),
                      
                      // Frosted Glass Login Button
                      GestureDetector(
                        onTapDown: (_) => setState(() => _isLoginPressed = true),
                        onTapUp: (_) => setState(() => _isLoginPressed = false),
                        onTapCancel: () => setState(() => _isLoginPressed = false),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          curve: Curves.easeOutQuint,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: _isLoginPressed ? 8 : 10,
                                sigmaY: _isLoginPressed ? 8 : 10,
                              ),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withOpacity(
                                        _isLoginPressed ? 0.25 : 0.2,
                                      ),
                                      Colors.white.withOpacity(
                                        _isLoginPressed ? 0.15 : 0.1,
                                      ),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(
                                      _isLoginPressed ? 0.4 : 0.3,
                                    ),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Text(
                                    "LOG IN",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Signup Section
                  Column(
                    children: [
                      Text(
                        'Create an account to get started',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 14),
                      
                      // Frosted Glass Signup Button
                      GestureDetector(
                        onTapDown: (_) => setState(() => _isSignupPressed = true),
                        onTapUp: (_) => setState(() => _isSignupPressed = false),
                        onTapCancel: () => setState(() => _isSignupPressed = false),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignupPage(),
                            ),
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          curve: Curves.easeOutQuint,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: _isSignupPressed ? 8 : 10,
                                sigmaY: _isSignupPressed ? 8 : 10,
                              ),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withOpacity(
                                        _isSignupPressed ? 0.25 : 0.2,
                                      ),
                                      Colors.white.withOpacity(
                                        _isSignupPressed ? 0.15 : 0.1,
                                      ),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(
                                      _isSignupPressed ? 0.4 : 0.3,
                                    ),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Text(
                                    "SIGN UP",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const Spacer(flex: 3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}