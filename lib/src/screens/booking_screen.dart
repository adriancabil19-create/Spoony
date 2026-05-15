import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/cebu_data.dart';
import '../models.dart';
import '../services/api_service.dart';

class BookingScreen extends StatefulWidget {
  static const routeName = '/booking';
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _step = 1;
  TourType _tourType = TourType.joiner;
  String? _packageId;
  String _accommodationId = 'acc_standard';
  String _transportId = 'trans_shared_van';
  final Set<String> _selectedAddOnIds = {};
  int _guestCount = 2;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _bookingSuccess = false;
  bool _isProcessing = false;
  String _bookingRef = '';

  TourPackage? get _pkg =>
      _packageId == null ? null : tourPackages.firstWhere((p) => p.id == _packageId);

  AccommodationOption get _accommodation =>
      accommodations.firstWhere((a) => a.id == _accommodationId);

  TransportOption get _transport =>
      transports.firstWhere((t) => t.id == _transportId);

  int get _nights {
    if (_startDate == null || _endDate == null) return 1;
    final n = _endDate!.difference(_startDate!).inDays;
    return n < 1 ? 1 : n;
  }

  double get _pkgTotal {
    final p = _pkg;
    if (p == null) return 0;
    final ppx = _tourType == TourType.joiner ? p.joinerPricePerPerson : p.premiumPricePerPerson;
    return ppx * _guestCount;
  }

  double get _addOnsTotal => tourAddOns
      .where((a) => _selectedAddOnIds.contains(a.id))
      .fold(0.0, (sum, a) => sum + (a.perPerson ? a.price * _guestCount : a.price));

  double get _accTotal => _accommodation.nightlyRate * _guestCount * _nights;
  double get _transTotal => _transport.price;
  double get _grandTotal => _pkgTotal + _addOnsTotal + _accTotal + _transTotal;

  bool _canProceed() {
    switch (_step) {
      case 1: return _startDate != null && _endDate != null;
      case 2: return _packageId != null;
      default: return true;
    }
  }

