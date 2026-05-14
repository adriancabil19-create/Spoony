import 'package:flutter/material.dart';
import '../models.dart';
import '../data/cebu_data.dart';
import 'home_screen.dart';
import 'booking_screen.dart';
import 'dashboard_screen.dart';

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
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _NavBar(current: 'explore'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Explore Destinations',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Color(0xFF006994))),
                  const SizedBox(height: 8),
                  const SizedBox(
                    width: 500,
                    child: Text(
                      'From pristine beaches to mountain peaks, discover the wonders of Cebu and its neighboring islands.',
                      style: TextStyle(color: Color(0xFF8B99A6), fontSize: 14, height: 1.6),
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Search
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (v) => setState(() => _searchQuery = v),
                          decoration: InputDecoration(
                            hintText: 'Search (e.g., Kawasan Falls)',
                            prefixIcon: const Icon(Icons.search, color: Color(0xFF00BCD4)),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Region filter chips
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _regions.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, i) {
                        final region = _regions[i];
                        final selected = region == _selectedRegion;
                        final label = region == DestinationRegion.all ? 'All' : regionTitle(region);
                        return FilterChip(
                          label: Text(label),
                          selected: selected,
                          onSelected: (_) => setState(() => _selectedRegion = region),
                          selectedColor: const Color(0xFF006994),
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: selected ? const Color(0xFF006994) : const Color(0xFFE0E0E0),
                            width: 1.5,
                          ),
                          labelStyle: TextStyle(
                            color: selected ? Colors.white : const Color(0xFF006994),
                            fontWeight: FontWeight.w600,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                                style: TextStyle(color: Color(0xFF8B99A6), fontSize: 16)),
                          ),
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 24,
                            crossAxisSpacing: 24,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: _filtered.length,
                          itemBuilder: (context, i) => _DestinationGridCard(spot: _filtered[i]),
                        ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            _Footer(),
          ],
        ),
      ),
    );
  }
}

class _DestinationGridCard extends StatelessWidget {
  final Destination spot;
  const _DestinationGridCard({required this.spot});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, BookingScreen.routeName),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
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
                    child: const Icon(Icons.image, color: Color(0xFF00BCD4), size: 40),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.favorite_border, color: Colors.white),
                    iconSize: 20,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.3),
                      fixedSize: const Size(32, 32),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
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
          const SizedBox(height: 12),
          Text(spot.name,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF00314F)),
              maxLines: 2),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.location_on, size: 12, color: Color(0xFF8B99A6)),
            const SizedBox(width: 3),
            Expanded(
              child: Text(regionTitle(spot.region),
                  style: const TextStyle(fontSize: 11, color: Color(0xFF8B99A6)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
          ]),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                const Icon(Icons.star, size: 14, color: Color(0xFFFFC107)),
                const SizedBox(width: 4),
                Text('${spot.rating}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF00314F))),
              ]),
              Text('₱${spot.entranceFee.toInt()}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF50C878))),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pushNamed(context, BookingScreen.routeName),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF00BCD4),
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Add to Itinerary', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Color _regionColor(DestinationRegion region) {
    switch (region) {
      case DestinationRegion.cebuCity:   return const Color(0xFF0066AA);
      case DestinationRegion.southCebu:  return const Color(0xFF00AA66);
      case DestinationRegion.northCebu:  return const Color(0xFFAA6600);
      case DestinationRegion.bohol:      return const Color(0xFF6600AA);
      default:                           return const Color(0xFF006994);
    }
  }
}

// Reuse shared widgets from home_screen.dart
class _NavBar extends StatelessWidget {
  final String current;
  const _NavBar({required this.current});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF00BCD4),
              child: Icon(Icons.public, color: Colors.white, size: 18),
            ),
            SizedBox(width: 8),
            Text('Spoony Travel',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF006994))),
          ]),
          Row(children: [
            _NavBtn(label: 'Home', active: current == 'home',
                onTap: () => Navigator.pushReplacementNamed(context, HomeScreen.routeName)),
            _NavBtn(label: 'Explore', active: current == 'explore', onTap: () {}),
            _NavBtn(label: 'Bookings', active: current == 'booking',
                onTap: () => Navigator.pushNamed(context, BookingScreen.routeName)),
            _NavBtn(label: 'Dashboard', active: current == 'dashboard',
                onTap: () => Navigator.pushNamed(context, DashboardScreen.routeName)),
            const SizedBox(width: 16),
            FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF00BCD4),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Sign In', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ]),
        ],
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _NavBtn({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Text(label,
          style: TextStyle(
            color: active ? const Color(0xFF006994) : const Color(0xFF5D6D7A),
            fontWeight: active ? FontWeight.w700 : FontWeight.w600,
          )),
    );
  }
}

class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        color: const Color(0xFF006994),
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Row(children: [
                  CircleAvatar(radius: 14, backgroundColor: Color(0xFF00BCD4),
                      child: Icon(Icons.public, color: Colors.white, size: 14)),
                  SizedBox(width: 8),
                  Text('Spoony Travel',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                ]),
                const SizedBox(height: 16),
                Text('Your premium gateway to the most beautiful destinations in Cebu, Philippines.',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13, height: 1.6)),
              ]),
            ),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Destinations',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 12),
                for (final l in ['Cebu City', 'South Cebu', 'North Cebu', 'Bohol Side Tours'])
                  Padding(padding: const EdgeInsets.only(bottom: 8),
                      child: Text(l, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13))),
              ]),
            ),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Support',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 12),
                for (final l in ['Contact Us', 'FAQs', 'Privacy Policy', 'Terms of Service'])
                  Padding(padding: const EdgeInsets.only(bottom: 8),
                      child: Text(l, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13))),
              ]),
            ),
          ],
        ),
      ),
      Container(
        color: const Color(0xFF00507A),
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
        child: Center(
          child: Text('© 2026 Spoony Travel and Tours. All rights reserved.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
        ),
      ),
    ]);
  }
}
