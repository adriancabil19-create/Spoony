const express = require('express');
const { body, validationResult } = require('express-validator');
const pool = require('../config/database');
const { authenticate, adminOnly } = require('../middleware/auth');

const router = express.Router();

// POST /api/payments — upload receipt
router.post(
  '/',
  authenticate,
  [
    body('bookingId').isUUID(),
    body('amount').isFloat({ min: 0 }),
    body('method').notEmpty(),
    body('receiptUrl').notEmpty(),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(422).json({ errors: errors.array() });

    const { bookingId, amount, method, receiptUrl } = req.body;
    try {
      const result = await pool.query(
        `INSERT INTO payments (booking_id, user_id, amount, method, receipt_url)
         VALUES ($1,$2,$3,$4,$5) RETURNING *`,
        [bookingId, req.user.id, amount, method, receiptUrl],
      );
      res.status(201).json({ payment: result.rows[0] });
    } catch {
      res.status(500).json({ message: 'Could not upload receipt.' });
    }
  },
);

// PUT /api/payments/:id/verify — admin verifies payment
router.put('/:id/verify', adminOnly, async (req, res) => {
  try {
    const result = await pool.query(
      `UPDATE payments SET status = 'verified', verified_at = NOW(), verified_by = $1
       WHERE id = $2 RETURNING *`,
      [req.admin.id, req.params.id],
    );
    if (result.rows.length === 0) return res.status(404).json({ message: 'Payment not found.' });

    const payment = result.rows[0];
    // Mark booking as confirmed after payment verified
    await pool.query(
      `UPDATE bookings SET status = 'confirmed', updated_at = NOW() WHERE id = $1`,
      [payment.booking_id],
    );
    await pool.query(
      `INSERT INTO notifications (user_id, title, body, type) VALUES ($1,$2,$3,$4)`,
      [payment.user_id, 'Payment Verified', 'Your payment has been verified. Enjoy your trip!', 'payment'],
    );
    res.json({ payment });
  } catch {
    res.status(500).json({ message: 'Could not verify payment.' });
  }
});

// GET /api/payments/:bookingId/invoice
router.get('/:bookingId/invoice', authenticate, async (req, res) => {
  try {
    const bookingResult = await pool.query(
      `SELECT b.*, u.name AS user_name, u.email AS user_email
       FROM bookings b JOIN users u ON b.user_id = u.id
       WHERE b.id = $1 AND b.user_id = $2`,
      [req.params.bookingId, req.user.id],
    );
    if (bookingResult.rows.length === 0) return res.status(404).json({ message: 'Booking not found.' });

    const paymentResult = await pool.query(
      'SELECT * FROM payments WHERE booking_id = $1 ORDER BY created_at DESC LIMIT 1',
      [req.params.bookingId],
    );

    res.json({
      invoice: {
        booking: bookingResult.rows[0],
        payment: paymentResult.rows[0] || null,
        generatedAt: new Date().toISOString(),
      },
    });
  } catch {
    res.status(500).json({ message: 'Could not generate invoice.' });
  }
});

// GET /api/payments — all payments (admin)
router.get('/', adminOnly, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT p.*, u.name AS user_name, b.reference_code
       FROM payments p
       LEFT JOIN users u ON p.user_id = u.id
       LEFT JOIN bookings b ON p.booking_id = b.id
       ORDER BY p.created_at DESC`,
    );
    res.json({ payments: result.rows });
  } catch {
    res.status(500).json({ message: 'Could not fetch payments.' });
  }
});

module.exports = router;
