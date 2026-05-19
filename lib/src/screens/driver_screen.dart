import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:web/web.dart' as web;
import 'home_screen.dart';
import 'auth_screen.dart';

const _kOcean = Color(0xFF0EA5E9);
const _kTeal  = Color(0xFF14B8A6);
const _kDark  = Color(0xFF0F172A);
const _kMid   = Color(0xFF64748B);
const _kBg    = Color(0xFFF8FAFC);

class DriverScreen extends StatefulWidget {
  static const routeName = '/driver';
  const DriverScreen({super.key});

  @override
  State<DriverScreen> createState() => _DriverScreenState();
}

class _DriverScreenState extends State<DriverScreen> {
  Map<String, dynamic>? _driver;
  List<Map<String, dynamic>> _trips = [];
  bool _loading = true;
  String? _error;

  final _searchCtrl = TextEditingController();
  String   _searchQuery  = '';
  String   _statusFilter = 'all';
  DateTime? _filterDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (mounted) Navigator.pushReplacementNamed(context, AuthScreen.routeName);
      return;
    }
    try {
      final data = await Supabase.instance.client
          .from('drivers')
          .select()
          .eq('email', user.email ?? '')
          .maybeSingle();
      if (data == null) {
        if (mounted) Navigator.pushReplacementNamed(context, HomeScreen.routeName);
        return;
      }
      _driver = data;
      await _loadTrips();
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _loadTrips() async {
    if (_driver == null) return;
    try {
      final data = await Supabase.instance.client
          .from('bookings')
          .select()
          .eq('driver_id', _driver!['id'] as String)
          .order('start_date', ascending: true);
      if (mounted) {
        setState(() {
          _trips = (data as List).cast<Map<String, dynamic>>();
          _loading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _complete(String bookingId, Map<String, dynamic> booking) async {
    try {
      await Supabase.instance.client
          .from('bookings')
          .update({'status': 'completed'})
          .eq('id', bookingId);

      // Notify the guest by email
      try {
        await Supabase.instance.client.functions.invoke('notify-guest-complete', body: {
          'guestEmail':  booking['user_email']  ?? '',
          'reference':   booking['reference_code'] ?? '',
          'tourType':    booking['tour_type']   ?? '',
          'startDate':   (booking['start_date'] as String? ?? '').split('T').first,
          'endDate':     (booking['end_date']   as String? ?? '').split('T').first,
          'guestCount':  booking['guest_count'] ?? 0,
        });
      } catch (_) {}

      await _loadTrips();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trip marked as completed. Guest notified.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _scanQR() async {
    await showDialog(
      context: context,
      builder: (ctx) => _QrScanDialog(
        onScanned: (code) {
          Navigator.pop(ctx);
          final ref = code.toUpperCase();
          _searchCtrl.text = ref;
          setState(() => _searchQuery = ref);
        },
      ),
    );
  }

  List<Map<String, dynamic>> get _filtered {
    var list = _trips;
    if (_statusFilter != 'all') {
      list = list.where((b) => (b['status'] as String? ?? '') == _statusFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((b) {
        final ref   = (b['reference_code'] as String? ?? '').toLowerCase();
        final email = (b['user_email']     as String? ?? '').toLowerCase();
        return ref.contains(q) || email.contains(q);
      }).toList();
    }
    if (_filterDate != null) {
      list = list.where((b) {
        final start = DateTime.tryParse((b['start_date'] as String? ?? '').split('T').first);
        final end   = DateTime.tryParse((b['end_date']   as String? ?? '').split('T').first);
        if (start == null || end == null) return false;
        final d = DateTime(_filterDate!.year, _filterDate!.month, _filterDate!.day);
        return !d.isBefore(start) && !d.isAfter(end);
      }).toList();
    }
    return list;
  }

  int _countByStatus(String status) =>
      _trips.where((b) => (b['status'] as String? ?? '') == status).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SingleChildScrollView(
        child: Column(children: [
          SpoonyNavBar(current: 'driver'),
          LayoutBuilder(builder: (context, constraints) {
            final hPad = constraints.maxWidth >= 700 ? 80.0 : 20.0;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 32),
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.red)))
                      : _buildContent(),
            );
          }),
          const SizedBox(height: 48),
          const SpoonyFooter(),
        ]),
      ),
    );
  }

  Widget _buildContent() {
    final driverName = _driver?['full_name'] as String? ?? 'Driver';
    final vehicle    = _driver?['vehicle_type'] as String? ?? 'Van';
    final plate      = _driver?['license_plate'] as String? ?? '—';

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // ── Header ─────────────────────────────────────────────────────────────
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Welcome, $driverName',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: _kDark)),
        Text('$vehicle · $plate',
            style: const TextStyle(fontSize: 14, color: _kMid)),
      ]),
      const SizedBox(height: 32),

      // ── Trips header ────────────────────────────────────────────────────────
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('My Assigned Trips',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _kDark)),
        IconButton(onPressed: _loadTrips, icon: const Icon(Icons.refresh, color: _kOcean)),
      ]),
      const SizedBox(height: 12),

      // ── Search + Date filter ────────────────────────────────────────────────
      Row(children: [
        Expanded(
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _searchQuery = v.trim()),
            decoration: InputDecoration(
              hintText: 'Search by reference or guest email…',
              hintStyle: const TextStyle(color: _kMid, fontSize: 13),
              prefixIcon: const Icon(Icons.search, color: _kMid, size: 18),
              suffixIcon: IconButton(
                onPressed: _scanQR,
                icon: const Icon(Icons.camera_alt, color: _kOcean),
                tooltip: 'Scan QR Code',
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _kOcean)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        OutlinedButton.icon(
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _filterDate ?? DateTime.now(),
              firstDate: DateTime(2024),
              lastDate: DateTime(2030),
            );
            if (picked != null) setState(() => _filterDate = picked);
          },
          icon: const Icon(Icons.calendar_today, size: 14),
          label: Text(
            _filterDate == null
                ? 'Filter date'
                : '${_filterDate!.year}-${_filterDate!.month.toString().padLeft(2, '0')}-${_filterDate!.day.toString().padLeft(2, '0')}',
            style: const TextStyle(fontSize: 13),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: _filterDate != null ? _kOcean : _kMid,
            side: BorderSide(color: _filterDate != null ? _kOcean : const Color(0xFFE2E8F0)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        if (_filterDate != null) ...[
          const SizedBox(width: 4),
          IconButton(
            onPressed: () => setState(() => _filterDate = null),
            icon: const Icon(Icons.close, size: 16, color: _kMid),
            tooltip: 'Clear date filter',
          ),
        ],
      ]),
      const SizedBox(height: 12),

      // ── Status filter chips ─────────────────────────────────────────────────
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          _statusChip('All',       'all',       _kOcean,                   _trips.length),
          const SizedBox(width: 8),
          _statusChip('Upcoming',  'pending',   const Color(0xFFFFC107),   _countByStatus('pending')),
          const SizedBox(width: 8),
          _statusChip('Completed', 'completed', _kTeal,                    _countByStatus('completed')),
          const SizedBox(width: 8),
          _statusChip('Cancelled', 'cancelled', const Color(0xFFFF6B4A),   _countByStatus('cancelled')),
        ]),
      ),
      const SizedBox(height: 20),

      // ── Trip list ───────────────────────────────────────────────────────────
      if (_filtered.isEmpty)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(children: [
            const Icon(Icons.directions_car_outlined, size: 48, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 16),
            Text(
              _trips.isEmpty ? 'No trips assigned yet.' : 'No trips match your search.',
              style: const TextStyle(fontSize: 16, color: _kMid, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              _trips.isEmpty ? 'Your admin will assign bookings to you.' : 'Try adjusting your search or filter.',
              style: const TextStyle(fontSize: 13, color: _kMid),
            ),
          ]),
        )
      else
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _filtered.length,
          itemBuilder: (_, i) => _TripCard(
            booking: _filtered[i],
            onComplete: _complete,
          ),
        ),
    ]);
  }

  Widget _statusChip(String label, String value, Color color, int count) {
    final sel = _statusFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _statusFilter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? color.withValues(alpha: 0.12) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: sel ? color : const Color(0xFFE2E8F0)),
        ),
        child: Row(children: [
          Text(label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: sel ? color : _kMid,
              )),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: sel ? color : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: sel ? Colors.white : _kMid,
                )),
          ),
        ]),
      ),
    );
  }
}

