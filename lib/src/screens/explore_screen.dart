import 'package:flutter/material.dart';
import '../widgets/spot_card.dart';
import '../widgets/wm_ui.dart';
import '../auth_gate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models.dart';
import '../data/cebu_data.dart';
import 'home_screen.dart';

const _kBg = Color(0xFFF8FAFC);

class ExploreScreen extends StatefulWidget {
  static const routeName = '/explore';
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  DestinationRegion _selectedRegion = DestinationRegion.all;
  String _searchQuery = '';
  Set<String> _favorites = {};
  List<Destination> _destinations = cebuDestinations;

  @override
  void initState() {
    super.initState();
    final raw = Supabase.instance.client.auth.currentUser?.userMetadata?['favorites'];
    if (raw is List) _favorites = raw.cast<String>().toSet();
    _loadDestinations();
  }

  /// DB rows saved before the Wikimedia switch still hold old Unsplash links.
  /// Those must not override the built-in photos, which carry the photo credit
  /// and the face/plate-blurred copies. Admin-uploaded images are kept.
  static List<String> _preferredImages(Object? dbUrls, List<String> fallback) {
    final urls = (dbUrls as List?)?.whereType<String>().where((u) => u.trim().isNotEmpty).toList() ?? const [];
    final custom = urls.where((u) => !u.contains('images.unsplash.com')).toList();
    return custom.isNotEmpty ? custom : fallback;
  }

  static DestinationRegion _parseRegion(String? r) {
    switch (r) {
      case 'cebu_city':   case 'cebuCity':   return DestinationRegion.cebuCity;
      case 'south_cebu':  case 'southCebu':  return DestinationRegion.southCebu;
      case 'north_cebu':  case 'northCebu':  return DestinationRegion.northCebu;
      case 'islands':     case 'bohol':      return DestinationRegion.bohol;
      default:                               return DestinationRegion.cebuCity;
    }
  }

  Future<void> _loadDestinations() async {
    try {
      final data = await Supabase.instance.client.from('destinations').select();
      final dbList = (data as List).cast<Map<String, dynamic>>();
      if (!mounted) return;

      // Names set to unavailable in DB — hide from explore
      final unavailable = dbList
          .where((r) => r['is_available'] == false)
          .map((r) => (r['name'] as String).toLowerCase())
          .toSet();

      // Hardcoded names (for detecting DB-only new spots)
      final hardcoded = cebuDestinations.map((d) => d.name.toLowerCase()).toSet();

      // Merge hardcoded with DB overrides, skip unavailable
      final merged = cebuDestinations
          .where((d) => !unavailable.contains(d.name.toLowerCase()))
          .map((d) {
            final db = dbList.firstWhere(
              (row) => (row['name'] as String).toLowerCase() == d.name.toLowerCase(),
              orElse: () => {},
            );
            if (db.isEmpty) return d;
            return Destination(
              id: db['id'] as String? ?? d.id,
              name: db['name'] as String? ?? d.name,
              description: db['description'] as String? ?? d.description,
              region: d.region,
              images: _preferredImages(db['image_urls'], d.images),
              entranceFee: (db['entrance_fee'] as num?)?.toDouble() ?? d.entranceFee,
              rating: (db['rating'] as num?)?.toDouble() ?? d.rating,
              reviews: d.reviews,
              coordinates: d.coordinates,
              travelTime: d.travelTime,
              averageDistanceKm: d.averageDistanceKm,
            );
          }).toList();

      // Append DB-only spots (added from admin, not in cebuDestinations)
      final newSpots = dbList
          .where((r) {
            final name = (r['name'] as String).toLowerCase();
            return !hardcoded.contains(name) && (r['is_available'] as bool? ?? true);
          })
          .map((r) => Destination(
            id: r['id'] as String? ?? '',
            name: r['name'] as String? ?? '',
            description: r['description'] as String? ?? '',
            region: _parseRegion(r['region'] as String?),
            images: (r['image_urls'] as List?)?.cast<String>() ?? [],
            entranceFee: (r['entrance_fee'] as num?)?.toDouble() ?? 0,
            rating: (r['rating'] as num?)?.toDouble() ?? 0,
            reviews: 0,
            coordinates: {
              'lat': (r['latitude'] as num?)?.toDouble() ?? 10.3157,
              'lng': (r['longitude'] as num?)?.toDouble() ?? 123.8854,
            },
            travelTime: '',
            averageDistanceKm: 0,
          )).toList();

      setState(() => _destinations = [...merged, ...newSpots]);
    } catch (_) {}
  }

