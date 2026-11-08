// Shared destination card (Watermelon UI style): hover image zoom, accent
// border tint, press scale, save toggle, shimmer "Book Now", and a detail modal.
import 'package:flutter/material.dart';

import '../data/cebu_data.dart';
import '../models.dart';
import '../screens/booking_screen.dart';
import 'safe_image.dart';
import 'wm_ui.dart';

/// In-memory saved spots for screens without a persisted favorites list.
final ValueNotifier<Set<String>> savedSpots = ValueNotifier<Set<String>>(<String>{});

Color spotRegionColor(DestinationRegion r) {
  switch (r) {
    case DestinationRegion.cebuCity:
      return Wm.accent;
    case DestinationRegion.southCebu:
      return const Color(0xFF3F7D58);
    case DestinationRegion.northCebu:
      return const Color(0xFF6D5BD0);
    case DestinationRegion.bohol:
      return const Color(0xFFB7791F);
    default:
      return Wm.muted;
  }
}

String _fee(double fee) => fee <= 0 ? 'Free' : '₱${fee.toInt()}';

Widget _imagePlaceholder({double? height}) => Container(
      height: height,
      color: const Color(0xFFFDF0E7),
      alignment: Alignment.center,
      child: const Icon(Icons.landscape_outlined, color: Wm.accent, size: 36),
    );

Widget _spotImage(Destination spot, {double? width, double? height, bool credit = true}) {
  if (spot.images.isEmpty) return _imagePlaceholder(height: height);
  return SafeImage(
    spot.images.first,
    width: width ?? double.infinity,
    height: height ?? double.infinity,
    fit: BoxFit.cover,
    showCredit: credit,
    errorBuilder: (_, _, _) => _imagePlaceholder(height: height),
  );
}

class _RegionPill extends StatelessWidget {
  final DestinationRegion region;
  final bool short;
  const _RegionPill({required this.region, this.short = true});

