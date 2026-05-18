import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models.dart';
import '../data/cebu_data.dart';
import 'booking_screen.dart';
import 'explore_screen.dart';
import 'dashboard_screen.dart';
import 'admin_screen.dart';
import 'auth_screen.dart';

// ── Color palette ─────────────────────────────────────────────────────────────
const _kOcean = Color(0xFF0EA5E9);
const _kTeal  = Color(0xFF14B8A6);
const _kGold  = Color(0xFFF59E0B);
const _kDark  = Color(0xFF0F172A);
const _kMid   = Color(0xFF64748B);
const _kBg    = Color(0xFFF8FAFC);

// ── Utilities ─────────────────────────────────────────────────────────────────

bool _isMobile(BuildContext context) => MediaQuery.of(context).size.width < 700;

// ── Home screen ───────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollCtrl = ScrollController();
  bool _navScrolled = false;
  bool _heroVisible = false;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      final scrolled = _scrollCtrl.offset > 60;
      if (scrolled != _navScrolled) setState(() => _navScrolled = scrolled);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _heroVisible = true);
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final popular = cebuDestinations.take(3).toList();
    final mobile = _isMobile(context);
    final hPad = mobile ? 20.0 : 80.0;

    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollCtrl,
            child: Column(
              children: [
                _HeroSection(visible: _heroVisible, mobile: mobile),
                _StatsBar(mobile: mobile),
                // ── Popular Destinations ──────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 60),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Text('Popular Destinations',
                                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: _kDark)),
                            const SizedBox(height: 6),
                            const Text('Discover the most highly-rated island spots across Cebu.',
                                style: TextStyle(fontSize: 14, color: _kMid)),
                          ]),
                          TextButton.icon(
                            onPressed: () => Navigator.pushNamed(context, ExploreScreen.routeName),
                            icon: const Icon(Icons.arrow_forward, size: 16, color: _kOcean),
                            label: const Text('View all',
                                style: TextStyle(color: _kOcean, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: mobile ? 1 : 3,
                          mainAxisSpacing: 24,
                          crossAxisSpacing: 24,
                          mainAxisExtent: mobile ? 130 : 355,
                        ),
                        itemCount: popular.length,
                        itemBuilder: (context, i) => _DestCard(spot: popular[i]),
                      ),
                    ],
                  ),
                ),
                _WhySection(mobile: mobile, hPad: hPad),
                _TestimonialsSection(mobile: mobile, hPad: hPad),
                const SpoonyFooter(),
              ],
            ),
          ),
          // Scroll-aware transparent navbar overlaid on top
          Positioned(
            top: 0, left: 0, right: 0,
            child: _StickyNav(scrolled: _navScrolled),
          ),
        ],
      ),
    );
  }
}

// ── Scroll-aware sticky nav ───────────────────────────────────────────────────

class _StickyNav extends StatefulWidget {
  final bool scrolled;
  const _StickyNav({required this.scrolled});

  @override
  State<_StickyNav> createState() => _StickyNavState();
}

class _StickyNavState extends State<_StickyNav> {
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

  bool get _isAdmin => _user?.appMetadata['role'] == 'admin';

  String _initials(User user) {
    final raw = user.userMetadata?['name'] as String? ??
        user.userMetadata?['full_name'] as String? ??
        user.email ?? '';
    final parts = raw.trim().split(' ');
    return parts.map((p) => p.isNotEmpty ? p[0].toUpperCase() : '').take(2).join();
  }

