import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/safe_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/media_data.dart';
import '../widgets/media_dialogs.dart';
import '../widgets/home/hero_search_bar.dart';
import '../widgets/home/home_destinations_rail.dart';
import '../widgets/home/home_packages.dart';
import '../widgets/home/home_regions.dart';
import '../widgets/home/home_stats.dart';
import '../widgets/home/home_story.dart';
import '../widgets/home/home_videos.dart';
import '../widgets/wm_ui.dart';
import 'booking_screen.dart';
import 'explore_screen.dart';
import 'dashboard_screen.dart';
import 'admin_screen.dart';
import 'auth_screen.dart';

// ── Color palette ─────────────────────────────────────────────────────────────
const _kAccent = Color(0xFFD96A2B);
const _kGold  = Color(0xFFF59E0B);
const _kDark  = Color(0xFF0F172A);
const _kMid   = Color(0xFF64748B);
// Landing-page accent (warm sunset orange used for active nav + highlights)
const _kSun   = Color(0xFFF0955A);
const _kHeroBg = 'assets/images/home_bg.jpg';

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
    final mobile = _isMobile(context);
    final hPad = mobile ? 20.0 : 80.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollCtrl,
            child: Column(
              children: [
                _HeroSection(visible: _heroVisible, mobile: mobile),
                // Floating trip search + stats card, overlapping the hero's bottom edge
                Transform.translate(
                  offset: Offset(0, mobile ? -44 : -64),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: hPad),
                    child: Column(children: [
                      WmBlurIn(
                        delay: const Duration(milliseconds: 300),
                        child: Center(child: HeroSearchBar(compact: mobile)),
                      ),
                      SizedBox(height: mobile ? 20 : 28),
                      WmBlurIn(
                        delay: const Duration(milliseconds: 450),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1100),
                          child: const HomeStatsCard(),
                        ),
                      ),
                    ]),
                  ),
                ),
                // Pull the rest of the page up by the same amount the search/stats
                // block overlaps the hero, so no empty band is left behind.
                Transform.translate(
                  offset: Offset(0, mobile ? -44 : -64),
                  child: Column(children: [
                    HomeRegionsSection(hPad: hPad),
                    HomeDestinationsRail(hPad: hPad),
                    HomePackagesSection(hPad: hPad),
                    HomeVideosSection(hPad: hPad),
                    HomeWhySection(hPad: hPad),
                    HomeTestimonialsSection(hPad: hPad),
                    Padding(
                      padding: EdgeInsets.only(top: mobile ? 48 : 80, bottom: mobile ? 4 : 16),
                      child: HomeCtaBanner(hPad: hPad),
                    ),
                  ]),
                ),
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
      padding: EdgeInsets.symmetric(horizontal: mobile ? 24 : 80, vertical: scrolled ? 14 : 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pushReplacementNamed(context, HomeScreen.routeName),
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800,
                letterSpacing: 1.5, color: textColor,
              ),
              child: const Text('SPOONY'),
            ),
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
              if (_user != null)
                _NavLink(label: 'Dashboard', textColor: textColor, active: false,
                  onTap: () => Navigator.pushNamed(context, DashboardScreen.routeName)),
              if (_isAdmin)
                _NavLink(label: 'Admin', textColor: textColor, active: false,
                    onTap: () => Navigator.pushNamed(context, AdminScreen.routeName)),
              const SizedBox(width: 24),
              if (_user != null) ...[
                CircleAvatar(
                  radius: 16, backgroundColor: _kSun,
                  child: Text(_initials(_user!),
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () async {
                    await Supabase.instance.client.auth.signOut();
                    if (context.mounted) Navigator.pushReplacementNamed(context, HomeScreen.routeName);
                  },
                  icon: const Icon(Icons.logout, size: 15),
                  label: const Text('Sign Out'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: textColor,
                    side: BorderSide(color: textColor, width: 1.5),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: const StadiumBorder(),
                    textStyle: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.5),
                  ),
                ),
              ] else
                OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, AuthScreen.routeName),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: textColor,
                    side: BorderSide(color: textColor, width: 1.5),
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text('SIGN IN',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                ),
              const SizedBox(width: 20),
              Icon(Icons.apps_rounded, color: textColor.withValues(alpha: 0.75), size: 22),
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
                      radius: 20, backgroundColor: _kAccent,
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
              if (_user != null)
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
                            if (context.mounted) Navigator.pushReplacementNamed(context, HomeScreen.routeName);
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
                            Navigator.pushNamed(context, AuthScreen.routeName);
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
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 150),
            style: TextStyle(
              fontSize: 16,
              letterSpacing: 0.3,
              fontWeight: widget.active ? FontWeight.w600 : FontWeight.w400,
              color: widget.active || _hovered
                  ? _kSun
                  : widget.textColor.withValues(alpha: 0.85),
            ),
            child: Text(widget.label),
          ),
        ),
      ),
    );
  }
}

