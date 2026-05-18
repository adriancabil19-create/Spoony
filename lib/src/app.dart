import 'package:flutter/material.dart';

import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/explore_screen.dart';
import 'screens/booking_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/admin_screen.dart';

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
          onGenerateRoute: (settings) {
            final Widget page;
            switch (settings.name) {
              case AuthScreen.routeName:
                page = const AuthScreen();
              case ExploreScreen.routeName:
                page = const ExploreScreen();
              case BookingScreen.routeName:
                page = const BookingScreen();
              case DashboardScreen.routeName:
                page = const DashboardScreen();
              case AdminScreen.routeName:
                page = const AdminScreen();
              default:
                page = const HomeScreen();
            }
            return PageRouteBuilder(
              settings: settings,
              pageBuilder: (_, _, _) => page,
              transitionsBuilder: (_, animation, _, child) => FadeTransition(
                opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
                child: child,
              ),
              transitionDuration: const Duration(milliseconds: 220),
            );
          },
        );
  }
}
