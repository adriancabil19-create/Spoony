import 'package:flutter/material.dart';

import '../data/media_data.dart';
import '../data/privacy_images.dart';

/// Resolves a destination image URL to the privacy-safe version when one exists
/// (faces / plate numbers blurred and bundled under assets/images/privacy/).
String safeImageSource(String src) => privacyImages[src] ?? src;

ImageProvider safeImageProvider(String src) {
  final s = safeImageSource(src);
  return s.startsWith('assets/') ? AssetImage(s) as ImageProvider : NetworkImage(s);
}

String? _fileKey(String url) {
  if (url.isEmpty) return null;
  var u = Uri.decodeFull(url.split('?').first);
  final file = u.indexOf('File:');
  if (file >= 0) return u.substring(file + 5).replaceAll(' ', '_').toLowerCase();
  final parts = u.split('/');
  final thumb = parts.indexOf('thumb');
  // .../thumb/a/ab/<File.jpg>/960px-<File.jpg>
  final name = thumb >= 0 && parts.length > thumb + 3 ? parts[thumb + 3] : parts.last;
  return name.replaceAll(' ', '_').toLowerCase();
}

final Map<String, PhotoCredit> _creditsByFile = {
  for (final c in photoCredits)
    if (_fileKey(c.sourceUrl) != null) _fileKey(c.sourceUrl)!: c,
};

/// Photo credit for a Wikimedia Commons image URL (thumb or original), if known.
PhotoCredit? creditForUrl(String url) {
  final k = _fileKey(url);
  return k == null ? null : _creditsByFile[k];
}

/// Drop-in replacement for Image.network for destination photos:
/// serves the blurred asset when available and can overlay a tiny photo credit.
class SafeImage extends StatelessWidget {
  final String src;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final ImageErrorWidgetBuilder? errorBuilder;
  final bool showCredit;
  const SafeImage(
    this.src, {
    super.key,
    this.width,
    this.height,
    this.fit,
    this.errorBuilder,
    this.showCredit = false,
  });

  @override
  Widget build(BuildContext context) {
    final resolved = safeImageSource(src);
    final Widget img = resolved.startsWith('assets/')
        ? Image.asset(resolved, width: width, height: height, fit: fit, errorBuilder: errorBuilder)
        : Image.network(resolved, width: width, height: height, fit: fit, errorBuilder: errorBuilder);
    if (!showCredit) return img;
    final c = creditForUrl(src);
    if (c == null) return img;
    return SizedBox(
      width: width,
      height: height,
      child: Stack(fit: StackFit.expand, children: [
        img,
        Positioned(right: 6, bottom: 6, child: PhotoCreditChip(credit: c)),
      ]),
    );
  }
}

/// Small translucent "© author · license" label used on photos.
class PhotoCreditChip extends StatelessWidget {
  final PhotoCredit credit;
  final bool light;
  const PhotoCreditChip({super.key, required this.credit, this.light = false});

  @override
  Widget build(BuildContext context) {
    final blurred = credit.modified ? ' · edited' : '';
    return Tooltip(
      message: 'Photo: ${credit.author}\n${credit.license}$blurred\nWikimedia Commons',
      child: Container(
        constraints: const BoxConstraints(maxWidth: 220),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: light ? 0.25 : 0.45),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '© ${credit.author} · ${credit.license}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white, fontSize: 9.5, letterSpacing: 0.2),
        ),
      ),
    );
  }
}
