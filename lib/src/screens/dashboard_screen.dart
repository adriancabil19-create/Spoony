import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/api_service.dart';
import 'home_screen.dart';
import 'auth_screen.dart';

class DashboardScreen extends StatefulWidget {
  static const routeName = '/dashboard';
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedTab = 0;

  static const _tabs = [
    (Icons.calendar_today, 'Upcoming Trips'),
    (Icons.history, 'Booking History'),
    (Icons.bookmark, 'Saved Spots'),
    (Icons.settings, 'Account Settings'),
  ];

  String _displayName(User user) {
    return user.userMetadata?['name'] as String? ??
        user.userMetadata?['full_name'] as String? ??
        user.email ??
        'User';
  }

  String _initials(User user) {
    final parts = _displayName(user).trim().split(' ');
    return parts.map((p) => p.isNotEmpty ? p[0].toUpperCase() : '').take(2).join();
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final name = user != null ? _displayName(user) : 'User';
    final initials = user != null ? _initials(user) : 'U';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SpoonyNavBar(current: 'dashboard'),
            LayoutBuilder(builder: (ctx, constraints) {
              final mobile = constraints.maxWidth < 700;
              if (mobile) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(children: [
                    // Mobile: avatar + name row
                    Row(children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: const Color(0xFFE0F7FA),
                        child: Text(initials,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF006994))),
                      ),
                      const SizedBox(width: 14),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF00314F))),
                        const Text('Member', style: TextStyle(fontSize: 12, color: Color(0xFF8B99A6))),
                      ]),
                      const Spacer(),
                      OutlinedButton.icon(
                        onPressed: () async {
                          await Supabase.instance.client.auth.signOut();
                          if (context.mounted) Navigator.pushReplacementNamed(context, AuthScreen.routeName);
                        },
                        icon: const Icon(Icons.logout, size: 14),
                        label: const Text('Out', style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFFF6B4A)),
                          foregroundColor: const Color(0xFFFF6B4A),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    // Horizontal tab bar
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(_tabs.length, (i) {
                          final (icon, label) = _tabs[i];
                          final sel = _selectedTab == i;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedTab = i),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: sel ? const Color(0xFFE0F7FA) : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: sel ? const Color(0xFF00BCD4) : const Color(0xFFE8EDEF)),
                                ),
                                child: Row(children: [
                                  Icon(icon, size: 16,
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
                    _buildContent(user),
                  ]),
                );
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 280,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE8EDEF)),
                        ),
                        child: Column(children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: const Color(0xFFE0F7FA),
                            child: Text(initials,
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF006994))),
                          ),
                          const SizedBox(height: 16),
                          Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF00314F))),
                          const SizedBox(height: 4),
                          const Text('Member', style: TextStyle(fontSize: 12, color: Color(0xFF8B99A6), fontWeight: FontWeight.w600)),
                          const SizedBox(height: 24),
                          ...List.generate(_tabs.length, (i) {
                            final (icon, label) = _tabs[i];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _MenuItem(icon: icon, label: label,
                                  selected: _selectedTab == i,
                                  onTap: () => setState(() => _selectedTab = i)),
                            );
                          }),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                await Supabase.instance.client.auth.signOut();
                                if (context.mounted) Navigator.pushReplacementNamed(context, AuthScreen.routeName);
                              },
                              icon: const Icon(Icons.logout, size: 18),
                              label: const Text('Sign Out'),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFFF6B4A)),
                                foregroundColor: const Color(0xFFFF6B4A),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                        ]),
                      ),
                    ),
                    const SizedBox(width: 32),
                    Expanded(child: _buildContent(user)),
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

  Widget _buildContent(User? user) {
    switch (_selectedTab) {
      case 0:
        return _UpcomingTripsTab();
      case 1:
        return _BookingHistoryTab();
      case 2:
        return _SavedSpotsTab();
      case 3:
        return _AccountSettingsTab(user: user);
      default:
        return _UpcomingTripsTab();
    }
  }
}

// ── Tab: Upcoming Trips ───────────────────────────────────────────────────────

class _UpcomingTripsTab extends StatefulWidget {
  @override
  State<_UpcomingTripsTab> createState() => _UpcomingTripsTabState();
}

