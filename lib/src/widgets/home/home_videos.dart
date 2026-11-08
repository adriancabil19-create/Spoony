// Dark featured-videos band that plays openly licensed films in-app (homepage).
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/video_data.dart';
import '../media_dialogs.dart';
import '../wm_ui.dart';

String _dur(int sec) => '${sec ~/ 60}:${(sec % 60).toString().padLeft(2, '0')}';

class HomeVideosSection extends StatelessWidget {
  final double hPad;
  const HomeVideosSection({super.key, required this.hPad});

  @override
  Widget build(BuildContext context) {
    if (travelVideos.isEmpty) return const SizedBox.shrink();
    final mobile = MediaQuery.of(context).size.width < 900;
    final featured = travelVideos.first;

    final header = WmBlurIn(
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.end,
        runSpacing: 16,
        spacing: 24,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Wm.sun.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Wm.sun.withValues(alpha: 0.3)),
              ),
              child: const Text('VIDEOS',
                  style: TextStyle(color: Wm.sun, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.4)),
            ),
            const SizedBox(height: 12),
            Text('Watch Cebu come alive',
                style: GoogleFonts.poppins(
                    fontSize: mobile ? 26 : 34, fontWeight: FontWeight.w600, color: Colors.white, height: 1.15)),
            const SizedBox(height: 6),
            Text('Openly licensed films · plays right here',
                style: TextStyle(fontSize: mobile ? 13 : 15, color: Colors.white.withValues(alpha: 0.6))),
          ]),
          WmPressable(
            onTap: () => showVideos(context),
            pressScale: 0.94,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1.5),
              ),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.video_library_outlined, size: 16, color: Colors.white),
                SizedBox(width: 8),
                Text('All videos', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
        ],
      ),
    );

    final featuredTile = WmBlurIn(
      delay: const Duration(milliseconds: 100),
      child: _FeaturedTile(video: featured, onTap: () => playTravelVideo(context, 0)),
    );

    final list = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i < travelVideos.length; i++)
          WmBlurIn(
            delay: Duration(milliseconds: 140 + 60 * i),
            child: _VideoRow(video: travelVideos[i], onTap: () => playTravelVideo(context, i)),
          ),
      ],
    );

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        gradient: RadialGradient(
          center: Alignment(-0.7, -0.8),
          radius: 1.3,
          colors: [Color(0xFF2A2236), Color(0xFF0F172A)],
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: mobile ? 48 : 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          SizedBox(height: mobile ? 24 : 36),
          if (mobile) ...[
            featuredTile,
            const SizedBox(height: 18),
            list,
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: featuredTile),
                const SizedBox(width: 28),
                Expanded(flex: 2, child: list),
              ],
            ),
        ],
      ),
    );
  }
}

class _FeaturedTile extends StatefulWidget {
  final TravelVideo video;
  final VoidCallback onTap;
  const _FeaturedTile({required this.video, required this.onTap});

  @override
  State<_FeaturedTile> createState() => _FeaturedTileState();
}

class _FeaturedTileState extends State<_FeaturedTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final v = widget.video;
    final small = MediaQuery.of(context).size.width < 500;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(fit: StackFit.expand, children: [
              WmZoomFrame(
                hoverOverride: _hover,
                child: Image.network(v.posterUrl,
                    fit: BoxFit.cover, errorBuilder: (_, _, _) => Container(color: Colors.white10)),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.35, 1],
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                  ),
                ),
              ),
              Center(
                child: AnimatedContainer(
                  duration: Wm.fast,
                  width: _hover ? 84 : 74,
                  height: _hover ? 84 : 74,
                  decoration: BoxDecoration(
                    color: _hover ? Wm.sun : Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 24)],
                  ),
                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 44),
                ),
              ),
              Positioned(
                top: 14,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(999)),
                  child: Text(_dur(v.durationSec),
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ),
              Positioned(
                left: 18,
                right: 18,
                bottom: 16,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                  Text(v.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                          color: Colors.white, fontSize: small ? 16 : 22, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(v.place,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
                  const SizedBox(height: 4),
                  Text('© ${v.author} · ${v.license}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10.5)),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _VideoRow extends StatefulWidget {
  final TravelVideo video;
  final VoidCallback onTap;
  const _VideoRow({required this.video, required this.onTap});

  @override
  State<_VideoRow> createState() => _VideoRowState();
}

class _VideoRowState extends State<_VideoRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final v = widget.video;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: Wm.fast,
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: _hover ? 0.10 : 0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: _hover ? 0.18 : 0.06)),
          ),
          child: Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 120,
                height: 68,
                child: Stack(fit: StackFit.expand, children: [
                  Image.network(v.posterUrl,
                      fit: BoxFit.cover, errorBuilder: (_, _, _) => Container(color: Colors.white10)),
                  Container(color: Colors.black.withValues(alpha: 0.25)),
                  Icon(Icons.play_circle_fill_rounded, color: _hover ? Wm.sun : Colors.white, size: 28),
                ]),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(v.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('${v.place} · ${_dur(v.durationSec)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 12)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