// ── Landing hero: 4K destination carousel ("Explore the World" style) ────────

class _HeroSection extends StatefulWidget {
  final bool visible;
  final bool mobile;
  const _HeroSection({required this.visible, required this.mobile});

  @override
  State<_HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<_HeroSection> {
  static const _interval = Duration(seconds: 7);
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _restartTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _precache(1);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _restartTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_interval, (_) => _goTo(_index + 1, fromTimer: true));
  }

  /// Network slides are 3840px (4K). On smaller screens use the 1920px rendition,
  /// and always decode at (screen width × DPR) so 4K bitmaps don't pile up in memory.
  ImageProvider _provider(HeroSlide s) {
    if (s.isAsset) return AssetImage(s.image);
    final blurred = safeImageSource(s.image);
    if (blurred.startsWith('assets/')) return AssetImage(blurred);
    final mq = MediaQuery.of(context);
    final targetW = (mq.size.width * mq.devicePixelRatio).round();
    final url = targetW <= 1920 ? s.image.replaceFirst('/3840px-', '/1920px-') : s.image;
    return ResizeImage(NetworkImage(url), width: targetW.clamp(800, 3840), allowUpscaling: false);
  }

  void _precache(int i) {
    final s = heroSlides[i % heroSlides.length];
    precacheImage(_provider(s), context, onError: (_, _) {});
  }

  void _goTo(int i, {bool fromTimer = false}) {
    if (!mounted) return;
    final n = heroSlides.length;
    setState(() => _index = (i % n + n) % n);
    _precache(_index + 1);
    if (!fromTimer) _restartTimer();
  }

  @override
  Widget build(BuildContext context) {
    final mobile = widget.mobile;
    final visible = widget.visible;
    final screenH = MediaQuery.of(context).size.height;
    final heroH = (mobile ? screenH * 0.92 : screenH).clamp(600.0, 980.0);
    final hPad = mobile ? 24.0 : 110.0;
    // Short phones get a smaller headline so the hero copy never overflows.
    final titleSize = mobile ? (screenH < 760 ? 42.0 : 54.0) : (screenH < 760 ? 76.0 : 96.0);
    final slide = heroSlides[_index];

    return SizedBox(
      height: heroH,
      width: double.infinity,
      child: Stack(
        children: [
          // Background carousel: cross-fade + slow Ken Burns zoom
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 1400),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              layoutBuilder: (current, previous) => Stack(
                fit: StackFit.expand,
                children: [...previous, ?current],
              ),
              child: _KenBurnsImage(key: ValueKey(_index), slide: slide, provider: _provider(slide)),
            ),
          ),
          // Scrims for legibility
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Colors.black.withValues(alpha: 0.55), Colors.black.withValues(alpha: 0.05)],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0, 0.22, 0.62, 1],
                    colors: [
                      Colors.black.withValues(alpha: 0.45),
                      Colors.transparent,
                      Colors.transparent,
                      const Color(0xFF0F172A).withValues(alpha: 0.75),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Main copy
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(top: mobile ? 76 : 96, bottom: mobile ? 130 : 140),
              // Auto-fit: on short or narrow screens the whole headline block scales
              // down to the space available instead of overflowing.
              child: LayoutBuilder(
                builder: (context, box) => FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: box.maxWidth,
                    child: AnimatedOpacity(
                opacity: visible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 900),
                child: AnimatedSlide(
                  offset: visible ? Offset.zero : const Offset(0, 0.04),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: hPad),
                        child: Text('DISCOVER 50+ DESTINATIONS',
                            style: TextStyle(
                              color: _kSun,
                              fontSize: mobile ? 12 : 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 3,
                            )),
                      ),
                      SizedBox(height: mobile ? 10 : 14),
                      Padding(
                        padding: EdgeInsets.only(left: hPad, right: 24),
                        child: Text.rich(
                          TextSpan(children: [
                            TextSpan(
                              text: 'Explore\n',
                              style: TextStyle(
                                fontSize: titleSize, fontWeight: FontWeight.w700, height: 1.05, letterSpacing: -1,
                              ),
                            ),
                            TextSpan(
                              text: 'Cebu Island',
                              style: TextStyle(
                                fontSize: titleSize, fontWeight: FontWeight.w200, height: 1.1, letterSpacing: -0.5,
                              ),
                            ),
                          ]),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            shadows: [Shadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 24)],
                          ),
                        ),
                      ),
                      SizedBox(height: mobile ? 22 : 32),
                      Container(
                        width: hPad + (mobile ? 180 : 340),
                        height: 2,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      SizedBox(height: mobile ? 22 : 32),
                      Padding(
                        padding: EdgeInsets.only(left: hPad, right: 24),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 520),
                          child: const Text(
                            'From the karst peaks of Osmeña to the turquoise pools of Kawasan Falls — '
                            'plan, book, and track your Cebu adventure in one place.',
                            style: TextStyle(color: Colors.white, fontSize: 15, height: 1.6, letterSpacing: 0.6),
                          ),
                        ),
                      ),
                      SizedBox(height: mobile ? 28 : 44),
                      Padding(
                        padding: EdgeInsets.only(left: hPad, right: 24),
                        child: Wrap(
                          spacing: 14,
                          runSpacing: 12,
                          children: [
                            _HeroCta(
                              label: 'EXPLORE',
                              primary: false,
                              onTap: () => Navigator.pushNamed(context, ExploreScreen.routeName),
                            ),
                            _HeroCta(
                              label: 'BOOK A TRIP',
                              primary: true,
                              onTap: () => Navigator.pushNamed(context, BookingScreen.routeName),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
                  ),
                ),
              ),
            ),
          ),

          // Right-side vertical rail with working social / media buttons
          if (!mobile)
            Positioned(
              right: 48,
              top: heroH * 0.2,
              bottom: heroH * 0.2,
              child: Column(
                children: [
                  Expanded(child: Container(width: 1.5, color: Colors.white.withValues(alpha: 0.8))),
                  const SizedBox(height: 14),
                  const _SocialButtons(axis: Axis.vertical),
                  const SizedBox(height: 14),
                  Expanded(child: Container(width: 1.5, color: Colors.white.withValues(alpha: 0.8))),
                ],
              ),
            ),

          // Bottom bar: current destination · dots · arrows
          Positioned(
            left: hPad,
            right: mobile ? 24 : 110,
            bottom: mobile ? 66 : 84,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    switchInCurve: const Interval(0.4, 1, curve: Curves.easeOut),
                    switchOutCurve: const Interval(0.6, 1, curve: Curves.easeIn),
                    layoutBuilder: (current, previous) => Stack(
                      alignment: Alignment.bottomLeft,
                      children: [...previous, ?current],
                    ),
                    child: _SlideCaption(
                      key: ValueKey(_index),
                      slide: slide,
                      number: _index + 1,
                      total: heroSlides.length,
                    ),
                  ),
                ),
                if (!mobile) ...[
                  _Dots(count: heroSlides.length, index: _index, onTap: _goTo),
                  const SizedBox(width: 28),
                ],
                _ArrowBtn(icon: Icons.arrow_back_rounded, tooltip: 'Previous', onTap: () => _goTo(_index - 1)),
                const SizedBox(width: 10),
                _ArrowBtn(icon: Icons.arrow_forward_rounded, tooltip: 'Next', onTap: () => _goTo(_index + 1)),
              ],
            ),
          ),
          // Progress bar for the current slide
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: TweenAnimationBuilder<double>(
              key: ValueKey('p$_index'),
              tween: Tween(begin: 0, end: 1),
              duration: _interval,
              builder: (_, v, _) => Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: v,
                  child: Container(height: 3, color: _kSun),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A slide image that slowly zooms in while it is on screen.
class _KenBurnsImage extends StatelessWidget {
  final HeroSlide slide;
  final ImageProvider provider;
  const _KenBurnsImage({super.key, required this.slide, required this.provider});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 1.09),
      duration: const Duration(seconds: 9),
      curve: Curves.easeOut,
      builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
      child: Image(
        image: provider,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        gaplessPlayback: true,
        frameBuilder: (_, child, frame, sync) => sync
            ? child
            : AnimatedOpacity(
                opacity: frame == null ? 0 : 1,
                duration: const Duration(milliseconds: 600),
                child: child,
              ),
        errorBuilder: (_, _, _) => Image.asset(_kHeroBg, fit: BoxFit.cover),
      ),
    );
  }
}

