import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/cebu_data.dart';
import '../models.dart';
import '../services/distance_service.dart';
import '../services/api_service.dart';

class BookingScreen extends StatefulWidget {
  static const routeName = '/booking';
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _step = 1;
  final Set<String> _selectedSpotIds = {};
  String _accommodationId = 'acc_standard';
  String _transportId = 'trans_shared_van';
  int _guestCount = 2;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _bookingSuccess = false;
  bool _isProcessing = false;
  String _bookingRef = '';

  List<Destination> get _selectedSpots =>
      cebuDestinations.where((s) => _selectedSpotIds.contains(s.id)).toList();

  AccommodationOption get _accommodation =>
      accommodations.firstWhere((a) => a.id == _accommodationId);

  TransportOption get _transport =>
      transports.firstWhere((t) => t.id == _transportId);

  double get _spotsTotal =>
      _selectedSpots.fold(0.0, (sum, s) => sum + s.entranceFee) * _guestCount;

  double get _accommodationTotal => _accommodation.nightlyRate * _guestCount;
  double get _transportTotal => _transport.price;
  double get _grandTotal => _spotsTotal + _accommodationTotal + _transportTotal;

  double get _routeDistance {
    if (_selectedSpots.length < 2) return 0;
    return DistanceService.calculateTotalRouteDistance(
      _selectedSpots.map((s) => s.coordinates).toList(),
    );
  }

  String get _routeTime =>
      DistanceService.estimateTravelTime(_routeDistance, transport: _transportId);

  void _toggleSpot(String id) => setState(() {
        _selectedSpotIds.contains(id)
            ? _selectedSpotIds.remove(id)
            : _selectedSpotIds.add(id);
      });

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
    if (_selectedSpotIds.isEmpty || _startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select dates and at least one destination.')),
      );
      return;
    }
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
      });
      final ref = (result['booking'] as Map<String, dynamic>)['reference_code'] as String? ?? 'CEB-ERROR';
      if (mounted) setState(() { _isProcessing = false; _bookingRef = ref; _bookingSuccess = true; });
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking failed: ${e.toString()}')),
        );
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
                  2 => _buildItineraryStep(),
                  3 => _buildExtrasStep(),
                  _ => _buildPaymentStep(),
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
                    onPressed: _step < 4
                        ? () => setState(() => _step++)
                        : _isProcessing ? null : _completeBooking,
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
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF00BCD4))),
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

  Widget _buildDetailsStep() {
    final fmt = DateFormat('MMM d, yyyy');
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Choose dates and guests',
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
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Expanded(
              child: Center(
                child: Text('$_guestCount Guests',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            IconButton(
              onPressed: () => setState(() => _guestCount++),
              icon: const Icon(Icons.add_circle_outline),
            ),
          ]),
          const Spacer(),
          _buildSummary(),
        ],
      ),
    );
  }

  Widget _buildItineraryStep() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select your destinations',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 18),
          Expanded(
            child: ListView.separated(
              itemCount: cebuDestinations.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final spot = cebuDestinations[i];
                final selected = _selectedSpotIds.contains(spot.id);
                return ListTile(
                  onTap: () => _toggleSpot(spot.id),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  tileColor: selected ? const Color(0xFFE0F7FA) : Colors.white,
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(spot.images.first),
                    onBackgroundImageError: (_, _) {},
                  ),
                  title: Text(spot.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${regionTitle(spot.region)} • ₱${spot.entranceFee.toInt()}'),
                  trailing: Icon(
                    selected ? Icons.check_circle : Icons.circle_outlined,
                    color: selected ? const Color(0xFF00BCD4) : Colors.grey,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExtrasStep() {
    return _Card(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose accommodation and transport',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 18),
            const Text('Accommodation', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: accommodations.map((item) {
                final sel = item.id == _accommodationId;
                return ChoiceChip(
                  label: Text(item.title),
                  selected: sel,
                  onSelected: (_) => setState(() => _accommodationId = item.id),
                  selectedColor: const Color(0xFF00BCD4),
                  backgroundColor: const Color(0xFFF2FBFF),
                  labelStyle: TextStyle(color: sel ? Colors.white : const Color(0xFF00314F)),
                );
              }).toList(),
            ),
            const SizedBox(height: 22),
            const Text('Transport', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            RadioGroup<String>(
              groupValue: _transportId,
              onChanged: (v) { if (v != null) setState(() => _transportId = v); },
              child: Column(
                children: transports.map((option) => RadioListTile<String>(
                  value: option.id,
                  title: Text(option.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(option.description),
                  secondary: Text('₱${option.price.toInt()}',
                      style: const TextStyle(color: Color(0xFF006994), fontWeight: FontWeight.bold)),
                  selected: option.id == _transportId,
                )).toList(),
              ),
            ),
            const SizedBox(height: 12),
            _buildSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentStep() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Review and confirm',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _SummaryTile(label: 'Destinations', value: '${_selectedSpotIds.length} spots'),
          _SummaryTile(label: 'Accommodation', value: _accommodation.title),
          _SummaryTile(label: 'Transport', value: _transport.title),
          _SummaryTile(label: 'Total route', value: '${_routeDistance.toStringAsFixed(1)} km'),
          _SummaryTile(label: 'Travel time', value: _routeTime),
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
          const Spacer(),
          _buildSummary(),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(height: 36, thickness: 1.2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Estimated total',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text('₱${_grandTotal.toStringAsFixed(0)}',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF50C878))),
          ],
        ),
        const SizedBox(height: 6),
        Text('Route: ${_routeDistance.toStringAsFixed(1)} km • Travel time: $_routeTime',
            style: const TextStyle(color: Color(0xFF5D6D7A), fontSize: 13)),
      ],
    );
  }
}

// ── Shared card with solid white background (visible on any background) ──────

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

// ── Step indicator ───────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int step;
  const _StepIndicator({required this.step});

  @override
  Widget build(BuildContext context) {
    const labels = ['Details', 'Itinerary', 'Extras', 'Payment'];
    return Row(
      children: List.generate(4, (i) {
        final active = i + 1 <= step;
        return [
          Row(children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: active ? const Color(0xFF00BCD4) : const Color(0xFFE5F7FB),
              child: Text('${i + 1}',
                  style: TextStyle(color: active ? Colors.white : const Color(0xFF00314F))),
            ),
            const SizedBox(width: 6),
            Text(labels[i],
                style: TextStyle(
                    color: active ? const Color(0xFF00314F) : const Color(0xFF8A9BA9))),
          ]),
          if (i < 3)
            Expanded(child: Container(height: 1, color: const Color(0xFFE5F7FB))),
        ];
      }).expand((w) => w).toList(),
    );
  }
}

// ── Small widgets ────────────────────────────────────────────────────────────

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF5D6D7A))),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00314F))),
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