// ── Trip card with expandable full details ─────────────────────────────────────

class _TripCard extends StatefulWidget {
  final Map<String, dynamic> booking;
  final Future<void> Function(String, Map<String, dynamic>) onComplete;

  const _TripCard({required this.booking, required this.onComplete});

  @override
  State<_TripCard> createState() => _TripCardState();
}

class _TripCardState extends State<_TripCard> {
  bool _expanded = false;

  static const _accLabels = {
    'acc_budget':    'Budget Stay',
    'acc_standard':  'Standard Hotel',
    'acc_premium':   'Premium Resort',
    'acc_luxury':    'Luxury Villa',
  };
  static const _transLabels = {
    'trans_shared_van':    'Shared Van',
    'trans_private_sedan': 'Private Sedan',
    'trans_suv':           'Private SUV',
  };

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;

    final ref      = b['reference_code'] as String? ?? '—';
    final status   = (b['status'] as String? ?? 'pending').toLowerCase();
    final email    = b['user_email'] as String? ?? '—';
    final tourType = b['tour_type']  as String? ?? '—';
    final guests   = b['guest_count'] as int? ?? 0;
    final adults   = b['adult_count'] as int? ?? guests;
    final kids     = b['kid_count']   as int? ?? 0;
    final toddlers = b['toddler_count'] as int? ?? 0;
    final start    = (b['start_date'] as String? ?? '').split('T').first;
    final end      = (b['end_date']   as String? ?? '').split('T').first;
    final id       = b['id'] as String;
    final itinerary = b['itinerary'] as String? ?? '';
    final amount   = b['amount'] as String? ?? '';
    final nights   = b['nights'] as int? ?? 0;
    final accId    = b['accommodation_id'] as String? ?? '';
    final transId  = b['transport_id'] as String? ?? '';

