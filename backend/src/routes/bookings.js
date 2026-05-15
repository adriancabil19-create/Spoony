const express = require('express');
const { body, validationResult } = require('express-validator');
const QRCode = require('qrcode');
const pool = require('../config/database');
const { supabaseAdmin } = require('../config/supabase');
const { authenticate, adminOnly } = require('../middleware/auth');
const { sendBookingConfirmation } = require('../services/email_service');

const router = express.Router();

function generateRef() {
  return 'CEB-' + Math.random().toString(36).substring(2, 7).toUpperCase();
}

// POST /api/bookings — create booking (guest)
router.post(
  '/',
  authenticate,
  [
    body('destinationIds').isArray(),
    body('guestCount').isInt({ min: 1 }),
    body('startDate').isISO8601(),
    body('endDate').isISO8601(),
    body('totalAmount').isFloat({ min: 0 }),
    body('accommodationType').notEmpty(),
    body('transportType').notEmpty(),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(422).json({ errors: errors.array() });

    const {
      destinationIds, guestCount, startDate, endDate,
      totalAmount, accommodationType, transportType, tourId,
    } = req.body;

    const ref = generateRef();
    try {
      const qrData = JSON.stringify({ ref, userId: req.user.id });
      const qrUrl = await QRCode.toDataURL(qrData);

      const result = await pool.query(
        `INSERT INTO bookings
         (user_id, tour_id, destination_ids, accommodation_type, transport_type,
          guest_count, start_date, end_date, total_amount, reference_code, qr_code_url)
         VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)
         RETURNING *`,
        [
          req.user.id, /^[0-9a-f-]{36}$/i.test(tourId) ? tourId : null, destinationIds || [], accommodationType,
          transportType, guestCount, startDate, endDate, totalAmount, ref, qrUrl,
        ],
      );

      const booking = result.rows[0];

      // Send confirmation email (non-blocking)
      try {
        const { data: { user: supaUser } } = await supabaseAdmin.auth.admin.getUserById(req.user.id);
        if (supaUser?.email) {
          sendBookingConfirmation({
            to: supaUser.email,
            name: supaUser.user_metadata?.name || supaUser.user_metadata?.full_name || '',
            referenceCode: ref,
            startDate,
            endDate,
            guestCount,
            totalAmount,
          });
        }
      } catch (_) {}

      res.status(201).json({ booking });
    } catch (err) {
      console.error(err);
      res.status(500).json({ message: 'Could not create booking.' });
    }
  },
);

// GET /api/bookings/my — user's own bookings
router.get('/my', authenticate, async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM bookings WHERE user_id = $1 ORDER BY created_at DESC',
      [req.user.id],
    );
    res.json({ bookings: result.rows });
  } catch {
    res.status(500).json({ message: 'Could not fetch bookings.' });
  }
});

// PUT /api/bookings/:id/cancel — cancel own booking
router.put('/:id/cancel', authenticate, async (req, res) => {
  try {
    const result = await pool.query(
      `UPDATE bookings SET status = 'cancelled', updated_at = NOW()
       WHERE id = $1 AND user_id = $2 AND status = 'pending'
       RETURNING *`,
      [req.params.id, req.user.id],
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Booking not found or cannot be cancelled.' });
    }
    res.json({ booking: result.rows[0] });
  } catch {
    res.status(500).json({ message: 'Could not cancel booking.' });
  }
});

// GET /api/bookings — all bookings (admin)
router.get('/', adminOnly, async (req, res) => {
  const { status, page = 1, limit = 50 } = req.query;
  const offset = (page - 1) * limit;

  try {
    let query, params;
    if (status) {
      query = 'SELECT * FROM bookings WHERE status = $1 ORDER BY created_at DESC LIMIT $2 OFFSET $3';
      params = [status, limit, offset];
    } else {
      query = 'SELECT * FROM bookings ORDER BY created_at DESC LIMIT $1 OFFSET $2';
      params = [limit, offset];
    }
    const result = await pool.query(query, params);

    // Fetch user emails from Supabase in one call
    let userMap = {};
    try {
      const { data: { users } } = await supabaseAdmin.auth.admin.listUsers({ perPage: 1000 });
      users.forEach(u => {
        userMap[u.id] = {
          email: u.email || '',
          name: u.user_metadata?.name || u.user_metadata?.full_name || '',
        };
      });
    } catch (_) {}

    const bookings = result.rows.map(b => ({
      ...b,
      user_email: userMap[b.user_id]?.email || '',
      user_name: userMap[b.user_id]?.name || '',
    }));

    res.json({ bookings });
  } catch {
    res.status(500).json({ message: 'Could not fetch bookings.' });
  }
});

// PUT /api/bookings/:id/approve — admin approves booking
router.put('/:id/approve', adminOnly, async (req, res) => {
  try {
    const result = await pool.query(
      `UPDATE bookings SET status = 'confirmed', updated_at = NOW()
       WHERE id = $1 AND status = 'pending'
       RETURNING *`,
      [req.params.id],
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Booking not found or already processed.' });
    }
    res.json({ booking: result.rows[0] });
  } catch {
    res.status(500).json({ message: 'Could not approve booking.' });
  }
});

// PUT /api/bookings/:id/reject — admin rejects/cancels booking
router.put('/:id/reject', adminOnly, async (req, res) => {
  try {
    const result = await pool.query(
      `UPDATE bookings SET status = 'cancelled', updated_at = NOW()
       WHERE id = $1 AND status IN ('pending', 'confirmed')
       RETURNING *`,
      [req.params.id],
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Booking not found or already cancelled.' });
    }
    res.json({ booking: result.rows[0] });
  } catch {
    res.status(500).json({ message: 'Could not reject booking.' });
  }
});

// GET /api/bookings/:id/qr — get QR code
router.get('/:id/qr', authenticate, async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT qr_code_url, reference_code FROM bookings WHERE id = $1 AND user_id = $2',
      [req.params.id, req.user.id],
    );
    if (result.rows.length === 0) return res.status(404).json({ message: 'Not found.' });
    res.json(result.rows[0]);
  } catch {
    res.status(500).json({ message: 'Could not get QR.' });
  }
});

module.exports = router;
