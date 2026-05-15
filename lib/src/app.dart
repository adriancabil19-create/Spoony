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
            primaryColor: const Color(0xFF006994),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF00BCD4),
              primary: const Color(0xFF006994),
              secondary: const Color(0xFF50C878),
            ),
            scaffoldBackgroundColor: const Color(0xFFF4FBFF),
            fontFamily: 'Inter',
            textTheme: ThemeData.light().textTheme.copyWith(
                  headlineLarge: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF00314F),
                  ),
                  titleLarge: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF005A7C),
                  ),
                  bodyLarge: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF314A5B),
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
          },
        );
  }
}