    final Color statusColor;
    final String statusLabel;
    switch (status) {
      case 'confirmed':
        statusColor = const Color(0xFF50C878); statusLabel = 'IN PROGRESS';
      case 'completed':
        statusColor = _kTeal; statusLabel = 'COMPLETED';
      case 'cancelled':
        statusColor = const Color(0xFFFF6B4A); statusLabel = 'CANCELLED';
      default:
        statusColor = const Color(0xFFFFC107); statusLabel = 'UPCOMING';
    }

    final itineraryLines = itinerary
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    final dayRegex = RegExp(r'^Day (\d+): (.+)$');

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Collapsed section (always visible) ─────────────────────────────
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(statusLabel,
                    style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 10),
              Text(ref, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _kOcean)),
              const Spacer(),
              Text('$start → $end', style: const TextStyle(fontSize: 12, color: _kMid)),
            ]),
            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFF0F4F5)),
            const SizedBox(height: 12),
            _iconRow(Icons.email_outlined, email),
            const SizedBox(height: 6),
            _iconRow(Icons.tour, tourType),
            const SizedBox(height: 6),
            _iconRow(Icons.people, '$guests guest${guests != 1 ? 's' : ''}'),
            if (status == 'confirmed') ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => widget.onComplete(id, widget.booking),
                  icon: const Icon(Icons.task_alt, size: 16),
                  label: const Text('Mark Trip as Completed', style: TextStyle(fontWeight: FontWeight.w700)),
                  style: FilledButton.styleFrom(
                    backgroundColor: _kOcean,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),

            // Expand toggle
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  _expanded ? 'Hide Details' : 'View Full Details',
                  style: const TextStyle(fontSize: 12, color: _kOcean, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 4),
                Icon(
                  _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: 16, color: _kOcean,
                ),
              ]),
            ),
          ]),
        ),

        // ── Expanded section ────────────────────────────────────────────────
        if (_expanded) ...[
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // Guest breakdown
              _sectionTitle('Guest Breakdown'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(children: [
                  _detailRow('Adults (18+)', '$adults'),
                  if (kids > 0) _detailRow('Kids (4–17)', '$kids', badge: '70% price', badgeColor: _kTeal),
                  if (toddlers > 0) _detailRow('Toddlers (0–3)', '$toddlers', badge: 'Free', badgeColor: const Color(0xFF50C878)),
                  if (kids == 0 && toddlers == 0 && adults == guests)
                    const SizedBox.shrink(),
                ]),
              ),
              const SizedBox(height: 16),

              // Trip info row
              if (nights > 0) ...[
                _infoRow(Icons.nights_stay_outlined, 'Duration', '$nights night${nights != 1 ? 's' : ''}'),
                const SizedBox(height: 8),
              ],
              if (accId.isNotEmpty && _accLabels.containsKey(accId)) ...[
                _infoRow(Icons.hotel_outlined, 'Accommodation', _accLabels[accId]!),
                const SizedBox(height: 8),
              ],
              if (transId.isNotEmpty && _transLabels.containsKey(transId)) ...[
                _infoRow(Icons.directions_car_outlined, 'Transport', _transLabels[transId]!),
                const SizedBox(height: 8),
              ],
              if (amount.isNotEmpty) ...[
                _infoRow(Icons.payments_outlined, 'Total Price', amount.replaceAll('₱', 'PHP ')),
                const SizedBox(height: 16),
              ],

              // Itinerary
              _sectionTitle('Full Itinerary'),
              const SizedBox(height: 8),
              if (itineraryLines.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Text('No itinerary recorded.',
                      style: TextStyle(fontSize: 12, color: _kMid)),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: itineraryLines.asMap().entries.map((entry) {
                      final i    = entry.key;
                      final line = entry.value;
                      final m    = dayRegex.firstMatch(line);
                      final dayNum  = m?.group(1) ?? '${i + 1}';
                      final content = m?.group(2) ?? line;
                      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        if (i > 0) const Divider(height: 1, color: Color(0xFFF0F4F5)),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _kOcean,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text('Day $dayNum',
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(content,
                                  style: const TextStyle(fontSize: 12, color: _kDark, fontWeight: FontWeight.w500)),
                            ),
                          ]),
                        ),
                      ]);
                    }).toList(),
                  ),
                ),
            ]),
          ),
        ],
      ]),
    );
  }

  Widget _sectionTitle(String text) => Text(text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _kDark));

  Widget _iconRow(IconData icon, String text) => Row(children: [
    Icon(icon, size: 14, color: _kMid),
    const SizedBox(width: 6),
    Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: _kDark))),
  ]);

  Widget _infoRow(IconData icon, String label, String value) => Row(children: [
    Icon(icon, size: 14, color: _kMid),
    const SizedBox(width: 8),
    Text('$label: ', style: const TextStyle(fontSize: 12, color: _kMid)),
    Expanded(
      child: Text(value,
          style: const TextStyle(fontSize: 12, color: _kDark, fontWeight: FontWeight.w600)),
    ),
  ]);

  Widget _detailRow(String label, String value, {String? badge, Color? badgeColor}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          Text(label, style: const TextStyle(fontSize: 12, color: _kMid)),
          if (badge != null) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: (badgeColor ?? _kTeal).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(badge,
                  style: TextStyle(fontSize: 10, color: badgeColor ?? _kTeal, fontWeight: FontWeight.w600)),
            ),
          ],
          const Spacer(),
          Text(value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _kDark)),
        ]),
      );
}

