const express = require('express');
const { supabaseAdmin } = require('../config/supabase');

const router = express.Router();

// GET /api/auth/me — validate JWT and return current user
router.get('/me', async (req, res) => {
  const header = req.headers.authorization;
  if (!header?.startsWith('Bearer ')) {
    return res.status(401).json({ message: 'Authentication required.' });
  }
  const { data: { user }, error } = await supabaseAdmin.auth.getUser(header.slice(7));
  if (error || !user) return res.status(401).json({ message: 'Invalid or expired session.' });
  res.json({ user });
});

module.exports = router;
