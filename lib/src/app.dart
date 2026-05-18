import 'package:flutter/material.dart';

import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/explore_screen.dart';
import 'screens/booking_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/driver_screen.dart';

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
            primaryColor: const Color(0xFF0EA5E9),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0EA5E9),
              primary: const Color(0xFF0EA5E9),
              secondary: const Color(0xFF14B8A6),
            ),
            scaffoldBackgroundColor: const Color(0xFFF8FAFC),
            fontFamily: 'Inter',
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: _FadePageTransition(),
                TargetPlatform.iOS: _FadePageTransition(),
                TargetPlatform.linux: _FadePageTransition(),
                TargetPlatform.macOS: _FadePageTransition(),
                TargetPlatform.windows: _FadePageTransition(),
              },
            ),
            textTheme: ThemeData.light().textTheme.copyWith(
                  headlineLarge: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                  titleLarge: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0EA5E9),
                  ),
                  bodyLarge: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF64748B),
                  ),
                ),
          ),
          initialRoute: AuthScreen.routeName,
          routes: {
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
