import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../data/cebu_data.dart';
import '../data/media_data.dart';
import '../data/video_data.dart';
import '../models.dart';
import 'safe_image.dart';

/// Spoony's Facebook page. Replace with the official page URL when available.
const kFacebookPageUrl = 'https://www.facebook.com/search/top?q=Spoony%20Travel%20and%20Tours';

const _kDark = Color(0xFF0F172A);
const _kSun = Color(0xFFF0955A);

Future<void> openExternal(BuildContext context, String url) async {
  final ok = await launchUrl(
    Uri.parse(url),
    mode: LaunchMode.externalApplication,
    webOnlyWindowName: '_blank',
  );
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not open $url')),
    );
  }
}

PhotoCredit? _creditFor(String name) {
  for (final c in photoCredits) {
    if (c.subject == name) return c;
  }
  return null;
}

// ── Shared dark full-screen shell ────────────────────────────────────────────

Future<void> _showDarkSheet(
  BuildContext context, {
  required String title,
  required String subtitle,
  required Widget child,
}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: title,
    barrierColor: Colors.black.withValues(alpha: 0.75),
    transitionDuration: const Duration(milliseconds: 260),
    transitionBuilder: (_, anim, _, w) => FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.03), end: Offset.zero)
            .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
        child: w,
      ),
    ),
    pageBuilder: (ctx, _, _) {
      final mobile = MediaQuery.of(ctx).size.width < 700;
      return SafeArea(
        child: Center(
          child: Container(
            margin: EdgeInsets.all(mobile ? 0 : 32),
            constraints: const BoxConstraints(maxWidth: 1200),
            decoration: BoxDecoration(
              color: _kDark,
              borderRadius: BorderRadius.circular(mobile ? 0 : 20),
            ),
            clipBehavior: Clip.antiAlias,
            child: Material(
              color: Colors.transparent,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(mobile ? 20 : 32, 24, 12, 16),
                    child: Row(children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(title,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(subtitle,
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13)),
                        ]),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ]),
                  ),
                  Container(height: 1, color: Colors.white.withValues(alpha: 0.08)),
                  Expanded(child: child),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

// ── Pictures: gallery grid + lightbox ────────────────────────────────────────

void showPhotoGallery(BuildContext context) {
  final spots = cebuDestinations.where((d) => d.images.isNotEmpty).toList();
  _showDarkSheet(
    context,
    title: 'Photo Gallery',
    subtitle: '${spots.length} destinations across Cebu · tap a photo to view it full-size',
    child: LayoutBuilder(builder: (ctx, c) {
      final cols = c.maxWidth > 1000 ? 4 : c.maxWidth > 650 ? 3 : 2;
      return GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 4 / 3,
        ),
        itemCount: spots.length,
        itemBuilder: (_, i) => _GalleryTile(
          spot: spots[i],
          onTap: () => _showLightbox(ctx, spots, i),
        ),
      );
    }),
  );
}

class _GalleryTile extends StatefulWidget {
  final Destination spot;
  final VoidCallback onTap;
  const _GalleryTile({required this.spot, required this.onTap});

  @override
  State<_GalleryTile> createState() => _GalleryTileState();
}

class _GalleryTileState extends State<_GalleryTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(fit: StackFit.expand, children: [
            AnimatedScale(
              scale: _hover ? 1.06 : 1.0,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOut,
              child: SafeImage(
                widget.spot.images.first,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(color: Colors.white10),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.5, 1],
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.75)],
                ),
              ),
            ),
            if (creditForUrl(widget.spot.images.first) case final c?)
              Positioned(top: 8, right: 8, left: 8,
                  child: Align(alignment: Alignment.topRight, child: PhotoCreditChip(credit: c, light: true))),
            Positioned(
              left: 12, right: 12, bottom: 10,
              child: Text(widget.spot.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          ]),
        ),
      ),
    );
  }
}

void _showLightbox(BuildContext context, List<Destination> spots, int start) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.92),
    builder: (_) => _Lightbox(spots: spots, start: start),
  );
}

