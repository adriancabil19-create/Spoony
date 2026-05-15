const express = require('express');
const { body, validationResult } = require('express-validator');
const pool = require('../config/database');
const { adminOnly } = require('../middleware/auth');
const { calculateRoute, geocode, roadDistance, touristSpots } = require('../services/maps_service');

const router = express.Router();

// GET /api/destinations
router.get('/', async (req, res) => {
  const { region, all } = req.query;
  try {
    let result;
    if (all === 'true') {
      // Admin: return all including unavailable
      result = region
        ? await pool.query('SELECT * FROM destinations WHERE region = $1 ORDER BY rating DESC', [region])
        : await pool.query('SELECT * FROM destinations ORDER BY rating DESC');
    } else {
      // Guest: only available destinations
      result = region
        ? await pool.query('SELECT * FROM destinations WHERE region = $1 AND is_available = TRUE ORDER BY rating DESC', [region])
        : await pool.query('SELECT * FROM destinations WHERE is_available = TRUE ORDER BY rating DESC');
    }
    res.json({ destinations: result.rows });
  } catch (err) {
    console.error('destinations GET:', err.message);
    res.status(500).json({ message: 'Could not fetch destinations.' });
  }
});

// GET /api/destinations/tourist-spots?lat=10.317&lng=123.891&radius=5000
// Must be before /:id to avoid Express treating "tourist-spots" as an ID
router.get('/tourist-spots', async (req, res) => {
  const { lat, lng, radius = '5000' } = req.query;
  if (!lat || !lng) {
    return res.status(422).json({ message: 'lat and lng query params are required.' });
  }
  const spots = await touristSpots(parseFloat(lat), parseFloat(lng), parseInt(radius, 10));
  if (spots === null) {
    return res.status(502).json({ message: 'Could not fetch tourist spots from Overpass API.' });
  }
  res.json({ spots, count: spots.length });
});

// GET /api/destinations/geocode?q=Kawasan+Falls
// Must be before /:id
router.get('/geocode', async (req, res) => {
  const q = req.query.q;
  if (!q) return res.status(422).json({ message: 'Query parameter q is required.' });
  const result = await geocode(q);
  if (!result) return res.status(404).json({ message: 'Place not found.' });
  res.json(result);
});

// GET /api/destinations/:id
router.get('/:id', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM destinations WHERE id = $1', [req.params.id]);
    if (result.rows.length === 0) return res.status(404).json({ message: 'Destination not found.' });
    res.json({ destination: result.rows[0] });
  } catch {
    res.status(500).json({ message: 'Could not fetch destination.' });
  }
});

// POST /api/destinations — admin
router.post(
  '/',
  adminOnly,
  [
    body('name').trim().notEmpty(),
    body('region').notEmpty(),
    body('entranceFee').isFloat({ min: 0 }),
    body('latitude').isFloat(),
    body('longitude').isFloat(),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(422).json({ errors: errors.array() });

    const { name, description, region, imageUrls, entranceFee, latitude, longitude, travelTime, averageDistanceKm } = req.body;
    try {
      const result = await pool.query(
        `INSERT INTO destinations
         (name, description, region, image_urls, entrance_fee, latitude, longitude, travel_time, average_distance_km)
         VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9) RETURNING *`,
        [name, description, region, imageUrls || [], entranceFee, latitude, longitude, travelTime, averageDistanceKm],
      );
      res.status(201).json({ destination: result.rows[0] });
    } catch {
      res.status(500).json({ message: 'Could not add destination.' });
    }
  },
);

// PUT /api/destinations/:id
router.put('/:id', adminOnly, async (req, res) => {
  const { name, description, region, imageUrls, entranceFee, latitude, longitude, travelTime, isAvailable } = req.body;
  try {
    const result = await pool.query(
      `UPDATE destinations SET
         name = COALESCE($1, name),
         description = COALESCE($2, description),
         region = COALESCE($3, region),
         image_urls = COALESCE($4, image_urls),
         entrance_fee = COALESCE($5, entrance_fee),
         latitude = COALESCE($6, latitude),
         longitude = COALESCE($7, longitude),
         travel_time = COALESCE($8, travel_time),
         is_available = COALESCE($9, is_available)
       WHERE id = $10 RETURNING *`,
      [name, description, region, imageUrls, entranceFee, latitude, longitude, travelTime, isAvailable, req.params.id],
    );
    if (result.rows.length === 0) return res.status(404).json({ message: 'Destination not found.' });
    res.json({ destination: result.rows[0] });
  } catch {
    res.status(500).json({ message: 'Could not update destination.' });
  }
});

// DELETE /api/destinations/:id
router.delete('/:id', adminOnly, async (req, res) => {
  try {
    await pool.query('DELETE FROM destinations WHERE id = $1', [req.params.id]);
    res.json({ message: 'Destination removed.' });
  } catch {
    res.status(500).json({ message: 'Could not delete destination.' });
  }
});

// POST /api/destinations/distance — haversine route calculation
router.post('/distance', (req, res) => {
  try {
    const result = calculateRoute(req.body.coordinates);
    res.json(result);
  } catch (err) {
    res.status(422).json({ message: err.message });
  }
});

// POST /api/destinations/road-distance — actual road distance via OSRM
router.post('/road-distance', async (req, res) => {
  const { origin, destination } = req.body;
  if (!origin || !destination) {
    return res.status(422).json({ message: 'origin and destination required.' });
  }
  const result = await roadDistance(origin, destination);
  if (!result) return res.status(502).json({ message: 'Could not calculate road distance.' });
  res.json(result);
});

module.exports = router;
