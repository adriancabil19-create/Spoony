import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/cebu_data.dart';
import 'home_screen.dart';
import 'auth_screen.dart';

const _accLabels = {
  'acc_budget': 'Budget Stay',
  'acc_standard': 'Standard Hotel',
  'acc_premium': 'Premium Resort',
  'acc_luxury': 'Luxury Villa',
};

const _transLabels = {
  'trans_shared_van': 'Shared Van',
  'trans_private_sedan': 'Private Sedan',
  'trans_suv': 'Private SUV',
};

class AdminScreen extends StatefulWidget {
  static const routeName = '/admin';
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Supabase.instance.client.auth.currentUser;
      final isAdmin = user?.appMetadata['role'] == 'admin';
      if (!isAdmin && mounted) {
        Navigator.pushReplacementNamed(context, HomeScreen.routeName);
      }
    });
  }

  static const _tabs = [
    (Icons.list_alt, 'Bookings'),
    (Icons.location_on, 'Manage Spots'),
    (Icons.hotel, 'Manage Hotels'),
    (Icons.tour, 'Manage Packages'),
    (Icons.directions_car, 'Manage Transport'),
  ];

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final name = user?.userMetadata?['name'] as String? ??
        user?.userMetadata?['full_name'] as String? ??
        user?.email ?? 'Admin';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
      body: LayoutBuilder(
        builder: (context, viewConstraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: viewConstraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
            // ── Header ────────────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushReplacementNamed(context, HomeScreen.routeName),
                    child: const Row(children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Color(0xFF00BCD4),
                        child: Icon(Icons.public, color: Colors.white, size: 18),
                      ),
                      SizedBox(width: 8),
                      Text('Spoony Admin',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF006994))),
                    ]),
                  ),
                  Row(children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F7FA),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(name,
                          style: const TextStyle(
                              color: Color(0xFF006994),
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: () async {
                        await Supabase.instance.client.auth.signOut();
                        if (context.mounted) {
                          Navigator.pushReplacementNamed(
                              context, AuthScreen.routeName);
                        }
                      },
                      icon: const Icon(Icons.logout, size: 16),
                      label: const Text('Sign Out'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B4A),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ]),
                ],
              ),
            ),

            // ── Body ──────────────────────────────────────────────────────
            Expanded(child: LayoutBuilder(builder: (ctx, constraints) {
              final mobile = constraints.maxWidth < 700;
              if (mobile) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  child: Column(children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(_tabs.length, (i) {
                          final (icon, label) = _tabs[i];
                          final sel = _tab == i;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => setState(() => _tab = i),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: sel
                                      ? const Color(0xFFE0F7FA)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: sel
                                          ? const Color(0xFF00BCD4)
                                          : const Color(0xFFE8EDEF)),
                                ),
                                child: Row(children: [
                                  Icon(icon,
                                      size: 15,
                                      color: sel
                                          ? const Color(0xFF006994)
                                          : const Color(0xFF8B99A6)),
                                  const SizedBox(width: 6),
                                  Text(label,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: sel
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: sel
                                            ? const Color(0xFF006994)
                                            : const Color(0xFF8B99A6),
                                      )),
                                ]),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildContent(),
                  ]),
                );
              }
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 220,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: const Color(0xFFE8EDEF)),
                        ),
                        child: Column(
                          children: List.generate(_tabs.length, (i) {
                            final (icon, label) = _tabs[i];
                            final sel = _tab == i;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => setState(() => _tab = i),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: sel
                                          ? const Color(0xFFE0F7FA)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(children: [
                                      Icon(icon,
                                          size: 20,
                                          color: sel
                                              ? const Color(0xFF00BCD4)
                                              : const Color(0xFF8B99A6)),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(label,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: sel
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
                                              color: sel
                                                  ? const Color(0xFF006994)
                                                  : const Color(0xFF8B99A6),
                                            )),
                                      ),
                                    ]),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(width: 32),
                    Expanded(child: _buildContent()),
                  ],
                ),
              );
            })),

            Container(
              color: const Color(0xFF006994),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              child: const Center(
                child: Text('© 2025 Spoony Travel. All rights reserved.',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
              ),
            ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_tab) {
      case 0: return const _BookingsTab();
      case 1: return const _ManageSpotsTab();
      case 2: return const _ManageHotelsTab();
      case 3: return const _ManagePackagesTab();
      case 4: return const _ManageTransportTab();
      default: return const _BookingsTab();
    }
  }
}

// ── Tab: Bookings ─────────────────────────────────────────────────────────────

class _BookingsTab extends StatefulWidget {
  const _BookingsTab();
  @override
  State<_BookingsTab> createState() => _BookingsTabState();
}

