import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top nav
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
                      Text('Spoony Travel',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF006994))),
                    ]),
                  ),
                  FilledButton.icon(
                    onPressed: () => Navigator.pushReplacementNamed(context, AuthScreen.routeName),
                    icon: const Icon(Icons.logout, size: 16),
                    label: const Text('Sign Out'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B4A),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sidebar
                  SizedBox(
                    width: 280,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE8EDEF)),
                      ),
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 48,
                            backgroundColor: Color(0xFFE0F7FA),
                            child: Text('JD',
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF006994))),
                          ),
                          const SizedBox(height: 16),
                          const Text('Juan Dela Cruz',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF00314F))),
                          const SizedBox(height: 4),
                          const Text('Premium Member',
                              style: TextStyle(fontSize: 12, color: Color(0xFF8B99A6), fontWeight: FontWeight.w600)),
                          const SizedBox(height: 24),
                          ...List.generate(_tabs.length, (i) {
                            final (icon, label) = _tabs[i];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _MenuItem(
                                icon: icon,
                                label: label,
                                selected: _selectedTab == i,
                                onTap: () => setState(() => _selectedTab = i),
                              ),
                            );
                          }),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.pushReplacementNamed(context, AuthScreen.routeName),
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
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 32),
                  // Main content — switches based on selected tab
                  Expanded(child: _buildContent()),
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

  Widget _buildContent() {
    switch (_selectedTab) {
      case 0:
        return _UpcomingTripsTab();
      case 1:
        return _BookingHistoryTab();
      case 2:
        return _SavedSpotsTab();
      case 3:
        return _AccountSettingsTab();
      default:
        return _UpcomingTripsTab();
    }
  }
}

// ── Tab content widgets ──────────────────────────────────────────────────────

class _UpcomingTripsTab extends StatelessWidget {
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
        _TripCard(
          status: 'CONFIRMED',
          statusColor: Color(0xFF50C878),
          ref: 'CEB-58X9Z',
          amount: '₱7,500',
          paymentLabel: 'Fully Paid via GCash',
          title: 'South Cebu Explorer',
          dates: 'Oct 12 - Oct 14, 2026',
          guests: '2 Adults',
          destinations: 'Oslob, Kawasan, Moalboal',
        ),
      ],
    );
  }
}

class _BookingHistoryTab extends StatelessWidget {
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
        _TripCard(
          status: 'COMPLETED',
          statusColor: Color(0xFF006994),
          ref: 'CEB-21A4B',
          amount: '₱4,200',
          paymentLabel: 'Paid via Maya',
          title: 'Cebu City Cultural Tour',
          dates: 'Mar 5 - Mar 6, 2026',
          guests: '3 Adults',
          destinations: 'Sirao Garden, Temple of Leah, Taoist Temple',
        ),
        const SizedBox(height: 20),
        _TripCard(
          status: 'CANCELLED',
          statusColor: Color(0xFFFF6B4A),
          ref: 'CEB-09Z3X',
          amount: '₱3,800',
          paymentLabel: 'Refunded',
          title: 'North Cebu Island Hop',
          dates: 'Jan 18 - Jan 20, 2026',
          guests: '2 Adults',
          destinations: 'Malapascua, Kalanggaman',
        ),
      ],
    );
  }
}

class _SavedSpotsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Saved Spots',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFF006994))),
        const SizedBox(height: 4),
        const Text('Destinations you\'ve bookmarked.',
            style: TextStyle(fontSize: 14, color: Color(0xFF8B99A6))),
        const SizedBox(height: 28),
        ...['Kawasan Falls', 'Malapascua Island', 'Chocolate Hills', 'Oslob Whale Shark']
            .map((name) => _SavedSpotTile(name: name)),
      ],
    );
  }
}

class _AccountSettingsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
            _SettingsField(label: 'Full Name', value: 'Juan Dela Cruz'),
            const Divider(),
            _SettingsField(label: 'Email', value: 'juan@email.com'),
            const Divider(),
            _SettingsField(label: 'Phone', value: '+63 912 345 6789'),
            const Divider(),
            _SettingsField(label: 'Password', value: '••••••••'),
          ]),
        ),
        const SizedBox(height: 20),
        _SettingsCard(
          child: Column(children: [
            _SettingToggle(label: 'Email notifications', value: true),
            const Divider(),
            _SettingToggle(label: 'SMS alerts', value: false),
            const Divider(),
            _SettingToggle(label: 'Marketing emails', value: true),
          ]),
        ),
      ],
    );
  }
}

// ── Reusable sub-widgets ─────────────────────────────────────────────────────

class _TripCard extends StatelessWidget {
  final String status;
  final Color statusColor;
  final String ref;
  final String amount;
  final String paymentLabel;
  final String title;
  final String dates;
  final String guests;
  final String destinations;

  const _TripCard({
    required this.status,
    required this.statusColor,
    required this.ref,
    required this.amount,
    required this.paymentLabel,
    required this.title,
    required this.dates,
    required this.guests,
    required this.destinations,
  });

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
            _TripDetail(icon: Icons.location_on, label: 'Destinations', value: destinations),
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
  const _SettingsField({required this.label, required this.value});

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
          child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF00314F))),
        ),
        TextButton(onPressed: () {}, child: const Text('Edit')),
      ]),
    );
  }
}

class _SettingToggle extends StatefulWidget {
  final String label;
  final bool value;
  const _SettingToggle({required this.label, required this.value});

  @override
  State<_SettingToggle> createState() => _SettingToggleState();
}

class _SettingToggleState extends State<_SettingToggle> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Expanded(
          child: Text(widget.label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF00314F))),
        ),
        Switch(
          value: _value,
          onChanged: (v) => setState(() => _value = v),
          activeThumbColor: const Color(0xFF00BCD4),
        ),
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
