// Homepage story sections: "Why Spoony" bento, testimonials marquee, CTA banner.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/cebu_data.dart';
import '../../screens/booking_screen.dart';
import '../../screens/explore_screen.dart';
import '../safe_image.dart';
import '../wm_ui.dart';

const _kGreen = Color(0xFF3F7D58);
const _kGold = Color(0xFFF59E0B);

String _spotImage(String id) {
  for (final d in cebuDestinations) {
    if (d.id == id && d.images.isNotEmpty) return d.images.first;
  }
  return cebuDestinations.first.images.first;
}

Widget _eyebrow(String text, {bool center = false}) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Wm.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Wm.accent.withValues(alpha: 0.2)),
      ),
      child: Text(text,
          textAlign: center ? TextAlign.center : TextAlign.start,
          style: const TextStyle(
              color: Wm.accent, fontSize: 11.5, fontWeight: FontWeight.w700, letterSpacing: 1.6)),
    );

TextStyle _title(bool mobile, {Color color = Wm.ink}) => GoogleFonts.poppins(
      fontSize: mobile ? 28 : 36,
      fontWeight: FontWeight.w700,
      height: 1.15,
      letterSpacing: -0.6,
      color: color,
    );

// ── 1. Why Spoony (bento) ────────────────────────────────────────────────────

class HomeWhySection extends StatelessWidget {
  final double hPad;
  const HomeWhySection({super.key, required this.hPad});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final mobile = w < 700;
    final wide = w >= 1100;

    final intro = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        WmBlurIn(child: _eyebrow('WHY SPOONY')),
        const SizedBox(height: 16),
        WmBlurIn(
          delay: const Duration(milliseconds: 80),
          child: Text('Travel Cebu\nthe easy way', style: _title(mobile)),
        ),
        const SizedBox(height: 16),
        WmBlurIn(
          delay: const Duration(milliseconds: 160),
          child: const Text(
            'Curated spots, smart day-by-day itineraries and secure booking — '
            'everything you need for island hopping, canyoneering and city tours in one place.',
            style: TextStyle(color: Wm.muted, fontSize: 15, height: 1.65),
          ),
        ),
        const SizedBox(height: 26),
        WmBlurIn(
          delay: const Duration(milliseconds: 240),
          child: WmShimmerButton(
            label: 'Plan my trip',
            icon: Icons.arrow_forward_rounded,
            onTap: () => Navigator.pushNamed(context, BookingScreen.routeName),
          ),
        ),
      ],
    );

    const features = [
      (Icons.route_rounded, Wm.accent, 'Smart itinerary', 'Optimized routes, distances and schedules for every day of your trip.'),
      (Icons.shield_rounded, _kGreen, 'Secure booking', 'Verified partners, transparent pricing and instant reference codes.'),
      (Icons.near_me_rounded, _kGold, 'Real-time tracking', 'Follow your driver live and get notified the moment they arrive.'),
    ];

    final photo = _PhotoFeature(image: _spotImage('osmena_peak'));
    final small = [
      for (var i = 0; i < features.length; i++)
        _FeatureCard(icon: features[i].$1, color: features[i].$2, title: features[i].$3, desc: features[i].$4),
    ];

    Widget bento;
    if (mobile) {
      bento = Column(children: [
        SizedBox(height: 240, child: photo),
        for (final c in small) ...[const SizedBox(height: 14), c],
      ]);
    } else {
      bento = SizedBox(
        height: 440,
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(flex: 5, child: photo),
          const SizedBox(width: 16),
          Expanded(
            flex: 5,
            child: Column(children: [
              for (var i = 0; i < small.length; i++) ...[
                if (i > 0) const SizedBox(height: 16),
                Expanded(child: small[i]),
              ],
            ]),
          ),
        ]),
      );
    }

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: mobile ? 56 : 96),
      child: wide
          ? Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Expanded(flex: 4, child: intro),
              const SizedBox(width: 56),
              Expanded(flex: 7, child: WmBlurIn(delay: const Duration(milliseconds: 200), child: bento)),
            ])
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              intro,
              const SizedBox(height: 36),
              WmBlurIn(delay: const Duration(milliseconds: 200), child: bento),
            ]),
    );
  }
}

