import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/cebu_data.dart';
import '../models.dart';
import 'home_screen.dart';

// ── Colors ────────────────────────────────────────────────────────────────────
const _kOcean = Color(0xFF0EA5E9);
const _kTeal  = Color(0xFF14B8A6);
const _kGold  = Color(0xFFF59E0B);
const _kDark  = Color(0xFF0F172A);
const _kMid   = Color(0xFF64748B);
const _kBg    = Color(0xFFF8FAFC);

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

  String _generateRef() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rng = Random();
    final code = List.generate(5, (_) => chars[rng.nextInt(chars.length)]).join();
    return 'CEB-$code';
  }

  Future<void> _completeBooking() async {
    if (_pkg == null || _startDate == null || _endDate == null) return;
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to complete your booking.')),
      );
      return;
    }
    setState(() => _isProcessing = true);
    try {
      final ref = _generateRef();
      final data = await Supabase.instance.client.from('bookings').insert({
        'user_id': user.id,
        'user_email': user.email ?? '',
        'guest_count': _guestCount,
        'start_date': _startDate!.toIso8601String().substring(0, 10),
        'end_date': _endDate!.toIso8601String().substring(0, 10),
        'total_amount': _grandTotal,
        'accommodation_type': _accommodationId,
        'transport_type': _transportId,
        'reference_code': ref,
        'status': 'pending',
      }).select().single();
      final bookingRef = (data['reference_code'] as String?) ?? ref;
      if (mounted) setState(() { _isProcessing = false; _bookingRef = bookingRef; _bookingSuccess = true; });
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Booking failed: $e')));
      }
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_bookingSuccess) return _buildSuccessScreen();

    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          SpoonyNavBar(current: 'booking'),
          Expanded(
            child: LayoutBuilder(builder: (context, constraints) {
              final mobile = constraints.maxWidth < 900;
              final hPad = mobile ? 20.0 : 80.0;
              return Padding(
                padding: EdgeInsets.fromLTRB(hPad, 28, hPad, 0),
                child: mobile ? _mobilLayout() : _desktopLayout(),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _mobilLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _pageHeader(),
        const SizedBox(height: 20),
        _StepIndicator(step: _step),
        const SizedBox(height: 16),
        Expanded(child: _stepContent()),
        const SizedBox(height: 14),
        _navRow(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _desktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _pageHeader(),
              const SizedBox(height: 24),
              _StepIndicator(step: _step),
              const SizedBox(height: 24),
              Expanded(child: _stepContent()),
              const SizedBox(height: 18),
              _navRow(),
              const SizedBox(height: 24),
            ],
          ),
        ),
        const SizedBox(width: 32),
        SizedBox(
          width: 300,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 70),
              child: _summaryPanel(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _pageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('Plan Your Adventure',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: _kDark)),
        SizedBox(height: 4),
        Text('4 steps to your perfect Cebu experience.',
            style: TextStyle(fontSize: 13, color: _kMid)),
      ],
    );
  }

  Widget _navRow() {
    return Row(children: [
      if (_step > 1) ...[
        Expanded(
          child: OutlinedButton(
            onPressed: () => setState(() => _step--),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: _kMid),
              foregroundColor: _kMid,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('← Back'),
          ),
        ),
        const SizedBox(width: 14),
      ],
      Expanded(
        flex: 2,
        child: FilledButton(
          onPressed: _canProceed()
              ? (_step < 4
                  ? () => setState(() => _step++)
                  : _isProcessing ? null : _completeBooking)
              : null,
          style: FilledButton.styleFrom(
            backgroundColor: _kOcean,
            disabledBackgroundColor: const Color(0xFFCBD5E1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: _isProcessing
              ? const SizedBox(
                  height: 18, width: 18,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(
                  _step < 4 ? 'Continue →' : 'Confirm Booking',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        ),
      ),
    ]);
  }

  Widget _stepContent() {
    return switch (_step) {
      1 => _buildDetailsStep(),
      2 => _buildPackageStep(),
      3 => _buildExtrasStep(),
      _ => _buildReviewStep(),
    };
  }

  // ── Summary sidebar ───────────────────────────────────────────────────────

  Widget _summaryPanel() {
    final fmt = DateFormat('MMM d');
    final pkg = _pkg;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white.withValues(alpha: 0.92), Colors.white.withValues(alpha: 0.68)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 24, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_kOcean, _kTeal]),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            const Text('Booking Summary',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _kDark)),
          ]),
          const SizedBox(height: 20),
          _SummaryRow(
            icon: Icons.calendar_today,
            label: _startDate == null
                ? 'No dates yet'
                : '${fmt.format(_startDate!)} – ${_endDate != null ? fmt.format(_endDate!) : '?'} · $_nights nights',
          ),
          _SummaryRow(
            icon: Icons.group,
            label: '$_guestCount Guest${_guestCount > 1 ? 's' : ''}',
          ),
          _SummaryRow(
            icon: _tourType == TourType.joiner ? Icons.group_outlined : Icons.star_outlined,
            label: _tourType == TourType.joiner ? 'Joiner Tour' : 'Premium Exclusive',
          ),
          if (pkg != null)
            _SummaryRow(icon: Icons.tour_rounded, label: pkg.name),
          const Divider(height: 28),
          if (pkg != null)
            _SummaryCostRow(label: 'Package', value: '₱${_pkgTotal.toStringAsFixed(0)}'),
          _SummaryCostRow(label: 'Accommodation', value: '₱${_accTotal.toStringAsFixed(0)}'),
          _SummaryCostRow(label: 'Transport', value: '₱${_transTotal.toStringAsFixed(0)}'),
          if (_addOnsTotal > 0)
            _SummaryCostRow(label: 'Add-ons', value: '₱${_addOnsTotal.toStringAsFixed(0)}'),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: _kDark)),
              Text('₱${_grandTotal.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _kTeal)),
            ],
          ),
          const SizedBox(height: 4),
          Text('$_nights night(s) · $_guestCount guest(s)',
              style: const TextStyle(fontSize: 11, color: _kMid)),
        ],
      ),
    );
  }

  // ── Step 1: Dates + Guests + Tour Type ──────────────────────────────────

  Widget _buildDetailsStep() {
    final fmt = DateFormat('MMM d, yyyy');
    return _GlassCard(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Plan your trip',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _kDark)),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                child: _DateButton(
                  label: _startDate == null ? 'Start Date' : fmt.format(_startDate!),
                  onTap: () => _selectDate(true),
                  filled: _startDate != null,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _DateButton(
                  label: _endDate == null ? 'End Date' : fmt.format(_endDate!),
                  onTap: () => _selectDate(false),
                  filled: _endDate != null,
                ),
              ),
            ]),
            const SizedBox(height: 26),
            const Text('Party size',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _kDark)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(children: [
                IconButton(
                  onPressed: () => setState(() { if (_guestCount > 1) _guestCount--; }),
                  icon: const Icon(Icons.remove_circle_outline, color: _kOcean),
                ),
                Expanded(
                  child: Center(
                    child: Text('$_guestCount Guest${_guestCount > 1 ? 's' : ''}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _kDark)),
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _guestCount++),
                  icon: const Icon(Icons.add_circle_outline, color: _kOcean),
                ),
              ]),
            ),
            const SizedBox(height: 26),
            const Text('Tour type',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _kDark)),
            const SizedBox(height: 4),
            const Text('Choose how you want to experience Cebu.',
                style: TextStyle(fontSize: 13, color: _kMid)),
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

  // ── Step 2: Package Selection ────────────────────────────────────────────

  Widget _buildPackageStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _tourType == TourType.joiner ? 'Joiner Tour Packages' : 'Premium Exclusive Packages',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _kDark),
        ),
        const SizedBox(height: 2),
        Text(
          _tourType == TourType.joiner
              ? 'Travel with fellow adventurers — great value, great fun.'
              : 'Your group only — fully private and personalised.',
          style: const TextStyle(fontSize: 13, color: _kMid),
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

  // ── Step 3: Extras ───────────────────────────────────────────────────────

  Widget _buildExtrasStep() {
    return _GlassCard(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Customize your trip',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _kDark)),
            const SizedBox(height: 18),
            const Text('Add-ons',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _kDark)),
            const SizedBox(height: 2),
            const Text('Optional extras to enhance your experience.',
                style: TextStyle(fontSize: 12, color: _kMid)),
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
            const Divider(color: Color(0xFFE2E8F0)),
            const SizedBox(height: 14),
            const Text('Accommodation',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _kDark)),
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
                      color: sel ? _kOcean : Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: sel ? _kOcean : const Color(0xFFE2E8F0),
                        width: sel ? 2 : 1,
                      ),
                      boxShadow: sel
                          ? [BoxShadow(color: _kOcean.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 3))]
                          : [],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: sel ? Colors.white : _kDark,
                            )),
                        const SizedBox(height: 2),
                        Text('₱${a.nightlyRate.toInt()}/night',
                            style: TextStyle(
                              fontSize: 11,
                              color: sel ? Colors.white70 : _kMid,
                            )),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Divider(color: Color(0xFFE2E8F0)),
            const SizedBox(height: 14),
            const Text('Transport',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _kDark)),
            const SizedBox(height: 8),
            RadioGroup<String>(
              groupValue: _transportId,
              onChanged: (v) { if (v != null) setState(() => _transportId = v); },
              child: Column(
                children: transports.map((t) => RadioListTile<String>(
                  value: t.id,
                  title: Text(t.title,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: _kDark)),
                  subtitle: Text(t.description, style: const TextStyle(fontSize: 12, color: _kMid)),
                  secondary: Text('₱${t.price.toInt()}',
                      style: const TextStyle(color: _kOcean, fontWeight: FontWeight.bold)),
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

  // ── Step 4: Review ────────────────────────────────────────────────────────

  Widget _buildReviewStep() {
    final pkg = _pkg;
    final fmt = DateFormat('MMM d, yyyy');
    return _GlassCard(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Review & confirm',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _kDark)),
            const SizedBox(height: 20),
            if (pkg != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _kOcean.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _kOcean.withValues(alpha: 0.2)),
                ),
                child: Row(children: [
                  const Icon(Icons.tour_rounded, color: _kOcean, size: 26),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(pkg.name,
                          style: const TextStyle(fontWeight: FontWeight.w800, color: _kOcean)),
                      Text(
                        '${pkg.durationDays}-day · ${pkg.region} · '
                        '${_tourType == TourType.joiner ? 'Joiner Tour' : 'Premium Exclusive'}',
                        style: const TextStyle(fontSize: 12, color: _kMid),
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
            const Text('Payment method',
                style: TextStyle(fontWeight: FontWeight.w700, color: _kDark)),
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
        const Divider(height: 28, color: Color(0xFFE2E8F0)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Estimated total',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: _kDark)),
            Text('₱${_grandTotal.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _kTeal)),
          ],
        ),
        const SizedBox(height: 4),
        Text('$_nights night(s) · $_guestCount guest(s)',
            style: const TextStyle(color: _kMid, fontSize: 12)),
      ],
    );
  }

  Widget _buildCostBreakdown() {
    final pkg = _pkg;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(height: 8, color: Color(0xFFE2E8F0)),
        const SizedBox(height: 12),
        const Text('Cost breakdown',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: _kMid)),
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
        const Divider(height: 20, color: Color(0xFFE2E8F0)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: _kDark)),
            Text('₱${_grandTotal.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: _kTeal)),
          ],
        ),
      ],
    );
  }

  // ── Success screen ────────────────────────────────────────────────────────

  Widget _buildSuccessScreen() {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          SpoonyNavBar(current: 'booking'),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: _GlassCard(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(
                            color: _kTeal.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_circle_rounded, size: 48, color: _kTeal),
                        ),
                        const SizedBox(height: 22),
                        const Text('Booking Confirmed!',
                            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: _kDark)),
                        const SizedBox(height: 10),
                        const Text(
                          'Your Cebu adventure is set. A confirmation email and QR ticket have been generated.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: _kMid, height: 1.6),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: _kOcean.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _kOcean.withValues(alpha: 0.2)),
                          ),
                          child: Column(children: [
                            const Text('Booking Reference',
                                style: TextStyle(color: _kOcean, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 8),
                            Text(_bookingRef,
                                style: const TextStyle(
                                    fontSize: 26, fontWeight: FontWeight.w900, color: _kDark,
                                    letterSpacing: 2)),
                          ]),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: _kOcean,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              minimumSize: const Size.fromHeight(52),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Back to Home',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tour type selector ────────────────────────────────────────────────────────

class _TourTypeCard extends StatelessWidget {
  final TourType type;
  final bool selected;
  final VoidCallback onTap;
  const _TourTypeCard({required this.type, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isJoiner = type == TourType.joiner;
    final color = isJoiner ? _kOcean : _kGold;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? color : const Color(0xFFE2E8F0), width: selected ? 2 : 1),
          boxShadow: selected
              ? [BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 10, offset: const Offset(0, 3))]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(isJoiner ? Icons.group_rounded : Icons.star_rounded, color: color, size: 22),
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
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: color)),
            const SizedBox(height: 4),
            Text(
              isJoiner
                  ? 'Share the experience with fellow travelers.'
                  : 'Your group only — private & personalised.',
              style: const TextStyle(fontSize: 11, color: _kMid, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Package card ──────────────────────────────────────────────────────────────

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
    final accentColor = tourType == TourType.joiner ? _kOcean : _kGold;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: selected
                ? [accentColor.withValues(alpha: 0.08), accentColor.withValues(alpha: 0.03)]
                : [Colors.white.withValues(alpha: 0.88), Colors.white.withValues(alpha: 0.60)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? accentColor : const Color(0xFFE2E8F0),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [BoxShadow(color: accentColor.withValues(alpha: 0.15), blurRadius: 14, offset: const Offset(0, 4))]
              : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: Stack(
                children: [
                  Image.network(
                    package.imageUrl,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      height: 140,
                      color: _kOcean.withValues(alpha: 0.1),
                      child: const Icon(Icons.landscape, size: 48, color: _kOcean),
                    ),
                  ),
                  Positioned(
                    top: 10, left: 10,
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
                      top: 10, right: 10,
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
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _kDark)),
                          const SizedBox(height: 2),
                          Text(package.tagline,
                              style: const TextStyle(fontSize: 12, color: _kMid)),
                        ]),
                      ),
                      const SizedBox(width: 10),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text('₱${price.toStringAsFixed(0)}',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: accentColor)),
                        const Text('/ person',
                            style: TextStyle(fontSize: 10, color: _kMid)),
                      ]),
                    ],
                  ),
                  const SizedBox(height: 10),
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
                                  style: TextStyle(fontSize: 11, color: accentColor, fontWeight: FontWeight.w600)),
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
  const _AddOnTile({required this.addOn, required this.selected, required this.guests, required this.onToggle});

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
          color: selected ? _kOcean.withValues(alpha: 0.07) : Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? _kOcean : const Color(0xFFE2E8F0),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(children: [
          Text(addOn.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(addOn.title,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: _kDark)),
              Text(
                addOn.perPerson
                    ? '₱${addOn.price.toInt()} × $guests = ₱${total.toInt()}'
                    : '₱${total.toInt()} (per group)',
                style: const TextStyle(fontSize: 12, color: _kMid),
              ),
            ]),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: selected ? _kOcean : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(color: selected ? _kOcean : const Color(0xFFCBD5E1)),
            ),
            child: Icon(Icons.check, color: selected ? Colors.white : Colors.transparent, size: 14),
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
        final done = i + 1 < step;
        final active = i + 1 == step;
        final color = (done || active) ? _kOcean : const Color(0xFFE2E8F0);
        return [
          Row(children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: done ? _kOcean : (active ? _kOcean.withValues(alpha: 0.12) : const Color(0xFFF1F5F9)),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child: Center(
                child: done
                    ? const Icon(Icons.check, color: Colors.white, size: 14)
                    : Text('${i + 1}',
                        style: TextStyle(
                          color: active ? _kOcean : _kMid,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        )),
              ),
            ),
            const SizedBox(width: 6),
            Text(labels[i],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                  color: active ? _kDark : _kMid,
                )),
          ]),
          if (i < 3)
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      i + 1 < step ? _kOcean : const Color(0xFFE2E8F0),
                      i + 2 <= step ? _kOcean : const Color(0xFFE2E8F0),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
        ];
      }).expand((w) => w).toList(),
    );
  }
}

