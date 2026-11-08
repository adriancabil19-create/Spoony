import 'package:flutter/material.dart';
import '../widgets/safe_image.dart';
import '../widgets/wm_ui.dart';
import '../widgets/media_dialogs.dart';
import '../data/media_data.dart';
import '../data/privacy_images.dart';
import '../data/video_data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/cebu_data.dart';
import 'home_screen.dart';

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
    (Icons.list_alt_rounded, 'Bookings'),
    (Icons.location_on_rounded, 'Manage Spots'),
    (Icons.hotel_rounded, 'Manage Hotels'),
    (Icons.tour_rounded, 'Manage Packages'),
    (Icons.directions_car_rounded, 'Manage Transport'),
    (Icons.drive_eta_rounded, 'Manage Drivers'),
    (Icons.perm_media_rounded, 'Media & Credits'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Wm.surface,
      body: LayoutBuilder(
        builder: (context, viewConstraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header
              const SpoonyNavBar(current: 'admin'),

              // ── Body
              Expanded(
                child: LayoutBuilder(
                  builder: (ctx, constraints) {
                    final mobile = constraints.maxWidth < 700;
                    if (mobile) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: WmContinuousTabs(
                                labels: [for (final t in _tabs) t.$2.replaceFirst('Manage ', '')],
                                selected: _tab,
                                onChanged: (i) => setState(() => _tab = i),
                              ),
                            ),
                            const SizedBox(height: 20),
                            WmBlurIn(key: ValueKey('m$_tab'), child: _buildContent()),
                          ],
                        ),
                      );
                    }

                    // Desktop layout
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 230,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: Wm.card(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.fromLTRB(10, 6, 10, 12),
                                    child: Text('ADMIN',
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 2,
                                            color: Wm.muted)),
                                  ),
                                  ...List.generate(_tabs.length, (i) {
                                    final (icon, label) = _tabs[i];
                                    return _AdminNavItem(
                                      icon: icon,
                                      label: label,
                                      selected: _tab == i,
                                      onTap: () => setState(() => _tab = i),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 32),
                          Expanded(
                            child: SingleChildScrollView(
                              child: WmBlurIn(key: ValueKey('d$_tab'), child: _buildContent()),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // ── Footer
              Container(
                color: const Color(0xFF0F172A),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                child: const Center(
                  child: Text(
                    '© 2026 Spoony Travel and Tours. All rights reserved.',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    switch (_tab) {
      case 0:
        return const _BookingsTab();
      case 1:
        return const _ManageSpotsTab();
      case 2:
        return const _ManageHotelsTab();
      case 3:
        return const _ManagePackagesTab();
      case 4:
        return const _ManageTransportTab();
      case 5:
        return const _ManageDriversTab();
      case 6:
        return const _MediaTab();
      default:
        return const _BookingsTab();
    }
  }
}

/// Watermelon-style side-nav item: rounded pill, dark active pill with accent icon dot.
class _AdminNavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _AdminNavItem({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  State<_AdminNavItem> createState() => _AdminNavItemState();
}

class _AdminNavItemState extends State<_AdminNavItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final sel = widget.selected;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: WmPressable(
          onTap: widget.onTap,
          pressScale: 0.97,
          child: AnimatedContainer(
            duration: Wm.fast,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: sel ? Wm.activePill : (_hover ? Wm.chip : Colors.transparent),
              borderRadius: BorderRadius.circular(999),
              boxShadow: sel ? Wm.shadow(0.4) : const [],
            ),
            child: Row(children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: sel ? Wm.accent : Colors.white,
                  shape: BoxShape.circle,
                  border: sel ? null : Border.all(color: Wm.border),
                ),
                child: Icon(widget.icon, size: 15, color: sel ? Colors.white : Wm.muted),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(widget.label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                      color: sel ? Colors.white : Wm.inkSoft,
                    )),
              ),
            ]),
          ),
        ),
      ),
    );
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
  List<Map<String, dynamic>> _drivers = [];
  String? _error;
  String _filter = 'all';
  String _searchQuery = '';
  DateTime? _filterDate;
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        Supabase.instance.client
            .from('bookings')
            .select()
            .order('created_at', ascending: false),
        Supabase.instance.client.from('drivers').select().order('full_name'),
      ]);
      setState(() {
        _bookings = (results[0] as List).cast<Map<String, dynamic>>();
        _drivers = (results[1] as List).cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _approve(String id) async {
    try {
      await Supabase.instance.client
          .from('bookings')
          .update({
            'status': 'confirmed',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .eq('status', 'pending');
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _reject(String id) async {
    try {
      await Supabase.instance.client
          .from('bookings')
          .update({
            'status': 'cancelled',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  List<Map<String, dynamic>> get _filtered {
    var list = _filter == 'all'
        ? _bookings
        : _bookings
              .where((b) => (b['status'] as String? ?? '') == _filter)
              .toList();

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((b) {
        final ref = (b['reference_code'] as String? ?? '').toLowerCase();
        final email = (b['user_email'] as String? ?? '').toLowerCase();
        return ref.contains(q) || email.contains(q);
      }).toList();
    }

    if (_filterDate != null) {
      final d = _filterDate!;
      final ds =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      list = list.where((b) {
        final start = (b['start_date'] as String? ?? '').split('T').first;
        return start == ds;
      }).toList();
    }

    return list;
  }

  int _count(String status) =>
      _bookings.where((b) => b['status'] == status).length;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'All Bookings',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Wm.ink,
                ),
              ),
              IconButton(
                onPressed: _load,
                icon: const Icon(Icons.refresh, color: Wm.accent),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Manage and approve guest bookings.',
            style: TextStyle(fontSize: 14, color: Wm.muted),
          ),
          const SizedBox(height: 16),
          // Search bar
          TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: 'Search by reference no. or email…',
              hintStyle: const TextStyle(
                color: Color(0xFFB0BEC5),
                fontSize: 13,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: Wm.accent,
                size: 20,
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.close,
                        size: 18,
                        color: Wm.muted,
                      ),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Wm.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Wm.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Wm.accent,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Date filter + status chips row
          Row(
            children: [
              // Date picker button
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _filterDate ?? DateTime.now(),
                    firstDate: DateTime(2024),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) setState(() => _filterDate = picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _filterDate != null
                        ? const Color(0xFFFDF0E7)
                        : Colors.white,
                    border: Border.all(
                      color: _filterDate != null
                          ? Wm.accent
                          : Wm.border,
                      width: _filterDate != null ? 1.5 : 1,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: _filterDate != null
                            ? const Color(0xFFC2571F)
                            : Wm.muted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _filterDate != null
                            ? '${_filterDate!.year}-${_filterDate!.month.toString().padLeft(2, '0')}-${_filterDate!.day.toString().padLeft(2, '0')}'
                            : 'Filter by date',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: _filterDate != null
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: _filterDate != null
                              ? const Color(0xFFC2571F)
                              : Wm.muted,
                        ),
                      ),
                      if (_filterDate != null) ...[
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => setState(() => _filterDate = null),
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: Color(0xFFC2571F),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Status chips
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'All',
                        count: _bookings.length,
                        color: const Color(0xFFC2571F),
                        selected: _filter == 'all',
                        onTap: () => setState(() => _filter = 'all'),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Pending',
                        count: _count('pending'),
                        color: const Color(0xFFFFC107),
                        selected: _filter == 'pending',
                        onTap: () => setState(() => _filter = 'pending'),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Confirmed',
                        count: _count('confirmed'),
                        color: const Color(0xFF50C878),
                        selected: _filter == 'confirmed',
                        onTap: () => setState(() => _filter = 'confirmed'),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Completed',
                        count: _count('completed'),
                        color: const Color(0xFFD96A2B),
                        selected: _filter == 'completed',
                        onTap: () => setState(() => _filter = 'completed'),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Cancelled',
                        count: _count('cancelled'),
                        color: const Color(0xFFFF6B4A),
                        selected: _filter == 'cancelled',
                        onTap: () => setState(() => _filter = 'cancelled'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_error != null)
            _AdminEmpty(message: _error!)
          else if (_filtered.isEmpty)
            _AdminEmpty(
              message: _searchQuery.isNotEmpty || _filterDate != null
                  ? 'No bookings match your filters.'
                  : _filter == 'all'
                  ? 'No bookings yet.'
                  : 'No $_filter bookings.',
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filtered.length,
              itemBuilder: (_, i) => _BookingRow(
                booking: _filtered[i],
                drivers: _drivers,
                onApprove: _approve,
                onReject: _reject,
                onRefresh: _load,
              ),
            ),
        ],
      ),
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
            color: selected ? color : Wm.border,
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? color : Wm.muted,
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingRow extends StatefulWidget {
  final Map<String, dynamic> booking;
  final List<Map<String, dynamic>> drivers;
  final Future<void> Function(String) onApprove;
  final Future<void> Function(String) onReject;
  final Future<void> Function() onRefresh;

  const _BookingRow({
    required this.booking,
    required this.drivers,
    required this.onApprove,
    required this.onReject,
    required this.onRefresh,
  });

  @override
  State<_BookingRow> createState() => _BookingRowState();
}

class _BookingRowState extends State<_BookingRow> {
  bool _assigningDriver = false;

  Future<void> _assignDriver(String bookingId, String? driverId) async {
    setState(() => _assigningDriver = true);
    try {
      await Supabase.instance.client
          .from('bookings')
          .update({'driver_id': driverId})
          .eq('id', bookingId);

      if (driverId != null) {
        final driver = widget.drivers
            .where((d) => d['id'] == driverId)
            .firstOrNull;
        if (driver != null) {
          final b = widget.booking;
          try {
            await Supabase.instance.client.functions.invoke(
              'notify-driver',
              body: {
                'driverEmail': driver['email'],
                'driverName': driver['full_name'],
                'reference': b['reference_code'],
                'guestEmail': b['user_email'] ?? '',
                'startDate': (b['start_date'] as String? ?? '')
                    .split('T')
                    .first,
                'endDate': (b['end_date'] as String? ?? '').split('T').first,
                'itinerary': b['itinerary'] ?? '',
                'tourType': b['tour_type'] ?? '',
                'guestCount': b['guest_count'] ?? 0,
              },
            );
          } catch (_) {}
        }
      }

      await widget.onRefresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              driverId == null
                  ? 'Driver unassigned.'
                  : 'Driver assigned. Notification sent.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _assigningDriver = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final status = (booking['status'] as String? ?? 'pending').toLowerCase();
    final Color statusColor;
    switch (status) {
      case 'confirmed':
        statusColor = const Color(0xFF50C878);
        break;
      case 'completed':
        statusColor = const Color(0xFFD96A2B);
        break;
      case 'cancelled':
        statusColor = const Color(0xFFFF6B4A);
        break;
      default:
        statusColor = const Color(0xFFFFC107);
    }

    final ref = booking['reference_code'] as String? ?? '—';
    final email = booking['user_email'] as String? ?? '—';
    final startDate = (booking['start_date'] as String? ?? '').replaceAll(
      'T00:00:00.000Z',
      '',
    );
    final endDate = (booking['end_date'] as String? ?? '').replaceAll(
      'T00:00:00.000Z',
      '',
    );
    final guests = booking['guest_count'] as int? ?? 0;
    final amount = booking['total_amount'] != null
        ? '₱${(booking['total_amount'] as num).toStringAsFixed(0)}'
        : '—';
    final id = booking['id'] as String;
    final accType = booking['accommodation_type'] as String? ?? '';
    final transType = booking['transport_type'] as String? ?? '';
    final tourType = booking['tour_type'] as String? ?? '';
    final accLabel =
        _accLabels[accType] ?? (accType.isNotEmpty ? accType : '—');
    final transLabel =
        _transLabels[transType] ?? (transType.isNotEmpty ? transType : '—');
    final createdAt = (booking['created_at'] as String? ?? '').split('T').first;
    final currentDriverId = booking['driver_id'] as String?;
    final currentDriver = widget.drivers
        .where((d) => d['id'] == currentDriverId)
        .firstOrNull;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Wm.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                ref,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFC2571F),
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amount,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF50C878),
                    ),
                  ),
                  if (createdAt.isNotEmpty)
                    Text(
                      'Booked $createdAt',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Wm.muted,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF0F4F5)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _InfoRow(
                  icon: Icons.email_outlined,
                  label: 'Guest',
                  value: email,
                ),
              ),
              Expanded(
                child: _InfoRow(
                  icon: Icons.people,
                  label: 'Guests',
                  value: '$guests person(s)',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _InfoRow(
                  icon: Icons.calendar_today,
                  label: 'Dates',
                  value: '$startDate → $endDate',
                ),
              ),
              Expanded(
                child: _InfoRow(
                  icon: Icons.hotel,
                  label: 'Accommodation',
                  value: accLabel,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _InfoRow(
                  icon: Icons.directions_car,
                  label: 'Transport',
                  value: transLabel,
                ),
              ),
              if (tourType.isNotEmpty)
                Expanded(
                  child: _InfoRow(
                    icon: Icons.tour,
                    label: 'Tour Package',
                    value: tourType,
                  ),
                ),
            ],
          ),

          // ── Assign driver (confirmed = editable, completed = read-only, pending = hidden) ──
          if (status == 'confirmed') ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF0F4F5)),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.drive_eta, size: 14, color: Wm.muted),
                const SizedBox(width: 6),
                const Text(
                  'Assigned Driver',
                  style: TextStyle(
                    fontSize: 11,
                    color: Wm.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (widget.drivers.isEmpty)
              const Text(
                'No drivers yet — add one in Manage Drivers.',
                style: TextStyle(fontSize: 12, color: Wm.muted),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String?>(
                      initialValue: currentDriverId,
                      decoration: const InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Color(0xFFD96A2B)),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      hint: const Text(
                        'Unassigned',
                        style: TextStyle(
                          fontSize: 13,
                          color: Wm.muted,
                        ),
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text(
                            'Unassigned',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                        ...widget.drivers.map(
                          (d) => DropdownMenuItem<String?>(
                            value: d['id'] as String,
                            child: Text(
                              '${d['full_name']} · ${d['vehicle_type']}',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ),
                      ],
                      onChanged: _assigningDriver
                          ? null
                          : (v) => _assignDriver(id, v),
                    ),
                  ),
                  if (_assigningDriver) ...[
                    const SizedBox(width: 10),
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFFD96A2B),
                      ),
                    ),
                  ],
                ],
              ),
            if (currentDriver != null) ...[
              const SizedBox(height: 4),
              Text(
                '${currentDriver['full_name']} · ${currentDriver['phone'] ?? ''}',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF50C878),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ] else if (status == 'completed' && currentDriver != null) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF0F4F5)),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.drive_eta, size: 14, color: Wm.muted),
                const SizedBox(width: 6),
                const Text(
                  'Assigned Driver',
                  style: TextStyle(
                    fontSize: 11,
                    color: Wm.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person, size: 14, color: Wm.muted),
                  const SizedBox(width: 8),
                  Text(
                    '${currentDriver['full_name']} · ${currentDriver['phone'] ?? ''}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (status == 'pending') ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => widget.onApprove(id),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text(
                      'Approve',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF50C878),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: const StadiumBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => widget.onReject(id),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text(
                      'Reject',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFFF6B4A)),
                      foregroundColor: const Color(0xFFFF6B4A),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: const StadiumBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ] else if (status == 'confirmed') ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => widget.onReject(id),
                icon: const Icon(Icons.cancel_outlined, size: 16),
                label: const Text('Cancel Booking'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFF6B4A)),
                  foregroundColor: const Color(0xFFFF6B4A),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: const StadiumBorder(),
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

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: Wm.muted),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: Wm.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
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
  String _query = '';

  static const _regions = [
    ('cebu_city', 'Cebu City'),
    ('south_cebu', 'South Cebu'),
    ('north_cebu', 'North Cebu'),
    ('bohol', 'Bohol'),
  ];

  /// Normalises DB snake_case and built-in enum names to one key per region.
  static String _normRegion(String? r) => switch (r) {
        'cebuCity' || 'cebu_city' => 'cebu_city',
        'southCebu' || 'south_cebu' => 'south_cebu',
        'northCebu' || 'north_cebu' => 'north_cebu',
        'bohol' || 'islands' => 'bohol',
        _ => r ?? 'other',
      };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await Supabase.instance.client
          .from('destinations')
          .select()
          .order('rating', ascending: false);
      final dbSpots = (data as List).cast<Map<String, dynamic>>();
      setState(() {
        _spots = dbSpots;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  // ── Merge: show cebu_data defaults not already in DB (matched by name) ──────
  List<Map<String, dynamic>> get _mergedSpots {
    final dbNames = _spots
        .map((s) => (s['name'] as String).toLowerCase())
        .toSet();
    final defaults = cebuDestinations
        .where((d) => !dbNames.contains(d.name.toLowerCase()))
        .map(
          (d) => {
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
          },
        )
        .toList();
    return [..._spots, ...defaults];
  }

  Future<void> _toggleAvailability(Map<String, dynamic> spot) async {
    if (spot['_isDefault'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Save this spot to the database first to manage it.'),
        ),
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
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showAddDialog() => _showSpotDialog(null);

  void _showEditDialog(Map<String, dynamic> spot) => _showSpotDialog(spot);

  void _showSpotDialog(Map<String, dynamic>? existing) {
    final isDefault = existing?['_isDefault'] == true;
    final isEdit = existing != null && !isDefault;

    final nameCtrl = TextEditingController(
      text: existing?['name'] as String? ?? '',
    );
    final descCtrl = TextEditingController(
      text: existing?['description'] as String? ?? '',
    );
    final feeCtrl = TextEditingController(
      text: (existing?['entrance_fee'] as num?)?.toStringAsFixed(0) ?? '',
    );
    final imgCtrl = TextEditingController(
      text: (existing?['image_urls'] as List?)?.isNotEmpty == true
          ? (existing!['image_urls'] as List).first as String
          : '',
    );

    String region = _normRegion(existing?['region'] as String? ?? 'south_cebu');
    bool saving = false;
    String? errorMsg;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => _ModernDialog(
          title: isEdit
              ? 'Edit Spot'
              : (isDefault ? 'Save to Database' : 'Add New Spot'),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isDefault) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFBBF24)),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Color(0xFFD97706),
                      ),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Built-in spot — saving will add it to your database.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF92400E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (errorMsg != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 16,
                        color: Color(0xFFEF4444),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          errorMsg!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFB91C1C),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              _DlgField(
                label: 'SPOT NAME *',
                controller: nameCtrl,
                hint: 'e.g. Kawasan Falls',
              ),
              const SizedBox(height: 14),
              _DlgField(
                label: 'DESCRIPTION',
                controller: descCtrl,
                hint: 'Brief description of the spot',
                maxLines: 3,
              ),
              const SizedBox(height: 14),
              const Text(
                'REGION *',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _regions.any((r) => r.$1 == region)
                    ? region
                    : _regions.first.$1,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFFD96A2B),
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                ),
                items: _regions
                    .map(
                      (r) => DropdownMenuItem(value: r.$1, child: Text(r.$2)),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) setDlg(() => region = v);
                },
              ),
              const SizedBox(height: 14),
              _DlgField(
                label: 'ENTRANCE FEE (₱) *',
                controller: feeCtrl,
                hint: '0',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 14),
              _DlgField(
                label: 'IMAGE URL',
                controller: imgCtrl,
                hint: 'https://example.com/image.jpg',
              ),
              if (imgCtrl.text.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SafeImage(
                    imgCtrl.text.trim(),
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    showCredit: true,
                    errorBuilder: (_, _, _) => Container(
                      height: 140,
                      color: Wm.chip,
                      child: const Center(
                        child: Icon(Icons.broken_image_outlined, color: Wm.muted),
                      ),
                    ),
                  ),
                ),
                if (privacyImages.containsKey(imgCtrl.text.trim())) ...[
                  const SizedBox(height: 6),
                  const Text(
                    'Shown to visitors with faces / plate numbers blurred. Keep the original URL.',
                    style: TextStyle(fontSize: 11, color: Wm.muted),
                  ),
                ],
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF64748B),
              ),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: saving
                  ? null
                  : () async {
                      if (nameCtrl.text.trim().isEmpty ||
                          feeCtrl.text.isEmpty) {
                        setDlg(
                          () => errorMsg =
                              'Spot name and entrance fee are required.',
                        );
                        return;
                      }
                      setDlg(() {
                        saving = true;
                        errorMsg = null;
                      });
                      try {
                        final payload = {
                          'name': nameCtrl.text.trim(),
                          'description': descCtrl.text.trim(),
                          'region': region,
                          'entrance_fee': double.tryParse(feeCtrl.text) ?? 0,
                          'image_urls': imgCtrl.text.trim().isNotEmpty
                              ? [imgCtrl.text.trim()]
                              : [],
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
                        setDlg(() {
                          saving = false;
                          errorMsg = e.toString();
                        });
                      }
                    },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFD96A2B),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: const StadiumBorder(),
              ),
              child: saving
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
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
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B4A),
            ),
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
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  static const _regionOrder = ['cebu_city', 'south_cebu', 'north_cebu', 'bohol'];

  static const _regionLabels = <String, String>{
    'cebu_city': 'Cebu City',
    'south_cebu': 'South Cebu',
    'north_cebu': 'North Cebu',
    'bohol': 'Bohol',
  };

  static String regionLabel(String? raw) => _regionLabels[_normRegion(raw)] ?? raw ?? '';

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final all = _mergedSpots
        .where((s) =>
            q.isEmpty ||
            (s['name'] as String? ?? '').toLowerCase().contains(q) ||
            regionLabel(s['region'] as String?).toLowerCase().contains(q))
        .toList();
    final total = _mergedSpots.length;

    // Group spots by (normalised) region in display order
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final s in all) {
      grouped.putIfAbsent(_normRegion(s['region'] as String?), () => []).add(s);
    }
    final orderedKeys = [
      ..._regionOrder.where(grouped.containsKey),
      ...grouped.keys.where((k) => !_regionOrder.contains(k)),
    ];

    final spotWidgets = <Widget>[];
    for (final key in orderedKeys) {
      final spots = grouped[key]!;
      spotWidgets.add(
        _SpotRegionHeader(
          label: _regionLabels[key] ?? key,
          count: spots.length,
        ),
      );
      for (final s in spots) {
        spotWidgets.add(
          _SpotRow(
            spot: s,
            onEdit: () => _showEditDialog(s),
            onToggle: () => _toggleAvailability(s),
            onDelete: s['_isDefault'] == true ? null : () => _deleteSpot(s),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 10,
          children: [
            const _AdminTitle('Manage Spots'),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Refresh',
                  onPressed: _load,
                  icon: const Icon(Icons.refresh_rounded, color: Wm.accent),
                ),
                WmShimmerButton(
                  label: 'Add Spot',
                  icon: Icons.add_rounded,
                  onTap: _showAddDialog,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '$total destinations · edit, add, or toggle visibility. Built-in spots can be saved to the database.',
          style: const TextStyle(fontSize: 14, color: Wm.muted),
        ),
        const SizedBox(height: 16),
        _AdminSearchField(
          hint: 'Search spots or regions…',
          onChanged: (v) => setState(() => _query = v),
        ),
        const SizedBox(height: 8),
        if (_loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_error != null)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFFB74D)),
            ),
            child: const Row(
              children: [
                Icon(Icons.wifi_off, size: 16, color: Color(0xFFF57C00)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Could not reach Supabase — showing built-in destinations. Check your Supabase connection.',
                    style: TextStyle(fontSize: 12, color: Color(0xFFF57C00)),
                  ),
                ),
              ],
            ),
          )
        else if (all.isEmpty)
          _AdminEmpty(
            message: q.isEmpty
                ? 'No spots yet. Click "Add Spot" to create one.'
                : 'No spots match "$_query".',
          )
        else
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: spotWidgets),
      ],
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
    final feeNum = (spot['entrance_fee'] as num?) ?? 0;
    final fee = feeNum == 0 ? 'Free entrance' : '₱${feeNum.toStringAsFixed(0)} entrance';
    final isDefault = spot['_isDefault'] == true;
    final urls = (spot['image_urls'] as List?)?.cast<String>() ?? const <String>[];
    final img = urls.isNotEmpty ? urls.first : null;
    final blurred = img != null && privacyImages.containsKey(img);
    final region = _ManageSpotsTabState.regionLabel(spot['region'] as String?);

    final thumb = ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: 64,
        height: 64,
        child: img == null
            ? Container(
                color: Wm.chip,
                child: const Icon(Icons.location_on_rounded, color: Wm.accent, size: 22),
              )
            : Stack(fit: StackFit.expand, children: [
                SafeImage(
                  img,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: Wm.chip,
                    child: const Icon(Icons.image_not_supported_outlined, color: Wm.muted, size: 20),
                  ),
                ),
                if (blurred)
                  Positioned(
                    right: 3,
                    bottom: 3,
                    child: Tooltip(
                      message: 'Visitors see a privacy-blurred copy',
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                        child: const Icon(Icons.blur_on_rounded, size: 12, color: Colors.white),
                      ),
                    ),
                  ),
              ]),
      ),
    );

    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            Text(
              spot['name'] as String? ?? '—',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Wm.ink),
            ),
            if (isDefault) const _Pill(label: 'Built-in', color: Color(0xFFB45309), bg: Color(0xFFFFF4E0)),
            if (!isDefault && !available)
              const _Pill(label: 'Hidden', color: Color(0xFFB91C1C), bg: Color(0xFFFEF2F2)),
          ],
        ),
        const SizedBox(height: 3),
        Text('$region · $fee', style: const TextStyle(fontSize: 12, color: Wm.muted)),
      ],
    );

    final actions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton.icon(
          onPressed: onEdit,
          icon: Icon(isDefault ? Icons.cloud_upload_outlined : Icons.edit_outlined, size: 15),
          label: Text(isDefault ? 'Save to DB' : 'Edit'),
          style: TextButton.styleFrom(
            foregroundColor: isDefault ? const Color(0xFFB45309) : Wm.accent,
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
        if (!isDefault) ...[
          Tooltip(
            message: available ? 'Visible to visitors' : 'Hidden from visitors',
            child: Switch(
              value: available,
              onChanged: (_) => onToggle(),
              activeThumbColor: Colors.white,
              activeTrackColor: Wm.accent,
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded, size: 19, color: Color(0xFFE11D48)),
            tooltip: 'Delete spot',
          ),
        ],
      ],
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Wm.rCard),
        border: Border.all(color: isDefault ? const Color(0xFFFCE3C4) : Wm.border),
        boxShadow: Wm.shadow(),
      ),
      child: LayoutBuilder(builder: (context, c) {
        if (c.maxWidth < 520) {
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              thumb,
              const SizedBox(width: 12),
              Expanded(child: info),
            ]),
            const SizedBox(height: 4),
            Align(alignment: Alignment.centerRight, child: actions),
          ]);
        }
        return Row(children: [
          thumb,
          const SizedBox(width: 14),
          Expanded(child: info),
          actions,
        ]);
      }),
    );
  }
}

