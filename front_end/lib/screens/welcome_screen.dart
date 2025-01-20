import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Animated background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF6C63FF),
                  Color(0xFF00BFA6),
                ],
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // App logo or image
                    Center(
                      child: Container(
                        width: screenWidth * 0.6,
                        height: screenWidth * 0.6,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.shopping_cart_outlined,
                          size: screenWidth * 0.3,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.06),
                    // Welcome text
                    Text(
                      'Welcome to\nTasker',
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.12,
                        height: 1.2,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      'Your local marketplace for tasks and services',
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.04,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.08),
                    // Login button
                    _buildButton(
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/login'),
                      text: 'Login',
                      isPrimary: true,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    // Register button
                    _buildButton(
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/register'),
                      text: 'Create Account',
                      isPrimary: false,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required VoidCallback onPressed,
    required String text,
    required bool isPrimary,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: isPrimary ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: isPrimary
            ? null
            : Border.all(
                color: Colors.white,
                width: 2,
              ),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isPrimary ? const Color(0xFF6C63FF) : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