class _Lightbox extends StatefulWidget {
  final List<Destination> spots;
  final int start;
  const _Lightbox({required this.spots, required this.start});

  @override
  State<_Lightbox> createState() => _LightboxState();
}

class _LightboxState extends State<_Lightbox> {
  late final PageController _ctrl = PageController(initialPage: widget.start);
  late int _i = widget.start;

  void _go(int d) {
    final n = (_i + d).clamp(0, widget.spots.length - 1);
    _ctrl.animateToPage(n, duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spot = widget.spots[_i];
    final credit = creditForUrl(spot.images.first) ?? _creditFor(spot.name);
    return Material(
      color: Colors.transparent,
      child: Stack(children: [
        PageView.builder(
          controller: _ctrl,
          itemCount: widget.spots.length,
          onPageChanged: (i) => setState(() => _i = i),
          itemBuilder: (_, i) => InteractiveViewer(
            maxScale: 4,
            child: Center(
              child: safeImageSource(widget.spots[i].images.first).startsWith('assets/')
                  ? Image.asset(safeImageSource(widget.spots[i].images.first), fit: BoxFit.contain)
                  : Image.network(
                      // Lightbox shows the larger rendition when available.
                      widget.spots[i].images.first.replaceFirst('/960px-', '/1920px-'),
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => Image.network(widget.spots[i].images.first, fit: BoxFit.contain),
                    ),
            ),
          ),
        ),
        Positioned(
          top: 16, right: 16,
          child: IconButton(
            tooltip: 'Close',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
          ),
        ),
        if (_i > 0)
          Positioned(left: 12, top: 0, bottom: 0, child: Center(child: _circleBtn(Icons.chevron_left, () => _go(-1)))),
        if (_i < widget.spots.length - 1)
          Positioned(right: 12, top: 0, bottom: 0, child: Center(child: _circleBtn(Icons.chevron_right, () => _go(1)))),
        Positioned(
          left: 24, right: 24, bottom: 24,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(spot.name,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(
              '${_i + 1} / ${widget.spots.length}'
              '${credit != null ? '  ·  Photo: ${credit.author} (${credit.license})${credit.modified ? ', faces/plates blurred' : ''}' : ''}',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 12),
            ),
          ]),
        ),
      ]),
    );
  }
}

Widget _circleBtn(IconData icon, VoidCallback onTap) => Material(
      color: Colors.white.withValues(alpha: 0.12),
      shape: const CircleBorder(side: BorderSide(color: Colors.white54)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(10), child: Icon(icon, color: Colors.white, size: 26)),
      ),
    );

// ── Videos: openly licensed travel films, played in-app ─────────────────────

String _fmt(Duration d) {
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return d.inHours > 0 ? '${d.inHours}:$m:$s' : '$m:$s';
}

void showVideos(BuildContext context) {
  if (travelVideos.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Travel videos are coming soon.')),
    );
    return;
  }
  _showDarkSheet(
    context,
    title: 'Travel Videos',
    subtitle: '${travelVideos.length} films of Cebu · tap to play here',
    child: LayoutBuilder(builder: (ctx, c) {
      final cols = c.maxWidth > 1000 ? 3 : c.maxWidth > 650 ? 2 : 1;
      return GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 16 / 9,
        ),
        itemCount: travelVideos.length,
        itemBuilder: (_, i) => _VideoTile(
          video: travelVideos[i],
          onTap: () => _showPlayer(ctx, i),
        ),
      );
    }),
  );
}

class _VideoTile extends StatefulWidget {
  final TravelVideo video;
  final VoidCallback onTap;
  const _VideoTile({required this.video, required this.onTap});

  @override
  State<_VideoTile> createState() => _VideoTileState();
}