// ── Shared admin UI bits (Watermelon style) ──────────────────────────────────

class _AdminTitle extends StatelessWidget {
  final String text;
  const _AdminTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Wm.ink, letterSpacing: -0.3),
      );
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;
  const _Pill({required this.label, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
        child: Text(label, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: color)),
      );
}

class _AdminSearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  const _AdminSearchField({required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder b(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: c, width: w),
        );
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Wm.muted, fontSize: 14),
        prefixIcon: const Icon(Icons.search_rounded, color: Wm.muted),
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: b(Wm.border),
        enabledBorder: b(Wm.border),
        focusedBorder: b(Wm.accent, 1.6),
      ),
    );
  }
}

class _SpotRegionHeader extends StatelessWidget {
  final String label;
  final int count;
  const _SpotRegionHeader({required this.label, required this.count});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(2, 14, 0, 8),
        child: Row(children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Wm.ink)),
          const SizedBox(width: 8),
          _Pill(label: '$count', color: Colors.white, bg: Wm.activePill),
          const SizedBox(width: 10),
          const Expanded(child: Divider(color: Wm.border, thickness: 1)),
        ]),
      );
}

// ── Tab: Media & Credits (read-only overview of site media) ──────────────────

class _MediaTab extends StatelessWidget {
  const _MediaTab();

