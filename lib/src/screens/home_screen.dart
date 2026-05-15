import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models.dart';
import '../data/cebu_data.dart';
import 'booking_screen.dart';
import 'explore_screen.dart';
import 'dashboard_screen.dart';
import 'auth_screen.dart';

bool _isMobile(BuildContext context) => MediaQuery.of(context).size.width < 700;

class HomeScreen extends StatelessWidget {
  static const routeName = '/home';
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final popular = cebuDestinations.take(3).toList();
    final mobile = _isMobile(context);
    final hPad = mobile ? 16.0 : 48.0;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SpoonyNavBar(current: 'home'),
            // Hero
            Stack(
              children: [
                Container(
                  height: mobile ? 320 : 400,
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
                  height: mobile ? 320 : 400,
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
                    padding: EdgeInsets.symmetric(horizontal: hPad, vertical: mobile ? 32 : 60),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Premium Cebu Island Experience',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Discover the\nMagic of Cebu',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: mobile ? 32 : 48,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),
                        if (!mobile) ...[
                          const SizedBox(height: 12),
                          const SizedBox(
                            width: 400,
                            child: Text(
                              'From the deep blue of Kawasan Falls to the peaks of Osmeña, book your dream itinerary with real-time distance tracking.',
                              style: TextStyle(color: Colors.white, fontSize: 15, height: 1.6),
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 12,
                          runSpacing: 10,
                          children: [
                            FilledButton(
                              onPressed: () => Navigator.pushNamed(context, ExploreScreen.routeName),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF00BCD4),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                              child: const Text('Explore Destinations →',
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                            ),
                            OutlinedButton(
                              onPressed: () => Navigator.pushNamed(context, BookingScreen.routeName),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white70, width: 2),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                              child: const Text('Plan Itinerary',
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Search bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: mobile
                  ? Column(children: [
                      _searchField('Where to in Cebu?', Icons.location_on),
                      const SizedBox(height: 10),
                      _searchField('mm/dd/yyyy', Icons.calendar_today),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => Navigator.pushNamed(context, ExploreScreen.routeName),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B4A),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Search →',
                              style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
                        ),
                      ),
                    ])
                  : Row(children: [
                      Expanded(child: _searchField('Where to in Cebu?', Icons.location_on)),
                      const SizedBox(width: 12),
                      Expanded(child: _searchField('mm/dd/yyyy', Icons.calendar_today)),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: () => Navigator.pushNamed(context, ExploreScreen.routeName),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B4A),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Search →',
                            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                    ]),
            ),
            const SizedBox(height: 48),
            // Popular Destinations
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Popular Destinations',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF006994))),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, ExploreScreen.routeName),
                        child: const Text('View all →',
                            style: TextStyle(color: Color(0xFF00BCD4), fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Discover the most highly-rated island spots across Cebu.',
                    style: TextStyle(color: Color(0xFF8B99A6), fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: mobile ? 1 : 3,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      childAspectRatio: mobile ? 1.4 : 0.85,
                    ),
                    itemCount: popular.length,
                    itemBuilder: (context, index) => _PopularDestinationCard(spot: popular[index]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            // Why Book With Us
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text('Why Book With Us?',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF006994))),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Experience the smartest way to book across Cebu. Our premium platform ensures your journey is seamless.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF8B99A6), fontSize: 13, height: 1.6),
                    ),
                  ),
                  const SizedBox(height: 28),
                  GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: mobile ? 1 : 3,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: mobile ? 2.5 : 1.1,
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
            const SizedBox(height: 56),
            const SpoonyFooter(),
          ],
        ),
      ),
    );
  }

  Widget _searchField(String hint, IconData icon) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF00BCD4)),
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
    );
  }
}

// ── Shared nav bar ────────────────────────────────────────────────────────────

class SpoonyNavBar extends StatefulWidget {
  final String current;
  const SpoonyNavBar({super.key, required this.current});

  @override
  State<SpoonyNavBar> createState() => _SpoonyNavBarState();
}

class _SpoonyNavBarState extends State<SpoonyNavBar> {
  User? _user;
  late final StreamSubscription<AuthState> _sub;