class _BookingsTabState extends State<_BookingsTab> {
  bool _loading = true;
  List<Map<String, dynamic>> _bookings = [];
  String? _error;
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await Supabase.instance.client
          .from('bookings')
          .select()
          .order('created_at', ascending: false);
      setState(() {
        _bookings = (data as List).cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _approve(String id) async {
    try {
      await Supabase.instance.client
          .from('bookings')
          .update({'status': 'confirmed', 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', id)
          .eq('status', 'pending');
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _reject(String id) async {
    try {
      await Supabase.instance.client
          .from('bookings')
          .update({'status': 'cancelled', 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', id);
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  List<Map<String, dynamic>> get _filtered {
    if (_filter == 'all') return _bookings;
    return _bookings.where((b) => (b['status'] as String? ?? '') == _filter).toList();
  }

  int _count(String status) => _bookings.where((b) => b['status'] == status).length;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('All Bookings',
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF006994))),
            IconButton(onPressed: _load, icon: const Icon(Icons.refresh, color: Color(0xFF00BCD4))),
          ],
        ),
        const SizedBox(height: 4),
        const Text('Manage and approve guest bookings.',
            style: TextStyle(fontSize: 14, color: Color(0xFF8B99A6))),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _FilterChip(label: 'All', count: _bookings.length, color: const Color(0xFF006994),
                selected: _filter == 'all', onTap: () => setState(() => _filter = 'all')),
            _FilterChip(label: 'Pending', count: _count('pending'), color: const Color(0xFFFFC107),
                selected: _filter == 'pending', onTap: () => setState(() => _filter = 'pending')),
            _FilterChip(label: 'Confirmed', count: _count('confirmed'), color: const Color(0xFF50C878),
                selected: _filter == 'confirmed', onTap: () => setState(() => _filter = 'confirmed')),
            _FilterChip(label: 'Cancelled', count: _count('cancelled'), color: const Color(0xFFFF6B4A),
                selected: _filter == 'cancelled', onTap: () => setState(() => _filter = 'cancelled')),
          ],
        ),
        const SizedBox(height: 16),
        if (_loading)
          const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
        else if (_error != null)
          _AdminEmpty(message: _error!)
        else if (_filtered.isEmpty)
          _AdminEmpty(message: _filter == 'all' ? 'No bookings yet.' : 'No $_filter bookings.')
        else
          for (final b in _filtered) _BookingRow(booking: b, onApprove: _approve, onReject: _reject),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label, required this.count, required this.color,
    required this.selected, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.1) : Colors.white,
          border: Border.all(
              color: selected ? color : const Color(0xFFE8EDEF),
              width: selected ? 1.5 : 1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(label,
              style: TextStyle(
                  color: selected ? color : const Color(0xFF8B99A6),
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10)),
            child: Text('$count',
                style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ]),
      ),
    );
  }
}

class _BookingRow extends StatelessWidget {
  final Map<String, dynamic> booking;
  final Future<void> Function(String) onApprove;
  final Future<void> Function(String) onReject;

  const _BookingRow({required this.booking, required this.onApprove, required this.onReject});

