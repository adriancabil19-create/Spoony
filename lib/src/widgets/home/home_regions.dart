import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/cebu_data.dart';
import '../../models.dart';
import '../../screens/explore_screen.dart';
import '../safe_image.dart';
import '../wm_ui.dart';

/// "Explore by region" bento grid.
class HomeRegionsSection extends StatelessWidget {
  final double hPad;
  const HomeRegionsSection({super.key, required this.hPad});

  static const _order = [
    DestinationRegion.cebuCity,
    DestinationRegion.southCebu,
    DestinationRegion.northCebu,
    DestinationRegion.bohol,
  ];

  static const _taglines = {
    DestinationRegion.cebuCity: 'Heritage, temples & city lights',
    DestinationRegion.southCebu: 'Waterfalls, whale sharks & peaks',
    DestinationRegion.northCebu: 'White-sand islands & dive spots',
    DestinationRegion.bohol: 'Chocolate Hills & tarsiers',
  };

  _RegionInfo _info(DestinationRegion r) {
    final spots = cebuDestinations.where((d) => d.region == r).toList();
    final withImg = spots.where((d) => d.images.isNotEmpty).toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));
    return _RegionInfo(
      region: r,
      count: spots.length,
      image: withImg.isEmpty ? '' : withImg.first.images.first,
      tagline: _taglines[r] ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    final regions = [for (final r in _order) _info(r)];
    return LayoutBuilder(builder: (context, c) {
      final mobile = c.maxWidth < 700;
      final tiles = [
        for (var i = 0; i < regions.length; i++)
          WmBlurIn(
            delay: Duration(milliseconds: 90 * i),
            child: _RegionTile(info: regions[i], large: i == 0 && !mobile),
          ),
      ];

      Widget grid;
      if (mobile) {
        grid = Column(children: [
          for (final t in tiles) Padding(padding: const EdgeInsets.only(bottom: 12), child: SizedBox(height: 200, child: t)),
        ]);
      } else {
        const gap = 16.0;
        grid = SizedBox(
          height: 520,
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(flex: 5, child: tiles[0]),
            const SizedBox(width: gap),
            Expanded(
              flex: 7,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Expanded(child: tiles[1]),
                const SizedBox(height: gap),
                Expanded(
                  child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Expanded(child: tiles[2]),
                    const SizedBox(width: gap),
                    Expanded(child: tiles[3]),
                  ]),
                ),
              ]),
            ),
          ]),
        );
      }

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: mobile ? 48 : 72),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          WmBlurIn(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Wm.accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Wm.accent.withValues(alpha: 0.2)),
                ),
                child: const Text('REGIONS',
                    style: TextStyle(color: Wm.accent, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.4)),
              ),
              const SizedBox(height: 14),
              Text('Where do you want to go?',
                  style: GoogleFonts.poppins(
                    fontSize: mobile ? 26 : 34,
                    fontWeight: FontWeight.w700,
                    color: Wm.ink,
                    letterSpacing: -0.6,
                    height: 1.15,
                  )),
              const SizedBox(height: 8),
              const Text('From heritage streets to turquoise reefs — pick a corner of Cebu to start.',
                  style: TextStyle(fontSize: 15, color: Wm.muted, height: 1.5)),
            ]),
          ),
          SizedBox(height: mobile ? 22 : 32),
          grid,
        ]),
      );
    });
  }
}

class _RegionInfo {
  final DestinationRegion region;
  final int count;
  final String image;
  final String tagline;
  const _RegionInfo({required this.region, required this.count, required this.image, required this.tagline});
}

class _RegionTile extends StatefulWidget {
  final _RegionInfo info;
  final bool large;
  const _RegionTile({required this.info, this.large = false});

  @override
  State<_RegionTile> createState() => _RegionTileState();
}

class _RegionTileState extends State<_RegionTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final info = widget.info;
    final credit = info.image.isEmpty ? null : creditForUrl(info.image);
    final radius = BorderRadius.circular(Wm.rLarge - 8);
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: WmPressable(
        onTap: () => Navigator.pushNamed(context, ExploreScreen.routeName),
        pressScale: 0.98,
        child: AnimatedContainer(
          duration: Wm.fast,
          decoration: BoxDecoration(borderRadius: radius, boxShadow: Wm.shadow(_hover ? 1.2 : 0.4)),
          child: ClipRRect(
            borderRadius: radius,
            child: Stack(fit: StackFit.expand, children: [
              WmZoomFrame(
                hoverOverride: _hover,
                child: info.image.isEmpty
                    ? Container(color: Wm.chip)
                    : SafeImage(
                        info.image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(color: Wm.chip),
                      ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.35, 1],
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.72)],
                  ),
                ),
              ),
              if (credit != null)
                Positioned(
                  top: 12,
                  right: 12,
                  left: 12,
                  child: Align(alignment: Alignment.topRight, child: PhotoCreditChip(credit: credit, light: true)),
                ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 18,
                child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                      Text(regionTitle(info.region),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: widget.large ? 28 : 24,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            height: 1.1,
                          )),
                      const SizedBox(height: 4),
                      Text('${info.count} destinations · ${info.tagline}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
                    ]),
                  ),
                  const SizedBox(width: 12),
                  AnimatedContainer(
                    duration: Wm.medium,
                    curve: Wm.spring,
                    width: 42,
                    height: 42,
                    transform: Matrix4.translationValues(_hover ? 4 : 0, 0, 0),
                    decoration: BoxDecoration(
                      color: _hover ? Wm.accent : Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                      border: Border.all(color: _hover ? Wm.accent : Colors.white.withValues(alpha: 0.7)),
                    ),
                    child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                  ),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
