import 'package:flutter/material.dart';
import '../models.dart';
import '../data/cebu_data.dart';
import 'booking_screen.dart';
import 'explore_screen.dart';
import 'dashboard_screen.dart';
import 'auth_screen.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/home';
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final popular = cebuDestinations.take(3).toList();
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _NavBar(current: 'home'),
            // Hero Section
            Stack(
              children: [
                Container(
                  height: 400,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?auto=format&fit=crop&w=1200&q=80',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  height: 400,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF006994).withValues(alpha: 0.6),
                        const Color(0xFF00BCD4).withValues(alpha: 0.4),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 60),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Premium Cebu Island Experience',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Discover the\nMagic of Cebu',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const SizedBox(
                          width: 400,
                          child: Text(
                            'From the deep blue of Kawasan Falls to the peaks of Osmeña, book your dream itinerary with real-time distance tracking and seamless reservations.',
                            style: TextStyle(color: Colors.white, fontSize: 16, height: 1.6),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Row(
                          children: [
                            FilledButton(
                              onPressed: () => Navigator.pushNamed(context, ExploreScreen.routeName),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF00BCD4),
                                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                              child: const Text('Explore Destinations →', style: TextStyle(fontWeight: FontWeight.w700)),
                            ),
                            const SizedBox(width: 16),
                            OutlinedButton(
                              onPressed: () => Navigator.pushNamed(context, BookingScreen.routeName),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white70, width: 2),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                              child: const Text('Plan Itinerary', style: TextStyle(fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Search Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Where to in Cebu?',
                        prefixIcon: const Icon(Icons.location_on, color: Color(0xFF00BCD4)),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'mm/dd/yyyy',
                        prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFF00BCD4)),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: () => Navigator.pushNamed(context, ExploreScreen.routeName),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B4A),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Search →', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 56),
            // Popular Destinations
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Popular Destinations',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFF006994)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, ExploreScreen.routeName),
                        child: const Text('View all →', style: TextStyle(color: Color(0xFF00BCD4), fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Discover the most highly-rated island spots across Cebu, curated just for you.',
                    style: TextStyle(color: Color(0xFF8B99A6), fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: popular.length,
                    itemBuilder: (context, index) => _PopularDestinationCard(spot: popular[index]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 56),
            // Why Book With Us
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'Why Book With Us?',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFF006994)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: SizedBox(
                      width: 500,
                      child: Text(
                        'Experience the smartest way to book across Cebu. Our premium platform ensures your journey is seamless from planning to memories.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF8B99A6), fontSize: 14, height: 1.6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                  GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      childAspectRatio: 1.1,
                    ),
                    children: const [
                      _FeatureCard(icon: Icons.flight_takeoff, title: 'Smart Itinerary & Routing', description: 'Optimize destination order, distance and schedule for your Cebu adventures.'),
                      _FeatureCard(icon: Icons.shield_rounded, title: 'Secure Premium Booking', description: 'Verified partners, payment tracking, and 24/7 dedicated support team.'),
                      _FeatureCard(icon: Icons.eco, title: 'Curated Local Experiences', description: 'Handpicked spots, hidden gems, and exclusive tours across all of Cebu.'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 64),
            _Footer(),
          ],
        ),
      ),
    );
  }
}

class _PopularDestinationCard extends StatelessWidget {
  final Destination spot;
  const _PopularDestinationCard({required this.spot});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, BookingScreen.routeName),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Image.network(
                  spot.images.first,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 160,
                    color: const Color(0xFFE0F7FA),
                    child: const Icon(Icons.image, color: Color(0xFF00BCD4), size: 40),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF00BCD4), width: 1.5),
                    ),
                    child: Text(
                      regionTitle(spot.region),
                      style: const TextStyle(color: Color(0xFF006994), fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(spot.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF00314F)),
              maxLines: 2),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: Color(0xFF8B99A6)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(spot.description,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF8B99A6)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                const Icon(Icons.star, size: 16, color: Color(0xFFFFC107)),
                const SizedBox(width: 4),
                Text('${spot.rating}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF00314F))),
              ]),
              Text('₱${spot.entranceFee.toInt()}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF50C878))),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pushNamed(context, BookingScreen.routeName),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF00BCD4),
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Book Now', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureCard({required this.icon, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EDEF)),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F4FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF00BCD4), size: 28),
          ),
          const SizedBox(height: 16),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF00314F))),
          const SizedBox(height: 8),
          Text(description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF8B99A6), height: 1.5)),
        ],
      ),
    );
  }
}

// Shared nav bar used across screens
class _NavBar extends StatelessWidget {
  final String current;
  const _NavBar({required this.current});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF00BCD4),
              child: Icon(Icons.public, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            const Text('Spoony Travel',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF006994))),
          ]),
          Row(children: [
            _NavBtn(label: 'Home', active: current == 'home',
                onTap: () => Navigator.pushReplacementNamed(context, HomeScreen.routeName)),
            _NavBtn(label: 'Explore', active: current == 'explore',
                onTap: () => Navigator.pushNamed(context, ExploreScreen.routeName)),
            _NavBtn(label: 'Bookings', active: current == 'booking',
                onTap: () => Navigator.pushNamed(context, BookingScreen.routeName)),
            _NavBtn(label: 'Dashboard', active: current == 'dashboard',
                onTap: () => Navigator.pushNamed(context, DashboardScreen.routeName)),
            const SizedBox(width: 16),
            FilledButton(
              onPressed: () => Navigator.pushReplacementNamed(context, AuthScreen.routeName),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF00BCD4),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Sign In', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ]),
        ],
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _NavBtn({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Text(label,
          style: TextStyle(
            color: active ? const Color(0xFF006994) : const Color(0xFF5D6D7A),
            fontWeight: active ? FontWeight.w700 : FontWeight.w600,
          )),
    );
  }
}

class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: const Color(0xFF006994),
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: Color(0xFF00BCD4),
                        child: Icon(Icons.public, color: Colors.white, size: 14),
                      ),
                      SizedBox(width: 8),
                      Text('Spoony Travel',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                    ]),
                    const SizedBox(height: 16),
                    Text(
                      'Your premium gateway to the most beautiful destinations in Cebu, Philippines.',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13, height: 1.6),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Destinations',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 12),
                    for (final label in ['Cebu City', 'South Cebu', 'North Cebu', 'Bohol Side Tours'])
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(label,
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13)),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Support',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 12),
                    for (final label in ['Contact Us', 'FAQs', 'Privacy Policy', 'Terms of Service'])
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(label,
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13)),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          color: const Color(0xFF00507A),
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
          child: Center(
            child: Text(
              '© 2026 Spoony Travel and Tours. All rights reserved.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}