  @override
  Widget build(BuildContext context) {
    final mobile = _isMobile(context);
    final scrolled = widget.scrolled;
    final textColor = scrolled ? _kDark : Colors.white;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: scrolled ? Colors.white : Colors.transparent,
        boxShadow: scrolled
            ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 2))]
            : [],
      ),
      padding: EdgeInsets.symmetric(horizontal: mobile ? 20 : 80, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pushReplacementNamed(context, HomeScreen.routeName),
            child: Row(children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_kOcean, _kTeal]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.public, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: textColor),
                child: const Text('Spoony Travel'),
              ),
            ]),
          ),
          if (mobile)
            IconButton(
              icon: Icon(Icons.menu, color: textColor, size: 28),
              onPressed: () => _showMobileMenu(context),
            )
          else
            Row(children: [
              _NavLink(label: 'Home', textColor: textColor, active: true,
                  onTap: () => Navigator.pushReplacementNamed(context, HomeScreen.routeName)),
              _NavLink(label: 'Explore', textColor: textColor, active: false,
                  onTap: () => Navigator.pushNamed(context, ExploreScreen.routeName)),
              _NavLink(label: 'Bookings', textColor: textColor, active: false,
                  onTap: () => Navigator.pushNamed(context, BookingScreen.routeName)),
              _NavLink(label: 'Dashboard', textColor: textColor, active: false,
                  onTap: () => Navigator.pushNamed(context, DashboardScreen.routeName)),
              if (_isAdmin)
                _NavLink(label: 'Admin', textColor: textColor, active: false,
                    onTap: () => Navigator.pushNamed(context, AdminScreen.routeName)),
              const SizedBox(width: 20),
              if (_user != null) ...[
                CircleAvatar(
                  radius: 16, backgroundColor: _kOcean,
                  child: Text(_initials(_user!),
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () async {
                    await Supabase.instance.client.auth.signOut();
                    if (context.mounted) Navigator.pushReplacementNamed(context, AuthScreen.routeName);
                  },
                  icon: const Icon(Icons.logout, size: 15),
                  label: const Text('Sign Out'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ] else
                FilledButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, AuthScreen.routeName),
                  style: FilledButton.styleFrom(
                    backgroundColor: _kGold,
                    foregroundColor: _kDark,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Sign In', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                ),
            ]),
        ],
      ),
    );
  }

  void _showMobileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
              if (_user != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(children: [
                    CircleAvatar(
                      radius: 20, backgroundColor: _kOcean,
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
              _MobileNavItem(label: 'Home', icon: Icons.home_outlined, active: true,
                  onTap: () { Navigator.pop(context); Navigator.pushReplacementNamed(context, HomeScreen.routeName); }),
              _MobileNavItem(label: 'Explore', icon: Icons.explore_outlined, active: false,
                  onTap: () { Navigator.pop(context); Navigator.pushNamed(context, ExploreScreen.routeName); }),
              _MobileNavItem(label: 'Bookings', icon: Icons.book_outlined, active: false,
                  onTap: () { Navigator.pop(context); Navigator.pushNamed(context, BookingScreen.routeName); }),
              _MobileNavItem(label: 'Dashboard', icon: Icons.dashboard_outlined, active: false,
                  onTap: () { Navigator.pop(context); Navigator.pushNamed(context, DashboardScreen.routeName); }),
              if (_isAdmin)
                _MobileNavItem(label: 'Admin Panel', icon: Icons.admin_panel_settings_outlined, active: false,
                    onTap: () { Navigator.pop(context); Navigator.pushNamed(context, AdminScreen.routeName); }),
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
                            if (context.mounted) Navigator.pushReplacementNamed(context, AuthScreen.routeName);
                          },
                          icon: const Icon(Icons.logout, size: 16),
                          label: const Text('Sign Out'),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFEF4444),
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
                            backgroundColor: _kGold,
                            foregroundColor: _kDark,
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
}

class _NavLink extends StatefulWidget {
  final String label;
  final Color textColor;
  final bool active;
  final VoidCallback onTap;
  const _NavLink({required this.label, required this.textColor, required this.active, required this.onTap});

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 150),
            style: TextStyle(
              fontSize: 15,
              fontWeight: widget.active || _hovered ? FontWeight.w700 : FontWeight.w500,
              color: _hovered ? _kOcean : widget.textColor,
            ),
            child: Text(widget.label),
          ),
        ),
      ),
    );
  }
}

