require('dotenv').config();
// Force IPv4 DNS resolution — Render free tier can't reach IPv6 addresses
require('dns').setDefaultResultOrder('ipv4first');
const fs = require('fs');
const path = require('path');
const express = require('express');
const cors = require('cors');
const rateLimit = require('express-rate-limit');

const authRoutes = require('./src/routes/auth');
const bookingRoutes = require('./src/routes/bookings');
const tourRoutes = require('./src/routes/tours');
const destinationRoutes = require('./src/routes/destinations');
const paymentRoutes = require('./src/routes/payments');
const reviewRoutes = require('./src/routes/reviews');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors({
  origin: (process.env.ALLOWED_ORIGINS || 'http://localhost:3000').split(','),
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Rate-limit the API only — the website's static files (JS, fonts, images)
// would otherwise exhaust the limit on a single page load.
app.use('/api', rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  message: { message: 'Too many requests, please try again later.' },
}));

app.get('/health', (req, res) => res.json({ status: 'ok', service: 'spoony-api' }));

app.use('/api/auth', authRoutes);
app.use('/api/bookings', bookingRoutes);
app.use('/api/tours', tourRoutes);
app.use('/api/destinations', destinationRoutes);
app.use('/api/payments', paymentRoutes);
app.use('/api/reviews', reviewRoutes);

// ── Flutter web app ──────────────────────────────────────────────────────────
// Serves the committed Flutter build (repo-root build/web) so the website is
// available at the root URL of this Render service. Build it locally with
// `flutter build web --release` and commit build/web before pushing.
const WEB_DIR = [
  process.env.WEB_DIR,
  path.join(__dirname, 'public'),
  path.join(__dirname, '..', 'build', 'web'),
].find((d) => d && fs.existsSync(path.join(d, 'index.html')));

if (WEB_DIR) {
  app.use(express.static(WEB_DIR, {
    index: false,
    maxAge: '1h',
    setHeaders: (res, filePath) => {
      // Always revalidate the entry files so new deploys show up immediately.
      if (/(index\.html|flutter_service_worker\.js|flutter_bootstrap\.js|version\.json)$/.test(filePath)) {
        res.setHeader('Cache-Control', 'no-cache');
      }
    },
  }));
  // Single-page app: every non-API route returns index.html (e.g. /home, /explore).
  app.get(/^\/(?!api\/|health$).*/, (req, res) => {
    res.setHeader('Cache-Control', 'no-cache');
    res.sendFile(path.join(WEB_DIR, 'index.html'));
  });
  console.log(`Serving Flutter web app from ${WEB_DIR}`);
} else {
  app.get('/', (req, res) => res.json({ status: 'ok', service: 'spoony-api', web: 'not built' }));
}

app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(err.status || 500).json({ message: err.message || 'Internal server error' });
});

app.listen(PORT, () => {
  console.log(`Spoony API running on port ${PORT}`);
});

module.exports = app;