class _UpcomingTripsTabState extends State<_UpcomingTripsTab> {
  bool _loading = true;
  List<Map<String, dynamic>> _bookings = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final result = await ApiService.getMyBookings();
      final all = (result['bookings'] as List).cast<Map<String, dynamic>>();
      final now = DateTime.now();
      setState(() {
        _bookings = all.where((b) {
          final end = DateTime.tryParse(b['end_date'] as String? ?? '');
          return end != null && end.isAfter(now) && b['status'] != 'cancelled';
        }).toList();
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Could not load bookings. Make sure you are connected.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Upcoming Trips',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFF006994))),
        const SizedBox(height: 4),
        const Text('Get ready for your next adventure.',
            style: TextStyle(fontSize: 14, color: Color(0xFF8B99A6))),
        const SizedBox(height: 28),
        if (_loading)
          const Center(child: CircularProgressIndicator())
        else if (_error != null)
          _EmptyState(message: _error!)
        else if (_bookings.isEmpty)
          const _EmptyState(message: 'No upcoming trips. Book one now!')
        else
          for (final b in _bookings) ...[
            _TripCard.fromBooking(b),
            const SizedBox(height: 20),
          ],
      ],
    );
  }
}

// ── Tab: Booking History ──────────────────────────────────────────────────────

class _BookingHistoryTab extends StatefulWidget {
  @override
  State<_BookingHistoryTab> createState() => _BookingHistoryTabState();
}

class _BookingHistoryTabState extends State<_BookingHistoryTab> {
  bool _loading = true;
  List<Map<String, dynamic>> _bookings = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final result = await ApiService.getMyBookings();
      final all = (result['bookings'] as List).cast<Map<String, dynamic>>();
      final now = DateTime.now();
      setState(() {
        _bookings = all.where((b) {
          final end = DateTime.tryParse(b['end_date'] as String? ?? '');
          return end == null || end.isBefore(now) || b['status'] == 'cancelled';
        }).toList();
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Could not load booking history.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Booking History',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFF006994))),
        const SizedBox(height: 4),
        const Text('All your past trips and reservations.',
            style: TextStyle(fontSize: 14, color: Color(0xFF8B99A6))),
        const SizedBox(height: 28),
        if (_loading)
          const Center(child: CircularProgressIndicator())
        else if (_error != null)
          _EmptyState(message: _error!)
        else if (_bookings.isEmpty)
          const _EmptyState(message: 'No booking history yet.')
        else
          for (final b in _bookings) ...[
            _TripCard.fromBooking(b),
            const SizedBox(height: 20),
          ],
      ],
    );
  }
}

// ── Tab: Saved Spots ──────────────────────────────────────────────────────────

class _SavedSpotsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Saved Spots',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFF006994))),
        const SizedBox(height: 4),
        const Text("Destinations you've bookmarked.",
            style: TextStyle(fontSize: 14, color: Color(0xFF8B99A6))),
        const SizedBox(height: 28),
        ...['Kawasan Falls', 'Malapascua Island', 'Chocolate Hills', 'Oslob Whale Shark']
            .map((name) => _SavedSpotTile(name: name)),
      ],
    );
  }
}

// ── Tab: Account Settings ─────────────────────────────────────────────────────

class _AccountSettingsTab extends StatefulWidget {
  final User? user;
  const _AccountSettingsTab({required this.user});

  @override
  State<_AccountSettingsTab> createState() => _AccountSettingsTabState();
}

class _AccountSettingsTabState extends State<_AccountSettingsTab> {
  late String _name;

  @override
  void initState() {
    super.initState();
    _name = widget.user?.userMetadata?['name'] as String? ??
        widget.user?.userMetadata?['full_name'] as String? ??
        'Not set';
  }