// ── Cinematic hero ────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  final bool visible;
  final bool mobile;
  const _HeroSection({required this.visible, required this.mobile});

  @override
  Widget build(BuildContext context) {
    final heroH = mobile ? 520.0 : 640.0;
    final hPad = mobile ? 24.0 : 80.0;

    return Stack(
      children: [
        SizedBox(
          height: heroH,
          width: double.infinity,
          child: Image.network(
            'https://upload.wikimedia.org/wikipedia/commons/0/00/Cebu-Cordova_Link_Expressway_%28CCLEX%29.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(color: _kOcean),
          ),
        ),
        Container(
          height: heroH,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _kDark.withValues(alpha: 0.78),
                _kOcean.withValues(alpha: 0.30),
              ],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
          ),
        ),
        SizedBox(
          height: heroH,
          child: Padding(
            padding: EdgeInsets.fromLTRB(hPad, mobile ? 90 : 100, hPad, 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedOpacity(
                  opacity: visible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: _kGold.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _kGold.withValues(alpha: 0.55)),
                        ),
                        child: const Text('✦  Premium Cebu Island Experience',
                            style: TextStyle(color: _kGold, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.6)),
                      ),
                      SizedBox(height: mobile ? 18 : 26),
                      Text(
                        'Discover the\nMagic of Cebu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: mobile ? 38 : 58,
                          fontWeight: FontWeight.w900,
                          height: 1.12,
                          letterSpacing: -0.5,
                        ),
                      ),
                      if (!mobile) ...[
                        const SizedBox(height: 18),
                        const SizedBox(
                          width: 520,
                          child: Text(
                            'From the deep blue of Kawasan Falls to the peaks of Osmeña, book your dream itinerary with real-time distance tracking.',
                            style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.7),
                          ),
                        ),
                      ],
                      SizedBox(height: mobile ? 28 : 40),
                      Wrap(
                        spacing: 14,
                        runSpacing: 12,
                        children: [
                          _HeroCta(
                            label: 'Explore Destinations',
                            icon: Icons.explore_rounded,
                            primary: true,
                            onTap: () => Navigator.pushNamed(context, ExploreScreen.routeName),
                          ),
                          _HeroCta(
                            label: 'Plan Itinerary',
                            icon: Icons.calendar_month_rounded,
                            primary: false,
                            onTap: () => Navigator.pushNamed(context, BookingScreen.routeName),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroCta extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool primary;
  final VoidCallback onTap;
  const _HeroCta({required this.label, required this.icon, required this.primary, required this.onTap});

  @override
  State<_HeroCta> createState() => _HeroCtaState();
}

class _HeroCtaState extends State<_HeroCta> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          transform: Matrix4.translationValues(0, _hovered ? -2 : 0, 0),
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 15),
          decoration: BoxDecoration(
            color: widget.primary
                ? (_hovered ? _kGold : _kOcean)
                : Colors.white.withValues(alpha: _hovered ? 0.22 : 0.12),
            borderRadius: BorderRadius.circular(50),
            border: widget.primary ? null : Border.all(color: Colors.white70, width: 1.5),
            boxShadow: widget.primary && _hovered
                ? [BoxShadow(color: _kOcean.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 6))]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(widget.label,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Stats bar ─────────────────────────────────────────────────────────────────

class _StatsBar extends StatelessWidget {
  final bool mobile;
  const _StatsBar({required this.mobile});

  static const _stats = [
    ('50+', 'Destinations'),
    ('1,200+', 'Happy Travelers'),
    ('4.9★', 'Average Rating'),
    ('24/7', 'Support'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _kDark,
      padding: EdgeInsets.symmetric(vertical: 22, horizontal: mobile ? 20 : 80),
      child: mobile
          ? GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 3.5,
              children: _stats.map((s) => _StatItem(value: s.$1, label: s.$2)).toList(),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _stats.map((s) => _StatItem(value: s.$1, label: s.$2)).toList(),
            ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: const TextStyle(color: _kGold, fontSize: 22, fontWeight: FontWeight.w900)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
      ],
    );
  }
}

// ── Destination card with hover lift ─────────────────────────────────────────

class _DestCard extends StatefulWidget {
  final Destination spot;
  const _DestCard({required this.spot});

  @override
  State<_DestCard> createState() => _DestCardState();
}

class _DestCardState extends State<_DestCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final spot = widget.spot;
    final mobile = _isMobile(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, BookingScreen.routeName),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(0, _hovered ? -6 : 0, 0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: _hovered ? 0.92 : 0.80),
                Colors.white.withValues(alpha: _hovered ? 0.65 : 0.50),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.85), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _hovered ? 0.10 : 0.05),
                blurRadius: _hovered ? 28 : 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: mobile
              ? Row(children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                    child: Image.network(
                      spot.images.first,
                      height: 100, width: 120, fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                          height: 100, width: 120, color: const Color(0xFFE0F7FA),
                          child: const Icon(Icons.image, color: _kOcean)),
                    ),
                  ),
                  Expanded(child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(spot.name,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _kDark),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(regionTitle(spot.region),
                          style: const TextStyle(fontSize: 11, color: _kMid)),
                      const SizedBox(height: 6),
                      Row(children: [
                        const Icon(Icons.star, size: 12, color: _kGold),
                        const SizedBox(width: 3),
                        Text('${spot.rating}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _kDark)),
                        const Spacer(),
                        Text('₱${spot.entranceFee.toInt()}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _kTeal)),
                      ]),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => Navigator.pushNamed(context, BookingScreen.routeName),
                          style: FilledButton.styleFrom(
                            backgroundColor: _kOcean,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            minimumSize: const Size(0, 0),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Book Now', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ]),
                  )),
                ])
              : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Stack(children: [
                      Image.network(
                        spot.images.first,
                        height: 180, width: double.infinity, fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                            height: 180, color: const Color(0xFFE0F7FA),
                            child: const Icon(Icons.image, color: _kOcean, size: 40)),
                      ),
                      Positioned(
                        top: 10, left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: _kOcean,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(regionTitle(spot.region),
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(spot.name,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _kDark),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Row(children: [
                        const Icon(Icons.location_on, size: 12, color: _kMid),
                        const SizedBox(width: 3),
                        Expanded(child: Text(spot.description,
                            style: const TextStyle(fontSize: 11, color: _kMid),
                            maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ]),
                      const SizedBox(height: 10),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Row(children: [
                          const Icon(Icons.star, size: 14, color: _kGold),
                          const SizedBox(width: 4),
                          Text('${spot.rating}',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _kDark)),
                        ]),
                        Text('₱${spot.entranceFee.toInt()}',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _kTeal)),
                      ]),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => Navigator.pushNamed(context, BookingScreen.routeName),
                          style: FilledButton.styleFrom(
                            backgroundColor: _kOcean,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Book Now', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ]),
                  ),
                ]),
        ),
      ),
    );
  }
}