  @override
  Widget build(BuildContext context) {
    final status = (booking['status'] as String? ?? 'pending').toLowerCase();
    final Color statusColor;
    switch (status) {
      case 'confirmed': statusColor = const Color(0xFF50C878); break;
      case 'cancelled': statusColor = const Color(0xFFFF6B4A); break;
      default: statusColor = const Color(0xFFFFC107);
    }

    final ref = booking['reference_code'] as String? ?? '—';
    final email = booking['user_email'] as String? ?? '—';
    final startDate = (booking['start_date'] as String? ?? '').replaceAll('T00:00:00.000Z', '');
    final endDate = (booking['end_date'] as String? ?? '').replaceAll('T00:00:00.000Z', '');
    final guests = booking['guest_count'] as int? ?? 0;
    final amount = booking['total_amount'] != null
        ? '₱${(booking['total_amount'] as num).toStringAsFixed(0)}'
        : '—';
    final id = booking['id'] as String;
    final accType = booking['accommodation_type'] as String? ?? '';
    final transType = booking['transport_type'] as String? ?? '';
    final accLabel = _accLabels[accType] ?? (accType.isNotEmpty ? accType : '—');
    final transLabel = _transLabels[transType] ?? (transType.isNotEmpty ? transType : '—');
    final createdAt = (booking['created_at'] as String? ?? '').split('T').first;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EDEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(status.toUpperCase(),
                  style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 10),
            Text(ref,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF006994))),
            const Spacer(),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(amount,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF50C878))),
              if (createdAt.isNotEmpty)
                Text('Booked $createdAt',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF8B99A6))),
            ]),
          ]),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF0F4F5)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _InfoRow(icon: Icons.email_outlined, label: 'Guest', value: email)),
            Expanded(child: _InfoRow(icon: Icons.people, label: 'Guests', value: '$guests person(s)')),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
                child: _InfoRow(
                    icon: Icons.calendar_today,
                    label: 'Dates',
                    value: '$startDate → $endDate')),
            Expanded(
                child: _InfoRow(
                    icon: Icons.hotel, label: 'Accommodation', value: accLabel)),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
                child: _InfoRow(
                    icon: Icons.directions_car, label: 'Transport', value: transLabel)),
          ]),
          if (status == 'pending') ...[
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => onApprove(id),
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Approve', style: TextStyle(fontWeight: FontWeight.w700)),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF50C878),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => onReject(id),
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Reject', style: TextStyle(fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFF6B4A)),
                    foregroundColor: const Color(0xFFFF6B4A),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ]),
          ] else if (status == 'confirmed') ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => onReject(id),
                icon: const Icon(Icons.cancel_outlined, size: 16),
                label: const Text('Cancel Booking'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFF6B4A)),
                  foregroundColor: const Color(0xFFFF6B4A),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 14, color: const Color(0xFF8B99A6)),
      const SizedBox(width: 6),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: Color(0xFF8B99A6), fontWeight: FontWeight.w600)),
          Text(value,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF00314F), fontWeight: FontWeight.w500)),
        ]),
      ),
    ]);
  }
}

// ── Tab: Manage Spots (combined with Add Spot) ────────────────────────────────

class _ManageSpotsTab extends StatefulWidget {
  const _ManageSpotsTab();
  @override
  State<_ManageSpotsTab> createState() => _ManageSpotsTabState();
}

class _ManageSpotsTabState extends State<_ManageSpotsTab> {
  bool _loading = true;
  List<Map<String, dynamic>> _spots = [];
  String? _error;