String _slideCredit(HeroSlide slide) {
  if (slide.isAsset) return 'Photo: Spoony Travel and Tours';
  final c = creditForUrl(slide.image);
  if (c == null) return '';
  return '© ${c.author} · ${c.license}${c.modified ? ' · edited' : ''}';
}

class _SlideCaption extends StatelessWidget {
  final HeroSlide slide;
  final int number;
  final int total;
  const _SlideCaption({super.key, required this.slide, required this.number, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(number.toString().padLeft(2, '0'),
            style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w200, height: 1)),
        Padding(
          padding: const EdgeInsets.only(left: 4, right: 14, bottom: 3),
          child: Text('/ ${total.toString().padLeft(2, '0')}',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
        ),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(slide.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
              Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.location_on, size: 12, color: _kSun),
                const SizedBox(width: 3),
                Flexible(
                  child: Text(slide.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12)),
                ),
              ]),
              const SizedBox(height: 3),
              Text(
                _slideCredit(slide),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Dots extends StatelessWidget {
  final int count;
  final int index;
  final void Function(int) onTap;
  const _Dots({required this.count, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final active = i == index;
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => onTap(i),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: active ? 22 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: active ? _kSun : Colors.white.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _ArrowBtn extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _ArrowBtn({required this.icon, required this.tooltip, required this.onTap});

  @override
  State<_ArrowBtn> createState() => _ArrowBtnState();
}

class _ArrowBtnState extends State<_ArrowBtn> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _hover ? Colors.white : Colors.white.withValues(alpha: 0.08),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.85), width: 1.5),
            ),
            child: Icon(widget.icon, size: 20, color: _hover ? _kDark : Colors.white),
          ),
        ),
      ),
    );
  }
}

