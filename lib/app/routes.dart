import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/onboarding/screens/login_screen.dart';
import '../features/onboarding/screens/onboarding_body_screen.dart';
import '../features/onboarding/screens/onboarding_goal_screen.dart';
import '../features/onboarding/screens/onboarding_lifestyle_screen.dart';
import '../features/onboarding/screens/onboarding_name_screen.dart';
import '../features/onboarding/screens/onboarding_targets_screen.dart';
import '../features/onboarding/screens/signup_screen.dart';
import '../features/onboarding/screens/welcome_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) async {
    final preferences = await SharedPreferences.getInstance();
    final onboardingComplete =
        preferences.getBool('onboarding_complete') ?? false;
    final location = state.uri.path;

    if (onboardingComplete &&
        (location == '/splash' || location == '/onboarding')) {
      return '/home/dashboard';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/onboarding/name',
      builder: (context, state) => const OnboardingNameScreen(),
    ),
    GoRoute(
      path: '/onboarding/body',
      builder: (context, state) => const OnboardingBodyScreen(),
    ),
    GoRoute(
      path: '/onboarding/goal',
      builder: (context, state) => const OnboardingGoalScreen(),
    ),
    GoRoute(
      path: '/onboarding/lifestyle',
      builder: (context, state) => const OnboardingLifestyleScreen(),
    ),
    GoRoute(
      path: '/onboarding/targets',
      builder: (context, state) => const OnboardingTargetsScreen(),
    ),
    GoRoute(path: '/home', redirect: (context, state) => '/home/dashboard'),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => ScaffoldWithNavBar(
        navigationShell: navigationShell,
        child: navigationShell,
      ),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home/dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home/log',
              builder: (context, state) => const LogScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home/plan',
              builder: (context, state) => const PlanScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home/progress',
              builder: (context, state) => const ProgressScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    super.key,
    required this.navigationShell,
    required this.child,
  });

  final StatefulNavigationShell navigationShell;
  final Widget child;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0F0F0F),
          border: Border(top: BorderSide(width: 0.5, color: Color(0xFF2A2A2A))),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: navigationShell.currentIndex,
          onTap: _onTap,
          backgroundColor: const Color(0xFF0F0F0F),
          selectedItemColor: const Color(0xFFCAFF3D),
          unselectedItemColor: const Color(0xFF555555),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Log'),
            BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu_outlined), label: 'Plan'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: 'Progress'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

// ── Placeholder screens (to be replaced one by one) ──────────────────────────

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const _PlaceholderScreen(title: 'Dashboard');
}

class LogScreen extends StatelessWidget {
  const LogScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const _PlaceholderScreen(title: 'Food Log');
}

class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const _PlaceholderScreen(title: 'Plan');
}

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const _PlaceholderScreen(title: 'Progress');
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const _PlaceholderScreen(title: 'Profile');
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F0F),
        title: Text(title, style: const TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Text(
          title,
          style: const TextStyle(color: Colors.white54, fontSize: 18),
        ),
      ),
    );
  }
}