  static const _regions = [
    ('cebu_city', 'Cebu City'),
    ('south_cebu', 'South Cebu'),
    ('north_cebu', 'North Cebu'),
    ('islands', 'Islands'),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await Supabase.instance.client
          .from('destinations')
          .select()
          .order('rating', ascending: false);
      final dbSpots = (data as List).cast<Map<String, dynamic>>();
      setState(() { _spots = dbSpots; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  // ── Merge: show cebu_data defaults not already in DB (matched by name) ──────
  List<Map<String, dynamic>> get _mergedSpots {
    final dbNames = _spots.map((s) => (s['name'] as String).toLowerCase()).toSet();
    final defaults = cebuDestinations
        .where((d) => !dbNames.contains(d.name.toLowerCase()))
        .map((d) => {
              '_isDefault': true,
              'name': d.name,
              'description': d.description,
              'region': d.region.name,
              'entrance_fee': d.entranceFee,
              'latitude': d.coordinates['lat'],
              'longitude': d.coordinates['lng'],
              'image_urls': d.images,
              'is_available': true,
              'rating': d.rating,
            })
        .toList();
    return [..._spots, ...defaults];
  }

  Future<void> _toggleAvailability(Map<String, dynamic> spot) async {
    if (spot['_isDefault'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Save this spot to the database first to manage it.')),
      );
      return;
    }
    final current = spot['is_available'] as bool? ?? true;
    try {
      await Supabase.instance.client
          .from('destinations')
          .update({'is_available': !current})
          .eq('id', spot['id'] as String);
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showAddDialog() => _showSpotDialog(null);

  void _showEditDialog(Map<String, dynamic> spot) => _showSpotDialog(spot);

  void _showSpotDialog(Map<String, dynamic>? existing) {
    final isDefault = existing?['_isDefault'] == true;
    final isEdit = existing != null && !isDefault;

    final nameCtrl = TextEditingController(text: existing?['name'] as String? ?? '');
    final descCtrl = TextEditingController(text: existing?['description'] as String? ?? '');
    final feeCtrl = TextEditingController(
        text: (existing?['entrance_fee'] as num?)?.toStringAsFixed(0) ?? '');
    final latCtrl = TextEditingController(
        text: (existing?['latitude'] as num?)?.toString() ?? '');
    final lngCtrl = TextEditingController(
        text: (existing?['longitude'] as num?)?.toString() ?? '');
    final imgCtrl = TextEditingController(
        text: (existing?['image_urls'] as List?)?.isNotEmpty == true
            ? (existing!['image_urls'] as List).first as String
            : '');

    String region = existing?['region'] as String? ?? 'south_cebu';
    bool saving = false;
    String? errorMsg;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          title: Text(isEdit ? 'Edit Spot' : (isDefault ? 'Save to Database' : 'Add New Spot'),
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF006994))),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isDefault) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFFB74D)),
                      ),
                      child: const Text(
                        'This is a built-in default spot. Saving it will add it to your database so you can manage it here.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF795548)),
                      ),
                    ),
                  ],
                  if (errorMsg != null) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(errorMsg!,
                          style: const TextStyle(color: Color(0xFFFF6B4A), fontSize: 12)),
                    ),
                  ],
                  _DlgField(label: 'Spot Name *', controller: nameCtrl, hint: 'e.g. Kawasan Falls'),
                  const SizedBox(height: 12),
                  _DlgField(
                      label: 'Description',
                      controller: descCtrl,
                      hint: 'Brief description',
                      maxLines: 3),
                  const SizedBox(height: 12),
                  const Text('Region *',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF5D6D7A))),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _regions.any((r) => r.$1 == region) ? region : _regions.first.$1,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    items: _regions
                        .map((r) => DropdownMenuItem(value: r.$1, child: Text(r.$2)))
                        .toList(),
                    onChanged: (v) { if (v != null) setDlg(() => region = v); },
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: _DlgField(
                        label: 'Entrance Fee (₱) *',
                        controller: feeCtrl,
                        hint: '0',
                        keyboardType: TextInputType.number)),
                    const SizedBox(width: 12),
                    Expanded(child: _DlgField(
                        label: 'Latitude',
                        controller: latCtrl,
                        hint: '10.3157',
                        keyboardType: TextInputType.number)),
                    const SizedBox(width: 12),
                    Expanded(child: _DlgField(
                        label: 'Longitude',
                        controller: lngCtrl,
                        hint: '123.8854',
                        keyboardType: TextInputType.number)),
                  ]),
                  const SizedBox(height: 12),
                  _DlgField(
                      label: 'Image URL',
                      controller: imgCtrl,
                      hint: 'https://...'),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: saving
                  ? null
                  : () async {
                      if (nameCtrl.text.trim().isEmpty || feeCtrl.text.isEmpty) {
                        setDlg(() => errorMsg = 'Name and entrance fee are required.');
                        return;
                      }
                      setDlg(() { saving = true; errorMsg = null; });
                      try {
                        final payload = {
                          'name': nameCtrl.text.trim(),
                          'description': descCtrl.text.trim(),
                          'region': region,
                          'entrance_fee': double.tryParse(feeCtrl.text) ?? 0,
                          'latitude': double.tryParse(latCtrl.text) ?? 10.3157,
                          'longitude': double.tryParse(lngCtrl.text) ?? 123.8854,
                          'image_urls': imgCtrl.text.trim().isNotEmpty ? [imgCtrl.text.trim()] : [],
                        };
                        if (isEdit) {
                          await Supabase.instance.client
                              .from('destinations')
                              .update(payload)
                              .eq('id', existing['id'] as String);
                        } else {
                          await Supabase.instance.client
                              .from('destinations')
                              .insert(payload);
                        }
                        if (ctx.mounted) Navigator.pop(ctx);
                        _load();
                      } catch (e) {
                        setDlg(() { saving = false; errorMsg = e.toString(); });
                      }
                    },
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF006994)),
              child: saving
                  ? const SizedBox(
                      height: 16, width: 16,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(isEdit ? 'Save Changes' : 'Add Spot'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteSpot(Map<String, dynamic> spot) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Spot'),
        content: Text('Remove "${spot['name']}" from the platform?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF6B4A)),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await Supabase.instance.client
          .from('destinations')
          .delete()
          .eq('id', spot['id'] as String);
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  static const _regionOrder = [
    'cebu_city', 'cebuCity',
    'south_cebu', 'southCebu',
    'north_cebu', 'northCebu',
    'islands', 'bohol',
  ];

  static const _regionLabels = <String, String>{
    'cebu_city': 'Cebu City',   'cebuCity': 'Cebu City',
    'south_cebu': 'South Cebu', 'southCebu': 'South Cebu',
    'north_cebu': 'North Cebu', 'northCebu': 'North Cebu',
    'islands': 'Islands',        'bohol': 'Islands',
  };

  @override
  Widget build(BuildContext context) {
    final all = _mergedSpots;

    // Group spots by region in display order
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final s in all) {
      grouped.putIfAbsent(s['region'] as String? ?? 'other', () => []).add(s);
    }
    final orderedKeys = [
      ..._regionOrder.where(grouped.containsKey),
      ...grouped.keys.where((k) => !_regionOrder.contains(k)),
    ];

    final spotWidgets = <Widget>[];
    for (final key in orderedKeys) {
      final spots = grouped[key]!;
      spotWidgets.add(_SpotSectionHeader(
        label: _regionLabels[key] ?? key,
        count: spots.length,
      ));
      for (final s in spots) {
        spotWidgets.add(_SpotRow(
          spot: s,
          onEdit: () => _showEditDialog(s),
          onToggle: () => _toggleAvailability(s),
          onDelete: s['_isDefault'] == true ? null : () => _deleteSpot(s),
        ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Manage Spots',
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF006994))),
            Row(children: [
              IconButton(
                  onPressed: _load, icon: const Icon(Icons.refresh, color: Color(0xFF00BCD4))),
              FilledButton.icon(
                onPressed: _showAddDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Spot'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF006994),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ]),
          ],
        ),
        const SizedBox(height: 4),
        const Text('Edit, add, or toggle visibility of tour destinations.',
            style: TextStyle(fontSize: 14, color: Color(0xFF8B99A6))),
        const SizedBox(height: 16),
        if (_loading)
          const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
        else if (_error != null)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFFB74D)),
            ),
            child: const Row(children: [
              Icon(Icons.wifi_off, size: 16, color: Color(0xFFF57C00)),
              SizedBox(width: 8),
              Expanded(child: Text(
                'Could not reach Supabase — showing built-in destinations. Check your Supabase connection.',
                style: TextStyle(fontSize: 12, color: Color(0xFFF57C00)),
              )),
            ]),
          )
        else if (all.isEmpty)
          const _AdminEmpty(message: 'No spots yet. Click "Add Spot" to create one.')
        else
          Expanded(
            child: ListView(children: spotWidgets),
          ),
      ],
    );
  }
}