// ── QR Scanner Dialog (native browser camera + BarcodeDetector API) ──────────

@JS('BarcodeDetector')
extension type _JsBarcodeDetector._(JSObject _) implements JSObject {
  external factory _JsBarcodeDetector(JSObject options);
  external JSPromise<JSArray<JSObject>> detect(JSAny source);
}

class _QrScanDialog extends StatefulWidget {
  final void Function(String) onScanned;
  const _QrScanDialog({required this.onScanned});
  @override
  State<_QrScanDialog> createState() => _QrScanDialogState();
}

class _QrScanDialogState extends State<_QrScanDialog> {
  static int _idCounter = 0;
  late final String _viewId;
  late final web.HTMLVideoElement _video;
  web.MediaStream? _stream;
  Timer? _timer;
  bool _scanned      = false;
  bool _cameraError  = false;
  bool _unsupported  = false;

  @override
  void initState() {
    super.initState();
    _viewId = 'qr-scanner-${_idCounter++}';
    _video  = web.HTMLVideoElement();
    _video.setAttribute('style', 'width:100%;height:100%;object-fit:cover;');
    _video.setAttribute('playsinline', 'true');
    _video.autoplay = true;
    _video.muted    = true;
    ui_web.platformViewRegistry.registerViewFactory(
      _viewId, (int id) => _video,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _startCamera());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopStream();
    super.dispose();
  }