// ── Why choose section ────────────────────────────────────────────────────────

class _WhySection extends StatelessWidget {
  final bool mobile;
  final double hPad;
  const _WhySection({required this.mobile, required this.hPad});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 60),
      child: Column(
        children: [
          const Text('Why Choose Spoony?',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: _kDark),
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          const Text(
            'The smartest way to explore Cebu — curated spots, real-time booking, and premium support.',
            style: TextStyle(fontSize: 14, color: _kMid, height: 1.6),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          mobile
              ? const Column(children: [
                  _FeatureTile(icon: Icons.route_rounded, color: _kOcean, title: 'Smart Itinerary', desc: 'Optimized routes, distances, and schedules for your Cebu adventure.'),
                  SizedBox(height: 16),
                  _FeatureTile(icon: Icons.shield_rounded, color: _kTeal, title: 'Secure Booking', desc: 'Verified partners, transparent pricing, and 24/7 dedicated support.'),
                  SizedBox(height: 16),
                  _FeatureTile(icon: Icons.eco_rounded, color: _kGold, title: 'Local Experiences', desc: 'Handpicked hidden gems and exclusive tours across all of Cebu.'),
                ])
              : const IntrinsicHeight(
                  child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Expanded(child: _FeatureTile(icon: Icons.route_rounded, color: _kOcean, title: 'Smart Itinerary', desc: 'Optimized routes, distances, and schedules for your Cebu adventure.')),
                    SizedBox(width: 20),
                    Expanded(child: _FeatureTile(icon: Icons.shield_rounded, color: _kTeal, title: 'Secure Booking', desc: 'Verified partners, transparent pricing, and 24/7 dedicated support.')),
                    SizedBox(width: 20),
                    Expanded(child: _FeatureTile(icon: Icons.eco_rounded, color: _kGold, title: 'Local Experiences', desc: 'Handpicked hidden gems and exclusive tours across all of Cebu.')),
                  ]),
                ),
        ],
      ),
    );
  }
}

class _FeatureTile extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String desc;
  const _FeatureTile({required this.icon, required this.color, required this.title, required this.desc});

  @override
  State<_FeatureTile> createState() => _FeatureTileState();
}

