const express = require('express');
const { body, validationResult } = require('express-validator');
const QRCode = require('qrcode');
const { v4: uuidv4 } = require('uuid');
const pool = require('../config/database');
const { authenticate, adminOnly } = require('../middleware/auth');

const router = express.Router();

function generateRef() {
  return 'CEB-' + Math.random().toString(36).substring(2, 7).toUpperCase();
}

// POST /api/bookings — create booking (guest)
router.post(
  '/',
  authenticate,
  [
    body('destinationIds').isArray({ min: 1 }).withMessage('At least one destination required.'),
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
          req.user.id, tourId || null, destinationIds, accommodationType,
          transportType, guestCount, startDate, endDate, totalAmount, ref, qrUrl,
        ],
      );

      await pool.query(
        `INSERT INTO notifications (user_id, title, body, type)
         VALUES ($1, $2, $3, $4)`,
        [req.user.id, 'Booking Received', `Your booking ${ref} is pending confirmation.`, 'booking'],
      );

      res.status(201).json({ booking: result.rows[0] });
    } catch (err) {
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
  const { status, page = 1, limit = 20 } = req.query;
  const offset = (page - 1) * limit;
  const conditions = status ? `WHERE status = $1` : '';
  const params = status ? [status, limit, offset] : [limit, offset];
  const statusIdx = status ? 3 : 1;

  try {
    const result = await pool.query(
      `SELECT b.*, u.name AS user_name, u.email AS user_email
       FROM bookings b
       LEFT JOIN users u ON b.user_id = u.id
       ${conditions}
       ORDER BY b.created_at DESC
       LIMIT $${statusIdx} OFFSET $${statusIdx + 1}`,
      params,
    );
    res.json({ bookings: result.rows });
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
    const booking = result.rows[0];
    await pool.query(
      `INSERT INTO notifications (user_id, title, body, type)
       VALUES ($1, $2, $3, $4)`,
      [booking.user_id, 'Booking Confirmed!', `Your booking ${booking.reference_code} is confirmed.`, 'booking'],
    );
    res.json({ booking });
  } catch {
    res.status(500).json({ message: 'Could not approve booking.' });
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