  Future<void> _selectDate(bool isStart) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(picked)) _endDate = null;
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _completeBooking() async {
    if (_pkg == null || _startDate == null || _endDate == null) return;
    if (Supabase.instance.client.auth.currentSession == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to complete your booking.')),
      );
      return;
    }
    setState(() => _isProcessing = true);
    try {
      final result = await ApiService.createBooking({
        'destinationIds': [],
        'guestCount': _guestCount,
        'startDate': _startDate!.toIso8601String().substring(0, 10),
        'endDate': _endDate!.toIso8601String().substring(0, 10),
        'totalAmount': _grandTotal,
        'accommodationType': _accommodationId,
        'transportType': _transportId,
        'tourId': _packageId,
      });
      final ref =
          (result['booking'] as Map<String, dynamic>)['reference_code'] as String? ?? 'CEB-ERROR';
      if (mounted) setState(() { _isProcessing = false; _bookingRef = ref; _bookingSuccess = true; });
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Booking failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_bookingSuccess) return _buildSuccessScreen();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan Your Cebu Adventure'),
        backgroundColor: const Color(0xFF006994),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _StepIndicator(step: _step),
              const SizedBox(height: 20),
              Expanded(
                child: switch (_step) {
                  1 => _buildDetailsStep(),
                  2 => _buildPackageStep(),
                  3 => _buildExtrasStep(),
                  _ => _buildReviewStep(),
                },
              ),
              const SizedBox(height: 16),
              Row(children: [
                if (_step > 1) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _step--),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF006994)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 14),
                ],
                Expanded(
                  child: FilledButton(
                    onPressed: _canProceed()
                        ? (_step < 4
                            ? () => setState(() => _step++)
                            : _isProcessing ? null : _completeBooking)
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF00BCD4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            height: 18, width: 18,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(
                            _step < 4 ? 'Continue' : 'Confirm Booking',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Complete'),
        backgroundColor: const Color(0xFF006994),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, size: 90, color: Color(0xFF50C878)),
                const SizedBox(height: 22),
                const Text('Booking Confirmed!',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF00314F))),
                const SizedBox(height: 12),
                const Text(
                  'Your Cebu adventure is set. A confirmation email and QR ticket have been generated.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF5D6D7A), height: 1.6),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F7FA),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(children: [
                    const Text('Booking Reference',
                        style: TextStyle(color: Color(0xFF006994), fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(_bookingRef,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF00BCD4))),
                  ]),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006994),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    minimumSize: const Size.fromHeight(54),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Back to Home',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Step 1: Dates + Guests + Tour Type ──────────────────────────────────────

  Widget _buildDetailsStep() {
    final fmt = DateFormat('MMM d, yyyy');
    return _Card(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Plan your trip',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _selectDate(true),
                  icon: const Icon(Icons.calendar_month),
                  label: Text(_startDate == null ? 'Start Date' : fmt.format(_startDate!)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _selectDate(false),
                  icon: const Icon(Icons.calendar_month),
                  label: Text(_endDate == null ? 'End Date' : fmt.format(_endDate!)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 26),
            const Text('Party size', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(children: [
              IconButton(
                onPressed: () => setState(() { if (_guestCount > 1) _guestCount--; }),
                icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF006994)),
              ),
              Expanded(
                child: Center(
                  child: Text('$_guestCount Guest${_guestCount > 1 ? 's' : ''}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _guestCount++),
                icon: const Icon(Icons.add_circle_outline, color: Color(0xFF006994)),
              ),
            ]),
            const SizedBox(height: 26),
            const Text('Tour type', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            const Text('Choose how you want to experience Cebu.',
                style: TextStyle(fontSize: 13, color: Color(0xFF8B99A6))),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: _TourTypeCard(
                  type: TourType.joiner,
                  selected: _tourType == TourType.joiner,
                  onTap: () => setState(() => _tourType = TourType.joiner),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TourTypeCard(
                  type: TourType.premium,
                  selected: _tourType == TourType.premium,
                  onTap: () => setState(() => _tourType = TourType.premium),
                ),
              ),
            ]),
            if (_startDate != null && _endDate != null) ...[
              const SizedBox(height: 20),
              _buildSummaryBar(),
            ],
          ],
        ),
      ),
    );
  }

  // ── Step 2: Package Selection ────────────────────────────────────────────────

  Widget _buildPackageStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _tourType == TourType.joiner ? 'Joiner Tour Packages' : 'Premium Exclusive Packages',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          _tourType == TourType.joiner
              ? 'Travel with fellow adventurers — great value, great fun.'
              : 'Your group only — fully private and personalised.',
          style: const TextStyle(fontSize: 13, color: Color(0xFF8B99A6)),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: ListView.separated(
            itemCount: tourPackages.length,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (ctx, i) {
              final pkg = tourPackages[i];
              final selected = pkg.id == _packageId;
              final price = _tourType == TourType.joiner
                  ? pkg.joinerPricePerPerson
                  : pkg.premiumPricePerPerson;
              return _PackageCard(
                package: pkg,
                price: price,
                selected: selected,
                tourType: _tourType,
                onTap: () => setState(() => _packageId = pkg.id),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Step 3: Add-ons + Accommodation + Transport ──────────────────────────────

  Widget _buildExtrasStep() {
    return _Card(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Customize your trip',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 18),

            // Add-ons
            const Text('Add-ons', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            const Text('Optional extras to enhance your experience.',
                style: TextStyle(fontSize: 12, color: Color(0xFF8B99A6))),
            const SizedBox(height: 12),
            for (final addOn in tourAddOns)
              _AddOnTile(
                addOn: addOn,
                selected: _selectedAddOnIds.contains(addOn.id),
                guests: _guestCount,
                onToggle: () => setState(() {
                  _selectedAddOnIds.contains(addOn.id)
                      ? _selectedAddOnIds.remove(addOn.id)
                      : _selectedAddOnIds.add(addOn.id);
                }),
              ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 14),

            // Accommodation
            const Text('Accommodation', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: accommodations.map((a) {
                final sel = a.id == _accommodationId;
                return GestureDetector(
                  onTap: () => setState(() => _accommodationId = a.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: sel ? const Color(0xFF006994) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: sel ? const Color(0xFF006994) : const Color(0xFFE8EDEF),
                        width: sel ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: sel ? Colors.white : const Color(0xFF00314F),
                            )),
                        const SizedBox(height: 2),
                        Text('₱${a.nightlyRate.toInt()}/night',
                            style: TextStyle(
                              fontSize: 11,
                              color: sel ? Colors.white70 : const Color(0xFF8B99A6),
                            )),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 14),

            // Transport
            const Text('Transport', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            RadioGroup<String>(
              groupValue: _transportId,
              onChanged: (v) { if (v != null) setState(() => _transportId = v); },
              child: Column(
                children: transports.map((t) => RadioListTile<String>(
                  value: t.id,
                  title: Text(t.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text(t.description, style: const TextStyle(fontSize: 12)),
                  secondary: Text('₱${t.price.toInt()}',
                      style: const TextStyle(
                          color: Color(0xFF006994), fontWeight: FontWeight.bold)),
                  contentPadding: EdgeInsets.zero,
                )).toList(),
              ),
            ),

            const SizedBox(height: 12),
            _buildSummaryBar(),
          ],
        ),
      ),
    );
  }

  // ── Step 4: Review + Confirm ─────────────────────────────────────────────────

  Widget _buildReviewStep() {
    final pkg = _pkg;
    final fmt = DateFormat('MMM d, yyyy');
    return _Card(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Review & confirm',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            if (pkg != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F7FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(children: [
                  const Icon(Icons.tour, color: Color(0xFF006994), size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(pkg.name,
                          style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF006994))),
                      Text(
                        '${pkg.durationDays}-day • ${pkg.region} • '
                        '${_tourType == TourType.joiner ? 'Joiner Tour' : 'Premium Exclusive'}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF5D6D7A)),
                      ),
                    ]),
                  ),
                ]),
              ),
              const SizedBox(height: 16),
            ],

            _SummaryTile(
              label: 'Dates',
              value: '${_startDate != null ? fmt.format(_startDate!) : '—'} → '
                  '${_endDate != null ? fmt.format(_endDate!) : '—'}',
            ),
            _SummaryTile(label: 'Guests', value: '$_guestCount person(s) · $_nights night(s)'),
            _SummaryTile(
              label: 'Tour type',
              value: _tourType == TourType.joiner ? 'Joiner Tour' : 'Premium Exclusive',
            ),
            _SummaryTile(label: 'Package', value: pkg?.name ?? '—'),
            _SummaryTile(label: 'Accommodation', value: _accommodation.title),
            _SummaryTile(label: 'Transport', value: _transport.title),
            if (_selectedAddOnIds.isNotEmpty)
              _SummaryTile(
                label: 'Add-ons',
                value: tourAddOns
                    .where((a) => _selectedAddOnIds.contains(a.id))
                    .map((a) => a.title)
                    .join(', '),
              ),

            const SizedBox(height: 16),
            const Text('Payment method', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            const Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _PaymentChip(label: 'GCash'),
                _PaymentChip(label: 'Maya'),
                _PaymentChip(label: 'Card'),
                _PaymentChip(label: 'Bank Transfer'),
              ],
            ),
            const SizedBox(height: 20),
            _buildCostBreakdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(height: 28, thickness: 1.2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Estimated total',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('₱${_grandTotal.toStringAsFixed(0)}',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF50C878))),
          ],
        ),
        const SizedBox(height: 4),
        Text('$_nights night(s) · $_guestCount guest(s)',
            style: const TextStyle(color: Color(0xFF5D6D7A), fontSize: 12)),
      ],
    );
  }

  Widget _buildCostBreakdown() {
    final pkg = _pkg;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(height: 8, thickness: 1.2),
        const SizedBox(height: 12),
        const Text('Cost breakdown',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF5D6D7A))),
        const SizedBox(height: 10),
        if (pkg != null)
          _BreakdownLine(
            label: 'Package (${pkg.name})',
            value: '₱${_pkgTotal.toStringAsFixed(0)}',
            sub: '₱${(_tourType == TourType.joiner ? pkg.joinerPricePerPerson : pkg.premiumPricePerPerson).toStringAsFixed(0)} × $_guestCount pax',
          ),
        if (_addOnsTotal > 0)
          _BreakdownLine(label: 'Add-ons', value: '₱${_addOnsTotal.toStringAsFixed(0)}'),
        _BreakdownLine(
          label: 'Accommodation (${_accommodation.title})',
          value: '₱${_accTotal.toStringAsFixed(0)}',
          sub: '₱${_accommodation.nightlyRate.toStringAsFixed(0)} × $_guestCount pax × $_nights nights',
        ),
        _BreakdownLine(
          label: 'Transport (${_transport.title})',
          value: '₱${_transTotal.toStringAsFixed(0)}',
        ),
        const Divider(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text('₱${_grandTotal.toStringAsFixed(0)}',
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF50C878))),
          ],
        ),
      ],
    );
  }
}

