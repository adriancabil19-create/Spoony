-- ============================================================
-- Run this in your Supabase SQL Editor (Dashboard → SQL Editor)
-- ============================================================

-- 1. DESTINATIONS TABLE
CREATE TABLE IF NOT EXISTS destinations (
  id                  UUID        DEFAULT gen_random_uuid() PRIMARY KEY,
  name                TEXT        NOT NULL,
  description         TEXT,
  region              TEXT        NOT NULL DEFAULT 'south_cebu',
  image_urls          TEXT[]      DEFAULT '{}',
  entrance_fee        NUMERIC(10,2) NOT NULL DEFAULT 0,
  latitude            DOUBLE PRECISION DEFAULT 10.3157,
  longitude           DOUBLE PRECISION DEFAULT 123.8854,
  travel_time         TEXT,
  average_distance_km NUMERIC(10,2),
  is_available        BOOLEAN     DEFAULT TRUE,
  rating              NUMERIC(3,2) DEFAULT 0,
  reviews_count       INT         DEFAULT 0,
  created_at          TIMESTAMPTZ DEFAULT NOW(),
  updated_at          TIMESTAMPTZ DEFAULT NOW()
);

-- 2. BOOKINGS TABLE
CREATE TABLE IF NOT EXISTS bookings (
  id                  UUID        DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id             UUID        REFERENCES auth.users(id),
  user_email          TEXT        DEFAULT '',
  tour_id             TEXT,
  destination_ids     TEXT[]      DEFAULT '{}',
  accommodation_type  TEXT        NOT NULL,
  transport_type      TEXT        NOT NULL,
  guest_count         INT         NOT NULL DEFAULT 1,
  start_date          DATE        NOT NULL,
  end_date            DATE        NOT NULL,
  total_amount        NUMERIC(10,2) NOT NULL DEFAULT 0,
  reference_code      TEXT        NOT NULL,
  qr_code_url         TEXT,
  status              TEXT        NOT NULL DEFAULT 'pending',
  created_at          TIMESTAMPTZ DEFAULT NOW(),
  updated_at          TIMESTAMPTZ DEFAULT NOW()
);

-- 3. ENABLE ROW LEVEL SECURITY
ALTER TABLE destinations ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings     ENABLE ROW LEVEL SECURITY;

-- 4. DESTINATIONS POLICIES
-- Guests (unauthenticated) can browse available spots
CREATE POLICY "Public read available destinations"
  ON destinations FOR SELECT
  USING (is_available = TRUE);

-- Logged-in users (admin) can read all destinations including unavailable
CREATE POLICY "Auth users read all destinations"
  ON destinations FOR SELECT
  TO authenticated
  USING (TRUE);

-- Admin can add spots
CREATE POLICY "Auth users insert destinations"
  ON destinations FOR INSERT
  TO authenticated
  WITH CHECK (TRUE);

-- Admin can edit spots
CREATE POLICY "Auth users update destinations"
  ON destinations FOR UPDATE
  TO authenticated
  USING (TRUE)
  WITH CHECK (TRUE);

-- Admin can delete spots
CREATE POLICY "Auth users delete destinations"
  ON destinations FOR DELETE
  TO authenticated
  USING (TRUE);

-- 5. BOOKINGS POLICIES
-- Users can create their own booking
CREATE POLICY "Users insert own bookings"
  ON bookings FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid()::uuid = user_id::uuid);

-- Users can see their own bookings (guest booking history)
CREATE POLICY "Users read own bookings"
  ON bookings FOR SELECT
  TO authenticated
  USING (auth.uid()::uuid = user_id::uuid);

-- Admin can read ALL bookings
CREATE POLICY "Auth users read all bookings"
  ON bookings FOR SELECT
  TO authenticated
  USING (TRUE);

-- Admin can update booking status (approve / reject)
CREATE POLICY "Auth users update bookings"
  ON bookings FOR UPDATE
  TO authenticated
  USING (TRUE)
  WITH CHECK (TRUE);

-- Users can cancel their own pending booking
CREATE POLICY "Users cancel own bookings"
  ON bookings FOR UPDATE
  TO authenticated
  USING (auth.uid()::uuid = user_id::uuid AND status = 'pending')
  WITH CHECK (TRUE);

-- 6. GRANT TABLE PRIVILEGES
-- (RLS policies alone are not enough — roles must also be granted access)
GRANT SELECT, INSERT, UPDATE ON public.bookings TO authenticated;
GRANT SELECT                  ON public.bookings TO anon;

GRANT SELECT, INSERT, UPDATE, DELETE ON public.destinations TO authenticated;
GRANT SELECT                          ON public.destinations TO anon;