class _VideoTileState extends State<_VideoTile> {
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(fit: StackFit.expand, children: [
            AnimatedScale(
              scale: _hover ? 1.05 : 1.0,
              duration: const Duration(milliseconds: 350),
              child: Image.network(v.posterUrl, fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(color: Colors.white10)),
            ),
            Container(color: Colors.black.withValues(alpha: _hover ? 0.2 : 0.38)),
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: _hover ? 64 : 56,
                height: _hover ? 64 : 56,
                decoration: BoxDecoration(
                  color: _hover ? _kSun : Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 34),
              ),
            ),
            Positioned(
              top: 10, right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)),
                child: Text(_fmt(Duration(seconds: v.durationSec)),
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ),
            Positioned(
              left: 14, right: 14, bottom: 12,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Text(v.title,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                Text('${v.place}  ·  © ${v.author} · ${v.license}',
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 11)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

/// Opens the in-app player at [index] of [travelVideos].
void playTravelVideo(BuildContext context, int index) => _showPlayer(context, index);

void _showPlayer(BuildContext context, int index) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.92),
    builder: (_) => _VideoPlayerDialog(start: index),
  );
}

class _VideoPlayerDialog extends StatefulWidget {
  final int start;
  const _VideoPlayerDialog({required this.start});

  @override
  State<_VideoPlayerDialog> createState() => _VideoPlayerDialogState();
}

class _VideoPlayerDialogState extends State<_VideoPlayerDialog> {
  late int _i = widget.start;
  VideoPlayerController? _ctrl;
  bool _error = false;
  bool _muted = false;
  bool _showControls = true;