class _FeatureTileState extends State<_FeatureTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: _hovered ? 0.90 : 0.78),
              Colors.white.withValues(alpha: _hovered ? 0.65 : 0.48),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hovered ? widget.color.withValues(alpha: 0.45) : Colors.white.withValues(alpha: 0.8),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _hovered ? widget.color.withValues(alpha: 0.10) : Colors.black.withValues(alpha: 0.04),
              blurRadius: _hovered ? 20 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(widget.icon, color: widget.color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _kDark)),
            const SizedBox(height: 4),
            Text(widget.desc,
                style: const TextStyle(fontSize: 12, color: _kMid, height: 1.5)),
          ])),
        ]),
      ),
    );
  }
}

// ── Testimonials section ──────────────────────────────────────────────────────

class _TestimonialsSection extends StatelessWidget {
  final bool mobile;
  final double hPad;
  const _TestimonialsSection({required this.mobile, required this.hPad});

  static const _reviews = [
    ('Maria Santos', 'Cebu City', 4.9, 'Spoony made our Cebu trip absolutely perfect! The booking was seamless and the destinations they suggested were hidden gems we never would have found on our own.'),
    ('John Reyes', 'Manila', 5.0, 'Best travel platform for Cebu! The real-time itinerary planner saved us hours of planning. Kawasan Falls was breathtaking — everything was organized perfectly.'),
    ('Ana Villanueva', 'Davao', 4.8, 'Wonderful experience! The team at Spoony was so helpful and responsive. Booked Osmeña Peak and Sardine Run in one go — it was incredible!'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _kBg,
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 60),
      child: Column(
        children: [
          const Text('What Travelers Say',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: _kDark),
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          const Text('Real reviews from people who explored Cebu with Spoony.',
              style: TextStyle(fontSize: 14, color: _kMid), textAlign: TextAlign.center),
          const SizedBox(height: 40),
          if (mobile)
            Column(children: _reviews
                .map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _ReviewCard(name: r.$1, location: r.$2, rating: r.$3, review: r.$4),
                    ))
                .toList())
          else
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: _ReviewCard(name: _reviews[0].$1, location: _reviews[0].$2, rating: _reviews[0].$3, review: _reviews[0].$4)),
              const SizedBox(width: 20),
              Expanded(child: _ReviewCard(name: _reviews[1].$1, location: _reviews[1].$2, rating: _reviews[1].$3, review: _reviews[1].$4)),
              const SizedBox(width: 20),
              Expanded(child: _ReviewCard(name: _reviews[2].$1, location: _reviews[2].$2, rating: _reviews[2].$3, review: _reviews[2].$4)),
            ]),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final String name;
  final String location;
  final double rating;
  final String review;
  const _ReviewCard({required this.name, required this.location, required this.rating, required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xCCFFFFFF), Color(0x80FFFFFF)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.85), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 14, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          for (int i = 0; i < 5; i++)
            Icon(Icons.star, size: 14,
                color: i < rating.round() ? _kGold : const Color(0xFFE2E8F0)),
          const SizedBox(width: 6),
          Text(rating.toString(),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _kDark)),
        ]),
        const SizedBox(height: 14),
        Text('"$review"',
            style: const TextStyle(fontSize: 13, color: _kMid, height: 1.6)),
        const SizedBox(height: 20),
        Row(children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: _kOcean.withValues(alpha: 0.12),
            child: Text(name[0],
                style: const TextStyle(color: _kOcean, fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _kDark)),
            Text(location, style: const TextStyle(fontSize: 11, color: _kMid)),
          ]),
        ]),
      ]),
    );
  }
}

// ── Shared nav bar (used by Explore, Booking, Dashboard, Admin) ───────────────

class SpoonyNavBar extends StatefulWidget {
  final String current;
  const SpoonyNavBar({super.key, required this.current});

  @override
  State<SpoonyNavBar> createState() => _SpoonyNavBarState();
}

class _SpoonyNavBarState extends State<SpoonyNavBar> {
  User? _user;
  bool _isDriver = false;
  late final StreamSubscription<AuthState> _sub;