  Future<void> _editName() async {
    final ctrl = TextEditingController(text: _name == 'Not set' ? '' : _name);
    String? error;
    final saved = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF0EA5E9), Color(0xFF14B8A6)]),
                ),
                child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Edit Full Name', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                  SizedBox(height: 2),
                  Text('Update your display name', style: TextStyle(fontSize: 13, color: Colors.white70)),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextField(
                    controller: ctrl,
                    decoration: InputDecoration(
                      hintText: 'Enter your full name',
                      hintStyle: const TextStyle(color: Color(0xFFCBD5E1)),
                      prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF94A3B8)),
                      errorText: error,
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0EA5E9), width: 2)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: TextButton.styleFrom(foregroundColor: const Color(0xFF64748B)),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: () {
                        final v = ctrl.text.trim();
                        if (v.isEmpty) { setS(() => error = 'Name cannot be empty'); return; }
                        Navigator.pop(ctx, v);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0EA5E9),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Save'),
                    ),
                  ]),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
    ctrl.dispose();
    if (saved == null || !mounted) return;
    try {
      await Supabase.instance.client.auth.updateUser(UserAttributes(data: {'name': saved}));
      if (mounted) setState(() => _name = saved);
    } on AuthException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update name.')));
    }
  }

  Future<void> _editPassword() async {
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool obscureNew = true;
    bool obscureConfirm = true;
    String? error;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF0EA5E9), Color(0xFF14B8A6)]),
                ),
                child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Change Password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                  SizedBox(height: 2),
                  Text('Choose a strong password', style: TextStyle(fontSize: 13, color: Colors.white70)),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextField(
                    controller: newCtrl,
                    obscureText: obscureNew,
                    decoration: InputDecoration(
                      hintText: 'New password',
                      hintStyle: const TextStyle(color: Color(0xFFCBD5E1)),
                      prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF94A3B8)),
                      errorText: error,
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0EA5E9), width: 2)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      suffixIcon: IconButton(
                        icon: Icon(obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFF94A3B8)),
                        onPressed: () => setS(() => obscureNew = !obscureNew),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: confirmCtrl,
                    obscureText: obscureConfirm,
                    decoration: InputDecoration(
                      hintText: 'Confirm new password',
                      hintStyle: const TextStyle(color: Color(0xFFCBD5E1)),
                      prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF94A3B8)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0EA5E9), width: 2)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      suffixIcon: IconButton(
                        icon: Icon(obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFF94A3B8)),
                        onPressed: () => setS(() => obscureConfirm = !obscureConfirm),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: TextButton.styleFrom(foregroundColor: const Color(0xFF64748B)),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: () {
                        final p = newCtrl.text;
                        final c = confirmCtrl.text;
                        if (p.length < 6) { setS(() => error = 'At least 6 characters required'); return; }
                        if (p != c) { setS(() => error = 'Passwords do not match'); return; }
                        Navigator.pop(ctx, true);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0EA5E9),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Save'),
                    ),
                  ]),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
    newCtrl.dispose();
    confirmCtrl.dispose();
    if (confirmed != true || !mounted) return;
    try {
      await Supabase.instance.client.auth.updateUser(UserAttributes(password: newCtrl.text));
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully.')),
      );
    } on AuthException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update password.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = widget.user?.email ?? 'Not set';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Account Settings',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFF006994))),
        const SizedBox(height: 4),
        const Text('Manage your profile and preferences.',
            style: TextStyle(fontSize: 14, color: Color(0xFF8B99A6))),
        const SizedBox(height: 28),
        _SettingsCard(
          child: Column(children: [
            _SettingsField(label: 'Full Name', value: _name, onEdit: _editName),
            const Divider(),
            _SettingsField(label: 'Email', value: email),
            const Divider(),
            _SettingsField(label: 'Password', value: '••••••••', onEdit: _editPassword),
          ]),
        ),
      ],
    );
  }
}

// ── Trip Card ─────────────────────────────────────────────────────────────────

class _TripCard extends StatelessWidget {
  final String status;
  final Color statusColor;
  final String ref;
  final String amount;
  final String paymentLabel;
  final String title;
  final String dates;
  final String guests;
  final String details;

  const _TripCard({
    required this.status,
    required this.statusColor,
    required this.ref,
    required this.amount,
    required this.paymentLabel,
    required this.title,
    required this.dates,
    required this.guests,
    required this.details,
  });

