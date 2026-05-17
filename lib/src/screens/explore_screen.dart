import 'package:flutter/material.dart';
import '../models.dart';
import '../data/cebu_data.dart';
import 'home_screen.dart';
import 'booking_screen.dart';

const _kOcean = Color(0xFF0EA5E9);
const _kTeal  = Color(0xFF14B8A6);
const _kGold  = Color(0xFFF59E0B);
const _kDark  = Color(0xFF0F172A);
const _kMid   = Color(0xFF64748B);
const _kBg    = Color(0xFFF8FAFC);

class ExploreScreen extends StatefulWidget {
  static const routeName = '/explore';
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  DestinationRegion _selectedRegion = DestinationRegion.all;
  String _searchQuery = '';

  static const _regions = [
    DestinationRegion.all,
    DestinationRegion.cebuCity,
    DestinationRegion.southCebu,
    DestinationRegion.northCebu,
    DestinationRegion.bohol,
  ];

  List<Destination> get _filtered => cebuDestinations.where((spot) {
        final matchesRegion =
            _selectedRegion == DestinationRegion.all || spot.region == _selectedRegion;
        final matchesSearch = _searchQuery.isEmpty ||
            spot.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            spot.description.toLowerCase().contains(_searchQuery.toLowerCase());
        return matchesRegion && matchesSearch;
      }).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SpoonyNavBar(current: 'explore'),
            LayoutBuilder(builder: (context, constraints) {
              final wide = constraints.maxWidth >= 700;
              final hPad = wide ? 80.0 : 20.0;
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Explore Destinations',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: _kDark)),
                    const SizedBox(height: 8),
                    const SizedBox(
                      width: 520,
                      child: Text(
                        'From pristine beaches to mountain peaks, discover the wonders of Cebu and its neighboring islands.',
                        style: TextStyle(color: _kMid, fontSize: 14, height: 1.6),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Search
                    TextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: 'Search destinations…',
                        hintStyle: const TextStyle(color: _kMid),
                        prefixIcon: const Icon(Icons.search, color: _kOcean),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: _kOcean, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Region filter chips
                    SizedBox(
                      height: 44,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _regions.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 10),
                        itemBuilder: (context, i) {
                          final region = _regions[i];
                          final selected = region == _selectedRegion;
                          final label = region == DestinationRegion.all ? 'All' : regionTitle(region);
                          return FilterChip(
                            label: Text(label),
                            selected: selected,
                            onSelected: (_) => setState(() => _selectedRegion = region),
                            selectedColor: _kOcean,
                            backgroundColor: Colors.white,
                            side: BorderSide(
                              color: selected ? _kOcean : const Color(0xFFE2E8F0),
                              width: 1.5,
                            ),
                            labelStyle: TextStyle(
                              color: selected ? Colors.white : _kMid,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            showCheckmark: false,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                    _filtered.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(48),
                              child: Text('No destinations found.',
                                  style: TextStyle(color: _kMid, fontSize: 16)),
                            ),
                          )
                        : LayoutBuilder(builder: (context, inner) {
                            final cols = inner.maxWidth < 500 ? 1
                                : inner.maxWidth < 900 ? 2 : 4;
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: cols,
                                mainAxisSpacing: 20,
                                crossAxisSpacing: 20,
                                mainAxisExtent: cols == 1 ? 350 : 310,
                              ),
                              itemCount: _filtered.length,
                              itemBuilder: (context, i) => _DestinationGridCard(spot: _filtered[i]),
                            );
                          }),
                  ],
                ),
              );
            }),
            const SizedBox(height: 48),
            const SpoonyFooter(),
          ],
        ),
      ),
    );
  }
}

class _DestinationGridCard extends StatefulWidget {
  final Destination spot;
  const _DestinationGridCard({required this.spot});

  @override
  State<_DestinationGridCard> createState() => _DestinationGridCardState();
}

class _DestinationGridCardState extends State<_DestinationGridCard> {
  bool _hovered = false;

  Color _regionColor(DestinationRegion r) {
    switch (r) {
      case DestinationRegion.cebuCity:  return _kOcean;
      case DestinationRegion.southCebu: return _kTeal;
      case DestinationRegion.northCebu: return const Color(0xFF8B5CF6);
      case DestinationRegion.bohol:     return _kGold;
      default:                          return _kMid;
    }
  }

  @override
  Widget build(BuildContext context) {
    final spot = widget.spot;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, BookingScreen.routeName),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(0, _hovered ? -6 : 0, 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _hovered ? 0.12 : 0.06),
                blurRadius: _hovered ? 24 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  children: [
                    Image.network(
                      spot.images.first,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        height: 160,
                        color: const Color(0xFFE0F7FA),
                        child: const Icon(Icons.image, color: _kOcean, size: 40),
                      ),
                    ),
                    Positioned(
                      top: 8, right: 8,
                      child: Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.favorite_border, color: Colors.white, size: 16),
                      ),
                    ),
                    Positioned(
                      top: 8, left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _regionColor(spot.region),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          regionTitle(spot.region).split(' ').first,
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(spot.name,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _kDark),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.location_on, size: 12, color: _kMid),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(regionTitle(spot.region),
                          style: const TextStyle(fontSize: 11, color: _kMid),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        const Icon(Icons.star, size: 13, color: _kGold),
                        const SizedBox(width: 3),
                        Text('${spot.rating}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _kDark)),
                      ]),
                      Text('₱${spot.entranceFee.toInt()}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _kTeal)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.pushNamed(context, BookingScreen.routeName),
                      style: FilledButton.styleFrom(
                        backgroundColor: _kOcean,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Add to Itinerary', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