  @override
  void initState() {
    super.initState();
    _user = Supabase.instance.client.auth.currentUser;
    if (_user != null) _checkDriver(_user!);
    _sub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (mounted) {
        setState(() { _user = data.session?.user; _isDriver = false; });
        if (data.session?.user != null) _checkDriver(data.session!.user);
      }
    });
  }

  Future<void> _checkDriver(User user) async {
    try {
      final row = await Supabase.instance.client
          .from('drivers')
          .select('id')
          .eq('email', user.email ?? '')
          .maybeSingle();
      if (mounted) setState(() => _isDriver = row != null);
    } catch (_) {}
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  bool get _isAdmin => _user?.appMetadata['role'] == 'admin';

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
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
              if (_user != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(children: [
                    CircleAvatar(
                      radius: 20, backgroundColor: _kOcean,
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
                  onTap: () { Navigator.pop(context); Navigator.pushReplacementNamed(context, ExploreScreen.routeName); }),
              _MobileNavItem(label: 'Bookings', icon: Icons.book_outlined,
                  active: widget.current == 'booking',
                  onTap: () { Navigator.pop(context); Navigator.pushReplacementNamed(context, BookingScreen.routeName); }),
              _MobileNavItem(label: 'Dashboard', icon: Icons.dashboard_outlined,
                  active: widget.current == 'dashboard',
                  onTap: () { Navigator.pop(context); Navigator.pushReplacementNamed(context, DashboardScreen.routeName); }),
              if (_isAdmin)
                _MobileNavItem(label: 'Admin Panel', icon: Icons.admin_panel_settings_outlined,
                    active: widget.current == 'admin',
                    onTap: () { Navigator.pop(context); Navigator.pushReplacementNamed(context, AdminScreen.routeName); }),
              if (_isDriver && !_isAdmin)
                _MobileNavItem(label: 'Driver Portal', icon: Icons.drive_eta_outlined,
                    active: widget.current == 'driver',
                    onTap: () { Navigator.pop(context); Navigator.pushReplacementNamed(context, '/driver'); }),
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
                            if (context.mounted) Navigator.pushReplacementNamed(context, AuthScreen.routeName);
                          },
                          icon: const Icon(Icons.logout, size: 16),
                          label: const Text('Sign Out'),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFEF4444),
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
                            backgroundColor: _kOcean,
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
      padding: EdgeInsets.symmetric(horizontal: mobile ? 20 : 80, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pushReplacementNamed(context, HomeScreen.routeName),
            child: Row(children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_kOcean, _kTeal]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.public, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              const Text('Spoony Travel',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _kDark)),
            ]),
          ),
          if (mobile)
            IconButton(
              icon: const Icon(Icons.menu, color: _kDark, size: 28),
              onPressed: () => _showMobileMenu(context),
            )
          else
            Row(children: [
              _NavBtn(label: 'Home', active: widget.current == 'home',
                  onTap: () => Navigator.pushReplacementNamed(context, HomeScreen.routeName)),
              _NavBtn(label: 'Explore', active: widget.current == 'explore',
                  onTap: () => Navigator.pushReplacementNamed(context, ExploreScreen.routeName)),
              _NavBtn(label: 'Bookings', active: widget.current == 'booking',
                  onTap: () => Navigator.pushReplacementNamed(context, BookingScreen.routeName)),
              _NavBtn(label: 'Dashboard', active: widget.current == 'dashboard',
                  onTap: () => Navigator.pushReplacementNamed(context, DashboardScreen.routeName)),
              if (_isAdmin)
                _NavBtn(label: 'Admin', active: widget.current == 'admin',
                    onTap: () => Navigator.pushReplacementNamed(context, AdminScreen.routeName)),
              if (_isDriver && !_isAdmin)
                _NavBtn(label: 'Driver', active: widget.current == 'driver',
                    onTap: () => Navigator.pushReplacementNamed(context, '/driver')),
              const SizedBox(width: 20),
              if (_user != null) ...[
                CircleAvatar(
                  radius: 16, backgroundColor: _kOcean,
                  child: Text(_initials(_user!),
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () async {
                    await Supabase.instance.client.auth.signOut();
                    if (context.mounted) Navigator.pushReplacementNamed(context, AuthScreen.routeName);
                  },
                  icon: const Icon(Icons.logout, size: 15),
                  label: const Text('Sign Out'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ] else
                FilledButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, AuthScreen.routeName),
                  style: FilledButton.styleFrom(
                    backgroundColor: _kOcean,
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

// ── Shared footer ─────────────────────────────────────────────────────────────

void _showContactUs(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Contact Us'),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('We\'d love to hear from you! Reach us through:', style: TextStyle(color: Color(0xFF64748B))),
        const SizedBox(height: 16),
        _ContactRow(icon: Icons.email_outlined, text: 'spoonytraveltours@gmail.com'),
        const SizedBox(height: 10),
        _ContactRow(icon: Icons.access_time, text: 'Mon–Sat, 8:00 AM – 6:00 PM'),
        const SizedBox(height: 10),
        _ContactRow(icon: Icons.location_on_outlined, text: 'Cebu, Philippines'),
        const SizedBox(height: 16),
        const Text('We respond within 24 hours.', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
    ),
  );
}

void _showFAQs(BuildContext context) {
  const faqs = [
    ('How do I book a tour?', 'Go to the Bookings tab, choose your preferred dates, accommodation type, and transport. Confirm your booking to receive a reference code.'),
    ('How do I view my bookings?', 'Open the Dashboard tab and go to Upcoming Trips to see all your active bookings.'),
    ('Can I cancel a booking?', 'Yes. Please contact us at spoonytraveltours@gmail.com at least 48 hours before your trip date for cancellations.'),
    ('Are entrance fees included?', 'Entrance fees vary per destination. The total shown during booking includes all applicable fees.'),
    ('How many guests can I bring?', 'You can add up to 20 guests per booking using the guest count selector.'),
    ('How do I get my reference code?', 'Your reference code appears immediately after confirming a booking and is also saved in your Dashboard under Booking History.'),
  ];

  showDialog(
    context: context,
    builder: (_) => Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 500),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Frequently Asked Questions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _kDark)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: faqs.length,
                separatorBuilder: (_, _) => const Divider(height: 24),
                itemBuilder: (_, i) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(faqs[i].$1, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: _kDark)),
                  const SizedBox(height: 6),
                  Text(faqs[i].$2, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.5)),
                ]),
              ),
            ),
            const SizedBox(height: 16),
            Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))),
          ]),
        ),
      ),
    ),
  );
}