class _SpotSectionHeader extends StatelessWidget {
  final String label;
  final int count;
  const _SpotSectionHeader({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 8),
      child: Row(children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF006994))),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFE0F7FA),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text('$count',
              style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF006994))),
        ),
        const SizedBox(width: 10),
        const Expanded(child: Divider(color: Color(0xFFE8EDEF), thickness: 1)),
      ]),
    );
  }
}

class _SpotRow extends StatelessWidget {
  final Map<String, dynamic> spot;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback? onDelete;

  const _SpotRow({
    required this.spot,
    required this.onEdit,
    required this.onToggle,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final available = spot['is_available'] as bool? ?? true;
    final fee = (spot['entrance_fee'] as num?)?.toStringAsFixed(0) ?? '0';
    final isDefault = spot['_isDefault'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: isDefault ? const Color(0xFFFFCC80) : const Color(0xFFE8EDEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDefault
                    ? const Color(0xFFFFF3E0)
                    : const Color(0xFFE0F7FA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isDefault ? Icons.bookmark_outline : Icons.location_on,
                color: isDefault ? const Color(0xFFFF8C00) : const Color(0xFF006994),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Flexible(
                    child: Text(spot['name'] as String? ?? '—',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF00314F))),
                  ),
                  if (isDefault) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFCC80),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('Default',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF795548))),
                    ),
                  ],
                ]),
                const SizedBox(height: 2),
                Text('${spot['region'] ?? ''} · ₱$fee entrance',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF8B99A6))),
              ]),
            ),
            // Action buttons
            TextButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit, size: 15),
              label: Text(isDefault ? 'Save to DB' : 'Edit'),
              style: TextButton.styleFrom(
                  foregroundColor: isDefault ? const Color(0xFFFF8C00) : const Color(0xFF006994),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
            ),
            if (!isDefault) ...[
              Switch(
                value: available,
                onChanged: (_) => onToggle(),
                activeThumbColor: const Color(0xFF00BCD4),
              ),
              Text(available ? 'On' : 'Off',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: available ? const Color(0xFF50C878) : const Color(0xFFFF6B4A),
                  )),
              const SizedBox(width: 4),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFFF6B4A)),
                tooltip: 'Delete spot',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ]),
        ],
      ),
    );
  }
}

// ── Tab: Manage Hotels ────────────────────────────────────────────────────────

class _ManageHotelsTab extends StatefulWidget {
  const _ManageHotelsTab();
  @override
  State<_ManageHotelsTab> createState() => _ManageHotelsTabState();
}

class _ManageHotelsTabState extends State<_ManageHotelsTab> {
  bool _loading = true;
  List<Map<String, dynamic>> _hotels = [];