// ── Tour type selector card ──────────────────────────────────────────────────

class _TourTypeCard extends StatelessWidget {
  final TourType type;
  final bool selected;
  final VoidCallback onTap;

  const _TourTypeCard({required this.type, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isJoiner = type == TourType.joiner;
    final color = isJoiner ? const Color(0xFF00BCD4) : const Color(0xFFFF8C00);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? color : const Color(0xFFE8EDEF), width: selected ? 2 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(isJoiner ? Icons.group : Icons.star, color: color, size: 22),
              const SizedBox(width: 8),
              if (selected)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
                  child: const Text('Selected',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                ),
            ]),
            const SizedBox(height: 10),
            Text(isJoiner ? 'Joiner Tour' : 'Premium Tour',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: color)),
            const SizedBox(height: 4),
            Text(
              isJoiner
                  ? 'Share the experience with fellow travelers. Best value.'
                  : 'Your group only — private, exclusive, fully personalised.',
              style: const TextStyle(fontSize: 11, color: Color(0xFF8B99A6), height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Package card ─────────────────────────────────────────────────────────────

class _PackageCard extends StatelessWidget {
  final TourPackage package;
  final double price;
  final bool selected;
  final TourType tourType;
  final VoidCallback onTap;

  const _PackageCard({
    required this.package,
    required this.price,
    required this.selected,
    required this.tourType,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = tourType == TourType.joiner ? const Color(0xFF00BCD4) : const Color(0xFFFF8C00);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? accentColor : const Color(0xFFE8EDEF),
            width: selected ? 2.5 : 1,
          ),
          boxShadow: selected
              ? [BoxShadow(color: accentColor.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 4))]
              : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  Image.network(
                    package.imageUrl,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      height: 140,
                      color: const Color(0xFFE0F7FA),
                      child: const Icon(Icons.landscape, size: 48, color: Color(0xFF006994)),
                    ),
                  ),
                  // Duration badge
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${package.durationDays} Day${package.durationDays > 1 ? 's' : ''}',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  if (selected)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
                        child: const Icon(Icons.check, color: Colors.white, size: 14),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(package.name,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF00314F))),
                          const SizedBox(height: 2),
                          Text(package.tagline,
                              style: const TextStyle(fontSize: 12, color: Color(0xFF8B99A6))),
                        ]),
                      ),
                      const SizedBox(width: 10),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text('₱${price.toStringAsFixed(0)}',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w800, color: accentColor)),
                        const Text('/ person',
                            style: TextStyle(fontSize: 10, color: Color(0xFF8B99A6))),
                      ]),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: package.highlights
                        .map((h) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(h,
                                  style: TextStyle(
                                      fontSize: 11, color: accentColor, fontWeight: FontWeight.w600)),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Add-on tile ───────────────────────────────────────────────────────────────

class _AddOnTile extends StatelessWidget {
  final TourAddOn addOn;
  final bool selected;
  final int guests;
  final VoidCallback onToggle;

  const _AddOnTile({
    required this.addOn,
    required this.selected,
    required this.guests,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final total = addOn.perPerson ? addOn.price * guests : addOn.price;
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE0F7FA) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF00BCD4) : const Color(0xFFE8EDEF),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(children: [
          Text(addOn.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(addOn.title,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF00314F))),
              Text(
                addOn.perPerson
                    ? '₱${addOn.price.toInt()} × $guests = ₱${total.toInt()}'
                    : '₱${total.toInt()} (per group)',
                style: const TextStyle(fontSize: 12, color: Color(0xFF8B99A6)),
              ),
            ]),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFF00BCD4) : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                  color: selected ? const Color(0xFF00BCD4) : const Color(0xFFCCCCCC)),
            ),
            child: Icon(Icons.check,
                color: selected ? Colors.white : Colors.transparent, size: 14),
          ),
        ]),
      ),
    );
  }
}

