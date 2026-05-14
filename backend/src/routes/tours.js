const express = require('express');
const { body, validationResult } = require('express-validator');
const pool = require('../config/database');
const { adminOnly } = require('../middleware/auth');

const router = express.Router();

// GET /api/tours
router.get('/', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM tours WHERE is_active = TRUE ORDER BY created_at DESC',
    );
    res.json({ tours: result.rows });
  } catch {
    res.status(500).json({ message: 'Could not fetch tours.' });
  }
});

// GET /api/tours/:id
router.get('/:id', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM tours WHERE id = $1', [req.params.id]);
    if (result.rows.length === 0) return res.status(404).json({ message: 'Tour not found.' });
    res.json({ tour: result.rows[0] });
  } catch {
    res.status(500).json({ message: 'Could not fetch tour.' });
  }
});

// POST /api/tours — admin creates tour
router.post(
  '/',
  adminOnly,
  [
    body('title').trim().notEmpty(),
    body('price').isFloat({ min: 0 }),
    body('durationDays').isInt({ min: 1 }),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(422).json({ errors: errors.array() });

    const { title, description, price, durationDays, maxGuests, imageUrls, destinationIds } = req.body;
    try {
      const result = await pool.query(
        `INSERT INTO tours (title, description, price, duration_days, max_guests, image_urls, destination_ids)
         VALUES ($1,$2,$3,$4,$5,$6,$7) RETURNING *`,
        [title, description, price, durationDays, maxGuests || 20, imageUrls || [], destinationIds || []],
      );
      res.status(201).json({ tour: result.rows[0] });
    } catch {
      res.status(500).json({ message: 'Could not create tour.' });
    }
  },
);

// PUT /api/tours/:id
router.put('/:id', adminOnly, async (req, res) => {
  const { title, description, price, durationDays, maxGuests, imageUrls, destinationIds, isActive } = req.body;
  try {
    const result = await pool.query(
      `UPDATE tours SET
         title = COALESCE($1, title),
         description = COALESCE($2, description),
         price = COALESCE($3, price),
         duration_days = COALESCE($4, duration_days),
         max_guests = COALESCE($5, max_guests),
         image_urls = COALESCE($6, image_urls),
         destination_ids = COALESCE($7, destination_ids),
         is_active = COALESCE($8, is_active),
         updated_at = NOW()
       WHERE id = $9 RETURNING *`,
      [title, description, price, durationDays, maxGuests, imageUrls, destinationIds, isActive, req.params.id],
    );
    if (result.rows.length === 0) return res.status(404).json({ message: 'Tour not found.' });
    res.json({ tour: result.rows[0] });
  } catch {
    res.status(500).json({ message: 'Could not update tour.' });
  }
});

// DELETE /api/tours/:id
router.delete('/:id', adminOnly, async (req, res) => {
  try {
    await pool.query('UPDATE tours SET is_active = FALSE WHERE id = $1', [req.params.id]);
    res.json({ message: 'Tour deactivated.' });
  } catch {
    res.status(500).json({ message: 'Could not delete tour.' });
  }
});

module.exports = router;