  static const _defaults = <Map<String, dynamic>>[
    {'id': 'acc_budget', 'title': 'Budget Stay', 'category': 'Budget', 'nightly_rate': 1200.0, 'description': 'Hostel-style rooms with local comfort and easy access to the city.', 'is_active': true},
    {'id': 'acc_standard', 'title': 'Standard Hotel', 'category': 'Standard', 'nightly_rate': 2200.0, 'description': 'Modern rooms with breakfast, city views, and premium amenities.', 'is_active': true},
    {'id': 'acc_premium', 'title': 'Premium Resort', 'category': 'Premium', 'nightly_rate': 5200.0, 'description': 'Luxury resort stay with pool access and curated leisure services.', 'is_active': true},
    {'id': 'acc_luxury', 'title': 'Luxury Villa', 'category': 'Luxury', 'nightly_rate': 9800.0, 'description': 'Private villa experience with VIP concierge and premium comforts.', 'is_active': true},
  ];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await Supabase.instance.client.from('accommodation_types').select();
      final list = (data as List).cast<Map<String, dynamic>>();
      setState(() { _hotels = list.isEmpty ? List.from(_defaults) : list; _loading = false; });
    } catch (_) {
      setState(() { _hotels = List.from(_defaults); _loading = false; });
    }
  }

  void _showEditDialog(Map<String, dynamic> hotel) {
    final rateCtrl = TextEditingController(
        text: (hotel['nightly_rate'] as num?)?.toStringAsFixed(0) ?? '0');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit Price — ${hotel['title']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(hotel['description'] as String? ?? '',
                style: const TextStyle(color: Color(0xFF8B99A6), fontSize: 13)),
            const SizedBox(height: 16),
            TextField(
              controller: rateCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nightly Rate (₱)',
                border: OutlineInputBorder(),
                prefixText: '₱ ',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final rate = double.tryParse(rateCtrl.text);
              if (rate == null) return;
              Navigator.pop(context);
              try {
                await Supabase.instance.client
                    .from('accommodation_types')
                    .update({'nightly_rate': rate})
                    .eq('id', hotel['id'] as String);
                _load();
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF006994)),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleActive(Map<String, dynamic> hotel) async {
    final current = hotel['is_active'] as bool? ?? true;
    try {
      await Supabase.instance.client
          .from('accommodation_types')
          .update({'is_active': !current})
          .eq('id', hotel['id'] as String);
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  static const _categoryColors = {
    'Budget': Color(0xFF50C878),
    'Standard': Color(0xFF00BCD4),
    'Premium': Color(0xFF9C27B0),
    'Luxury': Color(0xFFFF8C00),
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Manage Hotels',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF006994))),
            IconButton(onPressed: _load, icon: const Icon(Icons.refresh, color: Color(0xFF00BCD4))),
          ],
        ),
        const SizedBox(height: 4),
        const Text('Edit accommodation prices and toggle availability.',
            style: TextStyle(fontSize: 14, color: Color(0xFF8B99A6))),
        const SizedBox(height: 20),
        if (_loading)
          const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
        else
          for (final hotel in _hotels) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE8EDEF)),
              ),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (_categoryColors[hotel['category'] as String? ?? ''] ?? const Color(0xFF006994))
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.hotel,
                      color: _categoryColors[hotel['category'] as String? ?? ''] ?? const Color(0xFF006994),
                      size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Text(hotel['title'] as String? ?? '—',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF00314F))),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: (_categoryColors[hotel['category'] as String? ?? ''] ?? const Color(0xFF006994))
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(hotel['category'] as String? ?? '',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _categoryColors[hotel['category'] as String? ?? ''] ?? const Color(0xFF006994))),
                      ),
                    ]),
                    const SizedBox(height: 4),
                    Text(hotel['description'] as String? ?? '',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF8B99A6)),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Text('₱${(hotel['nightly_rate'] as num?)?.toStringAsFixed(0) ?? '0'} / night',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF50C878))),
                  ]),
                ),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  TextButton.icon(
                    onPressed: () => _showEditDialog(hotel),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit Price'),
                    style: TextButton.styleFrom(foregroundColor: const Color(0xFF006994)),
                  ),
                  Row(children: [
                    Switch(
                      value: hotel['is_active'] as bool? ?? true,
                      onChanged: (_) => _toggleActive(hotel),
                      activeThumbColor: const Color(0xFF00BCD4),
                    ),
                    Text(
                      (hotel['is_active'] as bool? ?? true) ? 'Active' : 'Hidden',
                      style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600,
                        color: (hotel['is_active'] as bool? ?? true)
                            ? const Color(0xFF50C878) : const Color(0xFFFF6B4A),
                      ),
                    ),
                  ]),
                ]),
              ]),
            ),
          ],
      ],
    );
  }
}

