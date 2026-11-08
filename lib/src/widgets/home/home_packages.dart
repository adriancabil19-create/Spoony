// Tour packages with a Watermelon-style "changeable pricing" toggle (homepage).
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/cebu_data.dart';
import '../../models.dart';
import '../../screens/booking_screen.dart';
import '../safe_image.dart';
import '../wm_ui.dart';

class HomePackagesSection extends StatefulWidget {
  final double hPad;
  const HomePackagesSection({super.key, required this.hPad});

  @override
  State<HomePackagesSection> createState() => _HomePackagesSectionState();
}

class _HomePackagesSectionState extends State<HomePackagesSection> {
  int _tier = 0; // 0 = Joiner, 1 = Premium

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final mobile = width < 700;
    final hPad = widget.hPad;
    final premium = _tier == 1;

    return Container(
      color: Wm.surface,
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: mobile ? 48 : 72),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WmBlurIn(
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.end,
              runSpacing: 18,
              spacing: 24,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: Wm.accent.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Wm.accent.withValues(alpha: 0.2)),
                      ),
                      child: const Text('TOUR PACKAGES',
                          style: TextStyle(
                              color: Wm.accent, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.4)),
                    ),
                    const SizedBox(height: 12),
                    Text('Curated day trips',
                        style: GoogleFonts.poppins(
                            fontSize: mobile ? 26 : 34, fontWeight: FontWeight.w600, color: Wm.ink, height: 1.15)),
                    const SizedBox(height: 6),
                    Text(
                      premium
                          ? 'Private vehicle, flexible schedule and a dedicated guide.'
                          : 'Join a small group and share the ride — the best value way to see Cebu.',
                      style: TextStyle(fontSize: mobile ? 13 : 15, color: Wm.muted, height: 1.5),
                    ),
                  ]),
                ),
                WmContinuousTabs(
                  labels: const ['Joiner', 'Premium'],
                  selected: _tier,
                  onChanged: (i) => setState(() => _tier = i),
                ),
              ],
            ),
          ),
          SizedBox(height: mobile ? 24 : 36),
          LayoutBuilder(builder: (context, c) {
            final cols = c.maxWidth >= 1100 ? 4 : c.maxWidth >= 640 ? 2 : 1;
            const gap = 20.0;
            final cardW = (c.maxWidth - gap * (cols - 1)) / cols;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (var i = 0; i < tourPackages.length; i++)
                  SizedBox(
                    width: cardW,
                    child: WmBlurIn(
                      delay: Duration(milliseconds: 80 * i),
                      child: _PackageCard(pkg: tourPackages[i], premium: premium),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _PackageCard extends StatefulWidget {
  final TourPackage pkg;
  final bool premium;
  const _PackageCard({required this.pkg, required this.premium});

  @override
  State<_PackageCard> createState() => _PackageCardState();
}

class _PackageCardState extends State<_PackageCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.pkg;
    final price = (widget.premium ? p.premiumPricePerPerson : p.joinerPricePerPerson).toInt();
    final days = p.durationDays == 1 ? '1 day' : '${p.durationDays} days';

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hover ? -6 : 0, 0),
        decoration: Wm.card(hover: _hover),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 170,
              width: double.infinity,
              child: Stack(fit: StackFit.expand, children: [
                WmZoomFrame(
                  hoverOverride: _hover,
                  child: SafeImage(
                    p.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(color: Wm.chip),
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black.withValues(alpha: 0.25), Colors.transparent],
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: _pill(p.region, Colors.white.withValues(alpha: 0.92), Wm.ink),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: _pill(days, Wm.activePill, Colors.white, icon: Icons.schedule_rounded),
                ),
                if (creditForUrl(p.imageUrl) case final c?)
                  Positioned(right: 8, bottom: 8, child: PhotoCreditChip(credit: c, light: true)),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w600, color: Wm.ink)),
                  const SizedBox(height: 4),
                  Text(p.tagline,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12.5, color: Wm.muted, height: 1.45)),
                  const SizedBox(height: 14),
                  for (final h in p.highlights.take(3))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 7),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Container(
                          margin: const EdgeInsets.only(top: 1),
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3F7D58).withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_rounded, size: 11, color: Color(0xFF3F7D58)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(h,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12.5, color: Wm.inkSoft)),
                        ),
                      ]),
                    ),
                  const SizedBox(height: 10),
                  Container(height: 1, color: Wm.border),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ClipRect(
                        child: AnimatedSwitcher(
                          duration: Wm.medium,
                          switchInCurve: Curves.easeOutCubic,
                          transitionBuilder: (child, anim) => FadeTransition(
                            opacity: anim,
                            child: SlideTransition(
                              position: Tween(begin: const Offset(0, 0.6), end: Offset.zero).animate(anim),
                              child: child,
                            ),
                          ),
                          child: Text(
                            '₱$price',
                            key: ValueKey(price),
                            style: GoogleFonts.poppins(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: Wm.ink,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 6),
                        child: Text('/ person', style: TextStyle(fontSize: 12, color: Wm.muted)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  WmShimmerButton(
                    label: 'Book package',
                    icon: Icons.arrow_forward_rounded,
                    expand: true,
                    onTap: () => Navigator.pushNamed(context, BookingScreen.routeName),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(String text, Color bg, Color fg, {IconData? icon}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          Text(text, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600)),
        ]),
      );
}