/// Facebook → Spoony's page, Pictures → in-app gallery, Videos → travel videos.
class _SocialButtons extends StatelessWidget {
  final Axis axis;
  const _SocialButtons({required this.axis});

  @override
  Widget build(BuildContext context) {
    final buttons = [
      _RailButton(
        icon: Icons.facebook,
        tooltip: 'Facebook',
        onTap: () => openExternal(context, kFacebookPageUrl),
      ),
      _RailButton(
        icon: Icons.photo_library_outlined,
        tooltip: 'Pictures',
        onTap: () => showPhotoGallery(context),
      ),
      _RailButton(
        icon: Icons.play_circle_outline,
        tooltip: 'Videos',
        onTap: () => showVideos(context),
      ),
    ];
    return axis == Axis.vertical
        ? Column(mainAxisSize: MainAxisSize.min, children: buttons)
        : Row(mainAxisSize: MainAxisSize.min, children: buttons);
  }
}

class _RailButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _RailButton({required this.icon, required this.tooltip, required this.onTap});

  @override
  State<_RailButton> createState() => _RailButtonState();
}

class _RailButtonState extends State<_RailButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      preferBelow: false,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.all(4),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _hover ? _kSun : Colors.black.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: _hover ? _kSun : Colors.white.withValues(alpha: 0.5)),
            ),
            child: Icon(widget.icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }
}

class _HeroCta extends StatefulWidget {
  final String label;
  final bool primary;
  final VoidCallback onTap;
  const _HeroCta({required this.label, required this.primary, required this.onTap});

  @override
  State<_HeroCta> createState() => _HeroCtaState();
}