class _PhotoFeature extends StatefulWidget {
  final String image;
  const _PhotoFeature({required this.image});

  @override
  State<_PhotoFeature> createState() => _PhotoFeatureState();
}

class _PhotoFeatureState extends State<_PhotoFeature> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final credit = creditForUrl(widget.image);
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: Wm.fast,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Wm.rLarge - 4),
          boxShadow: Wm.shadow(_hover ? 1 : 0.3),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Wm.rLarge - 4),
          child: Stack(fit: StackFit.expand, children: [
            WmZoomFrame(
              hoverOverride: _hover,
              child: SafeImage(widget.image, fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(color: Wm.ink)),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.3, 1],
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.78)],
                ),
              ),
            ),
            if (credit != null)
              Positioned(top: 12, right: 12, child: PhotoCreditChip(credit: credit, light: true)),
            Positioned(
              left: 22,
              right: 22,
              bottom: 22,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                  ),
                  child: const Icon(Icons.eco_rounded, color: Colors.white, size: 21),
                ),
                const SizedBox(height: 14),
                Text('Local experiences',
                    style: GoogleFonts.poppins(
                        color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600, height: 1.2)),
                const SizedBox(height: 6),
                Text('59 handpicked spots — hidden falls, sandbars, heritage towns and mountain peaks.',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13.5, height: 1.55)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String desc;
  const _FeatureCard({required this.icon, required this.color, required this.title, required this.desc});

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: Wm.fast,
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hover ? -3 : 0, 0),
        padding: const EdgeInsets.all(20),
        decoration: Wm.card(hover: _hover, tint: widget.color),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          AnimatedContainer(
            duration: Wm.fast,
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: _hover ? 0.18 : 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(widget.icon, color: widget.color, size: 23),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text(widget.title,
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Wm.ink)),
              const SizedBox(height: 4),
              Text(widget.desc,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: Wm.muted, height: 1.5)),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ── 2. Testimonials marquee ──────────────────────────────────────────────────

class _Review {
  final String name;
  final String city;
  final double rating;
  final String text;
  final String trip;
  final Color color;
  const _Review(this.name, this.city, this.rating, this.text, this.trip, this.color);
}

const _reviews = [
  _Review('Maria Santos', 'Cebu City', 4.9,
      'Spoony made our Cebu trip absolutely perfect! The booking was seamless and the destinations they suggested were hidden gems we never would have found on our own.',
      'Sirao Garden', Wm.accent),
  _Review('John Reyes', 'Manila', 5.0,
      'Best travel platform for Cebu! The real-time itinerary planner saved us hours of planning. Kawasan Falls was breathtaking — everything was organized perfectly.',
      'Kawasan Falls', _kGreen),
  _Review('Ana Villanueva', 'Davao', 4.8,
      'Wonderful experience! The team at Spoony was so helpful and responsive. Booked Osmeña Peak and Sardine Run in one go — it was incredible!',
      'Osmeña Peak', Color(0xFF6366F1)),
  _Review('Kenji Watanabe', 'Osaka, Japan', 4.9,
      'Our driver arrived right on time and we could track him live. The Sumilon sandbar at low tide was the highlight of our honeymoon.',
      'Sumilon Island', Color(0xFF0EA5E9)),
  _Review('Liza Mendoza', 'Iloilo', 4.7,
      'Joined the North Cebu island hop as a solo traveler and made friends for life. Bantayan sunsets are unreal — very good value for the joiner price.',
      'Bantayan Island', _kGold),
  _Review('Daniel Cruz', 'Quezon City', 5.0,
      'Booked a premium family tour with my parents and kids. Everything from the van to the lunch stops was smooth. Temple of Leah at night was magical.',
      'Temple of Leah', Color(0xFFE11D48)),
];