// ── Tab: Manage Packages ──────────────────────────────────────────────────────

class _ManagePackagesTab extends StatefulWidget {
  const _ManagePackagesTab();
  @override
  State<_ManagePackagesTab> createState() => _ManagePackagesTabState();
}

class _ManagePackagesTabState extends State<_ManagePackagesTab> {
  bool _loading = true;
  List<Map<String, dynamic>> _packages = [];

  static List<Map<String, dynamic>> get _defaults => tourPackages.map((p) => {
    'id': p.id,
    'name': p.name,
    'tagline': p.tagline,
    'region': p.region,
    'duration_days': p.durationDays,
    'joiner_price': p.joinerPricePerPerson,
    'premium_price': p.premiumPricePerPerson,
    'image_url': p.imageUrl,
    'is_active': true,
  }).toList();

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await Supabase.instance.client.from('tour_packages').select();
      final list = (data as List).cast<Map<String, dynamic>>();
      setState(() { _packages = list.isEmpty ? _defaults : list; _loading = false; });
    } catch (_) {
      setState(() { _packages = _defaults; _loading = false; });
    }
  }

  void _showEditDialog(Map<String, dynamic> pkg) {
    final joinerCtrl = TextEditingController(
        text: (pkg['joiner_price'] as num?)?.toStringAsFixed(0) ?? '0');
    final premiumCtrl = TextEditingController(
        text: (pkg['premium_price'] as num?)?.toStringAsFixed(0) ?? '0');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit Prices — ${pkg['name']}',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF006994))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: joinerCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Joiner Price per Person (₱)',
                border: OutlineInputBorder(),
                prefixText: '₱ ',
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: premiumCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Premium Price per Person (₱)',
                border: OutlineInputBorder(),
                prefixText: '₱ ',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final joiner = double.tryParse(joinerCtrl.text);
              final premium = double.tryParse(premiumCtrl.text);
              if (joiner == null || premium == null) return;
              Navigator.pop(context);
              try {
                await Supabase.instance.client
                    .from('tour_packages')
                    .upsert({'id': pkg['id'], 'joiner_price': joiner, 'premium_price': premium});
                _load();
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF006994)),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Manage Packages',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF006994))),
            IconButton(onPressed: _load, icon: const Icon(Icons.refresh, color: Color(0xFF00BCD4))),
          ],
        ),
        const SizedBox(height: 4),
        const Text('Edit joiner and premium prices for each tour package.',
            style: TextStyle(fontSize: 14, color: Color(0xFF8B99A6))),
        const SizedBox(height: 20),
        if (_loading)
          const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
        else
          for (final pkg in _packages) _PackageAdminRow(package: pkg, onEdit: () => _showEditDialog(pkg)),
      ],
    );
  }
}

class _PackageAdminRow extends StatelessWidget {
  final Map<String, dynamic> package;
  final VoidCallback onEdit;
  const _PackageAdminRow({required this.package, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final joiner = (package['joiner_price'] as num?)?.toStringAsFixed(0) ?? '—';
    final premium = (package['premium_price'] as num?)?.toStringAsFixed(0) ?? '—';
    final days = package['duration_days'] as int? ?? 1;
    final region = package['region'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EDEF)),
      ),
      child: Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            package['image_url'] as String? ?? '',
            width: 80, height: 80, fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              width: 80, height: 80,
              color: const Color(0xFFE0F7FA),
              child: const Icon(Icons.tour, color: Color(0xFF006994), size: 32),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(package['name'] as String? ?? '—',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF00314F))),
            const SizedBox(height: 4),
            Text('$region · $days day${days != 1 ? 's' : ''}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF8B99A6))),
            const SizedBox(height: 10),
            Row(children: [
              _PkgPriceTag(label: 'Joiner', price: '₱$joiner', color: const Color(0xFF00BCD4)),
              const SizedBox(width: 10),
              _PkgPriceTag(label: 'Premium', price: '₱$premium', color: const Color(0xFFFF8C00)),
            ]),
          ]),
        ),
        TextButton.icon(
          onPressed: onEdit,
          icon: const Icon(Icons.edit, size: 16),
          label: const Text('Edit Prices'),
          style: TextButton.styleFrom(foregroundColor: const Color(0xFF006994)),
        ),
      ]),
    );
  }
}

class _PkgPriceTag extends StatelessWidget {
  final String label;
  final String price;
  final Color color;
  const _PkgPriceTag({required this.label, required this.price, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
        Text(price, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
        Text('/person', style: const TextStyle(fontSize: 9, color: Color(0xFF8B99A6))),
      ]),
    );
  }
}