  static String _thumbFor(String url) {
    final blurred = privacyImages[url];
    if (blurred != null) return blurred;
    return url.replaceFirst('/3840px-', '/960px-');
  }

  static String _fmt(int s) => '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';

  Widget _section(String title, String subtitle) => Padding(
        padding: const EdgeInsets.only(top: 28, bottom: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Wm.ink)),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 13, color: Wm.muted)),
        ]),
      );

  Widget _img(String src, {double? height}) => src.startsWith('assets/')
      ? Image.asset(src, fit: BoxFit.cover, height: height, width: double.infinity)
      : Image.network(src,
          fit: BoxFit.cover,
          height: height,
          width: double.infinity,
          errorBuilder: (_, _, _) => Container(color: Wm.chip));

  @override
  Widget build(BuildContext context) {
    final editedCount = photoCredits.where((c) => c.modified).length;
    return LayoutBuilder(builder: (context, c) {
      final cols = c.maxWidth > 900 ? 3 : c.maxWidth > 560 ? 2 : 1;
      Widget grid(List<Widget> items, double ratio) => GridView.count(
            crossAxisCount: cols,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: ratio,
            children: items,
          );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _AdminTitle('Media & Credits'),
          const SizedBox(height: 4),
          Text(
            '${heroSlides.length} hero slides · ${travelVideos.length} videos · ${photoCredits.length} credited photos'
            ' · $editedCount privacy-blurred',
            style: const TextStyle(fontSize: 14, color: Wm.muted),
          ),

          // (a) Hero slides
          _section('Home hero carousel', 'Shown full-screen on the home page, in this order.'),
          grid([
            for (var i = 0; i < heroSlides.length; i++)
              _MediaCard(
                image: _img(_thumbFor(heroSlides[i].image)),
                badge: '${i + 1}',
                title: heroSlides[i].title,
                subtitle: heroSlides[i].location,
                caption: heroSlides[i].isAsset
                    ? 'Photo: Spoony Travel and Tours'
                    : (creditForUrl(heroSlides[i].image) != null
                        ? '© ${creditForUrl(heroSlides[i].image)!.author} · ${creditForUrl(heroSlides[i].image)!.license}'
                        : ''),
                blurred: privacyImages.containsKey(heroSlides[i].image),
              ),
          ], 1.15),

          // (b) Videos
          _section('Travel videos', 'Played in-app from the Videos button on the home page.'),
          if (travelVideos.isEmpty)
            const _AdminEmpty(message: 'No videos configured yet.')
          else
            grid([
              for (final v in travelVideos)
                _MediaCard(
                  image: Stack(fit: StackFit.expand, children: [
                    _img(v.posterUrl),
                    const Center(child: Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 40)),
                  ]),
                  badge: _fmt(v.durationSec),
                  title: v.title,
                  subtitle: v.place,
                  caption: '© ${v.author} · ${v.license}',
                  onTap: () => openExternal(context, v.sourceUrl),
                ),
            ], 1.15),

          // (c) Photo credits
          _section('Photo credits', 'All photos are from Wikimedia Commons under open licenses. Tap a row to open its source.'),
          Container(
            decoration: Wm.card(),
            clipBehavior: Clip.antiAlias,
            child: Column(children: [
              for (var i = 0; i < photoCredits.length; i++) ...[
                if (i > 0) const Divider(height: 1, color: Wm.border),
                _CreditRow(credit: photoCredits[i]),
              ],
            ]),
          ),
        ],
      );
    });
  }
}

