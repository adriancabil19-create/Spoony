const { supabaseAdmin } = require('../config/supabase');

async function authenticate(req, res, next) {
  const header = req.headers.authorization;
  if (!header?.startsWith('Bearer ')) {
    return res.status(401).json({ message: 'Authentication required.' });
  }
  const token = header.slice(7);
  const { data: { user }, error } = await supabaseAdmin.auth.getUser(token);
  if (error || !user) {
    return res.status(401).json({ message: 'Invalid or expired session.' });
  }
  req.user = user;
  next();
}

async function adminOnly(req, res, next) {
  const header = req.headers.authorization;
  if (!header?.startsWith('Bearer ')) {
    return res.status(401).json({ message: 'Authentication required.' });
  }
  const token = header.slice(7);
  const { data: { user }, error } = await supabaseAdmin.auth.getUser(token);
  if (error || !user) {
    return res.status(401).json({ message: 'Invalid or expired session.' });
  }
  if (user.app_metadata?.role !== 'admin') {
    return res.status(403).json({ message: 'Admin access required.' });
  }
  req.user = user;
  next();
}

module.exports = { authenticate, adminOnly };
