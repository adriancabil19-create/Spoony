// OpenStreetMap geocoding via Nominatim + routing via OSRM (free, no key needed)
// Optional: OpenRouteService for turn-by-turn (requires free API key)

const NOMINATIM = process.env.NOMINATIM_BASE_URL || 'https://nominatim.openstreetmap.org';
const ORS_KEY = process.env.OPENROUTESERVICE_API_KEY;

// Haversine straight-line distance between two lat/lng points (km)
function haversine(lat1, lng1, lat2, lng2) {
  const R = 6371;
  const dLat = ((lat2 - lat1) * Math.PI) / 180;
  const dLng = ((lng2 - lng1) * Math.PI) / 180;
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos((lat1 * Math.PI) / 180) *
      Math.cos((lat2 * Math.PI) / 180) *
      Math.sin(dLng / 2) ** 2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

// Total route distance + per-leg breakdown using haversine
function calculateRoute(coordinates) {
  if (!Array.isArray(coordinates) || coordinates.length < 2) {
    throw new Error('At least 2 coordinate pairs required.');
  }
  let total = 0;
  const legs = [];
  for (let i = 0; i < coordinates.length - 1; i++) {
    const d = haversine(
      coordinates[i].lat, coordinates[i].lng,
      coordinates[i + 1].lat, coordinates[i + 1].lng,
    );
    legs.push(Math.round(d * 10) / 10);
    total += d;
  }
  const totalKm = Math.round(total * 10) / 10;
  const durationMins = Math.round((totalKm / 45) * 60);
  const estimatedFuelL = Math.round((totalKm / 12) * 10) / 10;
  return { totalKm, legs, durationMins, estimatedFuelL };
}

// Geocode a place name to lat/lng using Nominatim (OpenStreetMap)
async function geocode(placeName) {
  const url = `${NOMINATIM}/search?q=${encodeURIComponent(placeName)}&format=json&limit=1&countrycodes=ph`;
  const res = await fetch(url, {
    headers: { 'User-Agent': 'SpoonyTravelApp/1.0 (contact@spoony.com)' },
  });
  const data = await res.json();
  if (!data.length) return null;
  return { lat: parseFloat(data[0].lat), lng: parseFloat(data[0].lon), displayName: data[0].display_name };
}

// Road distance via OSRM (free, no key required)
async function roadDistance(origin, destination) {
  const url = `https://router.project-osrm.org/route/v1/driving/${origin.lng},${origin.lat};${destination.lng},${destination.lat}?overview=false`;
  try {
    const res = await fetch(url);
    const data = await res.json();
    if (data.code !== 'Ok') return null;
    const route = data.routes[0];
    return {
      distanceKm: Math.round((route.distance / 1000) * 10) / 10,
      durationMins: Math.round(route.duration / 60),
    };
  } catch {
    return null;
  }
}

// Tourist spots near a coordinate via Overpass API (free, no key needed)
async function touristSpots(lat, lng, radiusMeters = 5000) {
  const query = `
    [out:json][timeout:25];
    (
      node["tourism"~"attraction|viewpoint|museum|artwork|gallery|theme_park|zoo|aquarium|hotel|guest_house|hostel|camp_site|picnic_site|information"](around:${radiusMeters},${lat},${lng});
      way["tourism"~"attraction|viewpoint|museum|artwork|gallery|theme_park|zoo|aquarium"](around:${radiusMeters},${lat},${lng});
    );
    out body center;
  `;
  try {
    const res = await fetch('https://overpass-api.de/api/interpreter', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: `data=${encodeURIComponent(query)}`,
    });
    const data = await res.json();
    return (data.elements || [])
      .map(el => ({
        id: el.id,
        type: el.type,
        name: el.tags?.name || el.tags?.['name:en'] || null,
        tourism: el.tags?.tourism,
        lat: el.lat ?? el.center?.lat,
        lng: el.lon ?? el.center?.lon,
        website: el.tags?.website || null,
        phone: el.tags?.phone || null,
        openingHours: el.tags?.opening_hours || null,
        description: el.tags?.description || null,
      }))
      .filter(s => s.lat && s.lng && s.name);
  } catch {
    return null;
  }
}

module.exports = { haversine, calculateRoute, geocode, roadDistance, touristSpots };
