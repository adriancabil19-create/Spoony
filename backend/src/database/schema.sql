-- Spoony Travel & Tours — PostgreSQL Schema

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users (guests)
CREATE TABLE IF NOT EXISTS users (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name        VARCHAR(150) NOT NULL,
  email       VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  phone       VARCHAR(30),
  avatar_url  TEXT,
  role        VARCHAR(20) DEFAULT 'guest' CHECK (role IN ('guest', 'admin')),
  is_verified BOOLEAN DEFAULT FALSE,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- Admins
CREATE TABLE IF NOT EXISTS admins (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name        VARCHAR(150) NOT NULL,
  email       VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role        VARCHAR(30) DEFAULT 'admin',
  last_login  TIMESTAMPTZ,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- Destinations
CREATE TABLE IF NOT EXISTS destinations (
  id                   UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name                 VARCHAR(200) NOT NULL,
  description          TEXT,
  region               VARCHAR(50) NOT NULL,
  image_urls           TEXT[] DEFAULT '{}',
  entrance_fee         NUMERIC(10,2) DEFAULT 0,
  rating               NUMERIC(3,2) DEFAULT 0,
  reviews_count        INTEGER DEFAULT 0,
  latitude             NUMERIC(10,7),
  longitude            NUMERIC(10,7),
  travel_time          VARCHAR(50),
  average_distance_km  NUMERIC(8,2),
  created_at           TIMESTAMPTZ DEFAULT NOW()
);

-- Tours
CREATE TABLE IF NOT EXISTS tours (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title           VARCHAR(200) NOT NULL,
  description     TEXT,
  price           NUMERIC(10,2) NOT NULL,
  duration_days   INTEGER DEFAULT 1,
  max_guests      INTEGER DEFAULT 20,
  image_urls      TEXT[] DEFAULT '{}',
  destination_ids UUID[] DEFAULT '{}',
  is_active       BOOLEAN DEFAULT TRUE,
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- Bookings
CREATE TABLE IF NOT EXISTS bookings (
  id                 UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id            UUID REFERENCES users(id) ON DELETE SET NULL,
  tour_id            UUID REFERENCES tours(id) ON DELETE SET NULL,
  destination_ids    UUID[] DEFAULT '{}',
  accommodation_type VARCHAR(50),
  transport_type     VARCHAR(50),
  guest_count        INTEGER NOT NULL DEFAULT 1,
  start_date         DATE NOT NULL,
  end_date           DATE NOT NULL,
  total_amount       NUMERIC(12,2) NOT NULL,
  status             VARCHAR(30) DEFAULT 'pending'
                     CHECK (status IN ('pending','confirmed','cancelled','completed')),
  reference_code     VARCHAR(20) UNIQUE NOT NULL,
  qr_code_url        TEXT,
  created_at         TIMESTAMPTZ DEFAULT NOW(),
  updated_at         TIMESTAMPTZ DEFAULT NOW()
);

-- Payments
CREATE TABLE IF NOT EXISTS payments (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  booking_id  UUID REFERENCES bookings(id) ON DELETE CASCADE,
  user_id     UUID REFERENCES users(id) ON DELETE SET NULL,
  amount      NUMERIC(12,2) NOT NULL,
  method      VARCHAR(50) NOT NULL,
  receipt_url TEXT,
  status      VARCHAR(20) DEFAULT 'pending'
              CHECK (status IN ('pending','verified','rejected')),
  verified_at TIMESTAMPTZ,
  verified_by UUID REFERENCES admins(id),
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- Reviews
CREATE TABLE IF NOT EXISTS reviews (
  id             UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id        UUID REFERENCES users(id) ON DELETE SET NULL,
  destination_id UUID REFERENCES destinations(id) ON DELETE CASCADE,
  rating         INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment        TEXT,
  is_approved    BOOLEAN DEFAULT TRUE,
  created_at     TIMESTAMPTZ DEFAULT NOW()
);

-- Notifications
CREATE TABLE IF NOT EXISTS notifications (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id    UUID REFERENCES users(id) ON DELETE CASCADE,
  title      VARCHAR(200) NOT NULL,
  body       TEXT,
  type       VARCHAR(50),
  is_read    BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Itineraries
CREATE TABLE IF NOT EXISTS itineraries (
  id             UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  booking_id     UUID REFERENCES bookings(id) ON DELETE CASCADE,
  day_number     INTEGER NOT NULL,
  destination_id UUID REFERENCES destinations(id),
  start_time     TIME,
  notes          TEXT,
  created_at     TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_bookings_user_id    ON bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_status     ON bookings(status);
CREATE INDEX IF NOT EXISTS idx_payments_booking_id ON payments(booking_id);
CREATE INDEX IF NOT EXISTS idx_reviews_destination ON reviews(destination_id);
CREATE INDEX IF NOT EXISTS idx_notif_user_id       ON notifications(user_id);
