import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/cebu_data.dart';
import '../../models.dart';
import '../../screens/explore_screen.dart';
import '../wm_ui.dart';

/// Floating trip-search card shown at the bottom of the home hero.
class HeroSearchBar extends StatefulWidget {
  final bool compact;
  const HeroSearchBar({super.key, this.compact = false});

  @override
  State<HeroSearchBar> createState() => _HeroSearchBarState();
}

class _HeroSearchBarState extends State<HeroSearchBar> {
  DestinationRegion _region = DestinationRegion.all;
  DateTime? _date;
  int _guests = 2;

  String get _regionLabel => _region == DestinationRegion.all ? 'Anywhere in Cebu' : regionTitle(_region);

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _date ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(primary: Wm.accent, onPrimary: Colors.white),
        ),
        child: child!,
      ),
    );
    if (d != null && mounted) setState(() => _date = d);
  }

  void _search() => Navigator.pushNamed(context, ExploreScreen.routeName);

  Widget _label(String t) => Text(t.toUpperCase(),
      style: const TextStyle(fontSize: 11, color: Wm.muted, fontWeight: FontWeight.w600, letterSpacing: 1.2));

  Widget _value(String t, {bool placeholder = false}) => Text(t,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: placeholder ? Wm.muted : Wm.ink,
      ));

  Widget _field({required IconData icon, required String label, required Widget value, VoidCallback? onTap}) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(children: [
        Icon(icon, size: 20, color: Wm.accent),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [_label(label), const SizedBox(height: 3), value],
          ),
        ),
      ]),
    );
    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(borderRadius: BorderRadius.circular(18), onTap: onTap, child: content),
    );
  }

  Widget _whereField() {
    return PopupMenuButton<DestinationRegion>(
      tooltip: 'Choose a region',
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      onSelected: (r) => setState(() => _region = r),
      itemBuilder: (_) => [
        for (final r in DestinationRegion.values)
          PopupMenuItem(
            value: r,
            child: Row(children: [
              Icon(r == _region ? Icons.check_circle_rounded : Icons.place_outlined,
                  size: 18, color: r == _region ? Wm.accent : Wm.muted),
              const SizedBox(width: 10),
              Text(r == DestinationRegion.all ? 'Anywhere in Cebu' : regionTitle(r),
                  style: TextStyle(fontWeight: r == _region ? FontWeight.w700 : FontWeight.w500, color: Wm.ink)),
            ]),
          ),
      ],
      child: _field(
        icon: Icons.place_outlined,
        label: 'Where',
        value: Row(children: [
          Flexible(child: _value(_regionLabel)),
          const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Wm.muted),
        ]),
      ),
    );
  }

  Widget _whenField() => _field(
        icon: Icons.calendar_today_outlined,
        label: 'When',
        value: _date == null
            ? _value('Add dates', placeholder: true)
            : _value(DateFormat('EEE, MMM d').format(_date!)),
        onTap: _pickDate,
      );

  Widget _guestsField({bool dense = false}) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Row(children: [
          const Icon(Icons.people_alt_outlined, size: 20, color: Wm.accent),
          const SizedBox(width: 10),
          if (!dense) ...[Flexible(child: _label('Guests')), const SizedBox(width: 10)],
          if (dense) Expanded(child: _label('Guests')),
          WmStepper(value: _guests, min: 1, max: 20, onChanged: (v) => setState(() => _guests = v)),
        ]),
      );

  Widget _divider() => Container(width: 1, height: 40, color: Wm.border);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      // One-row layout needs ~960px (guests stepper + search button); stack below that.
      final mobile = widget.compact || c.maxWidth < 960;
      final card = BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Wm.border),
        boxShadow: Wm.shadow(1.2),
      );

      if (mobile) {
        return Container(
          constraints: const BoxConstraints(maxWidth: 980),
          padding: const EdgeInsets.all(8),
          decoration: card,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(children: [
              Expanded(child: _whereField()),
              Container(width: 1, height: 36, color: Wm.border),
              Expanded(child: _whenField()),
            ]),
            Container(height: 1, color: Wm.border, margin: const EdgeInsets.symmetric(horizontal: 8)),
            _guestsField(dense: true),
            const SizedBox(height: 6),
            WmShimmerButton(label: 'Search', icon: Icons.search_rounded, onTap: _search, expand: true),
          ]),
        );
      }

      return Container(
        constraints: const BoxConstraints(maxWidth: 980),
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        decoration: card,
        child: Row(children: [
          Expanded(flex: 5, child: _whereField()),
          _divider(),
          Expanded(flex: 4, child: _whenField()),
          _divider(),
          Expanded(flex: 5, child: _guestsField()),
          const SizedBox(width: 8),
          WmShimmerButton(
            label: 'Search',
            icon: Icons.search_rounded,
            onTap: _search,
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
          ),
        ]),
      );
    });
  }
}
