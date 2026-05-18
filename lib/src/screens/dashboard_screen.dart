import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../services/api_service.dart';
import '../data/cebu_data.dart';
import 'home_screen.dart';
import 'auth_screen.dart';

const _kAccLabels = {
  'acc_budget': 'Budget Stay',
  'acc_standard': 'Standard Hotel',
  'acc_premium': 'Premium Resort',
  'acc_luxury': 'Luxury Villa',
};

const _kTransLabels = {
  'trans_shared_van': 'Shared Van',
  'trans_private_sedan': 'Private Sedan',
  'trans_suv': 'Private SUV',
};

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
    (Icons.favorite, 'Favorite Spots'),
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
        return _FavoriteSpotsTab();
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

// ── Tab: Favorite Spots ───────────────────────────────────────────────────────

class _FavoriteSpotsTab extends StatefulWidget {
  @override
  State<_FavoriteSpotsTab> createState() => _FavoriteSpotsTabState();
}

class _FavoriteSpotsTabState extends State<_FavoriteSpotsTab> {
  List<String> _favorites = [];

  @override
  void initState() {
    super.initState();
    final raw = Supabase.instance.client.auth.currentUser?.userMetadata?['favorites'];
    if (raw is List) _favorites = raw.cast<String>();
  }

  Future<void> _remove(String name) async {
    final updated = _favorites.where((f) => f != name).toList();
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'favorites': updated}),
      );
      if (mounted) setState(() => _favorites = updated);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to remove favorite.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Favorite Spots',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFF006994))),
        const SizedBox(height: 4),
        const Text("Destinations you've saved as favorites.",
            style: TextStyle(fontSize: 14, color: Color(0xFF8B99A6))),
        const SizedBox(height: 28),
        if (_favorites.isEmpty)
          const _EmptyState(message: 'No favorites yet. Heart a destination in Explore!')
        else
          for (final name in _favorites)
            _FavoriteSpotTile(name: name, onRemove: () => _remove(name)),
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully.')),
      );
      }
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

class _TripCard extends StatefulWidget {
  final String status;
  final Color statusColor;
  final String ref;
  final String amount;
  final String title;
  final String dates;
  final String guests;
  final String accId;
  final String transId;
  final String tourType;
  final String itinerary;
  final String startDate;
  final String endDate;
  final int guestCount;

  const _TripCard({
    required this.status,
    required this.statusColor,
    required this.ref,
    required this.amount,
    required this.title,
    required this.dates,
    required this.guests,
    required this.accId,
    required this.transId,
    required this.tourType,
    required this.itinerary,
    required this.startDate,
    required this.endDate,
    required this.guestCount,
  });

  factory _TripCard.fromBooking(Map<String, dynamic> b) {
    final statusStr = (b['status'] as String? ?? 'pending').toLowerCase();
    final Color color;
    switch (statusStr) {
      case 'confirmed': color = const Color(0xFF50C878); break;
      case 'cancelled': color = const Color(0xFFFF6B4A); break;
      default:          color = const Color(0xFFFFC107);
    }
    final guestCount = b['guest_count'] as int? ?? 1;
    final startRaw = b['start_date'] as String? ?? '';
    final endRaw   = b['end_date']   as String? ?? '';
    final start = _fmtDate(startRaw);
    final end   = _fmtDate(endRaw);
    return _TripCard(
      status:      statusStr.toUpperCase(),
      statusColor: color,
      ref:         b['reference_code'] as String? ?? '—',
      amount:      b['total_amount'] != null ? '₱${(b['total_amount'] as num).toStringAsFixed(0)}' : '—',
      title:       'Cebu Tour Package',
      dates:       (start.isNotEmpty && end.isNotEmpty) ? '$start – $end' : start,
      guests:      '$guestCount Adult${guestCount != 1 ? 's' : ''}',
      accId:       b['accommodation_type'] as String? ?? '',
      transId:     b['transport_type']     as String? ?? '',
      tourType:    b['tour_type']           as String? ?? '',
      itinerary:   b['itinerary']           as String? ?? '',
      startDate:   start,
      endDate:     end,
      guestCount:  guestCount,
    );
  }