// ── Tab: Manage Transport ─────────────────────────────────────────────────────

class _ManageTransportTab extends StatefulWidget {
  const _ManageTransportTab();
  @override
  State<_ManageTransportTab> createState() => _ManageTransportTabState();
}

class _ManageTransportTabState extends State<_ManageTransportTab> {
  bool _loading = true;
  List<Map<String, dynamic>> _transports = [];

  static const _defaults = <Map<String, dynamic>>[
    {'id': 'trans_shared_van', 'title': 'Shared Van', 'description': 'Comfortable shared transfer with budget-friendly pricing.', 'price': 450.0, 'is_active': true},
    {'id': 'trans_private_sedan', 'title': 'Private Sedan', 'description': 'Personal sedan with driver and flexible pickup time.', 'price': 1300.0, 'is_active': true},
    {'id': 'trans_suv', 'title': 'Private SUV', 'description': 'Spacious SUV for families and premium road comfort.', 'price': 2400.0, 'is_active': true},
  ];

  static const _transIcons = {
    'trans_shared_van': Icons.airport_shuttle,
    'trans_private_sedan': Icons.directions_car,
    'trans_suv': Icons.directions_car_filled,
  };

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await Supabase.instance.client.from('transport_types').select();
      final list = (data as List).cast<Map<String, dynamic>>();
      setState(() { _transports = list.isEmpty ? List.from(_defaults) : list; _loading = false; });
    } catch (_) {
      setState(() { _transports = List.from(_defaults); _loading = false; });
    }
  }

  void _showEditDialog(Map<String, dynamic> transport) {
    final priceCtrl = TextEditingController(
        text: (transport['price'] as num?)?.toStringAsFixed(0) ?? '0');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit Price — ${transport['title']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(transport['description'] as String? ?? '',
                style: const TextStyle(color: Color(0xFF8B99A6), fontSize: 13)),
            const SizedBox(height: 16),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Price (₱)',
                border: OutlineInputBorder(),
                prefixText: '₱ ',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final price = double.tryParse(priceCtrl.text);
              if (price == null) return;
              Navigator.pop(context);
              try {
                await Supabase.instance.client
                    .from('transport_types')
                    .update({'price': price})
                    .eq('id', transport['id'] as String);
                _load();
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF006994)),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleActive(Map<String, dynamic> transport) async {
    final current = transport['is_active'] as bool? ?? true;
    try {
      await Supabase.instance.client
          .from('transport_types')
          .update({'is_active': !current})
          .eq('id', transport['id'] as String);
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Manage Transport',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF006994))),
            IconButton(onPressed: _load, icon: const Icon(Icons.refresh, color: Color(0xFF00BCD4))),
          ],
        ),
        const SizedBox(height: 4),
        const Text('Edit transport prices and toggle availability.',
            style: TextStyle(fontSize: 14, color: Color(0xFF8B99A6))),
        const SizedBox(height: 20),
        if (_loading)
          const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
        else
          for (final t in _transports) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE8EDEF)),
              ),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F7FA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _transIcons[t['id'] as String? ?? ''] ?? Icons.directions_car,
                    color: const Color(0xFF006994), size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(t['title'] as String? ?? '—',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF00314F))),
                    const SizedBox(height: 4),
                    Text(t['description'] as String? ?? '',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF8B99A6)),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Text('₱${(t['price'] as num?)?.toStringAsFixed(0) ?? '0'} per trip',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF50C878))),
                  ]),
                ),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  TextButton.icon(
                    onPressed: () => _showEditDialog(t),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit Price'),
                    style: TextButton.styleFrom(foregroundColor: const Color(0xFF006994)),
                  ),
                  Row(children: [
                    Switch(
                      value: t['is_active'] as bool? ?? true,
                      onChanged: (_) => _toggleActive(t),
                      activeThumbColor: const Color(0xFF00BCD4),
                    ),
                    Text(
                      (t['is_active'] as bool? ?? true) ? 'Active' : 'Hidden',
                      style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600,
                        color: (t['is_active'] as bool? ?? true)
                            ? const Color(0xFF50C878) : const Color(0xFFFF6B4A),
                      ),
                    ),
                  ]),
                ]),
              ]),
            ),
          ],
      ],
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

class _DlgField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType keyboardType;

  const _DlgField({
    required this.label,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF5D6D7A))),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }
}

class _AdminEmpty extends StatelessWidget {
  final String message;
  const _AdminEmpty({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE8EDEF)),
      ),
      child: Center(
        child: Text(message, style: const TextStyle(color: Color(0xFF8B99A6))),
      ),
    );
  }
}
