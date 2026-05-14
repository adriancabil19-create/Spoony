const express = require('express');
const { body, validationResult } = require('express-validator');
const pool = require('../config/database');
const { authenticate, adminOnly } = require('../middleware/auth');

const router = express.Router();

// POST /api/reviews
router.post(
  '/',
  authenticate,
  [
    body('destinationId').isUUID(),
    body('rating').isInt({ min: 1, max: 5 }),
    body('comment').optional().isString(),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(422).json({ errors: errors.array() });

    const { destinationId, rating, comment } = req.body;
    try {
      const result = await pool.query(
        `INSERT INTO reviews (user_id, destination_id, rating, comment)
         VALUES ($1,$2,$3,$4) RETURNING *`,
        [req.user.id, destinationId, rating, comment],
      );

      // Recalculate average rating
      await pool.query(
        `UPDATE destinations SET
           rating = (SELECT ROUND(AVG(rating)::numeric, 2) FROM reviews WHERE destination_id = $1 AND is_approved = TRUE),
           reviews_count = (SELECT COUNT(*) FROM reviews WHERE destination_id = $1 AND is_approved = TRUE)
         WHERE id = $1`,
        [destinationId],
      );

      res.status(201).json({ review: result.rows[0] });
    } catch {
      res.status(500).json({ message: 'Could not add review.' });
    }
  },
);

// GET /api/reviews/:destinationId
router.get('/:destinationId', async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT r.*, u.name AS user_name, u.avatar_url
       FROM reviews r
       LEFT JOIN users u ON r.user_id = u.id
       WHERE r.destination_id = $1 AND r.is_approved = TRUE
       ORDER BY r.created_at DESC`,
      [req.params.destinationId],
    );
    res.json({ reviews: result.rows });
  } catch {
    res.status(500).json({ message: 'Could not fetch reviews.' });
  }
});

// GET /api/reviews/summary/:destinationId — rating breakdown
router.get('/summary/:destinationId', async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT
         rating,
         COUNT(*) AS count
       FROM reviews
       WHERE destination_id = $1 AND is_approved = TRUE
       GROUP BY rating
       ORDER BY rating DESC`,
      [req.params.destinationId],
    );
    const avgResult = await pool.query(
      `SELECT ROUND(AVG(rating)::numeric, 2) AS average, COUNT(*) AS total
       FROM reviews WHERE destination_id = $1 AND is_approved = TRUE`,
      [req.params.destinationId],
    );
    res.json({
      average: avgResult.rows[0].average,
      total: avgResult.rows[0].total,
      breakdown: result.rows,
    });
  } catch {
    res.status(500).json({ message: 'Could not fetch summary.' });
  }
});

// DELETE /api/reviews/:id — admin removes review
router.delete('/:id', adminOnly, async (req, res) => {
  try {
    const result = await pool.query(
      'UPDATE reviews SET is_approved = FALSE WHERE id = $1 RETURNING destination_id',
      [req.params.id],
    );
    if (result.rows.length === 0) return res.status(404).json({ message: 'Review not found.' });

    const destId = result.rows[0].destination_id;
    await pool.query(
      `UPDATE destinations SET
         rating = COALESCE((SELECT ROUND(AVG(rating)::numeric,2) FROM reviews WHERE destination_id=$1 AND is_approved=TRUE), 0),
         reviews_count = (SELECT COUNT(*) FROM reviews WHERE destination_id=$1 AND is_approved=TRUE)
       WHERE id = $1`,
      [destId],
    );
    res.json({ message: 'Review removed.' });
  } catch {
    res.status(500).json({ message: 'Could not remove review.' });
  }
});

module.exports = router;