  TravelVideo get _video => travelVideos[_i];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final old = _ctrl;
    setState(() {
      _ctrl = null;
      _error = false;
    });
    await old?.dispose();
    // VP9 WebM first; H.264 fallback for Apple platforms or when WebM fails.
    final apple = defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS;
    var c = VideoPlayerController.networkUrl(Uri.parse(apple ? _video.altVideoUrl : _video.videoUrl));
    _ctrl = c;
    try {
      try {
        await c.initialize();
      } catch (_) {
        if (!mounted || _ctrl != c) return;
        await c.dispose();
        c = VideoPlayerController.networkUrl(Uri.parse(apple ? _video.videoUrl : _video.altVideoUrl));
        _ctrl = c;
        await c.initialize();
      }
      if (!mounted || _ctrl != c) return;
      await c.setLooping(false);
      await c.setVolume(_muted ? 0 : 1);
      c.addListener(_tick);
      setState(() {});
      try {
        await c.play();
      } catch (_) {
        // Browser blocked autoplay with sound: start muted instead.
        await c.setVolume(0);
        if (mounted) setState(() => _muted = true);
        await c.play();
      }
    } catch (_) {
      if (mounted && _ctrl == c) setState(() => _error = true);
    }
  }

  void _tick() {
    if (mounted) setState(() {});
  }

  void _go(int d) {
    final n = _i + d;
    if (n < 0 || n >= travelVideos.length) return;
    _i = n;
    _load();
  }

  @override
  void dispose() {
    _ctrl?.removeListener(_tick);
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _ctrl;
    final ready = c != null && c.value.isInitialized;
    final v = _video;
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Stack(children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 64, 16, 120),
              child: _error
                  ? Column(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.error_outline, color: Colors.white54, size: 48),
                      const SizedBox(height: 12),
                      const Text('This video could not be played in your browser.',
                          style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: _load,
                        style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white, side: const BorderSide(color: Colors.white54)),
                        child: const Text('Try again'),
                      ),
                    ])
                  : !ready
                      ? const CircularProgressIndicator(color: _kSun)
                      : MouseRegion(
                          onHover: (_) {
                            if (!_showControls) setState(() => _showControls = true);
                          },
                          child: GestureDetector(
                            onTap: () => c.value.isPlaying ? c.pause() : c.play(),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: AspectRatio(
                                aspectRatio: c.value.aspectRatio,
                                child: Stack(fit: StackFit.expand, children: [
                                  VideoPlayer(c),
                                  if (!c.value.isPlaying)
                                    Container(
                                      color: Colors.black26,
                                      child: const Center(
                                        child: Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 72),
                                      ),
                                    ),
                                ]),
                              ),
                            ),
                          ),
                        ),
            ),
          ),
          // Top bar
          Positioned(
            top: 12, left: 20, right: 12,
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(v.title,
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                  Text('${v.place}  ·  ${_i + 1} / ${travelVideos.length}',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
                ]),
              ),
              IconButton(
                tooltip: 'Close',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
              ),
            ]),
          ),
          if (_i > 0)
            Positioned(left: 12, top: 0, bottom: 0, child: Center(child: _circleBtn(Icons.chevron_left, () => _go(-1)))),
          if (_i < travelVideos.length - 1)
            Positioned(right: 12, top: 0, bottom: 0, child: Center(child: _circleBtn(Icons.chevron_right, () => _go(1)))),
          // Bottom controls + credit
          Positioned(
            left: 20, right: 20, bottom: 16,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  if (ready) ...[
                    VideoProgressIndicator(
                      c,
                      allowScrubbing: true,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      colors: VideoProgressColors(
                        playedColor: _kSun,
                        bufferedColor: Colors.white.withValues(alpha: 0.3),
                        backgroundColor: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    Row(children: [
                      IconButton(
                        tooltip: c.value.isPlaying ? 'Pause' : 'Play',
                        onPressed: () => c.value.isPlaying ? c.pause() : c.play(),
                        icon: Icon(c.value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: Colors.white),
                      ),
                      IconButton(
                        tooltip: 'Replay',
                        onPressed: () {
                          c.seekTo(Duration.zero);
                          c.play();
                        },
                        icon: const Icon(Icons.replay_rounded, color: Colors.white),
                      ),
                      IconButton(
                        tooltip: _muted ? 'Unmute' : 'Mute',
                        onPressed: () {
                          setState(() => _muted = !_muted);
                          c.setVolume(_muted ? 0 : 1);
                        },
                        icon: Icon(_muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                            color: Colors.white),
                      ),
                      const SizedBox(width: 6),
                      Text('${_fmt(c.value.position)} / ${_fmt(c.value.duration)}',
                          style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      const Spacer(),
                    ]),
                  ],
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () => openExternal(context, v.sourceUrl),
                    child: Text(
                      'Video: ${v.author} · ${v.license} · Wikimedia Commons',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 11),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Photo credits (required attribution for CC BY / CC BY-SA images) ─────────

void showPhotoCredits(BuildContext context) {
  _showDarkSheet(
    context,
    title: 'Photo Credits',
    subtitle: 'Photos from Wikimedia Commons, used under their open licenses. Tap an entry to view the source.',
    child: ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: photoCredits.length + 1,
      separatorBuilder: (_, _) => Divider(height: 1, color: Colors.white.withValues(alpha: 0.06)),
      itemBuilder: (ctx, i) {
        if (i == 0) {
          return const ListTile(
            leading: Icon(Icons.landscape_outlined, color: _kSun),
            title: Text('Osmeña Peak (home banner)', style: TextStyle(color: Colors.white, fontSize: 14)),
            subtitle: Text('Provided by Spoony Travel and Tours', style: TextStyle(color: Colors.white54, fontSize: 12)),
          );
        }
        final c = photoCredits[i - 1];
        return ListTile(
          dense: true,
          leading: const Icon(Icons.photo_outlined, color: _kSun),
          title: Text(c.subject, style: const TextStyle(color: Colors.white, fontSize: 14)),
          subtitle: Text('Photo: ${c.author}  ·  ${c.license.isEmpty ? 'See source' : c.license}'
              '${c.modified ? '  ·  edited by Spoony (faces/plates blurred)' : ''}',
              style: const TextStyle(color: Colors.white60, fontSize: 12)),
          trailing: const Icon(Icons.open_in_new, color: Colors.white38, size: 16),
          onTap: c.sourceUrl.isEmpty ? null : () => openExternal(ctx, c.sourceUrl),
        );
      },
    ),
  );
}