void _showPrivacyPolicy(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 500),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Privacy Policy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _kDark)),
            const SizedBox(height: 4),
            const Text('Last updated: January 2026', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
            const SizedBox(height: 16),
            const Expanded(child: SingleChildScrollView(child: _PrivacyPolicyContent())),
            const SizedBox(height: 16),
            Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))),
          ]),
        ),
      ),
    ),
  );
}

void _showTerms(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 500),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Terms of Service', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _kDark)),
            const SizedBox(height: 4),
            const Text('Last updated: January 2026', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
            const SizedBox(height: 16),
            const Expanded(child: SingleChildScrollView(child: _TermsContent())),
            const SizedBox(height: 16),
            Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))),
          ]),
        ),
      ),
    ),
  );
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ContactRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 18, color: _kOcean),
      const SizedBox(width: 10),
      Flexible(child: Text(text, style: const TextStyle(fontSize: 14, color: _kDark))),
    ]);
  }
}

class _PrivacyPolicyContent extends StatelessWidget {
  const _PrivacyPolicyContent();

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.6);
    const head = TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _kDark);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Information We Collect', style: head),
      const SizedBox(height: 6),
      const Text('We collect your name, email address, and booking details when you create an account or make a reservation through Spoony Travel.', style: style),
      const SizedBox(height: 14),
      const Text('How We Use Your Information', style: head),
      const SizedBox(height: 6),
      const Text('Your information is used solely to process bookings, send confirmation emails, and improve our services. We do not sell or share your personal data with third parties.', style: style),
      const SizedBox(height: 14),
      const Text('Data Storage', style: head),
      const SizedBox(height: 6),
      const Text('All data is stored securely using Supabase with industry-standard encryption. We retain your data only as long as your account is active.', style: style),
      const SizedBox(height: 14),
      const Text('Your Rights', style: head),
      const SizedBox(height: 6),
      const Text('You may request access to, correction of, or deletion of your personal data at any time by contacting us at spoonytraveltours@gmail.com.', style: style),
      const SizedBox(height: 14),
      const Text('Cookies', style: head),
      const SizedBox(height: 6),
      const Text('We use session cookies only to keep you logged in. No tracking or advertising cookies are used.', style: style),
    ]);
  }
}

