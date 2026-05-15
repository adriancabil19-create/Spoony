const { Pool, types } = require('pg');
const dns = require('dns').promises;
const { URL } = require('url');

// Return NUMERIC/DECIMAL columns as JS numbers instead of strings
types.setTypeParser(1700, (val) => val === null ? null : parseFloat(val));

async function initPool() {
  const url = new URL(process.env.DATABASE_URL);
  let host = url.hostname;

  try {
    const { address } = await dns.lookup(host, { family: 4 });
    host = address;
    console.log(`DB resolved to IPv4: ${host}`);
  } catch (e) {
    console.warn('IPv4 DNS lookup failed, using original hostname:', e.message);
  }

  const pool = new Pool({
    host,
    port: parseInt(url.port) || 5432,
    user: decodeURIComponent(url.username),
    password: decodeURIComponent(url.password),
    database: url.pathname.slice(1),
    ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false,
    max: 10,
    idleTimeoutMillis: 30000,
  });

  pool.on('error', (err) => {
    console.error('PostgreSQL pool error:', err);
  });

  return pool;
}

const poolPromise = initPool();

module.exports = {
  query: (...args) => poolPromise.then(pool => pool.query(...args)),
  end: () => poolPromise.then(pool => pool.end()),
};