class _HeroCtaState extends State<_HeroCta> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final filled = widget.primary || _hovered;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
          decoration: BoxDecoration(
            color: filled
                ? (widget.primary ? (_hovered ? Colors.white : _kSun) : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: widget.primary && !_hovered ? _kSun : Colors.white,
              width: 2,
            ),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: filled && (_hovered || !widget.primary) ? _kDark : Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Shared nav bar (used by Explore, Booking, Dashboard, Admin) ───────────────

class SpoonyNavBar extends StatefulWidget {
  final String current;

  /// Optional page banner under the nav, styled like the home hero:
  /// bold [title] + light [subtitle] on the mountain photo, with a thin rule.
  final String? title;
  final String? subtitle;
  final String? tagline;
  const SpoonyNavBar({super.key, required this.current, this.title, this.subtitle, this.tagline});

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
                      radius: 20, backgroundColor: _kAccent,
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
              if (_user != null)
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
                            if (context.mounted) Navigator.pushReplacementNamed(context, HomeScreen.routeName);
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
                            Navigator.pushNamed(context, AuthScreen.routeName);
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: _kAccent,
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
    final hPad = mobile ? 20.0 : 80.0;
    final hasBanner = widget.title != null;

    // Same mountain-sunset photo as the home hero, cropped to the sky band.
    return Container(
      decoration: const BoxDecoration(
        color: _kDark,
        image: DecorationImage(
          image: AssetImage(_kHeroBg),
          fit: BoxFit.cover,
          alignment: Alignment(0, -0.3),
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.black.withValues(alpha: hasBanner ? 0.55 : 0.50),
              Colors.black.withValues(alpha: hasBanner ? 0.15 : 0.25),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: mobile ? 12 : 18),
              child: _navRow(context, mobile),
            ),
            if (hasBanner) _banner(mobile, hPad),
          ],
        ),
      ),
    );
  }

  Widget _banner(bool mobile, double hPad) {
    final size = mobile ? 38.0 : 58.0;
    return Padding(
      padding: EdgeInsets.only(top: mobile ? 12 : 24, bottom: mobile ? 28 : 44),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: hPad, right: hPad),
            child: Text.rich(
              TextSpan(children: [
                TextSpan(
                  text: widget.title,
                  style: TextStyle(fontSize: size, fontWeight: FontWeight.w700, letterSpacing: -0.5),
                ),
                if (widget.subtitle != null)
                  TextSpan(
                    text: ' ${widget.subtitle}',
                    style: TextStyle(fontSize: size, fontWeight: FontWeight.w200),
                  ),
              ]),
              style: const TextStyle(color: Colors.white, height: 1.1),
            ),
          ),
          SizedBox(height: mobile ? 14 : 20),
          Container(width: hPad + (mobile ? 140 : 260), height: 2, color: Colors.white.withValues(alpha: 0.9)),
          if (widget.tagline != null) ...[
            SizedBox(height: mobile ? 14 : 20),
            Padding(
              padding: EdgeInsets.only(left: hPad, right: hPad),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Text(widget.tagline!,
                    style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.6, letterSpacing: 0.4)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _navRow(BuildContext context, bool mobile) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pushReplacementNamed(context, HomeScreen.routeName),
            child: const Text('SPOONY',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: Colors.white)),
          ),
          if (mobile)
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 28),
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
              if (_user != null)
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
                  radius: 16, backgroundColor: _kSun,
                  child: Text(_initials(_user!),
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () async {
                    await Supabase.instance.client.auth.signOut();
                    if (context.mounted) Navigator.pushReplacementNamed(context, HomeScreen.routeName);
                  },
                  icon: const Icon(Icons.logout, size: 15),
                  label: const Text('Sign Out'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white, width: 1.5),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: const StadiumBorder(),
                    textStyle: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.5),
                  ),
                ),
              ] else
                OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, AuthScreen.routeName),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white, width: 1.5),
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text('SIGN IN',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                ),
            ]),
        ],
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
      Icon(icon, size: 18, color: _kAccent),
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
    void explore(BuildContext c) => Navigator.pushNamed(c, ExploreScreen.routeName);

    final columns = [
      _FooterLinks(title: 'Explore', links: [
        ('Cebu City', explore),
        ('South Cebu', explore),
        ('North Cebu', explore),
        ('Bohol day trips', explore),
      ]),
      _FooterLinks(title: 'Travel', links: [
        ('Book a trip', (c) => Navigator.pushNamed(c, BookingScreen.routeName)),
        ('Photo gallery', showPhotoGallery),
        ('Travel videos', showVideos),
        ('My trips', (c) => Navigator.pushNamed(c, DashboardScreen.routeName)),
      ]),
      _FooterLinks(title: 'Support', links: [
        ('Contact us', _showContactUs),
        ('FAQs', _showFAQs),
        ('Privacy policy', _showPrivacyPolicy),
        ('Terms of service', _showTerms),
        ('Photo credits', showPhotoCredits),
      ]),
    ];

    return Container(
      color: _kDark,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(hPad, mobile ? 40 : 72, hPad, mobile ? 28 : 48),
            child: mobile
                ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const _FooterBrand(),
                    const SizedBox(height: 32),
                    Wrap(spacing: 40, runSpacing: 28, children: columns),
                  ])
                : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Expanded(flex: 5, child: _FooterBrand()),
                    const SizedBox(width: 48),
                    for (final c in columns) Expanded(flex: 2, child: c),
                  ]),
          ),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.08), margin: EdgeInsets.symmetric(horizontal: hPad)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 20),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 8,
              children: [
                Text('© 2026 Spoony Travel and Tours. All rights reserved.',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 12)),
                Text('Photos & videos: Wikimedia Commons contributors (CC BY / CC BY-SA / CC0)',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterBrand extends StatefulWidget {
  const _FooterBrand();

  @override
  State<_FooterBrand> createState() => _FooterBrandState();
}

class _FooterBrandState extends State<_FooterBrand> {
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _subscribe() {
    final v = _email.text.trim();
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? 'Thanks! Travel deals are on their way to $v.' : 'Please enter a valid email address.'),
    ));
    if (ok) _email.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('SPOONY',
          style: GoogleFonts.poppins(
              fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: 3, color: Colors.white)),
      const SizedBox(height: 10),
      const SizedBox(
        width: 360,
        child: Text(
          'Curated trips, real-time booking and local know-how for the most beautiful corners of Cebu.',
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14, height: 1.6),
        ),
      ),
      const SizedBox(height: 24),
      const Text('Get travel deals in your inbox',
          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
      const SizedBox(height: 10),
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 4, 4, 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _email,
                onSubmitted: (_) => _subscribe(),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                cursorColor: _kSun,
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: 'you@email.com',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
                ),
              ),
            ),
            WmShimmerButton(
              label: 'Subscribe',
              onTap: _subscribe,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
              fontSize: 13,
            ),
          ]),
        ),
      ),
      const SizedBox(height: 24),
      const _SocialButtons(axis: Axis.horizontal),
    ]);
  }
}