class _TermsContent extends StatelessWidget {
  const _TermsContent();

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.6);
    const head = TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _kDark);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Bookings', style: head),
      const SizedBox(height: 6),
      const Text('All bookings are subject to availability and require admin approval. A booking is only confirmed once the status changes to "Confirmed" in your Dashboard.', style: style),
      const SizedBox(height: 14),
      const Text('Cancellations', style: head),
      const SizedBox(height: 6),
      const Text('Cancellation requests must be submitted at least 48 hours before the trip start date by emailing spoonytraveltours@gmail.com. Late cancellations may not be eligible for a refund.', style: style),
      const SizedBox(height: 14),
      const Text('Changes to Tours', style: head),
      const SizedBox(height: 6),
      const Text('Spoony Travel reserves the right to modify or cancel tours due to weather conditions, force majeure, or other unforeseen circumstances. Affected guests will be notified and offered a reschedule or refund.', style: style),
      const SizedBox(height: 14),
      const Text('Guest Responsibility', style: head),
      const SizedBox(height: 6),
      const Text('Guests are responsible for their own conduct during tours. Spoony Travel is not liable for personal injury, loss of property, or damages resulting from a guest\'s own actions.', style: style),
      const SizedBox(height: 14),
      const Text('Contact', style: head),
      const SizedBox(height: 6),
      const Text('For any concerns regarding these terms, contact us at spoonytraveltours@gmail.com.', style: style),
    ]);
  }
}

class SpoonyFooter extends StatelessWidget {
  const SpoonyFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final mobile = _isMobile(context);
    final hPad = mobile ? 20.0 : 80.0;

    return Column(
      children: [
        Container(
          color: _kDark,
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: mobile ? 24 : 44),
          child: mobile
              ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const _FooterBrand(),
                  const SizedBox(height: 20),
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Expanded(child: _FooterLinks(title: 'Destinations', links: [
                      ('Cebu City', null), ('South Cebu', null), ('North Cebu', null), ('Bohol', null),
                    ])),
                    Expanded(child: _FooterLinks(title: 'Support', links: [
                      ('Contact Us', _showContactUs),
                      ('FAQs', _showFAQs),
                      ('Privacy Policy', _showPrivacyPolicy),
                      ('Terms', _showTerms),
                    ])),
                  ]),
                ])
              : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Expanded(flex: 2, child: _FooterBrand()),
                  const Expanded(child: _FooterLinks(title: 'Destinations', links: [
                    ('Cebu City', null), ('South Cebu', null), ('North Cebu', null), ('Bohol', null),
                  ])),
                  Expanded(child: _FooterLinks(title: 'Support', links: [
                    ('Contact Us', _showContactUs),
                    ('FAQs', _showFAQs),
                    ('Privacy Policy', _showPrivacyPolicy),
                    ('Terms of Service', _showTerms),
                  ])),
                ]),
        ),
        Container(
          color: Colors.black,
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
          child: Center(
            child: Text('© 2026 Spoony Travel and Tours. All rights reserved.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 12)),
          ),
        ),
      ],
    );
  }
}

class _FooterBrand extends StatelessWidget {
  const _FooterBrand();

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [_kOcean, _kTeal]),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.public, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 10),
        const Text('Spoony Travel',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
      ]),
      const SizedBox(height: 16),
      const SizedBox(
        width: 240,
        child: Text(
          'Your premium gateway to the most beautiful destinations in Cebu, Philippines.',
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, height: 1.6),
        ),
      ),
    ]);
  }
}

class _FooterLinks extends StatelessWidget {
  final String title;
  final List<(String, void Function(BuildContext)?)> links;
  const _FooterLinks({required this.title, required this.links});

  @override
  Widget build(BuildContext context) {
    final mobile = _isMobile(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
      SizedBox(height: mobile ? 10 : 16),
      for (final (label, onTap) in links)
        Padding(
          padding: EdgeInsets.only(bottom: mobile ? 7 : 10),
          child: onTap != null
              ? GestureDetector(
                  onTap: () => onTap(context),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Text(label, style: const TextStyle(
                      color: Color(0xFF94A3B8), fontSize: 13,
                      decoration: TextDecoration.underline,
                      decorationColor: Color(0xFF94A3B8),
                    )),
                  ),
                )
              : Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
        ),
    ]);
  }
}

// ── Shared private widgets ────────────────────────────────────────────────────

class _MobileNavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _MobileNavItem({required this.label, required this.icon, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: active ? _kOcean : _kMid),
      title: Text(label,
          style: TextStyle(
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: active ? _kOcean : const Color(0xFF475569))),
      tileColor: active ? _kOcean.withValues(alpha: 0.06) : null,
      onTap: onTap,
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
            color: active ? _kOcean : _kMid,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          )),
    );
  }
}
