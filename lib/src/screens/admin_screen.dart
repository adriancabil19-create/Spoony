import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/api_service.dart';
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

  static const _tabs = [
    (Icons.list_alt, 'Bookings'),
    (Icons.location_on, 'Manage Spots'),
    (Icons.hotel, 'Manage Hotels'),
    (Icons.directions_car, 'Manage Transport'),
    (Icons.add_location_alt, 'Add Spot'),
  ];

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final name = user?.userMetadata?['name'] as String? ??
        user?.userMetadata?['full_name'] as String? ??
        user?.email ?? 'Admin';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pushReplacementNamed(context, HomeScreen.routeName),
                    child: const Row(children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Color(0xFF00BCD4),
                        child: Icon(Icons.public, color: Colors.white, size: 18),
                      ),
                      SizedBox(width: 8),
                      Text('Spoony Admin',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF006994))),
                    ]),
                  ),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F7FA),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(name,
                          style: const TextStyle(color: Color(0xFF006994), fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: () async {
                        await Supabase.instance.client.auth.signOut();
                        if (context.mounted) {
                          Navigator.pushReplacementNamed(context, AuthScreen.routeName);
                        }
                      },
                      icon: const Icon(Icons.logout, size: 16),
                      label: const Text('Sign Out'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B4A),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
            LayoutBuilder(builder: (ctx, constraints) {
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
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: sel ? const Color(0xFFE0F7FA) : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: sel ? const Color(0xFF00BCD4) : const Color(0xFFE8EDEF)),
                                ),
                                child: Row(children: [
                                  Icon(icon, size: 15,
                                      color: sel ? const Color(0xFF006994) : const Color(0xFF8B99A6)),
                                  const SizedBox(width: 6),
                                  Text(label,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                                        color: sel ? const Color(0xFF006994) : const Color(0xFF8B99A6),
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
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
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
                          border: Border.all(color: const Color(0xFFE8EDEF)),
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
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: sel ? const Color(0xFFE0F7FA) : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(children: [
                                      Icon(icon, size: 20,
                                          color: sel ? const Color(0xFF00BCD4) : const Color(0xFF8B99A6)),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(label,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                                              color: sel ? const Color(0xFF006994) : const Color(0xFF8B99A6),
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
            }),
            const SpoonyFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_tab) {
      case 0: return const _BookingsTab();
      case 1: return const _ManageSpotsTab();
      case 2: return const _ManageHotelsTab();
      case 3: return const _ManageTransportTab();
      case 4: return const _AddSpotTab();
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
      final result = await ApiService.getAllBookings();
      setState(() {
        _bookings = (result['bookings'] as List).cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _approve(String id) async {
    try {
      await ApiService.approveBooking(id);
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _reject(String id) async {
    try {
      await ApiService.rejectBooking(id);
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
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF006994))),
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
    required this.label,
    required this.count,
    required this.color,
    required this.selected,
    required this.onTap,
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
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF006994))),
            const Spacer(),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(amount,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF50C878))),
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
            Expanded(child: _InfoRow(icon: Icons.calendar_today, label: 'Dates', value: '$startDate → $endDate')),
            Expanded(child: _InfoRow(icon: Icons.hotel, label: 'Accommodation', value: accLabel)),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _InfoRow(icon: Icons.directions_car, label: 'Transport', value: transLabel)),
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
          Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF8B99A6), fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(fontSize: 13, color: Color(0xFF00314F), fontWeight: FontWeight.w500)),
        ]),
      ),
    ]);
  }
}

// ── Tab: Manage Spots ─────────────────────────────────────────────────────────

class _ManageSpotsTab extends StatefulWidget {
  const _ManageSpotsTab();

  @override
  State<_ManageSpotsTab> createState() => _ManageSpotsTabState();
}

