const express = require('express');
const { body, validationResult } = require('express-validator');
const { supabase, supabaseAdmin } = require('../config/supabase');

const router = express.Router();

// POST /api/auth/register
router.post(
  '/register',
  [
    body('name').trim().notEmpty().withMessage('Name is required.'),
    body('email').isEmail().normalizeEmail().withMessage('Valid email required.'),
    body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters.'),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(422).json({ errors: errors.array() });

    const { name, email, password } = req.body;
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: { data: { name } },
    });
    if (error) return res.status(400).json({ message: error.message });
    res.status(201).json({
      user: data.user,
      session: data.session,
      token: data.session?.access_token ?? null,
    });
  },
);

// POST /api/auth/login
router.post(
  '/login',
  [
    body('email').isEmail().normalizeEmail(),
    body('password').notEmpty(),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(422).json({ errors: errors.array() });

    const { email, password } = req.body;
    const { data, error } = await supabase.auth.signInWithPassword({ email, password });
    if (error) return res.status(401).json({ message: error.message });
    res.json({
      user: data.user,
      session: data.session,
      token: data.session.access_token,
    });
  },
);

// POST /api/auth/admin/login
router.post(
  '/admin/login',
  [
    body('email').isEmail().normalizeEmail(),
    body('password').notEmpty(),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(422).json({ errors: errors.array() });

    const { email, password } = req.body;
    const { data, error } = await supabase.auth.signInWithPassword({ email, password });
    if (error) return res.status(401).json({ message: error.message });

    if (data.user?.app_metadata?.role !== 'admin') {
      await supabase.auth.signOut();
      return res.status(403).json({ message: 'Not authorized as admin.' });
    }

    res.json({
      user: data.user,
      session: data.session,
      token: data.session.access_token,
    });
  },
);

// POST /api/auth/logout
router.post('/logout', async (req, res) => {
  await supabase.auth.signOut();
  res.json({ message: 'Logged out successfully.' });
});

// POST /api/auth/forgot-password — Supabase sends the reset email automatically
router.post('/forgot-password', body('email').isEmail().normalizeEmail(), async (req, res) => {
  const { email } = req.body;
  const { error } = await supabase.auth.resetPasswordForEmail(email, {
    redirectTo: `${process.env.API_BASE_URL}/reset-password`,
  });
  if (error) return res.status(400).json({ message: error.message });
  res.json({ message: 'Password reset email sent.' });
});

// GET /api/auth/me — return current user from Supabase token
router.get('/me', async (req, res) => {
  const header = req.headers.authorization;
  if (!header?.startsWith('Bearer ')) {
    return res.status(401).json({ message: 'Authentication required.' });
  }
  const { data: { user }, error } = await supabaseAdmin.auth.getUser(header.slice(7));
  if (error || !user) return res.status(401).json({ message: 'Invalid session.' });
  res.json({ user });
});

module.exports = router;
