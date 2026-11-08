// Spoony component kit, adapted from the Watermelon UI design language
// (https://ui.watermelon.sh, MIT): very rounded pills/cards, hairline borders,
// layered soft shadows, spring motion, blur-in entrances, hover zoom & press scale.
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

class Wm {
  Wm._();

  // Colors
  static const accent = Color(0xFFD96A2B);
  static const sun = Color(0xFFF0955A);
  static const ink = Color(0xFF242426);
  static const inkSoft = Color(0xFF343437);
  static const muted = Color(0xFF71717A);
  static const surface = Color(0xFFF6F5FA);
  static const chip = Color(0xFFF0EFF6);
  static const border = Color(0xFFE6E6EF);
  static const activePill = Color(0xFF252528);

  // Radii
  static const rCard = 20.0;
  static const rLarge = 32.0;
  static const rModal = 24.0;

  // Motion (spring-like curves; Flutter has no layout springs, easeOutBack ≈ stiffness 380/damping 30)
  static const spring = Curves.easeOutBack;
  static const fast = Duration(milliseconds: 220);
  static const medium = Duration(milliseconds: 380);

  /// Watermelon's layered "soft" shadow: faint drop + inner highlight feel.
  static List<BoxShadow> shadow([double lift = 0]) => [
        BoxShadow(color: Colors.black.withValues(alpha: 0.03 + lift * 0.04), blurRadius: 12 + lift * 18, offset: Offset(0, 4 + lift * 8)),
        BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 2, offset: const Offset(0, 1)),
      ];

  static BoxDecoration card({bool hover = false, Color? tint}) => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rCard),
        border: Border.all(color: hover ? (tint ?? accent).withValues(alpha: 0.35) : border),
        boxShadow: shadow(hover ? 1 : 0),
      );
}

// ── Pressable: hover lift + press scale (0.92) ───────────────────────────────

class WmPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double hoverScale;
  final double pressScale;
  const WmPressable({super.key, required this.child, this.onTap, this.hoverScale = 1.0, this.pressScale = 0.96});

  @override
  State<WmPressable> createState() => _WmPressableState();
}

class _WmPressableState extends State<WmPressable> {
  bool _hover = false;
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final scale = _down ? widget.pressScale : (_hover ? widget.hoverScale : 1.0);
    return MouseRegion(
      cursor: widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = _down = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _down = true),
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        onTap: widget.onTap,
        child: AnimatedScale(scale: scale, duration: Wm.fast, curve: Wm.spring, child: widget.child),
      ),
    );
  }
}

// ── Blur-in entrance (blur 4→0, y 16→0, opacity 0→1) ─────────────────────────

class WmBlurIn extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  const WmBlurIn({super.key, required this.child, this.delay = Duration.zero, this.duration = const Duration(milliseconds: 450)});

  @override
  Widget build(BuildContext context) {
    final total = delay + duration;
    final start = total.inMilliseconds == 0 ? 0.0 : delay.inMilliseconds / total.inMilliseconds;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: total,
      builder: (_, raw, c) {
        final t = Curves.easeOut.transform(((raw - start) / (1 - start)).clamp(0.0, 1.0));
        final blur = 4 * (1 - t);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - t)),
            child: blur < 0.05 ? c : ImageFiltered(imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur), child: c),
          ),
        );
      },
      child: child,
    );
  }
}

// ── Shimmer button (pill; white sheen sweeps across on hover, shadow grows) ───

class WmShimmerButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color color;
  final Color foreground;
  final EdgeInsets padding;
  final double fontSize;
  final bool expand;
  const WmShimmerButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.color = Wm.accent,
    this.foreground = Colors.white,
    this.padding = const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
    this.fontSize = 14,
    this.expand = false,
  });

  @override
  State<WmShimmerButton> createState() => _WmShimmerButtonState();
}

class _WmShimmerButtonState extends State<WmShimmerButton> with SingleTickerProviderStateMixin {
  late final AnimationController _sheen = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
  bool _hover = false;

