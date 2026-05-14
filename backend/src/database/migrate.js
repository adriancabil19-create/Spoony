require('dotenv').config({ path: require('path').resolve(__dirname, '../../.env') });
const fs = require('fs');
const path = require('path');
const pool = require('../config/database');
const { supabaseAdmin } = require('../config/supabase');

async function migrate() {
  const schema = fs.readFileSync(path.join(__dirname, 'schema.sql'), 'utf8');
  await pool.query(schema);
  console.log('Schema applied.');

  const adminEmail = process.env.ADMIN_EMAIL || 'admin@spoony.com';
  const adminPassword = process.env.ADMIN_PASSWORD || 'Admin@1234';

  const { data, error } = await supabaseAdmin.auth.admin.createUser({
    email: adminEmail,
    password: adminPassword,
    email_confirm: true,
    app_metadata: { role: 'admin' },
    user_metadata: { name: 'Super Admin' },
  });

  if (error) {
    if (error.message.toLowerCase().includes('already')) {
      console.log(`Admin already exists: ${adminEmail}`);
    } else {
      console.error('Admin seed error:', error.message);
    }
  } else {
    console.log(`Admin seeded: ${adminEmail} (id: ${data.user.id})`);
  }

  await pool.end();
}

migrate().catch((err) => { console.error(err); process.exit(1); });
