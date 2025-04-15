import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/logger.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final AppLogger _logger = AppLogger();
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Easy Shopping',
      description:
          'Browse through a wide selection of groceries from the comfort of your home',
      image: 'assets/images/make_groceries_shopping.jpg',
    ),
    OnboardingPage(
      title: 'Secure Payments',
      description: 'Pay securely using your preferred payment method',
      image: 'assets/images/secure_payment.jpg',
    ),
    OnboardingPage(
      title: 'Fast Delivery',
      description: 'Get your groceries delivered to your doorstep quickly',
      image: 'assets/images/earn_money.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _logger.debug('OnboardingScreen: Initializing');
    _logger.info('Total onboarding pages: ${_pages.length}');
  }

  @override
  void dispose() {
    _logger.debug('OnboardingScreen: Disposing page controller');
    _pageController.dispose();
    super.dispose();
  }

  void _onNextPage() async {
    try {
      if (_currentPage == _pages.length - 1) {
        _logger.info('Completing onboarding process');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('hasSeenOnboarding', true);

        if (mounted) {
          _logger.debug('Navigating to welcome screen');
          context.go('/welcome');
        }
      } else {
        _logger.debug('Moving to next onboarding page');
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } catch (e, stackTrace) {
      _logger.error('Error during onboarding navigation',
          error: e, stackTrace: stackTrace);
    }
  }

  void _onSkip() async {
    try {
      _logger.info('User skipped onboarding');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasSeenOnboarding', true);

      if (mounted) {
        _logger.debug('Navigating to welcome screen after skipping');
        context.go('/welcome');
      }
    } catch (e, stackTrace) {
      _logger.error('Error skipping onboarding',
          error: e, stackTrace: stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      _logger.debug('Building OnboardingScreen');
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                      _logger.debug('Onboarding page changed to: $index');
                    });
                  },
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return OnboardingPageWidget(page: page);
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: _onSkip,
                      child: const Text('Skip'),
                    ),
                    Row(
                      children: List.generate(
                        _pages.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentPage == index
                                ? Theme.of(context).primaryColor
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _onNextPage,
                      child: Text(_currentPage == _pages.length - 1
                          ? 'Finish'
                          : 'Next'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e, stackTrace) {
      _logger.error('Error building OnboardingScreen',
          error: e, stackTrace: stackTrace);
      return Scaffold(
        body: Center(
          child: Text('Error: ${e.toString()}'),
        ),
      );
    }
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String image;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.image,
  });
}

class OnboardingPageWidget extends StatelessWidget {
  final OnboardingPage page;
  final AppLogger _logger = AppLogger();

  OnboardingPageWidget({Key? key, required this.page}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    try {
      _logger.debug('Building OnboardingPageWidget for: ${page.title}');
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            page.image,
            height: 300,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 40),
          Text(
            page.title,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              page.description,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    } catch (e, stackTrace) {
      _logger.error('Error building OnboardingPageWidget',
          error: e, stackTrace: stackTrace);
      return Center(
        child: Text('Error: ${e.toString()}'),
      );
    }
  }
}
