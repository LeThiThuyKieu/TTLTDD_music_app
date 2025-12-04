import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      image: 'assets/images/onboarding_1.png',
      title: 'Listen to the best music everyday with ',
      highlightedText: 'Musea',
      subtitle: ' now!',
    ),
    OnboardingPage(
      image: 'assets/images/onboarding_2.png',
      title: 'Discover millions of songs and ',
      highlightedText: 'create',
      subtitle: ' your perfect playlist!',
    ),
    OnboardingPage(
      image: 'assets/images/onboarding_3.png',
      title: 'Stream music anywhere, anytime with ',
      highlightedText: 'Musea',
      subtitle: '!',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final screenW = MediaQuery.of(context).size.width;

    final topAreaH = screenH * 0.8;
    const cardOverlap = 80.0;
    final cardHeight = screenH * 0.34;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(
                  height: topAreaH,
                  width: double.infinity,
                  // ---- PageView để vuốt + chuyển ảnh ----
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) =>
                        _buildTopVisual(_pages[index], topAreaH, screenW),
                  ),
                ),
                const SizedBox(height: cardOverlap),
              ],
            ),

            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: _buildBottomCard(screenW, cardHeight),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopVisual(OnboardingPage page, double height, double screenW) {
    final imageHeight = height * 0.78;
    final imageWidth = screenW;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // decorative green circles
          Positioned(
            top: height * 0.3,
            left: 40,
            child: _greenCircle(28),
          ),
          Positioned(
            top: height * 0.4,
            right: 48,
            child: _greenCircle(18),
          ),
          Positioned(
            top: height * 0.27,
            right: screenW * 0.22,
            child: _greenCircle(16),
          ),
          Positioned(
            top: height * 0.21,
            right: screenW * 0.35,
            child: _greenCircle(15),
          ),
          Positioned(
            top: height * 0.2,
            left: screenW * 0.33,
            child: _greenCircle(20),
          ),

          // background big green circle
          Positioned(
            top: height * 0.33,
            child: Container(
              width: imageWidth * 0.7,
              height: imageWidth * 0.6,
              decoration: const BoxDecoration(
                color: Color(0xFF1ED760),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // onboarding image
          Positioned(
            top: height * 0.06,
            child: SizedBox(
              width: imageWidth,
              height: imageHeight,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  page.image,
                  fit: BoxFit.contain,
                  alignment: Alignment.topCenter,
                  errorBuilder: (context, error, stack) => Container(
                    color: Colors.grey[200],
                    alignment: Alignment.center,
                    child: const Icon(Icons.image, size: 64, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _greenCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFF1ED760),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildBottomCard(double screenW, double cardHeight) {
    final page = _pages[_currentPage];

    return SizedBox(
      height: cardHeight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(55),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      height: 1.25,
                    ),
                    children: [
                      TextSpan(text: page.title),
                      TextSpan(
                        text: page.highlightedText,
                        style: const TextStyle(
                          color: Color(0xFF1ED760),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      TextSpan(text: page.subtitle),
                    ],
                  ),
                ),
              ),
            ),

            // ---- DOT INDICATOR CLICKABLE ----
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                    (index) => GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: _currentPage == index ? 36 : 10,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? const Color(0xFF1ED760)
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ---- BUTTON ----
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1ED760),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  elevation: 6,
                  shadowColor: const Color(0xFF1ED760).withOpacity(0.5),
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage {
  final String image;
  final String title;
  final String highlightedText;
  final String subtitle;

  OnboardingPage({
    required this.image,
    required this.title,
    required this.highlightedText,
    required this.subtitle,
  });
}