  factory _TripCard.fromBooking(Map<String, dynamic> b) {
    final statusStr = (b['status'] as String? ?? 'pending').toLowerCase();
    final Color color;
    switch (statusStr) {
      case 'confirmed':
        color = const Color(0xFF50C878);
        break;
      case 'cancelled':
        color = const Color(0xFFFF6B4A);
        break;
      default:
        color = const Color(0xFFFFC107);
    }

    final start = _fmtDate(b['start_date'] as String?);
    final end = _fmtDate(b['end_date'] as String?);
    final dates = (start.isNotEmpty && end.isNotEmpty) ? '$start - $end' : start;

    final amount = b['total_amount'] != null
        ? '₱${(b['total_amount'] as num).toStringAsFixed(0)}'
        : '—';

    final guestCount = b['guest_count'] as int? ?? 1;
    final accommodation = b['accommodation_type'] as String? ?? '';
    final transport = b['transport_type'] as String? ?? '';
    final details = [accommodation, transport].where((s) => s.isNotEmpty).join(' · ');

    return _TripCard(
      status: statusStr.toUpperCase(),
      statusColor: color,
      ref: b['reference_code'] as String? ?? '—',
      amount: amount,
      paymentLabel: 'Total',
      title: 'Cebu Tour Package',
      dates: dates,
      guests: '$guestCount Adult${guestCount != 1 ? 's' : ''}',
      details: details.isNotEmpty ? details : 'Cebu, Philippines',
    );
  }

  static String _fmtDate(String? iso) {
    if (iso == null) return '';
    final d = DateTime.tryParse(iso);
    if (d == null) return '';
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(status,
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.w700, fontSize: 11)),
            ),
            const SizedBox(width: 12),
            Text(ref, style: const TextStyle(fontSize: 12, color: Color(0xFF8B99A6), fontWeight: FontWeight.w600)),
            const Spacer(),
            Text(amount,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF50C878))),
            const SizedBox(width: 8),
            Text(paymentLabel, style: const TextStyle(fontSize: 11, color: Color(0xFF8B99A6))),
          ]),
          const SizedBox(height: 20),
          Text(title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF00314F))),
          const SizedBox(height: 16),
          Row(children: [
            _TripDetail(icon: Icons.calendar_today, label: 'Dates', value: dates),
            _TripDetail(icon: Icons.people, label: 'Guests', value: guests),
            _TripDetail(icon: Icons.location_on, label: 'Details', value: details),
          ]),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.qr_code_2, size: 18),
                label: const Text('View Tickets (QR)'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF006994),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download, size: 18),
                label: const Text('Download Itinerary'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF006994)),
                  foregroundColor: const Color(0xFF006994),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

// ── Reusable sub-widgets ──────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EDEF)),
      ),
      child: Center(
        child: Text(message,
            style: const TextStyle(fontSize: 15, color: Color(0xFF8B99A6))),
      ),
    );
  }
}

class _TripDetail extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _TripDetail({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 16, color: const Color(0xFF00BCD4)),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF8B99A6))),
          ]),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF00314F)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _SavedSpotTile extends StatelessWidget {
  final String name;
  const _SavedSpotTile({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE8EDEF)),
      ),
      child: Row(children: [
        const Icon(Icons.location_on, color: Color(0xFF00BCD4), size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(name,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF00314F)))),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.bookmark, color: Color(0xFF00BCD4), size: 20),
        ),
        FilledButton(
          onPressed: () {},
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF00BCD4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Book', style: TextStyle(fontSize: 13)),
        ),
      ]),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final Widget child;
  const _SettingsCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EDEF)),
      ),
      child: child,
    );
  }
}

class _SettingsField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onEdit;
  const _SettingsField({required this.label, required this.value, this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(children: [
        SizedBox(
          width: 120,
          child: Text(label,
              style: const TextStyle(fontSize: 13, color: Color(0xFF8B99A6), fontWeight: FontWeight.w600)),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF00314F))),
        ),
        if (onEdit != null)
          TextButton(onPressed: onEdit, child: const Text('Edit')),
      ]),
    );
  }
}


class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _MenuItem({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE0F7FA) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(children: [
            Icon(icon, size: 20, color: selected ? const Color(0xFF00BCD4) : const Color(0xFF8B99A6)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? const Color(0xFF006994) : const Color(0xFF8B99A6),
                    fontSize: 13,
                  )),
            ),
          ]),
        ),
      ),
    );
  }
}