  @override
  Widget build(BuildContext context) {
    final label = short ? regionTitle(region).split(' ').first : regionTitle(region);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
        boxShadow: Wm.shadow(),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: spotRegionColor(region), shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(color: Wm.ink, fontSize: 10.5, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class SpotCard extends StatefulWidget {
  final Destination spot;

  /// Compact horizontal variant (mobile lists).
  final bool compact;

  /// Height of the photo in the vertical variant.
  final double imageHeight;

  /// Optional external saved state (e.g. persisted favorites). When null the
  /// card uses the in-memory [savedSpots] set.
  final bool? saved;
  final VoidCallback? onToggleSave;
  final String ctaLabel;

  const SpotCard({
    super.key,
    required this.spot,
    this.compact = false,
    this.imageHeight = 170,
    this.saved,
    this.onToggleSave,
    this.ctaLabel = 'Book Now',
  });

  @override
  State<SpotCard> createState() => _SpotCardState();
}

class _SpotCardState extends State<SpotCard> {
  bool _hover = false;

  void _book() => Navigator.pushNamed(context, BookingScreen.routeName);

  void _open() => showSpotDetails(
        context,
        widget.spot,
        saved: widget.saved,
        onToggleSave: widget.onToggleSave,
        ctaLabel: widget.ctaLabel,
      );

  Widget _save() {
    if (widget.saved != null) {
      return WmSaveToggle(saved: widget.saved!, onChanged: (_) => widget.onToggleSave?.call());
    }
    return ValueListenableBuilder<Set<String>>(
      valueListenable: savedSpots,
      builder: (_, set, _) => WmSaveToggle(
        saved: set.contains(widget.spot.id),
        onChanged: (v) {
          final next = Set<String>.from(set);
          v ? next.add(widget.spot.id) : next.remove(widget.spot.id);
          savedSpots.value = next;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final spot = widget.spot;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: WmPressable(
        onTap: _open,
        pressScale: 0.98,
        child: AnimatedContainer(
          duration: Wm.fast,
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _hover ? -4 : 0, 0),
          decoration: Wm.card(hover: _hover, tint: spotRegionColor(spot.region)),
          clipBehavior: Clip.antiAlias,
          child: widget.compact ? _compact(spot) : _vertical(spot),
        ),
      ),
    );
  }

  Widget _meta(Destination spot, {double size = 12}) => Row(children: [
        Icon(Icons.star_rounded, size: size + 3, color: const Color(0xFFF59E0B)),
        const SizedBox(width: 3),
        Text('${spot.rating}',
            style: TextStyle(fontSize: size, fontWeight: FontWeight.w700, color: Wm.ink)),
        const Spacer(),
        Text(_fee(spot.entranceFee),
            style: TextStyle(fontSize: size + 1, fontWeight: FontWeight.w700, color: const Color(0xFF3F7D58))),
      ]);

  Widget _vertical(Destination spot) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: widget.imageHeight,
          child: Stack(fit: StackFit.expand, children: [
            WmZoomFrame(hoverOverride: _hover, child: _spotImage(spot)),
            Positioned(top: 10, left: 10, child: _RegionPill(region: spot.region)),
            Positioned(top: 8, right: 8, child: _save()),
          ]),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(spot.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600, color: Wm.ink, letterSpacing: -0.2)),
                const SizedBox(height: 3),
                Text(
                  spot.description.isNotEmpty ? spot.description : regionTitle(spot.region),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11.5, color: Wm.muted),
                ),
                const SizedBox(height: 8),
                _meta(spot),
                const Spacer(),
                WmShimmerButton(
                  label: widget.ctaLabel,
                  onTap: _book,
                  expand: true,
                  fontSize: 12.5,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _compact(Destination spot) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 118,
          child: Stack(fit: StackFit.expand, children: [
            WmZoomFrame(hoverOverride: _hover, child: _spotImage(spot, credit: false)),
            Positioned(top: 6, left: 6, child: _RegionPill(region: spot.region)),
          ]),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(
                    child: Text(spot.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Wm.ink)),
                  ),
                  Transform.scale(scale: 0.8, alignment: Alignment.topRight, child: _save()),
                ]),
                Text(regionTitle(spot.region),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: Wm.muted)),
                const Spacer(),
                _meta(spot, size: 11),
                const SizedBox(height: 6),
                WmShimmerButton(
                  label: widget.ctaLabel,
                  onTap: _book,
                  expand: true,
                  fontSize: 11,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Spot detail modal ────────────────────────────────────────────────────────

Future<void> showSpotDetails(
  BuildContext context,
  Destination spot, {
  bool? saved,
  VoidCallback? onToggleSave,
  String ctaLabel = 'Book Now',
}) {
  return showWmModal(
    context,
    maxWidth: 620,
    builder: (ctx) {
      final h = MediaQuery.of(ctx).size.height;
      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: h * 0.88),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: h < 700 ? 200 : 280,
                child: Stack(fit: StackFit.expand, children: [
                  _spotImage(spot),
                  Positioned(top: 14, left: 14, child: _RegionPill(region: spot.region, short: false)),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: WmPressable(
                      onTap: () => Navigator.pop(ctx),
                      pressScale: 0.88,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          shape: BoxShape.circle,
                          boxShadow: Wm.shadow(),
                        ),
                        child: const Icon(Icons.close_rounded, size: 19, color: Wm.ink),
                      ),
                    ),
                  ),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WmBlurIn(
                      child: Text(spot.name,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.w700, color: Wm.ink, letterSpacing: -0.4)),
                    ),
                    const SizedBox(height: 6),
                    WmBlurIn(
                      delay: const Duration(milliseconds: 60),
                      child: Row(children: [
                        const Icon(Icons.star_rounded, size: 18, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 4),
                        Text('${spot.rating}',
                            style: const TextStyle(fontWeight: FontWeight.w700, color: Wm.ink)),
                        if (spot.reviews > 0)
                          Text('  ·  ${spot.reviews} reviews',
                              style: const TextStyle(color: Wm.muted, fontSize: 13)),
                      ]),
                    ),
                    const SizedBox(height: 14),
                    WmBlurIn(
                      delay: const Duration(milliseconds: 120),
                      child: Text(spot.description,
                          style: const TextStyle(color: Wm.inkSoft, fontSize: 14, height: 1.6)),
                    ),
                    const SizedBox(height: 18),
                    WmBlurIn(
                      delay: const Duration(milliseconds: 180),
                      child: Wrap(spacing: 10, runSpacing: 10, children: [
                        _InfoTile(icon: Icons.confirmation_number_outlined, label: 'Entrance', value: _fee(spot.entranceFee)),
                        if (spot.travelTime.isNotEmpty)
                          _InfoTile(icon: Icons.schedule_rounded, label: 'From Cebu City', value: spot.travelTime),
                        if (spot.averageDistanceKm > 0)
                          _InfoTile(
                              icon: Icons.route_outlined,
                              label: 'Distance',
                              value: '${spot.averageDistanceKm.toStringAsFixed(spot.averageDistanceKm % 1 == 0 ? 0 : 1)} km'),
                      ]),
                    ),
                    const SizedBox(height: 22),
                    Row(children: [
                      Expanded(
                        child: WmShimmerButton(
                          label: ctaLabel,
                          icon: Icons.calendar_month_rounded,
                          expand: true,
                          onTap: () {
                            Navigator.pop(ctx);
                            Navigator.pushNamed(context, BookingScreen.routeName);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      WmPressable(
                        onTap: () => Navigator.pop(ctx),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: Wm.surface,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: Wm.border),
                          ),
                          child: const Text('Close',
                              style: TextStyle(fontWeight: FontWeight.w600, color: Wm.ink, fontSize: 14)),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Wm.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Wm.border),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 18, color: Wm.accent),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text(label, style: const TextStyle(fontSize: 10.5, color: Wm.muted)),
          Text(value, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Wm.ink)),
        ]),
      ]),
    );
  }
}
