import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  bool _isLastPage = false;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      image: 'assets/images/task_posting.jpg',
      title: 'Post Tasks Easily',
      description:
          'Need help with grocery shopping or daily chores? Post a task in minutes!',
      color: const Color(0xFF6C63FF),
    ),
    OnboardingPage(
      image: 'assets/images/make_groceries_shopping.jpg',
      title: 'Connect Locally',
      description:
          'Find people nearby who are ready to help or complete tasks like grocery shopping.',
      color: const Color(0xFF00BFA6),
    ),
    OnboardingPage(
      image: 'assets/images/secure_payment.jpg',
      title: 'Safe & Secure Payments',
      description: 'Pay seamlessly, and let us handle the rest.',
      color: const Color(0xFFFF6584),
    ),
    OnboardingPage(
      image: 'assets/images/earn_money.png',
      title: 'Earn by Helping Others',
      description: 'Use your skills or time to assist others and make money.',
      color: const Color(0xFFFFB74D),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNextPage() {
    if (_isLastPage) {
      Navigator.pushReplacementNamed(context, '/welcome');
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PageView
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() {
                _isLastPage = index == _pages.length - 1;
              });
            },
            itemBuilder: (context, index) {
              return _buildPage(_pages[index]);
            },
          ),

          // Skip button
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/welcome'),
              child: Text(
                'Skip',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),

          // Bottom navigation
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page indicator
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _pages.length,
                    effect: WormEffect(
                      spacing: 16,
                      dotColor: Colors.grey[300]!,
                      activeDotColor: _pages[_pageController.hasClients
                              ? _pageController.page?.round() ?? 0
                              : 0]
                          .color,
                    ),
                  ),

                  // Next/Get Started button
                  _buildNextButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            page.color.withOpacity(0.3),
            Colors.white,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image
          Expanded(
            flex: 3,
            child: Image.asset(
              page.image,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 50),
          // Title
          Text(
            page.title,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          // Description
          Text(
            page.description,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return ElevatedButton(
      onPressed: _onNextPage,
      style: ElevatedButton.styleFrom(
        backgroundColor: _pages[_pageController.hasClients
                ? _pageController.page?.round() ?? 0
                : 0]
            .color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text(
        _isLastPage ? 'Get Started' : 'Next',
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class OnboardingPage {
  final String image;
  final String title;
  final String description;
  final Color color;

  OnboardingPage({
    required this.image,
    required this.title,
    required this.description,
    required this.color,
  });
}