// ── Step indicator ────────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int step;
  const _StepIndicator({required this.step});

  @override
  Widget build(BuildContext context) {
    const labels = ['Details', 'Package', 'Extras', 'Review'];
    return Row(
      children: List.generate(4, (i) {
        final active = i + 1 <= step;
        return [
          Row(children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: active ? const Color(0xFF00BCD4) : const Color(0xFFE5F7FB),
              child: Text('${i + 1}',
                  style: TextStyle(color: active ? Colors.white : const Color(0xFF00314F), fontSize: 13)),
            ),
            const SizedBox(width: 6),
            Text(labels[i],
                style: TextStyle(
                    fontSize: 12,
                    color: active ? const Color(0xFF00314F) : const Color(0xFF8A9BA9))),
          ]),
          if (i < 3)
            Expanded(child: Container(height: 1, color: const Color(0xFFE5F7FB))),
        ];
      }).expand((w) => w).toList(),
    );
  }
}

// ── Shared card ───────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8EDEF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ── Small widgets ─────────────────────────────────────────────────────────────

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF5D6D7A), fontSize: 13)),
          Flexible(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00314F), fontSize: 13),
                textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }
}

class _BreakdownLine extends StatelessWidget {
  final String label;
  final String value;
  final String? sub;

  const _BreakdownLine({required this.label, required this.value, this.sub});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF00314F))),
              if (sub != null)
                Text(sub!, style: const TextStyle(fontSize: 11, color: Color(0xFF8B99A6))),
            ]),
          ),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF00314F))),
        ],
      ),
    );
  }
}

class _PaymentChip extends StatelessWidget {
  final String label;
  const _PaymentChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      backgroundColor: const Color(0xFFE0F7FA),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}