class _MediaCard extends StatelessWidget {
  final Widget image;
  final String badge;
  final String title;
  final String subtitle;
  final String caption;
  final bool blurred;
  final VoidCallback? onTap;
  const _MediaCard({
    required this.image,
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.caption,
    this.blurred = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return WmPressable(
      onTap: onTap,
      pressScale: onTap == null ? 1 : 0.97,
      child: Container(
        decoration: Wm.card(),
        clipBehavior: Clip.antiAlias,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Stack(fit: StackFit.expand, children: [
              WmZoomFrame(child: image),
              Positioned(
                top: 8,
                left: 8,
                child: _Pill(label: badge, color: Colors.white, bg: Colors.black.withValues(alpha: 0.6)),
              ),
              if (blurred)
                const Positioned(
                  top: 8,
                  right: 8,
                  child: _Pill(label: 'Blurred copy', color: Colors.white, bg: Wm.accent),
                ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Wm.ink)),
              Text(subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Wm.muted)),
              if (caption.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: Wm.muted)),
              ],
            ]),
          ),
        ]),
      ),
    );
  }
}

class _CreditRow extends StatelessWidget {
  final PhotoCredit credit;
  const _CreditRow({required this.credit});

  @override
  Widget build(BuildContext context) {
    final c = credit;
    return InkWell(
      onTap: c.sourceUrl.isEmpty ? null : () => openExternal(context, c.sourceUrl),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          const Icon(Icons.photo_outlined, size: 18, color: Wm.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(c.subject,
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Wm.ink)),
              const SizedBox(height: 2),
              Wrap(spacing: 6, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
                Text('by ${c.author}', style: const TextStyle(fontSize: 12, color: Wm.muted)),
                if (c.license.isNotEmpty) _Pill(label: c.license, color: Wm.inkSoft, bg: Wm.chip),
                if (c.modified)
                  const _Pill(label: 'Edited · blurred', color: Color(0xFFB45309), bg: Color(0xFFFFF4E0)),
              ]),
            ]),
          ),
          if (c.sourceUrl.isNotEmpty) const Icon(Icons.open_in_new_rounded, size: 16, color: Wm.muted),
        ]),
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
    {
      'id': 'acc_budget',
      'title': 'Budget Stay',
      'category': 'Budget',
      'nightly_rate': 1200.0,
      'description':
          'Hostel-style rooms with local comfort and easy access to the city.',
      'is_active': true,
    },
    {
      'id': 'acc_standard',
      'title': 'Standard Hotel',
      'category': 'Standard',
      'nightly_rate': 2200.0,
      'description':
          'Modern rooms with breakfast, city views, and premium amenities.',
      'is_active': true,
    },
    {
      'id': 'acc_premium',
      'title': 'Premium Resort',
      'category': 'Premium',
      'nightly_rate': 5200.0,
      'description':
          'Luxury resort stay with pool access and curated leisure services.',
      'is_active': true,
    },
    {
      'id': 'acc_luxury',
      'title': 'Luxury Villa',
      'category': 'Luxury',
      'nightly_rate': 9800.0,
      'description':
          'Private villa experience with VIP concierge and premium comforts.',
      'is_active': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await Supabase.instance.client
          .from('accommodation_types')
          .select();
      final list = (data as List).cast<Map<String, dynamic>>();
      setState(() {
        _hotels = list.isEmpty ? List.from(_defaults) : list;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _hotels = List.from(_defaults);
        _loading = false;
      });
    }
  }

  void _showEditDialog(Map<String, dynamic> hotel) {
    final rateCtrl = TextEditingController(
      text: (hotel['nightly_rate'] as num?)?.toStringAsFixed(0) ?? '0',
    );
    bool saving = false;
    String? errorMsg;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => _ModernDialog(
          title: 'Edit Price — ${hotel['title']}',
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hotel['description'] as String? ?? '',
                style: const TextStyle(color: Wm.muted, fontSize: 13),
              ),
              const SizedBox(height: 16),
              if (errorMsg != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 16,
                        color: Color(0xFFEF4444),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          errorMsg!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFB91C1C),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              _DlgField(
                label: 'NIGHTLY RATE (₱)',
                controller: rateCtrl,
                hint: '0',
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF64748B),
              ),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: saving
                  ? null
                  : () async {
                      final rate = double.tryParse(rateCtrl.text);
                      if (rate == null) {
                        setDlg(() => errorMsg = 'Enter a valid number.');
                        return;
                      }
                      setDlg(() {
                        saving = true;
                        errorMsg = null;
                      });
                      try {
                        await Supabase.instance.client
                            .from('accommodation_types')
                            .update({'nightly_rate': rate})
                            .eq('id', hotel['id'] as String);
                        if (ctx.mounted) Navigator.pop(ctx);
                        _load();
                      } catch (e) {
                        setDlg(() {
                          saving = false;
                          errorMsg = e.toString();
                        });
                      }
                    },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFD96A2B),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: const StadiumBorder(),
              ),
              child: saving
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Save Price'),
            ),
          ],
        ),
      ),
    ).then((_) => rateCtrl.dispose());
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
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  static const _categoryColors = {
    'Budget': Color(0xFF50C878),
    'Standard': Wm.accent,
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
            const Text(
              'Manage Hotels',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Wm.ink,
              ),
            ),
            IconButton(
              onPressed: _load,
              icon: const Icon(Icons.refresh, color: Wm.accent),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Edit accommodation prices and toggle availability.',
          style: TextStyle(fontSize: 14, color: Wm.muted),
        ),
        const SizedBox(height: 20),
        if (_loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          )
        else
          for (final hotel in _hotels) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Wm.border),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color:
                          (_categoryColors[hotel['category'] as String? ??
                                      ''] ??
                                  const Color(0xFFC2571F))
                              .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.hotel,
                      color:
                          _categoryColors[hotel['category'] as String? ?? ''] ??
                          const Color(0xFFC2571F),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              hotel['title'] as String? ?? '—',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    (_categoryColors[hotel['category']
                                                    as String? ??
                                                ''] ??
                                            const Color(0xFFC2571F))
                                        .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Text(
                                hotel['category'] as String? ?? '',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color:
                                      _categoryColors[hotel['category']
                                              as String? ??
                                          ''] ??
                                      const Color(0xFFC2571F),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          hotel['description'] as String? ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Wm.muted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '₱${(hotel['nightly_rate'] as num?)?.toStringAsFixed(0) ?? '0'} / night',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF50C878),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () => _showEditDialog(hotel),
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Edit Price'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFC2571F),
                        ),
                      ),
                      Row(
                        children: [
                          Switch(
                            value: hotel['is_active'] as bool? ?? true,
                            onChanged: (_) => _toggleActive(hotel),
                            activeThumbColor: Wm.accent,
                          ),
                          Text(
                            (hotel['is_active'] as bool? ?? true)
                                ? 'Active'
                                : 'Hidden',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: (hotel['is_active'] as bool? ?? true)
                                  ? const Color(0xFF50C878)
                                  : const Color(0xFFFF6B4A),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
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
  bool _dbAvailable = true;
  List<Map<String, dynamic>> _packages = [];

  static const _regionOptions = [
    'Cebu City',
    'South Cebu',
    'North Cebu',
    'Bohol',
  ];

  static List<Map<String, dynamic>> get _defaults => tourPackages
      .map(
        (p) => {
          '_isDefault': true,
          'id': p.id,
          'name': p.name,
          'tagline': p.tagline,
          'description': p.description,
          'highlights': p.highlights,
          'region': p.region,
          'duration_days': p.durationDays,
          'joiner_price': p.joinerPricePerPerson,
          'premium_price': p.premiumPricePerPerson,
          'image_url': p.imageUrl,
          'is_active': true,
        },
      )
      .toList();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final data = await Supabase.instance.client
          .from('tour_packages')
          .select()
          .order('created_at', ascending: true);
      if (!mounted) return;
      final list = (data as List).cast<Map<String, dynamic>>();
      setState(() {
        _dbAvailable = true;
        _packages = list.isEmpty ? _defaults : list;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _dbAvailable = false;
        _packages = _defaults;
        _loading = false;
      });
    }
  }

  void _showAddDialog() => _showPackageDialog(null);
  void _showEditDialog(Map<String, dynamic> pkg) => _showPackageDialog(pkg);

  void _showPackageDialog(Map<String, dynamic>? existing) {
    final isDefault = existing?['_isDefault'] == true;
    final isEdit = existing != null && !isDefault;

    final nameCtrl = TextEditingController(
      text: existing?['name'] as String? ?? '',
    );
    final taglineCtrl = TextEditingController(
      text: existing?['tagline'] as String? ?? '',
    );
    final descCtrl = TextEditingController(
      text: existing?['description'] as String? ?? '',
    );
    final daysCtrl = TextEditingController(
      text: (existing?['duration_days'] as int?)?.toString() ?? '1',
    );
    final joinerCtrl = TextEditingController(
      text: (existing?['joiner_price'] as num?)?.toStringAsFixed(0) ?? '',
    );
    final premiumCtrl = TextEditingController(
      text: (existing?['premium_price'] as num?)?.toStringAsFixed(0) ?? '',
    );
    final imgCtrl = TextEditingController(
      text: existing?['image_url'] as String? ?? '',
    );
    final existingHighlights =
        (existing?['highlights'] as List?)?.map((h) => h.toString()).toSet() ??
        <String>{};
    var selectedSpots = Set<String>.from(existingHighlights);
    var spotQuery = '';

    String region = existing?['region'] as String? ?? _regionOptions.first;
    if (!_regionOptions.contains(region)) region = _regionOptions.first;

    bool saving = false;
    String? errorMsg;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => _ModernDialog(
          title: isEdit
              ? 'Edit Package'
              : (isDefault ? 'Save to Database' : 'Add New Package'),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isDefault) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFBBF24)),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Color(0xFFD97706),
                      ),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Built-in package — saving will add it to your database.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF92400E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (!_dbAvailable) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 16,
                        color: Color(0xFFEF4444),
                      ),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Table "tour_packages" not found. Run the SQL in supabase_tables.sql first.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFB91C1C),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (errorMsg != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 16,
                        color: Color(0xFFEF4444),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          errorMsg!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFB91C1C),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              _DlgField(
                label: 'PACKAGE NAME *',
                controller: nameCtrl,
                hint: 'e.g. South Cebu Adventure',
              ),
              const SizedBox(height: 14),
              _DlgField(
                label: 'TAGLINE',
                controller: taglineCtrl,
                hint: 'Short catchphrase',
              ),
              const SizedBox(height: 14),
              _DlgField(
                label: 'DESCRIPTION',
                controller: descCtrl,
                hint: 'Full description of the package',
                maxLines: 3,
              ),
              const SizedBox(height: 14),
              const Text(
                'REGION *',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: region,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFFD96A2B),
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                ),
                items: _regionOptions
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setDlg(() => region = v);
                },
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _DlgField(
                      label: 'DAYS *',
                      controller: daysCtrl,
                      hint: '1',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DlgField(
                      label: 'JOINER ₱ *',
                      controller: joinerCtrl,
                      hint: '1500',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DlgField(
                      label: 'PREMIUM ₱ *',
                      controller: premiumCtrl,
                      hint: '3000',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _DlgField(
                label: 'IMAGE URL',
                controller: imgCtrl,
                hint: 'https://example.com/image.jpg',
              ),
              const SizedBox(height: 14),
              Row(children: [
                const Text(
                  'INCLUDED SPOTS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.2,
                  ),
                ),
                const Spacer(),
                Text(
                  '${selectedSpots.length} of ${cebuDestinations.length} selected',
                  style: const TextStyle(fontSize: 11, color: Wm.muted),
                ),
              ]),
              const SizedBox(height: 6),
              _AdminSearchField(
                hint: 'Filter spots…',
                onChanged: (v) => setDlg(() => spotQuery = v),
              ),
              const SizedBox(height: 8),
              Builder(builder: (_) {
                final q = spotQuery.trim().toLowerCase();
                final list = cebuDestinations
                    .where((d) =>
                        q.isEmpty ||
                        d.name.toLowerCase().contains(q) ||
                        regionTitle(d.region).toLowerCase().contains(q))
                    .toList();
                return Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Wm.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Wm.border),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: list.isEmpty
                      ? const Center(
                          child: Text('No spots match.', style: TextStyle(color: Wm.muted, fontSize: 12)),
                        )
                      : ListView.builder(
                          itemCount: list.length,
                          itemBuilder: (_, i) {
                            final d = list[i];
                            final checked = selectedSpots.contains(d.name);
                            return CheckboxListTile(
                              value: checked,
                              dense: true,
                              activeColor: Wm.accent,
                              secondary: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SafeImage(
                                  d.images.isNotEmpty ? d.images.first : '',
                                  width: 36,
                                  height: 36,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) =>
                                      Container(width: 36, height: 36, color: Wm.chip),
                                ),
                              ),
                              title: Text(
                                d.name,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Wm.ink,
                                ),
                              ),
                              subtitle: Text(
                                regionTitle(d.region),
                                style: const TextStyle(fontSize: 11, color: Wm.muted),
                              ),
                              onChanged: (v) {
                                final updated = Set<String>.from(selectedSpots);
                                v == true ? updated.add(d.name) : updated.remove(d.name);
                                setDlg(() => selectedSpots = updated);
                              },
                            );
                          },
                        ),
                );
              }),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF64748B),
              ),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: saving
                  ? null
                  : () async {
                      final name = nameCtrl.text.trim();
                      final joiner = double.tryParse(joinerCtrl.text);
                      final premium = double.tryParse(premiumCtrl.text);
                      final days = int.tryParse(daysCtrl.text) ?? 1;
                      if (name.isEmpty || joiner == null || premium == null) {
                        setDlg(
                          () => errorMsg =
                              'Name, joiner price and premium price are required.',
                        );
                        return;
                      }
                      setDlg(() {
                        saving = true;
                        errorMsg = null;
                      });
                      final highlightsList = selectedSpots.toList();
                      final payload = {
                        'name': name,
                        'tagline': taglineCtrl.text.trim(),
                        'description': descCtrl.text.trim(),
                        'region': region,
                        'duration_days': days,
                        'joiner_price': joiner,
                        'premium_price': premium,
                        'image_url': imgCtrl.text.trim(),
                        'highlights': highlightsList,
                      };
                      try {
                        if (isEdit) {
                          await Supabase.instance.client
                              .from('tour_packages')
                              .update(payload)
                              .eq('id', existing['id'] as String);
                        } else {
                          await Supabase.instance.client
                              .from('tour_packages')
                              .insert(payload);
                        }
                        if (ctx.mounted) Navigator.pop(ctx);
                        _load();
                      } catch (e) {
                        setDlg(() {
                          saving = false;
                          errorMsg = e.toString();
                        });
                      }
                    },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFD96A2B),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: const StadiumBorder(),
              ),
              child: saving
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(isEdit ? 'Save Changes' : 'Add Package'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleActive(Map<String, dynamic> pkg) async {
    if (pkg['_isDefault'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Save this package to the database first.'),
        ),
      );
      return;
    }
    final current = pkg['is_active'] as bool? ?? true;
    try {
      await Supabase.instance.client
          .from('tour_packages')
          .update({'is_active': !current})
          .eq('id', pkg['id'] as String);
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _delete(Map<String, dynamic> pkg) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Package'),
        content: Text('Remove "${pkg['name']}" from the platform?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B4A),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await Supabase.instance.client
          .from('tour_packages')
          .delete()
          .eq('id', pkg['id'] as String);
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
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
            const Text(
              'Manage Packages',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Wm.ink,
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: _load,
                  icon: const Icon(Icons.refresh, color: Wm.accent),
                ),
                FilledButton.icon(
                  onPressed: _showAddDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Package'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFC2571F),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: const StadiumBorder(),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Add, edit, toggle or delete tour packages.',
          style: TextStyle(fontSize: 14, color: Wm.muted),
        ),
        const SizedBox(height: 10),
        if (!_dbAvailable)
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFFB74D)),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 16,
                  color: Color(0xFFF57C00),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Table "tour_packages" not found in Supabase. Run the SQL in supabase_tables.sql to enable full CRUD. Showing built-in defaults.',
                    style: TextStyle(fontSize: 12, color: Color(0xFFF57C00)),
                  ),
                ),
              ],
            ),
          ),
        if (_loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_packages.isEmpty)
          const _AdminEmpty(
            message: 'No packages yet. Click "Add Package" to create one.',
          )
        else
          for (final pkg in _packages)
            _PackageAdminRow(
              package: pkg,
              onEdit: () => _showEditDialog(pkg),
              onToggle: () => _toggleActive(pkg),
              onDelete: pkg['_isDefault'] == true ? null : () => _delete(pkg),
            ),
      ],
    );
  }
}

