import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/explore_screen.dart';
import 'screens/booking_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/driver_screen.dart';
import 'recovery_flag.dart';

class _FadePageTransition extends PageTransitionsBuilder {
  const _FadePageTransition();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: child,
    );
  }
}

class SpoonyApp extends StatelessWidget {
  const SpoonyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Spoony Cebu Travel',
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: const Color(0xFFD96A2B),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFD96A2B),
              primary: const Color(0xFFD96A2B),
              secondary: const Color(0xFF3F7D58),
            ),
            scaffoldBackgroundColor: const Color(0xFFF8FAFC),
            // Inter for UI text, Poppins for display headings (see textTheme).
            fontFamily: GoogleFonts.inter().fontFamily,
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: _FadePageTransition(),
                TargetPlatform.iOS: _FadePageTransition(),
                TargetPlatform.linux: _FadePageTransition(),
                TargetPlatform.macOS: _FadePageTransition(),
                TargetPlatform.windows: _FadePageTransition(),
              },
            ),
            textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
                  headlineLarge: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                  titleLarge: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFD96A2B),
                  ),
                  bodyLarge: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF64748B),
                  ),
                ),
          ),
          initialRoute: '/',
          routes: {
            // Visitors land on the home page. The login screen only takes over the root
            // URL when returning from an OAuth / password-recovery link.
            '/': (context) => kHasRecoveryToken ? const AuthScreen() : const HomeScreen(),
            AuthScreen.routeName: (context) => const AuthScreen(),
            HomeScreen.routeName: (context) => const HomeScreen(),
            ExploreScreen.routeName: (context) => const ExploreScreen(),
            BookingScreen.routeName: (context) => const BookingScreen(),
            DashboardScreen.routeName: (context) => const DashboardScreen(),
            AdminScreen.routeName: (context) => const AdminScreen(),
            DriverScreen.routeName: (context) => const DriverScreen(),
          },
        );
  }
}