  @override
  void initState() {
    super.initState();
    _user = Supabase.instance.client.auth.currentUser;
    _sub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (mounted) setState(() => _user = data.session?.user);
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  String _initials(User user) {
    final raw = user.userMetadata?['name'] as String? ??
        user.userMetadata?['full_name'] as String? ??
        user.email ?? '';
    final parts = raw.trim().split(' ');
    return parts.map((p) => p.isNotEmpty ? p[0].toUpperCase() : '').take(2).join();
  }

  void _showMobileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2)),
              ),
              if (_user != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFF00BCD4),
                      child: Text(_initials(_user!),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(
                      _user!.userMetadata?['name'] as String? ??
                          _user!.userMetadata?['full_name'] as String? ??
                          _user!.email ?? '',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    )),
                  ]),
                ),
                const Divider(),
              ],
              _MobileNavItem(label: 'Home', icon: Icons.home_outlined,
                  active: widget.current == 'home',
                  onTap: () { Navigator.pop(context); Navigator.pushReplacementNamed(context, HomeScreen.routeName); }),
              _MobileNavItem(label: 'Explore', icon: Icons.explore_outlined,
                  active: widget.current == 'explore',
                  onTap: () { Navigator.pop(context); Navigator.pushNamed(context, ExploreScreen.routeName); }),
              _MobileNavItem(label: 'Bookings', icon: Icons.book_outlined,
                  active: widget.current == 'booking',
                  onTap: () { Navigator.pop(context); Navigator.pushNamed(context, BookingScreen.routeName); }),
              _MobileNavItem(label: 'Dashboard', icon: Icons.dashboard_outlined,
                  active: widget.current == 'dashboard',
                  onTap: () { Navigator.pop(context); Navigator.pushNamed(context, DashboardScreen.routeName); }),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _user != null
                    ? SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () async {
                            Navigator.pop(context);
                            await Supabase.instance.client.auth.signOut();
                            if (context.mounted) {
                              Navigator.pushReplacementNamed(context, AuthScreen.routeName);
                            }
                          },
                          icon: const Icon(Icons.logout, size: 16),
                          label: const Text('Sign Out'),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B4A),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      )
                    : SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushReplacementNamed(context, AuthScreen.routeName);
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF00BCD4),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Sign In', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mobile = _isMobile(context);
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: mobile ? 16 : 24, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pushReplacementNamed(context, HomeScreen.routeName),
            child: const Row(children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFF00BCD4),
                child: Icon(Icons.public, color: Colors.white, size: 18),
              ),
              SizedBox(width: 8),
              Text('Spoony Travel',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF006994))),
            ]),
          ),
          if (mobile)
            IconButton(
              icon: const Icon(Icons.menu, color: Color(0xFF006994), size: 28),
              onPressed: () => _showMobileMenu(context),
            )
          else
            Row(children: [
              _NavBtn(label: 'Home', active: widget.current == 'home',
                  onTap: () => Navigator.pushReplacementNamed(context, HomeScreen.routeName)),
              _NavBtn(label: 'Explore', active: widget.current == 'explore',
                  onTap: () => Navigator.pushNamed(context, ExploreScreen.routeName)),
              _NavBtn(label: 'Bookings', active: widget.current == 'booking',
                  onTap: () => Navigator.pushNamed(context, BookingScreen.routeName)),
              _NavBtn(label: 'Dashboard', active: widget.current == 'dashboard',
                  onTap: () => Navigator.pushNamed(context, DashboardScreen.routeName)),
              const SizedBox(width: 16),
              if (_user != null) ...[
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFF00BCD4),
                  child: Text(_initials(_user!),
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () async {
                    await Supabase.instance.client.auth.signOut();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, AuthScreen.routeName);
                    }
                  },
                  icon: const Icon(Icons.logout, size: 16),
                  label: const Text('Sign Out'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B4A),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ] else
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

class _MobileNavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _MobileNavItem({required this.label, required this.icon, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: active ? const Color(0xFF006994) : const Color(0xFF8B99A6)),
      title: Text(label,
          style: TextStyle(
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: active ? const Color(0xFF006994) : const Color(0xFF5D6D7A))),
      tileColor: active ? const Color(0xFFE0F7FA) : null,
      onTap: onTap,
    );
  }
}

// ── Shared footer ─────────────────────────────────────────────────────────────

class SpoonyFooter extends StatelessWidget {
  const SpoonyFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final mobile = _isMobile(context);
    final hPad = mobile ? 20.0 : 48.0;

