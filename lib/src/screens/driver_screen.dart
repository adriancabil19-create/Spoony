import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  final _refCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  @override
  void dispose() {
    _refCtrl.dispose();
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

  Future<void> _checkIn(String bookingId) async {
    try {
      await Supabase.instance.client
          .from('bookings')
          .update({'status': 'confirmed'})
          .eq('id', bookingId);
      await _loadTrips();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Guest checked in successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Check-in failed: $e')),
        );
      }
    }
  }

  Future<void> _lookupByRef() async {
    final ref = _refCtrl.text.trim().toUpperCase();
    if (ref.isEmpty) return;
    try {
      final data = await Supabase.instance.client
          .from('bookings')
          .select()
          .eq('reference_code', ref)
          .maybeSingle();
      if (!mounted) return;
      if (data == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking not found.')),
        );
        return;
      }
      final bookingId = data['id'] as String;
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Confirm Check-in'),
          content: Text(
            'Booking: ${data['reference_code']}\n'
            'Guest: ${data['user_email'] ?? '—'}\n'
            'Tour: ${data['tour_type'] ?? '—'}\n'
            'Guests: ${data['guest_count'] ?? 1}',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(backgroundColor: _kTeal),
              child: const Text('Check In'),
            ),
          ],
        ),
      );
      if (confirm == true) {
        await _checkIn(bookingId);
        _refCtrl.clear();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

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
      // Header
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Welcome, $driverName',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: _kDark)),
          Text('$vehicle · $plate',
              style: const TextStyle(fontSize: 14, color: _kMid)),
        ]),
        OutlinedButton.icon(
          onPressed: () async {
            await Supabase.instance.client.auth.signOut();
            if (mounted) Navigator.pushReplacementNamed(context, AuthScreen.routeName);
          },
          icon: const Icon(Icons.logout, size: 16),
          label: const Text('Sign Out'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFFF6B4A),
            side: const BorderSide(color: Color(0xFFFF6B4A)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ]),
      const SizedBox(height: 32),

      // Check-in by reference
      const Text('Guest Check-in',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _kDark)),
      const SizedBox(height: 4),
      const Text('Enter the booking reference from the guest\'s QR ticket.',
          style: TextStyle(fontSize: 13, color: _kMid)),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(
          child: TextField(
            controller: _refCtrl,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'e.g. CEB-A1B2C',
              hintStyle: const TextStyle(color: _kMid),
              prefixIcon: const Icon(Icons.qr_code, color: _kOcean),
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
        ),
        const SizedBox(width: 12),
        FilledButton(
          onPressed: _lookupByRef,
          style: FilledButton.styleFrom(
            backgroundColor: _kOcean,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Check In', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ]),
      const SizedBox(height: 40),

      // Assigned trips
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('My Assigned Trips',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _kDark)),
        IconButton(
          onPressed: _loadTrips,
          icon: const Icon(Icons.refresh, color: _kOcean),
        ),
      ]),
      const SizedBox(height: 16),
      if (_trips.isEmpty)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: const Column(children: [
            Icon(Icons.directions_car_outlined, size: 48, color: Color(0xFFCBD5E1)),
            SizedBox(height: 16),
            Text('No trips assigned yet.',
                style: TextStyle(fontSize: 16, color: _kMid, fontWeight: FontWeight.w600)),
            SizedBox(height: 4),
            Text('Your admin will assign bookings to you.',
                style: TextStyle(fontSize: 13, color: _kMid)),
          ]),
        )
      else
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _trips.length,
          itemBuilder: (_, i) => _TripCard(booking: _trips[i], onCheckIn: _checkIn),
        ),
    ]);
  }
}

class _TripCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final Future<void> Function(String) onCheckIn;

  const _TripCard({required this.booking, required this.onCheckIn});

  @override
  Widget build(BuildContext context) {
    final ref       = booking['reference_code'] as String? ?? '—';
    final status    = (booking['status'] as String? ?? 'pending').toLowerCase();
    final email     = booking['user_email'] as String? ?? '—';
    final tourType  = booking['tour_type']  as String? ?? '—';
    final guests    = booking['guest_count'] as int? ?? 0;
    final start     = (booking['start_date'] as String? ?? '').split('T').first;
    final end       = (booking['end_date']   as String? ?? '').split('T').first;
    final id        = booking['id'] as String;

    final Color statusColor;
    switch (status) {
      case 'confirmed': statusColor = const Color(0xFF50C878); break;
      case 'cancelled': statusColor = const Color(0xFFFF6B4A); break;
      default:          statusColor = const Color(0xFFFFC107);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _kOcean)),
          const Spacer(),
          Text('$start → $end',
              style: const TextStyle(fontSize: 12, color: _kMid)),
        ]),
        const SizedBox(height: 14),
        const Divider(height: 1, color: Color(0xFFF0F4F5)),
        const SizedBox(height: 12),
        Row(children: [
          const Icon(Icons.email_outlined, size: 14, color: _kMid),
          const SizedBox(width: 6),
          Expanded(child: Text(email, style: const TextStyle(fontSize: 13, color: _kDark))),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          const Icon(Icons.tour, size: 14, color: _kMid),
          const SizedBox(width: 6),
          Expanded(child: Text(tourType, style: const TextStyle(fontSize: 13, color: _kDark))),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          const Icon(Icons.people, size: 14, color: _kMid),
          const SizedBox(width: 6),
          Text('$guests guest${guests != 1 ? 's' : ''}',
              style: const TextStyle(fontSize: 13, color: _kDark)),
        ]),
        if (status == 'pending') ...[
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => onCheckIn(id),
              icon: const Icon(Icons.check_circle_outline, size: 16),
              label: const Text('Mark as Confirmed', style: TextStyle(fontWeight: FontWeight.w700)),
              style: FilledButton.styleFrom(
                backgroundColor: _kTeal,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ]),
    );
  }
}