class _PackageAdminRow extends StatelessWidget {
  final Map<String, dynamic> package;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback? onDelete;

  const _PackageAdminRow({
    required this.package,
    required this.onEdit,
    required this.onToggle,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final joiner = (package['joiner_price'] as num?)?.toStringAsFixed(0) ?? '—';
    final premium =
        (package['premium_price'] as num?)?.toStringAsFixed(0) ?? '—';
    final days = package['duration_days'] as int? ?? 1;
    final region = package['region'] as String? ?? '';
    final active = package['is_active'] as bool? ?? true;
    final isDefault = package['_isDefault'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDefault ? const Color(0xFFFFCC80) : Wm.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SafeImage(
                  package['image_url'] as String? ?? '',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 80,
                    height: 80,
                    color: const Color(0xFFFDF0E7),
                    child: const Icon(
                      Icons.tour,
                      color: Color(0xFFC2571F),
                      size: 32,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            package['name'] as String? ?? '—',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        if (isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFCC80),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Text(
                              'Default',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF795548),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      package['tagline'] as String? ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Wm.muted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$region · $days day${days != 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Wm.muted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _PkgPriceTag(
                          label: 'Joiner',
                          price: '₱$joiner',
                          color: Wm.accent,
                        ),
                        const SizedBox(width: 10),
                        _PkgPriceTag(
                          label: 'Premium',
                          price: '₱$premium',
                          color: const Color(0xFFFF8C00),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, size: 15),
                    label: Text(isDefault ? 'Save to DB' : 'Edit'),
                    style: TextButton.styleFrom(
                      foregroundColor: isDefault
                          ? const Color(0xFFFF8C00)
                          : const Color(0xFFC2571F),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                    ),
                  ),
                  if (!isDefault) ...[
                    Row(
                      children: [
                        Switch(
                          value: active,
                          onChanged: (_) => onToggle(),
                          activeThumbColor: Wm.accent,
                        ),
                        Text(
                          active ? 'On' : 'Off',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: active
                                ? const Color(0xFF50C878)
                                : const Color(0xFFFF6B4A),
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          onPressed: onDelete,
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: Color(0xFFFF6B4A),
                          ),
                          tooltip: 'Delete',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PkgPriceTag extends StatelessWidget {
  final String label;
  final String price;
  final Color color;
  const _PkgPriceTag({
    required this.label,
    required this.price,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Text(
            price,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            '/person',
            style: const TextStyle(fontSize: 9, color: Wm.muted),
          ),
        ],
      ),
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
    {
      'id': 'trans_shared_van',
      'title': 'Shared Van',
      'description':
          'Comfortable shared transfer with budget-friendly pricing.',
      'price': 450.0,
      'is_active': true,
    },
    {
      'id': 'trans_private_sedan',
      'title': 'Private Sedan',
      'description': 'Personal sedan with driver and flexible pickup time.',
      'price': 1300.0,
      'is_active': true,
    },
    {
      'id': 'trans_suv',
      'title': 'Private SUV',
      'description': 'Spacious SUV for families and premium road comfort.',
      'price': 2400.0,
      'is_active': true,
    },
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
      final data = await Supabase.instance.client
          .from('transport_types')
          .select();
      final list = (data as List).cast<Map<String, dynamic>>();
      setState(() {
        _transports = list.isEmpty ? List.from(_defaults) : list;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _transports = List.from(_defaults);
        _loading = false;
      });
    }
  }

  void _showEditDialog(Map<String, dynamic> transport) {
    final priceCtrl = TextEditingController(
      text: (transport['price'] as num?)?.toStringAsFixed(0) ?? '0',
    );
    bool saving = false;
    String? errorMsg;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => _ModernDialog(
          title: 'Edit Price — ${transport['title']}',
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                transport['description'] as String? ?? '',
                style: const TextStyle(color: Wm.muted, fontSize: 13),
              ),
              const SizedBox(height: 16),
              if (errorMsg != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 16,
                        color: Color(0xFFEF4444),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          errorMsg!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFB91C1C),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              _DlgField(
                label: 'PRICE PER TRIP (₱)',
                controller: priceCtrl,
                hint: '0',
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF64748B),
              ),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: saving
                  ? null
                  : () async {
                      final price = double.tryParse(priceCtrl.text);
                      if (price == null) {
                        setDlg(() => errorMsg = 'Enter a valid number.');
                        return;
                      }
                      setDlg(() {
                        saving = true;
                        errorMsg = null;
                      });
                      try {
                        await Supabase.instance.client
                            .from('transport_types')
                            .update({'price': price})
                            .eq('id', transport['id'] as String);
                        if (ctx.mounted) Navigator.pop(ctx);
                        _load();
                      } catch (e) {
                        setDlg(() {
                          saving = false;
                          errorMsg = e.toString();
                        });
                      }
                    },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFD96A2B),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: const StadiumBorder(),
              ),
              child: saving
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Save Price'),
            ),
          ],
        ),
      ),
    ).then((_) => priceCtrl.dispose());
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
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
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
            const Text(
              'Manage Transport',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Wm.ink,
              ),
            ),
            IconButton(
              onPressed: _load,
              icon: const Icon(Icons.refresh, color: Wm.accent),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Edit transport prices and toggle availability.',
          style: TextStyle(fontSize: 14, color: Wm.muted),
        ),
        const SizedBox(height: 20),
        if (_loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          )
        else
          for (final t in _transports) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Wm.border),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF0E7),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _transIcons[t['id'] as String? ?? ''] ??
                          Icons.directions_car,
                      color: const Color(0xFFC2571F),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t['title'] as String? ?? '—',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          t['description'] as String? ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Wm.muted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '₱${(t['price'] as num?)?.toStringAsFixed(0) ?? '0'} per trip',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF50C878),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () => _showEditDialog(t),
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Edit Price'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFC2571F),
                        ),
                      ),
                      Row(
                        children: [
                          Switch(
                            value: t['is_active'] as bool? ?? true,
                            onChanged: (_) => _toggleActive(t),
                            activeThumbColor: Wm.accent,
                          ),
                          Text(
                            (t['is_active'] as bool? ?? true)
                                ? 'Active'
                                : 'Hidden',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: (t['is_active'] as bool? ?? true)
                                  ? const Color(0xFF50C878)
                                  : const Color(0xFFFF6B4A),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
      ],
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

// ── Modern dialog shell ───────────────────────────────────────────────────────

class _ModernDialog extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget> actions;
  const _ModernDialog({
    required this.title,
    required this.body,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Wm.rModal)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540, maxHeight: 680),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 22, 16, 18),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Wm.border)),
              ),
              child: Row(children: [
                Container(
                  width: 8,
                  height: 22,
                  decoration: BoxDecoration(color: Wm.accent, borderRadius: BorderRadius.circular(999)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Wm.ink,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.maybePop(context),
                  icon: const Icon(Icons.close_rounded, color: Wm.muted),
                ),
              ]),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: body,
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
              decoration: const BoxDecoration(
                color: Wm.surface,
                border: Border(top: BorderSide(color: Wm.border)),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  filledButtonTheme: FilledButtonThemeData(
                    style: FilledButton.styleFrom(
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                    ),
                  ),
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(shape: const StadiumBorder()),
                  ),
                ),
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 10,
                  runSpacing: 8,
                  children: actions,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Modern field ──────────────────────────────────────────────────────────────

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
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 14),
            filled: true,
            fillColor: Wm.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Wm.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Wm.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Wm.accent, width: 1.6),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Tab: Manage Drivers ───────────────────────────────────────────────────────

