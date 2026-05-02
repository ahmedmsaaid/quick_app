import 'package:flutter/material.dart';
import 'package:base_app/core/utils/extensions.dart';

import '../../../core/routes/app_routes.dart';
import '../data/models/on_boarding_model.dart';
import '../widgets/onboarding_bottom_controls.dart';
import '../widgets/onboarding_page_item.dart';
import '../widgets/onboarding_skip_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController(
    viewportFraction: 0.90,
    initialPage: 0,
  );
  int _currentPage = 0;
  double _currentPageValue = 0.0;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _pageController.addListener(_onPageScroll);
    _initAnimations();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();
  }

  void _onPageScroll() {
    setState(() {
      _currentPageValue = _pageController.page ?? 0.0;
      _currentPage = _pageController.page?.round() ?? 0;
    });
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageScroll);
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    if (mounted) {
      context.pushNamed(AppRoutes.chooseYourLanguageScreen);
    }
  }

  void _skipToEnd() {
    _pageController.animateToPage(
      onboardingPages().length - 1,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  void _nextPage() {
    if (_currentPage < onboardingPages().length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: OnboardingSkipButton(
                currentPage: _currentPage,
                totalPages: onboardingPages().length,
                onSkip: _skipToEnd,
                fadeAnimation: _fadeAnimation,
                slideAnimation: _slideAnimation,
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: onboardingPages().length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return OnboardingPageItem(
                    index: index,
                    currentPageValue: _currentPageValue,
                    page: onboardingPages()[index],
                  );
                },
              ),
            ),
            OnboardingBottomControls(
              currentPage: _currentPage,
              totalPages: onboardingPages().length,
              pageController: _pageController,
              onNext: _nextPage,
              fadeAnimation: _fadeAnimation,
              slideAnimation: _slideAnimation,
            ),
          ],
        ),
      ),
    );
  }
}