  static String _fmtDate(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    final d = DateTime.tryParse(iso);
    if (d == null) return '';
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${m[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  State<_TripCard> createState() => _TripCardState();
}

class _TripCardState extends State<_TripCard> {
  bool _expanded = false;

  String get _accLabel => _kAccLabels[widget.accId] ?? (widget.accId.isNotEmpty ? widget.accId : '—');
  String get _transLabel => _kTransLabels[widget.transId] ?? (widget.transId.isNotEmpty ? widget.transId : '—');
  bool get _isPending => widget.status == 'PENDING';

  void _showQR() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF006994), Color(0xFF00BCD4)]),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Booking Ticket', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                Text(widget.ref, style: const TextStyle(fontSize: 13, color: Colors.white70)),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(28),
              child: Column(children: [
                QrImageView(data: widget.ref, size: 200, backgroundColor: Colors.white),
                const SizedBox(height: 16),
                Text(widget.ref,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF006994), letterSpacing: 2)),
                const SizedBox(height: 8),
                const Text('Show this QR code at the tour meeting point for check-in.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Color(0xFF8B99A6), height: 1.5)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> _downloadPdf() async {
    try {
      final doc = pw.Document();
      final ocean   = PdfColor.fromHex('#0EA5E9');
      final teal    = PdfColor.fromHex('#14B8A6');
      final dark    = PdfColor.fromHex('#0F172A');
      final mid     = PdfColor.fromHex('#64748B');
      final light   = PdfColor.fromHex('#F0F9FF');
      final border  = PdfColor.fromHex('#E2E8F0');
      final rowAlt  = PdfColor.fromHex('#F8FAFC');
      final white   = PdfColors.white;

      final isDIY = widget.tourType == 'Build Your Own';
      final itineraryLines = widget.itinerary.isNotEmpty
          ? widget.itinerary.split('\n').where((l) => l.trim().isNotEmpty).toList()
          : <String>[];

      // Fallback highlights for old bookings without itinerary field:
      // tour_type may be "Pkg A" (single) or "Pkg A, Pkg B" (multi-day)
      final fallbackPkgNames = widget.tourType.split(', ').map((s) => s.trim()).toList();
      final fallbackHighlights = <String>[];
      for (final pName in fallbackPkgNames) {
        final p = tourPackages.where((p) => p.name == pName).firstOrNull;
        if (p != null) {
          if (fallbackPkgNames.length > 1) fallbackHighlights.add('${p.name}:');
          fallbackHighlights.addAll(p.highlights);
        }
      }

      // Pre-build itinerary widgets (avoids IIFE issues in pdf package)
      final itineraryWidgets = <pw.Widget>[];
      if (itineraryLines.isNotEmpty) {
        final dayRegex = RegExp(r'^Day (\d+): (.+)$');
        bool firstDay = true;
        for (final line in itineraryLines) {
          final m = dayRegex.firstMatch(line.trim());
          if (m == null) continue;
          final dayNum = m.group(1)!;
          final content = m.group(2)!;
          final matchedPkg = tourPackages.where((p) => p.name == content).firstOrNull;
          final items = matchedPkg != null
              ? matchedPkg.highlights
              : content.split(', ').where((s) => s.trim().isNotEmpty && s != 'Free day' && s != 'No package selected').toList();

          if (!firstDay) {
            itineraryWidgets.add(pw.Container(height: 1, color: border));
          }
          firstDay = false;

          itineraryWidgets.add(pw.Container(
            color: white,
            padding: const pw.EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: pw.Row(children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: pw.BoxDecoration(
                  color: ocean,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
                ),
                child: pw.Text('Day $dayNum',
                    style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: white)),
              ),
              pw.SizedBox(width: 10),
              pw.Expanded(child: pw.Text(content,
                  style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: dark))),
            ]),
          ));