  @override
  void dispose() {
    _sheen.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final content = Row(
      mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, size: widget.fontSize + 2, color: widget.foreground),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(widget.label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: widget.foreground, fontWeight: FontWeight.w700, fontSize: widget.fontSize, letterSpacing: 0.3)),
        ),
      ],
    );
    return MouseRegion(
      onEnter: (_) {
        setState(() => _hover = true);
        if (enabled) _sheen.forward(from: 0);
      },
      onExit: (_) => setState(() => _hover = false),
      child: WmPressable(
        onTap: widget.onTap,
        pressScale: 0.94,
        child: AnimatedContainer(
          duration: Wm.fast,
          decoration: BoxDecoration(
            color: enabled ? widget.color : widget.color.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(999),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: widget.color.withValues(alpha: _hover ? 0.45 : 0.22),
                      blurRadius: _hover ? 22 : 10,
                      offset: Offset(0, _hover ? 8 : 4),
                    ),
                  ]
                : const [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Stack(children: [
              Padding(padding: widget.padding, child: content),
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _sheen,
                    builder: (_, _) => _sheen.value == 0 || _sheen.value == 1
                        ? const SizedBox.shrink()
                        : FractionalTranslation(
                            translation: Offset(-1 + 2 * Curves.easeInOut.transform(_sheen.value), 0),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [
                                  Colors.white.withValues(alpha: 0),
                                  Colors.white.withValues(alpha: 0.28),
                                  Colors.white.withValues(alpha: 0),
                                ]),
                              ),
                            ),
                          ),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ── Continuous tabs: a dark pill slides (spring) under the active item ───────

class WmContinuousTabs extends StatefulWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;
  final bool dark;
  const WmContinuousTabs({
    super.key,
    required this.labels,
    required this.selected,
    required this.onChanged,
    this.dark = false,
  });

  @override
  State<WmContinuousTabs> createState() => _WmContinuousTabsState();
}

class _WmContinuousTabsState extends State<WmContinuousTabs> {
  late List<GlobalKey> _keys = _makeKeys();
  final _trackKey = GlobalKey();
  Rect? _pill;

  List<GlobalKey> _makeKeys() => List.generate(widget.labels.length, (_) => GlobalKey());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  @override
  void didUpdateWidget(WmContinuousTabs old) {
    super.didUpdateWidget(old);
    if (old.labels.length != widget.labels.length) _keys = _makeKeys();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  void _measure() {
    if (!mounted || widget.selected < 0 || widget.selected >= _keys.length) return;
    final track = _trackKey.currentContext?.findRenderObject() as RenderBox?;
    final item = _keys[widget.selected].currentContext?.findRenderObject() as RenderBox?;
    if (track == null || item == null || !track.hasSize || !item.hasSize) return;
    final off = item.localToGlobal(Offset.zero, ancestor: track);
    final r = off & item.size;
    if (r != _pill) setState(() => _pill = r);
  }

  @override
  Widget build(BuildContext context) {
    final trackColor = widget.dark ? Colors.white.withValues(alpha: 0.1) : Wm.chip;
    final pillColor = widget.dark ? Colors.white : Wm.activePill;
    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (_) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
        return false;
      },
      child: SizeChangedLayoutNotifier(
        child: Container(
          key: _trackKey,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: trackColor,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: widget.dark ? Colors.white24 : Wm.border),
          ),
          child: Stack(children: [
            if (_pill != null)
              AnimatedPositioned(
                duration: Wm.medium,
                curve: Wm.spring,
                left: _pill!.left - 4,
                top: _pill!.top - 4,
                width: _pill!.width,
                height: _pill!.height,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: pillColor,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: Wm.shadow(0.4),
                  ),
                ),
              ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(widget.labels.length, (i) {
                final active = i == widget.selected;
                final fg = active
                    ? (widget.dark ? Wm.ink : Colors.white)
                    : (widget.dark ? Colors.white70 : Wm.inkSoft);
                return GestureDetector(
                  key: _keys[i],
                  onTap: () => widget.onChanged(i),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                      child: AnimatedDefaultTextStyle(
                        duration: Wm.fast,
                        style: TextStyle(color: fg, fontSize: 13.5, fontWeight: FontWeight.w600),
                        child: Text(widget.labels[i]),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ]),
        ),
      ),
    );
  }
}

// ── Stepper: outlined pill, round ± buttons, rolling digits ──────────────────

class WmStepper extends StatefulWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final String? suffix;
  const WmStepper({super.key, required this.value, required this.onChanged, this.min = 0, this.max = 99, this.suffix});

  @override
  State<WmStepper> createState() => _WmStepperState();
}