  Future<void> _toggleFavorite(String spotName) async {
    final signedIn = await requireLogin(context,
        message: 'Sign in to save destinations to your favorites.');
    if (!signedIn || !mounted) return;
    final updated = Set<String>.from(_favorites);
    if (updated.contains(spotName)) {
      updated.remove(spotName);
    } else {
      updated.add(spotName);
    }
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'favorites': updated.toList()}),
      );
      if (mounted) setState(() => _favorites = updated);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not update favorites.')),
        );
      }
    }
  }

  static const _regions = [
    DestinationRegion.all,
    DestinationRegion.cebuCity,
    DestinationRegion.southCebu,
    DestinationRegion.northCebu,
    DestinationRegion.bohol,
  ];

  List<Destination> get _filtered => _destinations.where((spot) {
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
            const SpoonyNavBar(
              current: 'explore',
              title: 'Explore',
              subtitle: 'Cebu',
              tagline: 'From pristine beaches to mountain peaks, discover the wonders of Cebu and its neighboring islands.',
            ),
            LayoutBuilder(builder: (context, constraints) {
              final wide = constraints.maxWidth >= 700;
              final hPad = wide ? 80.0 : 20.0;
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search (Watermelon pill input)
                    WmBlurIn(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 640),
                        child: TextField(
                          onChanged: (v) => setState(() => _searchQuery = v),
                          style: const TextStyle(fontSize: 14.5, color: Wm.ink),
                          decoration: InputDecoration(
                            hintText: 'Search destinations, beaches, falls…',
                            hintStyle: const TextStyle(color: Wm.muted),
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(left: 14, right: 6),
                              child: Icon(Icons.search_rounded, color: Wm.accent),
                            ),
                            filled: true,
                            fillColor: Wm.surface,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(999),
                              borderSide: const BorderSide(color: Wm.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(999),
                              borderSide: const BorderSide(color: Wm.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(999),
                              borderSide: BorderSide(color: Wm.accent.withValues(alpha: 0.7), width: 2),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Region filter: spring-sliding pill tabs
                    WmBlurIn(
                      delay: const Duration(milliseconds: 80),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: WmContinuousTabs(
                          labels: [
                            for (final r in _regions) r == DestinationRegion.all ? 'All' : regionTitle(r),
                          ],
                          selected: _regions.indexOf(_selectedRegion),
                          onChanged: (i) => setState(() => _selectedRegion = _regions[i]),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('${_filtered.length} destination${_filtered.length == 1 ? '' : 's'}',
                        style: const TextStyle(color: Wm.muted, fontSize: 12.5)),
                    const SizedBox(height: 32),
                    _filtered.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(48),
                              child: Text('No destinations found.',
                                  style: TextStyle(color: Wm.muted, fontSize: 16)),
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
                                mainAxisExtent: cols == 1 ? 350 : 320,
                              ),
                              itemCount: _filtered.length,
                              itemBuilder: (context, i) => WmBlurIn(
                                key: ValueKey('${_selectedRegion.name}-${_filtered[i].id}'),
                                delay: Duration(milliseconds: 40 * (i < 12 ? i : 12)),
                                child: SpotCard(
                                  spot: _filtered[i],
                                  imageHeight: cols == 1 ? 190 : 160,
                                  saved: _favorites.contains(_filtered[i].name),
                                  onToggleSave: () => _toggleFavorite(_filtered[i].name),
                                  ctaLabel: 'Add to Itinerary',
                                ),
                              ),
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