          if (items.isEmpty) {
            itineraryWidgets.add(pw.Container(
              color: rowAlt,
              padding: const pw.EdgeInsets.fromLTRB(36, 5, 16, 10),
              child: pw.Text('Free day / No destinations selected',
                  style: pw.TextStyle(fontSize: 9, color: mid)),
            ));
          } else {
            for (final item in items) {
              itineraryWidgets.add(pw.Container(
                color: rowAlt,
                padding: const pw.EdgeInsets.fromLTRB(36, 5, 16, 5),
                child: pw.Row(children: [
                  pw.Container(width: 5, height: 5,
                      decoration: pw.BoxDecoration(color: teal, shape: pw.BoxShape.circle)),
                  pw.SizedBox(width: 8),
                  pw.Expanded(child: pw.Text(item,
                      style: pw.TextStyle(fontSize: 9, color: mid))),
                ]),
              ));
            }
          }
        }
      }

      pw.Widget sectionLabel(String text) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 10),
        child: pw.Row(children: [
          pw.Container(width: 4, height: 14, color: ocean),
          pw.SizedBox(width: 8),
          pw.Text(text, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: dark, letterSpacing: 1)),
        ]),
      );

      pw.Widget detailRow(String label, String value, {bool alt = false, PdfColor? valueColor}) =>
        pw.Container(
          color: alt ? rowAlt : white,
          padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          child: pw.Row(children: [
            pw.SizedBox(width: 150,
              child: pw.Text(label, style: pw.TextStyle(fontSize: 10, color: mid))),
            pw.Expanded(child: pw.Text(value,
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: valueColor ?? dark))),
          ]),
        );

      doc.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────
            pw.Container(
              width: double.infinity,
              color: ocean,
              child: pw.Stack(children: [
                pw.Positioned(right: 0, top: 0, bottom: 0,
                  child: pw.Container(width: 120, color: teal)),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 48, vertical: 36),
                  child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                    pw.Text('Spoony Travel and Tours',
                        style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: white)),
                    pw.SizedBox(height: 4),
                    pw.Text('OFFICIAL BOOKING ITINERARY',
                        style: pw.TextStyle(fontSize: 9, color: const PdfColor(1,1,1,0.8), letterSpacing: 2)),
                  ]),
                ),
              ]),
            ),

            pw.Expanded(child: pw.Padding(
              padding: const pw.EdgeInsets.fromLTRB(48, 36, 48, 36),
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [

                // ── Reference + Tour name row ──────────────────────────
                pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(16),
                      decoration: pw.BoxDecoration(
                        color: light,
                        border: pw.Border.all(color: PdfColor.fromHex('#BAE6FD')),
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
                      ),
                      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                        pw.Text('BOOKING REFERENCE',
                            style: pw.TextStyle(fontSize: 8, color: ocean, fontWeight: pw.FontWeight.bold, letterSpacing: 1)),
                        pw.SizedBox(height: 6),
                        pw.Text(widget.ref,
                            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: dark, letterSpacing: 2)),
                      ]),
                    ),
                  ),
                  pw.SizedBox(width: 16),
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(16),
                      decoration: pw.BoxDecoration(
                        color: rowAlt,
                        border: pw.Border.all(color: border),
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
                      ),
                      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                        pw.Text('TOUR',
                            style: pw.TextStyle(fontSize: 8, color: mid, fontWeight: pw.FontWeight.bold, letterSpacing: 1)),
                        pw.SizedBox(height: 6),
                        pw.Text(isDIY ? 'Custom DIY Tour' : (widget.tourType.isNotEmpty ? widget.tourType : widget.title),
                            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: dark)),
                      ]),
                    ),
                  ),
                ]),
                pw.SizedBox(height: 24),

                // ── Booking Details ────────────────────────────────────
                sectionLabel('BOOKING DETAILS'),
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: border),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
                  ),
                  child: pw.Column(children: [
                    detailRow('Check-in',      widget.startDate),
                    detailRow('Check-out',     widget.endDate,      alt: true),
                    detailRow('Guests',        widget.guests),
                    detailRow('Accommodation', _accLabel,           alt: true),
                    detailRow('Transport',     _transLabel),
                    pw.Container(
                      color: teal,
                      padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: pw.Row(children: [
                        pw.SizedBox(width: 150,
                          child: pw.Text('Total Amount', style: pw.TextStyle(fontSize: 10, color: white, fontWeight: pw.FontWeight.bold))),
                        pw.Expanded(child: pw.Text(widget.amount.replaceAll('₱', 'PHP '),
                            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: white))),
                      ]),
                    ),
                  ]),
                ),
                pw.SizedBox(height: 20),

                // ── Itinerary / Highlights ─────────────────────────────
                if (itineraryWidgets.isNotEmpty) ...[
                  sectionLabel(isDIY ? 'YOUR CUSTOM ITINERARY' : 'TOUR ITINERARY'),
                  pw.Container(
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: border),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
                    ),
                    child: pw.Column(children: itineraryWidgets),
                  ),
                ] else if (isDIY) ...[
                  sectionLabel('YOUR CUSTOM ITINERARY'),
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(16),
                    decoration: pw.BoxDecoration(
                      color: light,
                      border: pw.Border.all(color: border),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
                    ),
                    child: pw.Text(
                      'You have selected a custom DIY tour. Our team will contact you to finalize your personalized itinerary based on your preferences.',
                      style: pw.TextStyle(fontSize: 10, color: mid, lineSpacing: 4),
                    ),
                  ),
                ] else if (fallbackHighlights.isNotEmpty) ...[
                  sectionLabel('TOUR HIGHLIGHTS'),
                  pw.Container(
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: border),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
                    ),
                    child: pw.Column(
                      children: fallbackHighlights.asMap().entries.map((e) =>
                        pw.Container(
                          color: e.key.isOdd ? rowAlt : white,
                          padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: pw.Row(children: [
                            pw.Container(width: 6, height: 6, decoration: pw.BoxDecoration(color: ocean, shape: pw.BoxShape.circle)),
                            pw.SizedBox(width: 10),
                            pw.Expanded(child: pw.Text(e.value,
                                style: pw.TextStyle(fontSize: 10, color: dark))),
                          ]),
                        ),
                      ).toList(),
                    ),
                  ),
                ],

                pw.Spacer(),

                // ── Footer ────────────────────────────────────────────
                pw.Container(height: 1, color: border),
                pw.SizedBox(height: 10),
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                  pw.Text('Spoony Tours · Cebu, Philippines',
                      style: pw.TextStyle(fontSize: 9, color: mid)),
                  pw.Text('spoonytraveltours@gmail.com',
                      style: pw.TextStyle(fontSize: 9, color: ocean)),
                ]),
              ]),
            )),
          ],
        ),
      ));

      final bytes = await doc.save();
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute('download', 'Spoony_Itinerary_${widget.ref}.pdf')
        ..click();
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not generate PDF: $e')),
        );
      }
    }
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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Status row
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: widget.statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(widget.status,
                style: TextStyle(color: widget.statusColor, fontWeight: FontWeight.w700, fontSize: 11)),
          ),
          const SizedBox(width: 12),
          Text(widget.ref,
              style: const TextStyle(fontSize: 12, color: Color(0xFF8B99A6), fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(widget.amount,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF50C878))),
          const SizedBox(width: 6),
          const Text('Total', style: TextStyle(fontSize: 11, color: Color(0xFF8B99A6))),
        ]),
        const SizedBox(height: 16),
        Text(widget.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF00314F))),
        const SizedBox(height: 16),
        Row(children: [
          _TripDetail(icon: Icons.calendar_today, label: 'Dates',  value: widget.dates),
          _TripDetail(icon: Icons.people,         label: 'Guests', value: widget.guests),
          _TripDetail(icon: Icons.location_on,    label: 'Region', value: 'Cebu, Philippines'),
        ]),

        // Expand toggle
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Row(children: [
            const Text('Booking Details',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF006994))),
            const SizedBox(width: 4),
            AnimatedRotation(
              turns: _expanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF006994)),
            ),
          ]),
        ),

        // Expanded details
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFBAE6FD)),
            ),
            child: Column(children: [
              if (widget.tourType.isNotEmpty) ...[
                Row(children: [
                  const Icon(Icons.tour, size: 16, color: Color(0xFF7C3AED)),
                  const SizedBox(width: 10),
                  const Text('Tour Package',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  const Spacer(),
                  Text(widget.tourType,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF00314F))),
                ]),
                const SizedBox(height: 10),
              ],
              Row(children: [
                const Icon(Icons.hotel, size: 16, color: Color(0xFF0EA5E9)),
                const SizedBox(width: 10),
                const Text('Accommodation',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                const Spacer(),
                Text(_accLabel,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF00314F))),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                const Icon(Icons.directions_car, size: 16, color: Color(0xFF14B8A6)),
                const SizedBox(width: 10),
                const Text('Transport',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                const Spacer(),
                Text(_transLabel,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF00314F))),
              ]),
            ]),
          ),
          crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 220),
        ),

        // Action buttons
        const SizedBox(height: 20),
        Row(children: [
          if (!_isPending) ...[
            Expanded(
              child: FilledButton.icon(
                onPressed: _showQR,
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
          ],
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _downloadPdf,
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
      ]),
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

class _FavoriteSpotTile extends StatelessWidget {
  final String name;
  final VoidCallback onRemove;
  const _FavoriteSpotTile({required this.name, required this.onRemove});

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
          onPressed: onRemove,
          icon: const Icon(Icons.favorite, color: Color(0xFFFF6B4A), size: 20),
          tooltip: 'Remove from favorites',
        ),
        FilledButton(
          onPressed: () => Navigator.pushNamed(context, '/booking'),
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
