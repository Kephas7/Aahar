import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/themes/aahar_theme.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AaharTheme.darkBg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 3),
                Center(child: SvgPicture.string(_kLogoSvg, width: 88, height: 88)),
                const SizedBox(height: 28),
                const Text(
                  'Aahar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 46,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Track your micronutrients.\nEat right for Nepal.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
                const Spacer(flex: 4),
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () => context.go('/onboarding'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AaharTheme.brandLime,
                      foregroundColor: AaharTheme.darkBg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Get started',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () => context.go('/login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AaharTheme.darkSurface,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Log in',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const String _kLogoSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 88 88" fill="none">
  <rect width="88" height="88" rx="20" fill="#163728"/>
  <ellipse cx="29" cy="40" rx="8" ry="12" fill="#4ECDB4" transform="rotate(-10 29 40)"/>
  <ellipse cx="44" cy="36" rx="8.5" ry="14" fill="#F5C842"/>
  <ellipse cx="59" cy="40" rx="8" ry="12" fill="#F4899E" transform="rotate(10 59 40)"/>
  <path d="M16 54 Q44 74 72 54" stroke="white" stroke-width="2.5" stroke-linecap="round"/>
  <line x1="37" y1="68" x2="51" y2="68" stroke="white" stroke-width="2.5" stroke-linecap="round"/>
</svg>
''';
