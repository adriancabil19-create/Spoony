# System Analysis and Design
## Spoony Travel and Tours Web Application

**System Name:** Spoony Travel and Tours  
**Platform:** Flutter Web (Dart)  
**Backend:** Supabase (PostgreSQL + Auth + Edge Functions)  
**Location Context:** Cebu, Philippines  
**Version:** 1.0.0  

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [System Overview](#2-system-overview)
3. [Objectives](#3-objectives)
4. [Scope and Limitations](#4-scope-and-limitations)
5. [User Roles and Access Control](#5-user-roles-and-access-control)
6. [Functional Requirements](#6-functional-requirements)
7. [System Architecture](#7-system-architecture)
8. [Module Descriptions](#8-module-descriptions)
9. [Database Design](#9-database-design)
10. [Data Flow and Process Flow](#10-data-flow-and-process-flow)
11. [Technology Stack](#11-technology-stack)
12. [External Services and Integrations](#12-external-services-and-integrations)
13. [Security Design](#13-security-design)
14. [Non-Functional Requirements](#14-non-functional-requirements)
15. [Booking Status Lifecycle](#15-booking-status-lifecycle)
16. [Email Notification System](#16-email-notification-system)

---

## 1. Executive Summary

Spoony Travel and Tours is a full-stack web application designed to automate and streamline the operations of a local tour and travel agency based in Cebu, Philippines. The system addresses the operational gap in travel agency management by digitizing the entire booking lifecycle — from destination browsing and tour package selection to payment summary, driver assignment, and trip completion — all within a single integrated platform.

The system serves three distinct user roles: **Guests** (tourists booking tours), **Drivers** (assigned to transport guests), and **Administrators** (managing all operations). Each role has a dedicated portal with relevant features and access controls enforced at both the application and database levels.

---

## 2. System Overview

Spoony Travel and Tours provides the following core capabilities:

- A public-facing landing page showcasing popular destinations in Cebu
- A destination explorer with regional filters, ratings, search, and favoriting
- A multi-step booking wizard supporting tour packages (Joiner and Premium) and custom itinerary building
- Automated email receipts upon booking confirmation
- A guest dashboard for tracking bookings, viewing QR tickets, downloading PDF itineraries, and managing favorites
- An admin control panel for booking management, driver assignment, and content management
- A driver portal for viewing assigned trips and marking completions
- QR-code-based booking search using the browser's native camera API

---

## 3. Objectives

1. **Digitize tour booking** — replace manual booking processes with an automated, real-time online system accessible from any browser.
2. **Automate communications** — send automated email receipts, driver assignment notifications, and trip completion confirmations via SendGrid.
3. **Streamline driver operations** — provide drivers a dedicated portal to view assigned trips, filter by status, and search bookings via text or QR scan.
4. **Empower administrators** — provide a single dashboard to manage all bookings, drivers, destinations, accommodations, tour packages, and transport options.
5. **Enforce role-based access** — ensure guests, drivers, and admins can only access data and functions relevant to their role.
6. **Enable paperless workflows** — allow guests to download PDF itineraries and present QR-coded booking references for driver lookup.

---

## 4. Scope and Limitations

### In Scope
- User registration, login, password recovery, and profile management
- Multi-step tour booking (package-based and custom itinerary)
- Pricing engine: accommodation × nights, transport, entrance fees, add-ons, per-person rates
- Booking lifecycle management (Pending → Confirmed → Completed / Cancelled)
- Driver assignment by admin, with automated email notification to drivers
- Trip completion by driver, with automated email notification to guest
- Admin content management: destinations, hotels, packages, transport, drivers
- Guest QR ticket and PDF itinerary generation
- Booking search via camera QR scan (Chrome/Edge browsers)
- Favorite destination saving per user account
- Email notifications via Supabase Edge Functions + SendGrid

### Out of Scope
- Online payment gateway integration (payments handled offline)
- Native mobile application (iOS/Android)
- Multi-language support
- Third-party travel API integration (e.g., airline, hotel OTA feeds)
- Real-time GPS tracking of drivers

---

## 5. User Roles and Access Control

| Role | Access Mechanism | Key Capabilities |
|---|---|---|
| **Guest** | Email/password auth via Supabase Auth | Browse destinations, book tours, view/download bookings, manage profile |
| **Admin** | `app_metadata.role = 'admin'` set server-side | Full access to all bookings, drivers, content management tabs |
| **Driver** | Email exists in `drivers` table | View assigned trips, search bookings, mark trips complete, QR scan |

### Role Detection Logic

```
Auth → currentUser
  ├── appMetadata['role'] == 'admin'  →  AdminScreen
  ├── email in drivers table          →  DriverScreen (tab visible in NavBar)
  └── otherwise                       →  Guest (DashboardScreen)
```

Row-Level Security (RLS) policies on Supabase enforce that:
- Guests can only read/write their own bookings (`user_id = auth.uid()`)
- Drivers can only read bookings assigned to them (`driver_id` matching their driver record)
- Admins have unrestricted access via service role or permissive policies
- The `drivers` table uses `email = auth.email()` for self-identification without querying `auth.users`

---

## 6. Functional Requirements

### 6.1 Authentication Module
- FR-AUTH-01: Users can register with name, email, and password
- FR-AUTH-02: Users can log in with email and password with optional "Remember Me"
- FR-AUTH-03: Users can request and complete password recovery via email link
- FR-AUTH-04: Admin mode login is available through a toggle on the auth screen
- FR-AUTH-05: The system auto-navigates logged-in users away from the auth screen
- FR-AUTH-06: Driver users are detected and the Driver tab is conditionally shown in the nav bar

### 6.2 Home / Landing Module
- FR-HOME-01: Display a hero section with call-to-action for booking
- FR-HOME-02: Display popular Cebu destinations (top 3)
- FR-HOME-03: Display available tour packages with pricing
- FR-HOME-04: Display company contact information and social links in the footer
- FR-HOME-05: Navigation bar collapses to a hamburger menu on mobile

### 6.3 Explore Module
- FR-EXP-01: List all Cebu destinations loaded from the database
- FR-EXP-02: Filter destinations by region (All, Cebu City, South Cebu, North Cebu, Islands/Bohol)
- FR-EXP-03: Search destinations by name
- FR-EXP-04: Display destination details: description, entrance fee, rating, reviews, distance, travel time
- FR-EXP-05: Allow guests to favorite/unfavorite destinations (saved to user metadata)
- FR-EXP-06: Navigate to the booking wizard from any destination card

### 6.4 Booking Module
- FR-BOOK-01: Multi-step wizard: Step 1 (Dates + Guests), Step 2 (Tour Plan), Step 3 (Accommodation + Transport + Add-ons), Step 4 (Review + Confirm)
- FR-BOOK-02: Support two tour modes: **Joiner** (shared group) and **Premium** (private)
- FR-BOOK-03: Support two itinerary modes: **Package-based** (pre-built daily packages) and **Custom** (guest selects spots per day)
- FR-BOOK-04: Dynamic pricing engine: packages priced per person per type; kids at 70%; toddlers free for packages; accommodation = nightly rate × guests × nights
- FR-BOOK-05: Generate a unique booking reference code (format: `CEB-XXXXX`)
- FR-BOOK-06: Insert booking record into `bookings` table with status `pending`
- FR-BOOK-07: Send booking receipt email to guest via SendGrid Edge Function on successful booking
- FR-BOOK-08: Display a success screen with QR code of the reference after booking
- FR-BOOK-09: Allow add-on services (e.g., photography, snorkeling) priced per person or flat

### 6.5 Guest Dashboard Module
- FR-DASH-01: Show upcoming trips (pending + confirmed bookings) with search and date filter
- FR-DASH-02: Show all booking history with search and status filter chips
- FR-DASH-03: Display per-booking QR code (encodes the reference code)
- FR-DASH-04: Allow downloading a PDF itinerary per booking via browser blob download
- FR-DASH-05: Show saved favorite destinations
- FR-DASH-06: Allow editing of display name in Account Settings

### 6.6 Admin Module
- FR-ADMIN-01: View all bookings with filter (All / Pending / Confirmed / Completed / Cancelled), search by reference/email, and date filter
- FR-ADMIN-02: Approve pending bookings → sets status to `confirmed`
- FR-ADMIN-03: Reject/cancel bookings → sets status to `cancelled`
- FR-ADMIN-04: Assign a driver to a confirmed booking; sends email notification to driver
- FR-ADMIN-05: Driver assignment is: hidden for pending, editable for confirmed, read-only for completed
- FR-ADMIN-06: Manage destinations (add, edit, delete) with image URLs and regional categorization
- FR-ADMIN-07: Manage hotel/accommodation types with nightly rate pricing
- FR-ADMIN-08: Manage tour packages with joiner and premium per-person pricing
- FR-ADMIN-09: Manage transport options with flat pricing
- FR-ADMIN-10: Manage drivers: add, edit (name, email, phone, license plate, vehicle type, photo URL, availability), delete

### 6.7 Driver Module
- FR-DRV-01: Driver portal is accessible only to authenticated users whose email is in the `drivers` table
- FR-DRV-02: Display all trips assigned to the logged-in driver
- FR-DRV-03: Filter trips by status (All / Upcoming / Completed / Cancelled)
- FR-DRV-04: Search bookings by reference code or guest email, with date filter
- FR-DRV-05: Scan guest QR ticket using the browser camera via the `BarcodeDetector` API
- FR-DRV-06: Mark a trip as `completed`; triggers guest notification email
- FR-DRV-07: Expand trip cards to view full itinerary, guest details, accommodation, and transport

---

## 7. System Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                        CLIENT (Browser)                              │
│                                                                      │
│  Flutter Web Application (Dart → compiled JavaScript)               │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────────────┐   │
│  │   Home   │  │ Explore  │  │ Booking  │  │    Dashboard     │   │
│  │  Screen  │  │  Screen  │  │  Screen  │  │     Screen       │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────────────┘   │
│  ┌──────────┐  ┌──────────┐  ┌──────────────────────────────────┐  │
│  │  Admin   │  │  Driver  │  │   Auth Screen (Login/Register)   │  │
│  │  Screen  │  │  Screen  │  └──────────────────────────────────┘  │
│  └──────────┘  └──────────┘                                         │
│                                                                      │
│  State Management: Flutter setState + Riverpod (auth)               │
│  Navigation: Named routes (/home, /explore, /booking, etc.)         │
└──────────────────────────┬──────────────────────────────────────────┘
                           │ HTTPS / WebSockets
                           ▼
┌─────────────────────────────────────────────────────────────────────┐
│                     SUPABASE BACKEND                                 │
│                                                                      │
│  ┌─────────────────────┐   ┌────────────────────────────────────┐  │
│  │    Supabase Auth    │   │     Supabase PostgreSQL Database   │  │
│  │  (JWT, email/pass,  │   │  bookings / drivers / destinations │  │
│  │   magic links,      │   │  accommodation_types / packages    │  │
│  │   password recovery)│   │  transport_types / spots / hotels  │  │
│  └─────────────────────┘   └────────────────────────────────────┘  │
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              Supabase Edge Functions (Deno)                  │   │
│  │  send-booking-receipt │ notify-driver │ notify-guest-complete│   │
│  └──────────────────────────────┬──────────────────────────────┘   │
└─────────────────────────────────┼───────────────────────────────────┘
                                  │ HTTPS POST
                                  ▼
                    ┌─────────────────────────┐
                    │   SendGrid Email API    │
                    │  (Transactional Email)  │
                    └─────────────────────────┘
```

---

## 8. Module Descriptions

### 8.1 Authentication Screen (`auth_screen.dart`)
Entry point of the application. Handles:
- **Sign Up**: collects name, email, password, confirm password; registers via `supabase.auth.signUp()`
- **Sign In**: email + password via `supabase.auth.signInWithPassword()`; optional "Remember Me"
- **Admin Mode**: toggled UI that directs admin users to `AdminScreen` after login
- **Password Recovery**: email sent via Supabase; `onAuthStateChange` listens for `passwordRecovery` event; renders new password form
- **Auto-redirect**: existing sessions detected on load route users directly to their appropriate screen

### 8.2 Home Screen (`home_screen.dart`)
Public landing page. Features:
- Scroll-responsive navigation bar (transparent → solid on scroll)
- Hero banner with animated fade-in and Book Now CTA
- Featured destinations grid (top 3 from `cebuDestinations`)
- Tour packages showcase
- Sticky navigation: Home, Explore, Book, Dashboard/Admin/Driver (role-dependent), Login/Logout

### 8.3 Explore Screen (`explore_screen.dart`)
Destination discovery module. Features:
- Loads destinations from both local data (`cebu_data.dart`) and the `destinations` Supabase table (DB overrides local data for admin-editable fields)
- Region filter tabs: All / Cebu City / South Cebu / North Cebu / Islands
- Text search bar (filters by destination name)
- Destination cards: image, name, entrance fee, rating, travel time, region badge
- Heart button to toggle favorites (saved to `auth.updateUser` metadata for persistence)
- Book Now button navigates to `BookingScreen`

### 8.4 Booking Screen (`booking_screen.dart`)
Multi-step booking wizard. Steps:

| Step | Description |
|------|-------------|
| 1 | Select start/end dates; set adult, kid, toddler counts |
| 2 | Choose Package-based (select a pre-built package per day) or Custom (pick destinations per day) |
| 3 | Select accommodation tier; select transport type; pick optional add-ons |
| 4 | Review summary with itemized pricing; confirm and submit |

On submission:
1. Generates a unique `CEB-XXXXX` reference code
2. Builds itinerary string (`Day 1: Kawasan Falls, Day 2: ...`)
3. Inserts record into `bookings` table with `status: 'pending'`
4. Invokes `send-booking-receipt` Edge Function (non-blocking)
5. Displays success screen with QR code of the reference

### 8.5 Dashboard Screen (`dashboard_screen.dart`)
Guest self-service portal. Four tabs:

| Tab | Description |
|-----|-------------|
| Upcoming Trips | Pending + Confirmed bookings; search by reference/tour; date filter |
| Booking History | All bookings (all statuses); search + status filter chips |
| Favorite Spots | Destinations the guest has hearted, with remove option |
| Account Settings | Edit display name |

Each booking card shows: reference code, status badge, tour type, dates, guest count, total amount. Expandable to show full itinerary. Includes:
- **QR Code** widget (encodes the reference code) for presenting to the driver
- **Download PDF** button: generates a PDF itinerary using `pdf` package and triggers browser blob download via `package:web` + `dart:js_interop`

### 8.6 Admin Screen (`admin_screen.dart`)
Role-restricted (admin only). Six tabs:

| Tab | Description |
|-----|-------------|
| Bookings | View all bookings; filter/search; approve, reject, assign driver |
| Manage Spots | CRUD for destinations (name, region, image URL, description, fee) |
| Manage Hotels | CRUD for accommodation types with nightly rate pricing |
| Manage Packages | CRUD for tour packages (joiner + premium per-person prices) |
| Manage Transport | CRUD for transport options with flat prices |
| Manage Drivers | CRUD for drivers (name, email, phone, plate, vehicle, photo URL, availability) |

Driver assignment logic per booking status:
- `pending` → No driver section shown (booking not yet approved)
- `confirmed` → Editable dropdown; selecting triggers `notify-driver` Edge Function
- `completed` → Read-only display of the assigned driver's name and phone

### 8.7 Driver Screen (`driver_screen.dart`)
Driver-restricted portal. Features:
- Validates driver identity: queries `drivers` table by `auth.email()`
- Displays all bookings with `driver_id` matching the logged-in driver
- Search bar (reference or email) with camera QR scan button
- **QR Scan**: Opens dialog using browser `getUserMedia` camera API + `BarcodeDetector` JS API; scanned code fills the search bar to locate the booking
- Status filter chips: All / Upcoming (pending) / Completed / Cancelled
- Date filter on assigned trips
- Expandable trip cards: full itinerary, guest email, tour type, accommodation, transport, guest count
- **Complete Trip** button (on confirmed bookings): sets status to `completed`, invokes `notify-guest-complete` Edge Function

---

## 9. Database Design

### 9.1 Table: `bookings`

| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID (PK) | Auto-generated primary key |
| `user_id` | UUID (FK → auth.users) | Booking owner |
| `user_email` | TEXT | Guest email (denormalized for display) |
| `reference_code` | TEXT | Unique booking reference (CEB-XXXXX) |
| `status` | TEXT | `pending` / `confirmed` / `completed` / `cancelled` |
| `driver_id` | UUID (FK → drivers) | Assigned driver (nullable) |
| `start_date` | DATE | Trip start date |
| `end_date` | DATE | Trip end date |
| `guest_count` | INTEGER | Total guests |
| `adult_count` | INTEGER | Adults |
| `kid_count` | INTEGER | Kids (3–12) |
| `toddler_count` | INTEGER | Toddlers (0–3, free for packages) |
| `tour_type` | TEXT | Package name(s) or "Build Your Own" |
| `itinerary` | TEXT | Day-by-day itinerary string |
| `accommodation_type` | TEXT | Accommodation ID |
| `transport_type` | TEXT | Transport ID |
| `total_amount` | NUMERIC | Grand total in PHP |
| `created_at` | TIMESTAMPTZ | Auto-set on insert |
| `updated_at` | TIMESTAMPTZ | Updated on status change |

### 9.2 Table: `drivers`

| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID (PK) | Auto-generated primary key |
| `full_name` | TEXT | Driver's full name |
| `email` | TEXT | Driver's email (used for auth identification) |
| `phone` | TEXT | Contact number |
| `license_plate` | TEXT | Vehicle plate number |
| `vehicle_type` | TEXT | e.g., Van, SUV, Sedan |
| `photo_url` | TEXT | URL to driver's profile photo |
| `available` | BOOLEAN | Whether driver is currently available |

### 9.3 Table: `destinations`

| Column | Type | Description |
|--------|------|-------------|
| `id` | TEXT (PK) | Slug-based ID (e.g., `kawasan_falls`) |
| `name` | TEXT | Display name |
| `description` | TEXT | Short description |
| `region` | TEXT | Region slug (cebu_city, south_cebu, etc.) |
| `images` | TEXT[] | Array of image URLs |
| `entrance_fee` | NUMERIC | Fee in PHP |
| `rating` | NUMERIC | Average rating (0–5) |
| `reviews` | INTEGER | Review count |
| `travel_time` | TEXT | Estimated travel time from Cebu City |

### 9.4 Table: `accommodation_types`

| Column | Type | Description |
|--------|------|-------------|
| `id` | TEXT (PK) | Slug ID (e.g., `acc_standard`) |
| `title` | TEXT | Display title |
| `nightly_rate` | NUMERIC | Per-night, per-person rate in PHP |
| `description` | TEXT | Short description |

### 9.5 Table: `transport_types`

| Column | Type | Description |
|--------|------|-------------|
| `id` | TEXT (PK) | Slug ID (e.g., `trans_private_sedan`) |
| `title` | TEXT | Display title |
| `price` | NUMERIC | Flat trip price in PHP |
| `description` | TEXT | Short description |

### 9.6 Table: `tour_packages` / `spots` (Admin-managed)
Managed through the Admin screen's Manage Packages and Manage Spots tabs. Support CRUD operations with image URLs, pricing (joiner + premium per person), and regional grouping.

### 9.7 Row-Level Security (RLS) Summary

| Table | Policy | Rule |
|-------|--------|------|
| `bookings` | Guest read own | `user_id = auth.uid()` |
| `bookings` | Guest insert | `user_id = auth.uid()` |
| `bookings` | Driver read assigned | `driver_id` matches driver record by `email = auth.email()` |
| `bookings` | Admin all | `app_metadata.role = 'admin'` |
| `drivers` | Self read | `email = auth.email()` |
| `drivers` | Admin all | `app_metadata.role = 'admin'` |

---

## 10. Data Flow and Process Flow

### 10.1 Booking Flow

```
Guest selects dates + guests
        │
        ▼
Guest builds itinerary (packages or custom spots)
        │
        ▼
Guest selects accommodation + transport + add-ons
        │
        ▼
System calculates total (pricing engine)
        │
        ▼
Guest confirms → POST to Supabase bookings table
  status = 'pending', reference = CEB-XXXXX
        │
        ▼
Edge Function: send-booking-receipt → SendGrid → Guest email
        │
        ▼
Success screen: QR code of reference displayed
```

### 10.2 Booking Approval and Driver Assignment Flow

```
Admin opens Bookings tab
        │
        ▼
Admin reviews pending booking → clicks Approve
  bookings.status = 'confirmed'
        │
        ▼
Admin selects driver from dropdown (confirmed bookings only)
  bookings.driver_id = selected driver UUID
        │
        ▼
Edge Function: notify-driver → SendGrid → Driver email
  (contains itinerary, guest info, dates, tour type)
        │
        ▼
Driver sees trip in Driver Portal under "Upcoming"
```

### 10.3 Trip Completion Flow

```
Driver opens Driver Portal
        │
        ▼
Driver searches booking (manual reference or QR camera scan)
        │
        ▼
Driver expands trip card → clicks "Mark Complete"
  bookings.status = 'completed'
        │
        ▼
Edge Function: notify-guest-complete → SendGrid → Guest email
  (CC: spoonytraveltours@gmail.com)
        │
        ▼
Admin sees booking as "Completed" (driver assignment read-only)
Guest sees booking in Booking History under "Completed"
```

---

## 11. Technology Stack

### Frontend

| Technology | Purpose |
|-----------|---------|
| **Flutter Web (Dart)** | Cross-platform UI framework compiled to JavaScript for browser |
| **Flutter Riverpod** | State management for auth-related providers |
| **qr_flutter** | QR code widget generation from booking reference |
| **pdf + printing** | Client-side PDF itinerary generation |
| **package:web + dart:js_interop** | Browser API access (Blob, URL, BarcodeDetector, getUserMedia) |
| **dart:ui_web** | Platform view registration for embedding HTML video element |
| **intl** | Date and number formatting |
| **google_maps_flutter** | Map display for destination coordinates |
| **geolocator** | Device location access |

### Backend

| Technology | Purpose |
|-----------|---------|
| **Supabase** | Managed Backend-as-a-Service platform |
| **PostgreSQL** | Primary relational database |
| **Supabase Auth** | JWT-based authentication with email/password and magic links |
| **Supabase Edge Functions** | Deno-based serverless functions for email dispatch |
| **Row-Level Security (RLS)** | Database-level access control per user role |
| **PostgREST** | Auto-generated REST API from PostgreSQL schema |

### Email

| Technology | Purpose |
|-----------|---------|
| **SendGrid** | Transactional email delivery (receipts, notifications) |
| **Supabase Edge Functions** | Serverless API bridge between Flutter and SendGrid |

### Hosting / Deployment

| Component | Hosting |
|-----------|---------|
| Flutter Web build (`build/web/`) | GitHub repository (static hosting / GitHub Pages or custom host) |
| Supabase Backend | Supabase cloud (managed PostgreSQL + Auth + Edge Functions) |

---

## 12. External Services and Integrations

### 12.1 SendGrid (Email Delivery)

Three Edge Functions handle email delivery:

**`send-booking-receipt`**
- Trigger: Guest completes a booking
- Recipient: Guest email
- Content: Reference code, tour details, dates, guests, accommodation, transport, total amount

**`notify-driver`**
- Trigger: Admin assigns a driver to a confirmed booking
- Recipient: Driver email
- Content: Guest name/email, booking reference, tour type, start/end dates, full day-by-day itinerary, guest count

**`notify-guest-complete`**
- Trigger: Driver marks a trip as complete
- Recipient: Guest email + CC to `spoonytraveltours@gmail.com`
- Content: Reference, tour type, dates, guest count, completion message

All functions authenticate with SendGrid using `SENDGRID_API_KEY` stored as a Supabase environment secret.

### 12.2 Browser Native APIs (via `dart:js_interop`)

**`getUserMedia` Camera API**
- Used in the Driver Portal QR scanner dialog
- Requests video stream from the device camera
- Stream attached to an `<video>` HTML element rendered via `HtmlElementView`
- Supported in all modern browsers (Chrome, Edge, Firefox, Safari)

**`BarcodeDetector` Shape Detection API**
- Used for QR code decoding from the video stream
- Polls every 600ms using `Timer.periodic`
- Supported in Chrome and Edge (Chromium-based browsers)
- System shows a friendly error message in unsupported browsers

### 12.3 Google Maps Flutter

Used in the Explore screen for displaying destination map coordinates. Destination data includes `lat`/`lng` coordinates for each Cebu location.

---

## 13. Security Design

### 13.1 Authentication Security
- Passwords are hashed and stored by Supabase Auth (bcrypt); never exposed to the application layer
- JWT tokens are short-lived; Supabase manages refresh automatically
- Password recovery uses a time-limited email link; the app listens for the `passwordRecovery` auth event before allowing password change
- "Remember Me" controls whether the session persists across browser restarts

### 13.2 Authorization Security

**Application Layer:**
- Admin detection: `user.appMetadata['role'] == 'admin'` (set server-side; not writable by client)
- Driver detection: queries `drivers` table by email; if no match, redirects to home
- All admin routes check the role on mount and redirect unauthorized users

**Database Layer (RLS):**
- Every Supabase table has RLS enabled
- Guests can only read/write their own rows: `user_id = auth.uid()`
- Drivers use `email = auth.email()` for self-identification (avoids querying `auth.users`, which is blocked for the `authenticated` role)
- Admin policies use `(auth.jwt() -> 'app_metadata' ->> 'role') = 'admin'`

### 13.3 Input Security
- All inputs are sanitized by Supabase's parameterized PostgREST queries (no raw SQL from client)
- Reference code generation uses cryptographic randomness from Dart's `Random()` seeded values
- No sensitive credentials (API keys, secrets) are stored in the Flutter client; all secrets are Edge Function environment variables

---

## 14. Non-Functional Requirements

| Category | Requirement |
|----------|-------------|
| **Performance** | Booking list filtering is client-side (no extra DB call per filter change) |
| **Responsiveness** | All screens have mobile (<700px) and desktop (≥700px) layouts |
| **Availability** | Relies on Supabase SLA (99.9% uptime for cloud-hosted tier) |
| **Scalability** | Supabase PostgreSQL scales vertically; Edge Functions scale automatically |
| **Accessibility** | Flutter Material components follow WCAG contrast guidelines |
| **Browser Compatibility** | Full functionality in Chrome/Edge; QR scanner not available in Firefox/Safari (graceful fallback) |
| **Offline Behavior** | Application requires network connectivity; no offline caching implemented |
| **PDF Generation** | Client-side via `pdf` package; no server-side rendering required |
| **Data Integrity** | Booking reference uniqueness enforced at insert; status transitions validated server-side |
| **Maintainability** | Modular screen-per-feature architecture; shared `SpoonyNavBar` and `SpoonyFooter` components |

---

## 15. Booking Status Lifecycle

```
                    ┌─────────────────────────────┐
  Guest Submits ──► │          PENDING             │
   (status set)     │  Visible in: Admin (Pending) │
                    │  Guest: Upcoming Trips        │
                    └──────────┬──────────┬────────┘
                               │          │
                     [Approve] │          │ [Reject]
                               │          │
                               ▼          ▼
                    ┌──────────────┐  ┌──────────────────────┐
                    │  CONFIRMED   │  │      CANCELLED        │
                    │ Admin assigns│  │ No further actions    │
                    │ driver here  │  └──────────────────────┘
                    │ Driver sees  │
                    │ in "Upcoming"│
                    └──────┬───────┘
                           │ [Driver marks complete]
                           ▼
                    ┌──────────────┐
                    │  COMPLETED   │
                    │ Driver read- │
                    │ only in admin│
                    │ Guest History│
                    └──────────────┘
```

| Status | Admin Label | Guest Label | Driver Label |
|--------|-------------|-------------|--------------|
| `pending` | Pending | Upcoming | — |
| `confirmed` | Confirmed | Upcoming | Upcoming |
| `completed` | Completed | Completed (History) | Completed |
| `cancelled` | Cancelled | Cancelled (History) | Cancelled |

---

## 16. Email Notification System

All notifications are transactional HTML emails sent via **SendGrid** through **Supabase Edge Functions** (Deno runtime). The system sends from `spoonytraveltours@gmail.com` with the display name *Spoony Travel and Tours*.

### Notification Trigger Map

| Event | Function | Sender | Recipient | CC |
|-------|----------|--------|-----------|-----|
| Booking submitted | `send-booking-receipt` | Spoony | Guest | — |
| Driver assigned | `notify-driver` | Spoony | Driver | — |
| Trip completed | `notify-guest-complete` | Spoony | Guest | `spoonytraveltours@gmail.com` |

### Email Architecture

```
Flutter App
    │
    │ supabase.functions.invoke('notify-driver', body: { ... })
    ▼
Supabase Edge Function (Deno)
    │ Reads SENDGRID_API_KEY from env
    │ POST https://api.sendgrid.com/v3/mail/send
    ▼
SendGrid API → Guest/Driver Inbox
```

Email content is rendered as styled HTML using inline CSS for cross-client compatibility (Gmail, Outlook, Apple Mail). Each email includes:
- Spoony Travel branding with gradient header
- Booking reference code in large display text
- Structured booking details table
- Contextual message body per notification type

---

*Document prepared for System Analysis and Design research purposes.*  
*System: Spoony Travel and Tours Web Application*  
*Technology: Flutter Web + Supabase + SendGrid*  
*Context: Cebu, Philippines Tourism Management System*
