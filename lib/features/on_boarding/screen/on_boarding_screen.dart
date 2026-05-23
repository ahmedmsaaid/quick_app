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
  late final List<OnBoardingModel> _pages = onboardingPages();

  final PageController _pageController = PageController();

  int _currentPage = 0;
  double _currentPageValue = 0.0;

  late final AnimationController _fadeController;
  late final AnimationController _slideController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _pageController.addListener(_onPageScroll);
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  void _onPageScroll() {
    final page = _pageController.page ?? 0.0;
    final nextPage = page.round().clamp(0, _pages.length - 1).toInt();

    if (!mounted) return;

    setState(() {
      _currentPageValue = page;
      _currentPage = nextPage;
    });
  }

  Future<void> _completeOnboarding() async {
    if (!mounted) return;

    context.pushNamedAndRemoveUntil(AppRoutes.chooseYourLanguageScreen);
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageScroll);
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.topStart,
              child: OnboardingSkipButton(
                currentPage: _currentPage,
                totalPages: _pages.length,
                onSkip: _skipOnboarding,
                fadeAnimation: _fadeAnimation,
                slideAnimation: _slideAnimation,
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return OnboardingPageItem(
                    index: index,
                    currentPageValue: _currentPageValue,
                    page: _pages[index],
                  );
                },
              ),
            ),
            OnboardingBottomControls(
              currentPage: _currentPage,
              totalPages: _pages.length,
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