// ── Glass card ────────────────────────────────────────────────────────────────

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white.withValues(alpha: 0.90), Colors.white.withValues(alpha: 0.65)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 6)),
        ],
      ),
      child: child,
    );
  }
}

// ── Date button ───────────────────────────────────────────────────────────────

class _DateButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool filled;
  const _DateButton({required this.label, required this.onTap, required this.filled});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        decoration: BoxDecoration(
          color: filled ? _kOcean.withValues(alpha: 0.07) : Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: filled ? _kOcean : const Color(0xFFE2E8F0), width: filled ? 1.5 : 1),
        ),
        child: Row(children: [
          Icon(Icons.calendar_month_rounded, color: filled ? _kOcean : _kMid, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(label,
              style: TextStyle(
                color: filled ? _kDark : _kMid,
                fontWeight: filled ? FontWeight.w600 : FontWeight.w400,
                fontSize: 13,
              ))),
        ]),
      ),
    );
  }
}

// ── Summary row (sidebar) ─────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SummaryRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: [
        Icon(icon, size: 14, color: _kMid),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: _kMid))),
      ]),
    );
  }
}

class _SummaryCostRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryCostRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: _kMid)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _kDark)),
        ],
      ),
    );
  }
}

// ── Small shared widgets ──────────────────────────────────────────────────────

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
          Text(label, style: const TextStyle(color: _kMid, fontSize: 13)),
          Flexible(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.w700, color: _kDark, fontSize: 13),
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
              Text(label, style: const TextStyle(fontSize: 13, color: _kDark)),
              if (sub != null)
                Text(sub!, style: const TextStyle(fontSize: 11, color: _kMid)),
            ]),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: _kDark)),
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
      label: Text(label,
          style: const TextStyle(fontWeight: FontWeight.w600, color: _kOcean, fontSize: 12)),
      backgroundColor: _kOcean.withValues(alpha: 0.08),
      side: BorderSide(color: _kOcean.withValues(alpha: 0.2)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}