class _ManageDriversTab extends StatefulWidget {
  const _ManageDriversTab();
  @override
  State<_ManageDriversTab> createState() => _ManageDriversTabState();
}

class _ManageDriversTabState extends State<_ManageDriversTab> {
  bool _loading = true;
  List<Map<String, dynamic>> _drivers = [];
  String? _error;

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _plateCtrl = TextEditingController();
  final _photoCtrl = TextEditingController();
  String _vehicleType = 'Van';
  bool _saving = false;

  static const _vehicleTypes = ['Van', 'SUV', 'Sedan', 'Bus', 'Motorcycle'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _plateCtrl.dispose();
    _photoCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await Supabase.instance.client
          .from('drivers')
          .select()
          .order('created_at', ascending: false);
      setState(() {
        _drivers = (data as List).cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _addDriver() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    if (name.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and email are required.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await Supabase.instance.client.from('drivers').insert({
        'full_name': name,
        'email': email,
        'phone': _phoneCtrl.text.trim(),
        'vehicle_type': _vehicleType,
        'license_plate': _plateCtrl.text.trim(),
        'photo_url': _photoCtrl.text.trim(),
        'is_available': true,
      });
      _nameCtrl.clear();
      _emailCtrl.clear();
      _phoneCtrl.clear();
      _plateCtrl.clear();
      _photoCtrl.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Driver added successfully.')),
        );
      }
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _editDriver(Map<String, dynamic> d) async {
    final nameCtrl = TextEditingController(
      text: d['full_name'] as String? ?? '',
    );
    final emailCtrl = TextEditingController(text: d['email'] as String? ?? '');
    final phoneCtrl = TextEditingController(text: d['phone'] as String? ?? '');
    final plateCtrl = TextEditingController(
      text: d['license_plate'] as String? ?? '',
    );
    final photoCtrl = TextEditingController(
      text: d['photo_url'] as String? ?? '',
    );
    String vehicle = d['vehicle_type'] as String? ?? 'Van';
    bool avail = d['is_available'] as bool? ?? true;
    bool saving = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          title: const Text(
            'Edit Driver',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _DlgField(
                          label: 'Full Name *',
                          hint: 'Juan dela Cruz',
                          controller: nameCtrl,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DlgField(
                          label: 'Email *',
                          hint: 'driver@email.com',
                          controller: emailCtrl,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _DlgField(
                          label: 'Phone',
                          hint: '+63 912 345 6789',
                          controller: phoneCtrl,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DlgField(
                          label: 'License Plate',
                          hint: 'ABC 1234',
                          controller: plateCtrl,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _DlgField(
                    label: 'Photo URL',
                    hint: 'https://i.imgur.com/photo.jpg',
                    controller: photoCtrl,
                  ),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Vehicle Type',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: vehicle,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFFD96A2B),
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                        ),
                        items: _vehicleTypes
                            .map(
                              (v) => DropdownMenuItem(value: v, child: Text(v)),
                            )
                            .toList(),
                        onChanged: (v) => setDlg(() => vehicle = v ?? 'Van'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text(
                      'Available',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    value: avail,
                    activeThumbColor: const Color(0xFFD96A2B),
                    contentPadding: EdgeInsets.zero,
                    onChanged: (v) => setDlg(() => avail = v),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: saving
                  ? null
                  : () async {
                      final name = nameCtrl.text.trim();
                      final email = emailCtrl.text.trim();
                      if (name.isEmpty || email.isEmpty) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(
                            content: Text('Name and email are required.'),
                          ),
                        );
                        return;
                      }
                      setDlg(() => saving = true);
                      try {
                        await Supabase.instance.client
                            .from('drivers')
                            .update({
                              'full_name': name,
                              'email': email,
                              'phone': phoneCtrl.text.trim(),
                              'license_plate': plateCtrl.text.trim(),
                              'photo_url': photoCtrl.text.trim(),
                              'vehicle_type': vehicle,
                              'is_available': avail,
                            })
                            .eq('id', d['id'] as String);
                        if (ctx.mounted) Navigator.pop(ctx);
                        await _load();
                      } catch (e) {
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(
                            ctx,
                          ).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      } finally {
                        setDlg(() => saving = false);
                      }
                    },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFD96A2B),
              ),
              child: saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Save Changes',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
            ),
          ],
        ),
      ),
    );
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    plateCtrl.dispose();
    photoCtrl.dispose();
  }

  Future<void> _deleteDriver(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove Driver'),
        content: const Text(
          'Remove this driver? Their assigned bookings will be unassigned.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B4A),
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await Supabase.instance.client.from('drivers').delete().eq('id', id);
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Manage Drivers',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Wm.ink,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Add drivers and assign them to bookings.',
          style: TextStyle(fontSize: 14, color: Wm.muted),
        ),
        const SizedBox(height: 24),

        // ── Add driver form ─────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Wm.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add New Driver',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFC2571F),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _DlgField(
                      label: 'Full Name *',
                      hint: 'Juan dela Cruz',
                      controller: _nameCtrl,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DlgField(
                      label: 'Email *',
                      hint: 'driver@email.com',
                      controller: _emailCtrl,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _DlgField(
                      label: 'Phone',
                      hint: '+63 912 345 6789',
                      controller: _phoneCtrl,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DlgField(
                      label: 'License Plate',
                      hint: 'ABC 1234',
                      controller: _plateCtrl,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _DlgField(
                label: 'Photo URL',
                hint: 'https://i.imgur.com/photo.jpg',
                controller: _photoCtrl,
              ),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Vehicle Type',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _vehicleType,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFFD96A2B),
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                    ),
                    items: _vehicleTypes
                        .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                        .toList(),
                    onChanged: (v) => setState(() => _vehicleType = v ?? 'Van'),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _addDriver,
                  icon: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.person_add, size: 18),
                  label: const Text(
                    'Add Driver',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFD96A2B),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const StadiumBorder(),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // ── Driver list ─────────────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Drivers (${_drivers.length})',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFFC2571F),
              ),
            ),
            IconButton(
              onPressed: _load,
              icon: const Icon(Icons.refresh, color: Wm.accent),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_error != null)
          _AdminEmpty(message: _error!)
        else if (_drivers.isEmpty)
          const _AdminEmpty(message: 'No drivers yet. Add one above.')
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _drivers.length,
            itemBuilder: (_, i) {
              final d = _drivers[i];
              final name = d['full_name'] as String? ?? '—';
              final email = d['email'] as String? ?? '—';
              final phone = d['phone'] as String? ?? '—';
              final vehicle = d['vehicle_type'] as String? ?? 'Van';
              final plate = d['license_plate'] as String? ?? '—';
              final avail = d['is_available'] as bool? ?? true;
              final photoUrl = d['photo_url'] as String? ?? '';
              final id = d['id'] as String;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Wm.border),
                ),
                child: Row(
                  children: [
                    photoUrl.isNotEmpty
                        ? CircleAvatar(
                            radius: 22,
                            backgroundImage: NetworkImage(photoUrl),
                            onBackgroundImageError: (_, _) {},
                            backgroundColor: const Color(0xFFFDF0E7),
                          )
                        : Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDF0E7),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: const Icon(
                              Icons.drive_eta,
                              color: Color(0xFFC2571F),
                              size: 22,
                            ),
                          ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFC2571F),
                            ),
                          ),
                          Text(
                            email,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Wm.muted,
                            ),
                          ),
                          Text(
                            '$vehicle · $plate · $phone',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Wm.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color:
                            (avail
                                    ? const Color(0xFF50C878)
                                    : const Color(0xFFFF6B4A))
                                .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        avail ? 'Available' : 'Busy',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: avail
                              ? const Color(0xFF50C878)
                              : const Color(0xFFFF6B4A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      onPressed: () => _editDriver(d),
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: Color(0xFFD96A2B),
                        size: 20,
                      ),
                      tooltip: 'Edit driver',
                    ),
                    IconButton(
                      onPressed: () => _deleteDriver(id),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Color(0xFFFF6B4A),
                        size: 20,
                      ),
                      tooltip: 'Remove driver',
                    ),
                  ],
                ),
              );
            },
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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Wm.border),
      ),
      child: Center(
        child: Text(message, style: const TextStyle(color: Wm.muted)),
      ),
    );
  }
}