class _WmStepperState extends State<WmStepper> {
  int _dir = 1;

  void _set(int v) {
    if (v < widget.min || v > widget.max) return;
    setState(() => _dir = v > widget.value ? 1 : -1);
    widget.onChanged(v);
  }

  Widget _btn(IconData icon, bool enabled, VoidCallback onTap) => WmPressable(
        onTap: enabled ? onTap : null,
        pressScale: 0.88,
        child: AnimatedContainer(
          duration: Wm.fast,
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: enabled ? Colors.white : Wm.chip,
            shape: BoxShape.circle,
            border: Border.all(color: Wm.border),
            boxShadow: enabled ? Wm.shadow() : const [],
          ),
          child: Icon(icon, size: 18, color: enabled ? Wm.ink : Wm.muted.withValues(alpha: 0.5)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Wm.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Wm.border),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _btn(Icons.remove_rounded, widget.value > widget.min, () => _set(widget.value - 1)),
        SizedBox(
          width: widget.suffix == null ? 44 : 84,
          child: ClipRect(
            child: AnimatedSwitcher(
              duration: Wm.medium,
              switchInCurve: Wm.spring,
              transitionBuilder: (child, anim) {
                final incoming = child.key == ValueKey(widget.value);
                final dy = (incoming ? 0.8 : -0.8) * _dir;
                return FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween(begin: Offset(0, dy), end: Offset.zero).animate(anim),
                    child: ScaleTransition(scale: Tween(begin: 0.7, end: 1.0).animate(anim), child: child),
                  ),
                );
              },
              child: Text(
                widget.suffix == null ? '${widget.value}' : '${widget.value} ${widget.suffix}',
                key: ValueKey(widget.value),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Wm.ink,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
        ),
        _btn(Icons.add_rounded, widget.value < widget.max, () => _set(widget.value + 1)),
      ]),
    );
  }
}

// ── Save toggle: heart that pops when saved ──────────────────────────────────

class WmSaveToggle extends StatelessWidget {
  final bool saved;
  final ValueChanged<bool> onChanged;
  const WmSaveToggle({super.key, required this.saved, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: saved ? 'Saved' : 'Save',
      child: WmPressable(
        onTap: () => onChanged(!saved),
        pressScale: 0.85,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            shape: BoxShape.circle,
            boxShadow: Wm.shadow(),
          ),
          child: AnimatedSwitcher(
            duration: Wm.medium,
            switchInCurve: Wm.spring,
            transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
            child: Icon(
              saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              key: ValueKey(saved),
              size: 19,
              color: saved ? const Color(0xFFE11D48) : Wm.ink,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Hover-zoom image frame (image scales to 1.05 over 500ms on hover) ────────

class WmZoomFrame extends StatefulWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final bool? hoverOverride;
  const WmZoomFrame({super.key, required this.child, this.borderRadius = BorderRadius.zero, this.hoverOverride});

  @override
  State<WmZoomFrame> createState() => _WmZoomFrameState();
}

class _WmZoomFrameState extends State<WmZoomFrame> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final h = widget.hoverOverride ?? _hover;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: ClipRRect(
        borderRadius: widget.borderRadius,
        child: AnimatedScale(
          scale: h ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}

// ── Expanding modal (backdrop blur + spring scale-in), for spot details ──────

Future<T?> showWmModal<T>(BuildContext context, {required Widget Function(BuildContext) builder, double maxWidth = 640}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: Colors.transparent,
    transitionDuration: Wm.medium,
    transitionBuilder: (_, anim, _, child) {
      final t = anim.value;
      return Stack(children: [
        Positioned.fill(
          child: IgnorePointer(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8 * t, sigmaY: 8 * t),
              child: Container(color: Colors.black.withValues(alpha: 0.55 * t)),
            ),
          ),
        ),
        FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
          child: ScaleTransition(
            scale: Tween(begin: 0.92, end: 1.0).animate(CurvedAnimation(parent: anim, curve: Wm.spring)),
            child: child,
          ),
        ),
      ]);
    },
    pageBuilder: (ctx, _, _) => SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Wm.rModal),
              clipBehavior: Clip.antiAlias,
              child: builder(ctx),
            ),
          ),
        ),
      ),
    ),
  );
}