class _ManageSpotsTabState extends State<_ManageSpotsTab> {
  bool _loading = true;
  List<Map<String, dynamic>> _spots = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final result = await ApiService.getAllDestinations();
      setState(() {
        _spots = (result['destinations'] as List).cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _toggleAvailability(Map<String, dynamic> spot) async {
    final current = spot['is_available'] as bool? ?? true;
    try {
      await ApiService.updateDestination(spot['id'] as String, {'isAvailable': !current});
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showEditPrice(Map<String, dynamic> spot) {
    final ctrl = TextEditingController(
        text: (spot['entrance_fee'] as num?)?.toStringAsFixed(0) ?? '0');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit Price — ${spot['name']}'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Entrance Fee (₱)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final fee = double.tryParse(ctrl.text);
              if (fee == null) return;
              Navigator.pop(context);
              try {
                await ApiService.updateDestination(spot['id'] as String, {'entranceFee': fee});
                _load();
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
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
            const Text('Manage Spots',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF006994))),
            IconButton(onPressed: _load, icon: const Icon(Icons.refresh, color: Color(0xFF00BCD4))),
          ],
        ),
        const SizedBox(height: 4),
        const Text('Edit prices and toggle spot availability.',
            style: TextStyle(fontSize: 14, color: Color(0xFF8B99A6))),
        const SizedBox(height: 20),
        if (_loading)
          const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
        else if (_error != null)
          _AdminEmpty(message: _error!)
        else if (_spots.isEmpty)
          const _AdminEmpty(message: 'No destinations yet. Use "Add Spot" to create one.')
        else
          for (final s in _spots) _SpotRow(spot: s, onToggle: _toggleAvailability, onEditPrice: _showEditPrice),
      ],
    );
  }
}

class _SpotRow extends StatelessWidget {
  final Map<String, dynamic> spot;
  final Future<void> Function(Map<String, dynamic>) onToggle;
  final void Function(Map<String, dynamic>) onEditPrice;

  const _SpotRow({required this.spot, required this.onToggle, required this.onEditPrice});

  @override
  Widget build(BuildContext context) {
    final available = spot['is_available'] as bool? ?? true;
    final fee = (spot['entrance_fee'] as num?)?.toStringAsFixed(0) ?? '0';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE8EDEF)),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFE0F7FA),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.location_on, color: Color(0xFF006994), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(spot['name'] as String? ?? '—',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF00314F))),
            const SizedBox(height: 2),
            Text('${spot['region'] ?? ''} · ₱$fee entrance',
                style: const TextStyle(fontSize: 12, color: Color(0xFF8B99A6))),
          ]),
        ),
        TextButton.icon(
          onPressed: () => onEditPrice(spot),
          icon: const Icon(Icons.edit, size: 16),
          label: const Text('Price'),
          style: TextButton.styleFrom(foregroundColor: const Color(0xFF006994)),
        ),
        const SizedBox(width: 4),
        Switch(
          value: available,
          onChanged: (_) => onToggle(spot),
          activeThumbColor: const Color(0xFF00BCD4),
        ),
        Text(available ? 'Available' : 'Hidden',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: available ? const Color(0xFF50C878) : const Color(0xFFFF6B4A),
            )),
      ]),
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
  void initState() {
    super.initState();
    _load();
  }

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
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF00314F))),
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
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF50C878))),
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
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: (hotel['is_active'] as bool? ?? true)
                            ? const Color(0xFF50C878)
                            : const Color(0xFFFF6B4A),
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
  void initState() {
    super.initState();
    _load();
  }

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
                    color: const Color(0xFF006994),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(t['title'] as String? ?? '—',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF00314F))),
                    const SizedBox(height: 4),
                    Text(t['description'] as String? ?? '',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF8B99A6)),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Text('₱${(t['price'] as num?)?.toStringAsFixed(0) ?? '0'} per trip',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF50C878))),
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
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: (t['is_active'] as bool? ?? true)
                            ? const Color(0xFF50C878)
                            : const Color(0xFFFF6B4A),
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

// ── Tab: Add Spot ─────────────────────────────────────────────────────────────