class _FooterLinks extends StatelessWidget {
  final String title;
  final List<(String, void Function(BuildContext)?)> links;
  const _FooterLinks({required this.title, required this.links});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Text(title.toUpperCase(),
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.6, color: Colors.white.withValues(alpha: 0.5))),
      const SizedBox(height: 16),
      for (final (label, onTap) in links)
        Padding(
          padding: const EdgeInsets.only(bottom: 11),
          child: _FooterLink(label: label, onTap: onTap == null ? null : () => onTap(context)),
        ),
    ]);
  }
}

class _FooterLink extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  const _FooterLink({required this.label, this.onTap});

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 150),
          style: TextStyle(
            color: _hover ? Colors.white : const Color(0xFFB4BCC8),
            fontSize: 14,
          ),
          child: AnimatedSlide(
            offset: Offset(_hover ? 0.03 : 0, 0),
            duration: const Duration(milliseconds: 150),
            child: Text(widget.label),
          ),
        ),
      ),
    );
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
      leading: Icon(icon, color: active ? _kAccent : _kMid),
      title: Text(label,
          style: TextStyle(
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: active ? _kAccent : const Color(0xFF475569))),
      tileColor: active ? _kAccent.withValues(alpha: 0.06) : null,
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
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        foregroundColor: _kSun,
      ),
      child: Text(label,
          style: TextStyle(
            fontSize: 15,
            letterSpacing: 0.3,
            color: active ? _kSun : Colors.white.withValues(alpha: 0.88),
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          )),
    );
  }
}