    return Column(
      children: [
        Container(
          color: const Color(0xFF006994),
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 32),
          child: mobile
              ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Row(children: [
                    CircleAvatar(
                      radius: 14, backgroundColor: Color(0xFF00BCD4),
                      child: Icon(Icons.public, color: Colors.white, size: 14),
                    ),
                    SizedBox(width: 8),
                    Text('Spoony Travel',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                  ]),
                  const SizedBox(height: 12),
                  Text('Your premium gateway to the most beautiful destinations in Cebu, Philippines.',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13, height: 1.6)),
                  const SizedBox(height: 24),
                  const Text('Destinations',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 8),
                  for (final l in ['Cebu City', 'South Cebu', 'North Cebu', 'Bohol Side Tours'])
                    Padding(padding: const EdgeInsets.only(bottom: 6),
                        child: Text(l, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13))),
                  const SizedBox(height: 16),
                  const Text('Support',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 8),
                  for (final l in ['Contact Us', 'FAQs', 'Privacy Policy', 'Terms of Service'])
                    Padding(padding: const EdgeInsets.only(bottom: 6),
                        child: Text(l, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13))),
                ])
              : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(
                    flex: 2,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Row(children: [
                        CircleAvatar(radius: 14, backgroundColor: Color(0xFF00BCD4),
                            child: Icon(Icons.public, color: Colors.white, size: 14)),
                        SizedBox(width: 8),
                        Text('Spoony Travel',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                      ]),
                      const SizedBox(height: 16),
                      Text('Your premium gateway to the most beautiful destinations in Cebu, Philippines.',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13, height: 1.6)),
                    ]),
                  ),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Destinations',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 12),
                      for (final l in ['Cebu City', 'South Cebu', 'North Cebu', 'Bohol Side Tours'])
                        Padding(padding: const EdgeInsets.only(bottom: 8),
                            child: Text(l, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13))),
                    ]),
                  ),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Support',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 12),
                      for (final l in ['Contact Us', 'FAQs', 'Privacy Policy', 'Terms of Service'])
                        Padding(padding: const EdgeInsets.only(bottom: 8),
                            child: Text(l, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13))),
                    ]),
                  ),
                ]),
        ),
        Container(
          color: const Color(0xFF00507A),
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 14),
          child: Center(
            child: Text('© 2026 Spoony Travel and Tours. All rights reserved.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
          ),
        ),
      ],
    );
  }
}

// ── Private widgets ───────────────────────────────────────────────────────────

class _PopularDestinationCard extends StatelessWidget {
  final Destination spot;
  const _PopularDestinationCard({required this.spot});

  @override
  Widget build(BuildContext context) {
    final mobile = _isMobile(context);
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, BookingScreen.routeName),
      child: mobile
          ? Row(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  spot.images.first,
                  height: 90, width: 110,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                      height: 90, width: 110,
                      color: const Color(0xFFE0F7FA),
                      child: const Icon(Icons.image, color: Color(0xFF00BCD4))),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(spot.name,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF00314F)),
                    maxLines: 1),
                const SizedBox(height: 4),
                Text(regionTitle(spot.region),
                    style: const TextStyle(fontSize: 12, color: Color(0xFF8B99A6))),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.star, size: 13, color: Color(0xFFFFC107)),
                  const SizedBox(width: 4),
                  Text('${spot.rating}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Text('₱${spot.entranceFee.toInt()}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF50C878))),
                ]),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () => Navigator.pushNamed(context, BookingScreen.routeName),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF00BCD4),
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    minimumSize: const Size(0, 0),
                  ),
                  child: const Text('Book Now', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                ),
              ])),
            ])
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(children: [
                  Image.network(
                    spot.images.first,
                    height: 160, width: double.infinity, fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                        height: 160, color: const Color(0xFFE0F7FA),
                        child: const Icon(Icons.image, color: Color(0xFF00BCD4), size: 40)),
                  ),
                  Positioned(top: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF00BCD4), width: 1.5),
                      ),
                      child: Text(regionTitle(spot.region),
                          style: const TextStyle(color: Color(0xFF006994), fontSize: 11, fontWeight: FontWeight.w700)),
                    )),
                ]),
              ),
              const SizedBox(height: 12),
              Text(spot.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF00314F)),
                  maxLines: 2),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.location_on, size: 14, color: Color(0xFF8B99A6)),
                const SizedBox(width: 4),
                Expanded(child: Text(spot.description,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF8B99A6)),
                    maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                  const Icon(Icons.star, size: 16, color: Color(0xFFFFC107)),
                  const SizedBox(width: 4),
                  Text('${spot.rating}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF00314F))),
                ]),
                Text('₱${spot.entranceFee.toInt()}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF50C878))),
              ]),
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
            ]),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EDEF)),
      ),
      child: Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F4FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF00BCD4), size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF00314F))),
          const SizedBox(height: 4),
          Text(description,
              style: const TextStyle(fontSize: 12, color: Color(0xFF8B99A6), height: 1.4),
              maxLines: 2, overflow: TextOverflow.ellipsis),
        ])),
      ]),
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