class _AddSpotTab extends StatefulWidget {
  const _AddSpotTab();

  @override
  State<_AddSpotTab> createState() => _AddSpotTabState();
}

class _AddSpotTabState extends State<_AddSpotTab> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _feeCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();
  final _imgCtrl = TextEditingController();
  String _region = 'south_cebu';
  bool _saving = false;
  String? _success;
  String? _error;

  static const _regions = [
    ('cebu_city', 'Cebu City'),
    ('south_cebu', 'South Cebu'),
    ('north_cebu', 'North Cebu'),
    ('islands', 'Islands'),
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _feeCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    _imgCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty || _feeCtrl.text.isEmpty) {
      setState(() => _error = 'Name and entrance fee are required.');
      return;
    }
    setState(() { _saving = true; _error = null; _success = null; });
    try {
      await ApiService.addDestination({
        'name': _nameCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'region': _region,
        'entranceFee': double.tryParse(_feeCtrl.text) ?? 0,
        'latitude': double.tryParse(_latCtrl.text) ?? 10.3157,
        'longitude': double.tryParse(_lngCtrl.text) ?? 123.8854,
        'imageUrls': _imgCtrl.text.trim().isNotEmpty ? [_imgCtrl.text.trim()] : [],
      });
      setState(() {
        _saving = false;
        _success = 'Spot "${_nameCtrl.text.trim()}" added successfully!';
        _nameCtrl.clear(); _descCtrl.clear(); _feeCtrl.clear();
        _latCtrl.clear(); _lngCtrl.clear(); _imgCtrl.clear();
      });
    } catch (e) {
      setState(() { _saving = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Add New Spot',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF006994))),
        const SizedBox(height: 4),
        const Text('Add a new destination to the platform.',
            style: TextStyle(fontSize: 14, color: Color(0xFF8B99A6))),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE8EDEF)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_success != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF50C878).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(children: [
                    const Icon(Icons.check_circle, color: Color(0xFF50C878), size: 18),
                    const SizedBox(width: 8),
                    Text(_success!, style: const TextStyle(color: Color(0xFF50C878), fontWeight: FontWeight.w600)),
                  ]),
                ),
                const SizedBox(height: 16),
              ],
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B4A).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(children: [
                    const Icon(Icons.error_outline, color: Color(0xFFFF6B4A), size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_error!, style: const TextStyle(color: Color(0xFFFF6B4A)))),
                  ]),
                ),
                const SizedBox(height: 16),
              ],
              _FormField(label: 'Spot Name *', controller: _nameCtrl, hint: 'e.g. Kawasan Falls'),
              const SizedBox(height: 16),
              _FormField(label: 'Description', controller: _descCtrl, hint: 'Brief description of the spot', maxLines: 3),
              const SizedBox(height: 16),
              const Text('Region *',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF5D6D7A))),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _region,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
                items: _regions.map((r) => DropdownMenuItem(value: r.$1, child: Text(r.$2))).toList(),
                onChanged: (v) { if (v != null) setState(() => _region = v); },
              ),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: _FormField(
                    label: 'Entrance Fee (₱) *', controller: _feeCtrl,
                    hint: '0', keyboardType: TextInputType.number)),
                const SizedBox(width: 16),
                Expanded(child: _FormField(
                    label: 'Latitude', controller: _latCtrl,
                    hint: '10.3157', keyboardType: TextInputType.number)),
                const SizedBox(width: 16),
                Expanded(child: _FormField(
                    label: 'Longitude', controller: _lngCtrl,
                    hint: '123.8854', keyboardType: TextInputType.number)),
              ]),
              const SizedBox(height: 16),
              _FormField(label: 'Image URL', controller: _imgCtrl, hint: 'https://...'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(height: 16, width: 16,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.add_location_alt),
                  label: Text(_saving ? 'Saving…' : 'Add Spot',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF006994),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType keyboardType;

  const _FormField({
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
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF5D6D7A))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