  void _stopStream() {
    final s = _stream;
    if (s == null) return;
    for (final t in s.getTracks().toDart) { t.stop(); }
  }

  Future<void> _startCamera() async {
    if (!mounted) return;
    try {
      final constraints =
          {'video': true}.jsify() as web.MediaStreamConstraints;
      final stream = await web.window.navigator.mediaDevices
          .getUserMedia(constraints)
          .toDart;
      if (!mounted) {
        for (final t in stream.getTracks().toDart) { t.stop(); }
        return;
      }
      _stream = stream;
      _video.srcObject = stream;
      try { await _video.play().toDart; } catch (_) {}
      _timer = Timer.periodic(
        const Duration(milliseconds: 600), (_) => _scan(),
      );
    } catch (_) {
      if (mounted) setState(() => _cameraError = true);
    }
  }

  Future<void> _scan() async {
    if (_scanned || !mounted) return;
    if (!globalContext.has('BarcodeDetector')) {
      _timer?.cancel();
      if (mounted) setState(() => _unsupported = true);
      return;
    }
    try {
      final det = _JsBarcodeDetector(
        {'formats': ['qr_code'].jsify()}.jsify() as JSObject,
      );
      final results = (await det.detect(_video).toDart).toDart;
      if (results.isNotEmpty && !_scanned) {
        final raw =
            results.first.getProperty<JSString?>('rawValue'.toJS)?.toDart;
        if (raw != null && raw.isNotEmpty) {
          _scanned = true;
          widget.onScanned(raw);
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 380, height: 440,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
            child: Row(children: [
              const Icon(Icons.qr_code_scanner, color: _kOcean, size: 22),
              const SizedBox(width: 10),
              const Expanded(child: Text('Scan Guest QR Code',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _kDark))),
              IconButton(onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 20)),
            ]),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Text("Point the camera at the guest's QR ticket",
                style: TextStyle(fontSize: 12, color: _kMid)),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              child: _cameraError
                  ? _errMsg('Camera access denied.\nAllow camera permission and try again.')
                  : _unsupported
                      ? _errMsg('QR scanning requires Chrome or Edge.')
                      : Stack(children: [
                          HtmlElementView(viewType: _viewId),
                          Center(
                            child: Container(
                              width: 220, height: 220,
                              decoration: BoxDecoration(
                                border: Border.all(color: _kOcean, width: 2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _errMsg(String msg) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.no_photography_outlined, color: _kMid, size: 48),
        const SizedBox(height: 12),
        Text(msg, textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: _kMid, height: 1.5)),
      ]),
    ),
  );
}