class HomeTestimonialsSection extends StatefulWidget {
  final double hPad;
  const HomeTestimonialsSection({super.key, required this.hPad});

  @override
  State<HomeTestimonialsSection> createState() => _HomeTestimonialsSectionState();
}

class _HomeTestimonialsSectionState extends State<HomeTestimonialsSection> with SingleTickerProviderStateMixin {
  static const _cardW = 360.0;
  static const _gap = 20.0;
  static const _speed = 40.0; // px per second
  static final _setWidth = _reviews.length * (_cardW + _gap);

  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: (_setWidth / _speed * 1000).round()),
  );
  bool _reduced = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = MediaQuery.of(context).disableAnimations;
    if (_reduced) {
      _ctrl.stop();
    } else if (!_ctrl.isAnimating) {
      _ctrl.repeat();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.of(context).size.width < 700;
    final header = Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.hPad),
      child: Column(children: [
        WmBlurIn(child: _eyebrow('TESTIMONIALS', center: true)),
        const SizedBox(height: 14),
        WmBlurIn(
          delay: const Duration(milliseconds: 80),
          child: Text('Loved by travelers', textAlign: TextAlign.center, style: _title(mobile)),
        ),
        const SizedBox(height: 10),
        WmBlurIn(
          delay: const Duration(milliseconds: 160),
          child: const Text('Real reviews from people who explored Cebu with Spoony.',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Wm.muted, height: 1.5)),
        ),
      ]),
    );

    Widget body;
    if (_reduced) {
      body = Padding(
        padding: EdgeInsets.symmetric(horizontal: widget.hPad),
        child: Wrap(
          spacing: _gap,
          runSpacing: _gap,
          alignment: WrapAlignment.center,
          children: [for (final r in _reviews) _ReviewCard(review: r, width: mobile ? double.infinity : _cardW)],
        ),
      );
    } else {
      final cardW = mobile ? 300.0 : _cardW;
      final setW = _reviews.length * (cardW + _gap);
      final row = Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var k = 0; k < 2; k++)
            for (final r in _reviews)
              Padding(padding: const EdgeInsets.only(right: _gap), child: _ReviewCard(review: r, width: cardW)),
        ],
      );
      body = MouseRegion(
        onEnter: (_) => _ctrl.stop(),
        onExit: (_) {
          if (!_reduced) _ctrl.repeat();
        },
        child: ShaderMask(
          shaderCallback: (rect) => const LinearGradient(
            colors: [Colors.transparent, Colors.black, Colors.black, Colors.transparent],
            stops: [0, 0.08, 0.92, 1],
          ).createShader(rect),
          blendMode: BlendMode.dstIn,
          child: SizedBox(
            height: 270,
            child: ClipRect(
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (_, child) => OverflowBox(
                  alignment: Alignment.centerLeft,
                  minWidth: 0,
                  maxWidth: double.infinity,
                  child: Transform.translate(offset: Offset(-_ctrl.value * setW, 0), child: child),
                ),
                child: row,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      color: Wm.surface,
      padding: EdgeInsets.symmetric(vertical: mobile ? 56 : 88),
      child: Column(children: [header, SizedBox(height: mobile ? 30 : 44), body]),
    );
  }
}

class _ReviewCard extends StatefulWidget {
  final _Review review;
  final double width;
  const _ReviewCard({required this.review, required this.width});

  @override
  State<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<_ReviewCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.review;
    final initials = r.name.split(' ').map((p) => p.isEmpty ? '' : p[0]).take(2).join();
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: Wm.fast,
        width: widget.width == double.infinity ? null : widget.width,
        height: widget.width == double.infinity ? null : 250,
        padding: const EdgeInsets.all(22),
        decoration: Wm.card(hover: _hover, tint: r.color),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            for (var i = 0; i < 5; i++)
              Icon(Icons.star_rounded, size: 17, color: i < r.rating.round() ? _kGold : Wm.border),
            const Spacer(),
            Icon(Icons.format_quote_rounded, size: 26, color: r.color.withValues(alpha: 0.35)),
          ]),
          const SizedBox(height: 12),
          Flexible(
            fit: widget.width == double.infinity ? FlexFit.loose : FlexFit.tight,
            child: Text('"${r.text}"',
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13.5, color: Wm.inkSoft, height: 1.6)),
          ),
          const SizedBox(height: 14),
          Row(children: [
            CircleAvatar(
              radius: 19,
              backgroundColor: r.color.withValues(alpha: 0.14),
              child: Text(initials, style: TextStyle(color: r.color, fontWeight: FontWeight.w700, fontSize: 13)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Text(r.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Wm.ink)),
                Text(r.city,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11.5, color: Wm.muted)),
              ]),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(color: Wm.chip, borderRadius: BorderRadius.circular(999)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.location_on_rounded, size: 12, color: Wm.accent),
                  const SizedBox(width: 3),
                  Flexible(
                    child: Text(r.trip,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Wm.inkSoft)),
                  ),
                ]),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

