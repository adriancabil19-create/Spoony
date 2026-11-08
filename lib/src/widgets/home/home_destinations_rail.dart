// Image-first horizontal rail of top-rated destinations (homepage).
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/cebu_data.dart';
import '../../models.dart';
import '../../screens/explore_screen.dart';
import '../safe_image.dart';
import '../spot_card.dart';
import '../wm_ui.dart';

class HomeDestinationsRail extends StatefulWidget {
  final double hPad;
  const HomeDestinationsRail({super.key, required this.hPad});

  @override
  State<HomeDestinationsRail> createState() => _HomeDestinationsRailState();
}

class _HomeDestinationsRailState extends State<HomeDestinationsRail> {
  final _ctrl = ScrollController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _scroll(double cardW, int dir) {
    if (!_ctrl.hasClients) return;
    final target = (_ctrl.offset + dir * (cardW + 18)).clamp(0.0, _ctrl.position.maxScrollExtent);
    _ctrl.animateTo(target, duration: const Duration(milliseconds: 450), curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.of(context).size.width < 700;
    final cardW = mobile ? 250.0 : 300.0;
    final cardH = mobile ? 340.0 : 400.0;
    final spots = [...cebuDestinations]..sort((a, b) => b.rating.compareTo(a.rating));
    final top = spots.take(10).toList();
    final hPad = widget.hPad;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: mobile ? 48 : 72),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            child: WmBlurIn(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const _Eyebrow('TOP RATED'),
                      const SizedBox(height: 12),
                      Text('Popular destinations',
                          style: GoogleFonts.poppins(
                              fontSize: mobile ? 26 : 34, fontWeight: FontWeight.w600, color: Wm.ink, height: 1.15)),
                      const SizedBox(height: 6),
                      Text('The highest-rated spots across Cebu, loved by travelers.',
                          style: TextStyle(fontSize: mobile ? 13 : 15, color: Wm.muted, height: 1.5)),
                    ]),
                  ),
                  if (!mobile) ...[
                    _RoundArrow(icon: Icons.arrow_back_rounded, onTap: () => _scroll(cardW, -1)),
                    const SizedBox(width: 10),
                    _RoundArrow(icon: Icons.arrow_forward_rounded, onTap: () => _scroll(cardW, 1)),
                    const SizedBox(width: 14),
                  ],
                  _ViewAllPill(onTap: () => Navigator.pushNamed(context, ExploreScreen.routeName)),
                ],
              ),
            ),
          ),
          SizedBox(height: mobile ? 22 : 32),
          SizedBox(
            height: cardH + 16,
            child: ListView.separated(
              controller: _ctrl,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(hPad, 6, hPad, 10),
              itemCount: top.length,
              separatorBuilder: (_, _) => const SizedBox(width: 18),
              itemBuilder: (_, i) => WmBlurIn(
                delay: Duration(milliseconds: 60 * (i < 6 ? i : 6)),
                child: _RailCard(spot: top[i], width: cardW, height: cardH),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RailCard extends StatefulWidget {
  final Destination spot;
  final double width;
  final double height;
  const _RailCard({required this.spot, required this.width, required this.height});

  @override
  State<_RailCard> createState() => _RailCardState();
}

class _RailCardState extends State<_RailCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final spot = widget.spot;
    final credit = spot.images.isEmpty ? null : creditForUrl(spot.images.first);
    final fee = spot.entranceFee <= 0 ? 'Free' : 'from ₱${spot.entranceFee.toInt()}';
    final radius = BorderRadius.circular(24);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: WmPressable(
        onTap: () => showSpotDetails(context, spot),
        pressScale: 0.97,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
          width: widget.width,
          height: widget.height,
          transform: Matrix4.translationValues(0, _hover ? -6 : 0, 0),
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _hover ? 0.22 : 0.10),
                blurRadius: _hover ? 28 : 14,
                offset: Offset(0, _hover ? 14 : 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: Stack(fit: StackFit.expand, children: [
              WmZoomFrame(
                hoverOverride: _hover,
                child: spot.images.isEmpty
                    ? Container(color: Wm.chip)
                    : SafeImage(
                        spot.images.first,
                        fit: BoxFit.cover,
                        width: widget.width,
                        height: widget.height,
                        errorBuilder: (_, _, _) => Container(color: Wm.chip),
                      ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0, 0.25, 0.55, 1],
                    colors: [
                      Colors.black.withValues(alpha: 0.25),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.10),
                      Colors.black.withValues(alpha: 0.78),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 14,
                left: 14,
                right: 60,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
                    ),
                    child: Text(regionTitle(spot.region),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: ValueListenableBuilder<Set<String>>(
                  valueListenable: savedSpots,
                  builder: (_, set, _) => WmSaveToggle(
                    saved: set.contains(spot.id),
                    onChanged: (v) {
                      final next = Set<String>.from(set);
                      v ? next.add(spot.id) : next.remove(spot.id);
                      savedSpots.value = next;
                    },
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (credit != null) ...[
                      PhotoCreditChip(credit: credit, light: true),
                      const SizedBox(height: 10),
                    ],
                    Text(spot.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                            color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600, height: 1.2)),
                    const SizedBox(height: 6),
                    Row(children: [
                      const Icon(Icons.location_on_rounded, size: 13, color: Wm.sun),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(regionTitle(spot.region),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12)),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFBBF24)),
                      const SizedBox(width: 2),
                      Text('${spot.rating}',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                    ]),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(fee,
                          style: const TextStyle(color: Wm.ink, fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _Eyebrow extends StatelessWidget {
  final String text;
  const _Eyebrow(this.text);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: Wm.accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Wm.accent.withValues(alpha: 0.2)),
        ),
        child: Text(text,
            style: const TextStyle(color: Wm.accent, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.4)),
      );
}

class _RoundArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundArrow({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => WmPressable(
        onTap: onTap,
        pressScale: 0.9,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Wm.border),
            boxShadow: Wm.shadow(),
          ),
          child: Icon(icon, size: 20, color: Wm.ink),
        ),
      );
}

class _ViewAllPill extends StatelessWidget {
  final VoidCallback onTap;
  const _ViewAllPill({required this.onTap});

  @override
  Widget build(BuildContext context) => WmPressable(
        onTap: onTap,
        pressScale: 0.94,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            color: Wm.activePill,
            borderRadius: BorderRadius.circular(999),
            boxShadow: Wm.shadow(0.3),
          ),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Text('View all', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            SizedBox(width: 6),
            Icon(Icons.arrow_forward_rounded, size: 15, color: Colors.white),
          ]),
        ),
      );
}
