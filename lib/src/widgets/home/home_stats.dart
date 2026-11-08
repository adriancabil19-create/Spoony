import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/cebu_data.dart';
import '../wm_ui.dart';

/// White stats card designed to overlap the hero's bottom edge.
class HomeStatsCard extends StatelessWidget {
  const HomeStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = <_Stat>[
      _Stat(Icons.place_rounded, cebuDestinations.length.toDouble(), (v) => v.round().toString(), 'Destinations'),
      _Stat(Icons.groups_rounded, 1200, (v) => '${NumberFormatLite.thousands(v.round())}+', 'Happy travelers'),
      _Stat(Icons.star_rounded, 4.9, (v) => v.toStringAsFixed(1), 'Average rating', star: true),
      _Stat(Icons.support_agent_rounded, 24, (v) => '${v.round()}/7', 'Support'),
    ];

    return LayoutBuilder(builder: (context, c) {
      final mobile = c.maxWidth < 700;
      final deco = BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Wm.border),
        boxShadow: Wm.shadow(1.2),
      );
      if (mobile) {
        return Container(
          decoration: deco,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            IntrinsicHeight(
              child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Expanded(child: _StatTile(stat: stats[0], compact: true)),
                Container(width: 1, color: Wm.border),
                Expanded(child: _StatTile(stat: stats[1], compact: true)),
              ]),
            ),
            Container(height: 1, color: Wm.border),
            IntrinsicHeight(
              child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Expanded(child: _StatTile(stat: stats[2], compact: true)),
                Container(width: 1, color: Wm.border),
                Expanded(child: _StatTile(stat: stats[3], compact: true)),
              ]),
            ),
          ]),
        );
      }
      return Container(
        decoration: deco,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            for (var i = 0; i < stats.length; i++) ...[
              if (i > 0) Container(width: 1, margin: const EdgeInsets.symmetric(vertical: 14), color: Wm.border),
              Expanded(child: _StatTile(stat: stats[i])),
            ],
          ]),
        ),
      );
    });
  }
}

class NumberFormatLite {
  static String thousands(int v) {
    final s = v.toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return b.toString();
  }
}

class _Stat {
  final IconData icon;
  final double value;
  final String Function(double) format;
  final String label;
  final bool star;
  const _Stat(this.icon, this.value, this.format, this.label, {this.star = false});
}

class _StatTile extends StatelessWidget {
  final _Stat stat;
  final bool compact;
  const _StatTile({required this.stat, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 20, vertical: compact ? 14 : 16),
      child: Row(
        mainAxisAlignment: compact ? MainAxisAlignment.start : MainAxisAlignment.center,
        children: [
          Container(
            width: compact ? 36 : 44,
            height: compact ? 36 : 44,
            decoration: BoxDecoration(color: Wm.accent.withValues(alpha: 0.10), shape: BoxShape.circle),
            child: Icon(stat.icon, color: Wm.accent, size: compact ? 18 : 22),
          ),
          SizedBox(width: compact ? 10 : 14),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: stat.value),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, _) => Row(mainAxisSize: MainAxisSize.min, children: [
                    Flexible(
                      child: Text(
                        stat.format(v),
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: GoogleFonts.poppins(
                          fontSize: compact ? 22 : 28,
                          fontWeight: FontWeight.w700,
                          color: Wm.ink,
                          height: 1.1,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                    if (stat.star) ...[
                      const SizedBox(width: 3),
                      Icon(Icons.star_rounded, size: compact ? 18 : 22, color: const Color(0xFFF59E0B)),
                    ],
                  ]),
                ),
                const SizedBox(height: 2),
                Text(stat.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: compact ? 11.5 : 13, color: Wm.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