// ── 3. CTA banner ────────────────────────────────────────────────────────────

class HomeCtaBanner extends StatelessWidget {
  final double hPad;
  const HomeCtaBanner({super.key, required this.hPad});

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.of(context).size.width < 700;
    final image = _spotImage('kalanggaman_island');
    final credit = creditForUrl(image);

    final content = Padding(
      padding: EdgeInsets.fromLTRB(mobile ? 24 : 56, mobile ? 36 : 48, mobile ? 24 : 56, mobile ? 48 : 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Text('Ready for your Cebu adventure?',
                style: GoogleFonts.poppins(
                    fontSize: mobile ? 28 : 40,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                    letterSpacing: -0.6,
                    color: Colors.white)),
          ),
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Text(
              'Pick your spots, choose joiner or premium, and we\'ll handle the rides, routes and reservations.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 15, height: 1.6),
            ),
          ),
          const SizedBox(height: 28),
          Wrap(spacing: 12, runSpacing: 12, children: [
            WmShimmerButton(
              label: 'Book a trip',
              icon: Icons.calendar_month_rounded,
              onTap: () => Navigator.pushNamed(context, BookingScreen.routeName),
            ),
            WmPressable(
              onTap: () => Navigator.pushNamed(context, ExploreScreen.routeName),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: const Text('Explore destinations',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14, letterSpacing: 0.3)),
              ),
            ),
          ]),
        ],
      ),
    );

    final banner = ClipRRect(
      borderRadius: BorderRadius.circular(Wm.rLarge),
      child: Stack(children: [
        Positioned.fill(
          child: SafeImage(image, fit: BoxFit.cover, errorBuilder: (_, _, _) => Container(color: Wm.ink)),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: mobile ? Alignment.topCenter : Alignment.centerLeft,
                end: mobile ? Alignment.bottomCenter : Alignment.centerRight,
                colors: [Colors.black.withValues(alpha: 0.75), Colors.black.withValues(alpha: mobile ? 0.55 : 0.05)],
              ),
            ),
          ),
        ),
        if (mobile) content else SizedBox(height: 360, child: Align(alignment: Alignment.centerLeft, child: content)),
        if (credit != null)
          Positioned(right: 14, bottom: 14, child: PhotoCreditChip(credit: credit, light: true)),
      ]),
    );

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(hPad, mobile ? 40 : 72, hPad, mobile ? 40 : 72),
      child: WmBlurIn(
        child: DecoratedBox(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(Wm.rLarge), boxShadow: Wm.shadow(1)),
          child: banner,
        ),
      ),
    );
  }
}
