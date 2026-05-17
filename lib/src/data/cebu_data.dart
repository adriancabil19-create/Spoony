import '../models.dart';

final List<Destination> cebuDestinations = [
  Destination(
    id: 'sirao_garden',
    name: 'Sirao Garden',
    description: 'A flowering hillside garden with sweeping Cebu City views and floral photo spots.',
    region: DestinationRegion.cebuCity,
    images: [
      'https://images.unsplash.com/photo-1778477501822-d4236715cd96?auto=format&fit=crop&w=900&q=80',
    ],
    entranceFee: 100,
    rating: 4.8,
    reviews: 890,
    coordinates: {'lat': 10.2651, 'lng': 123.8290},
    travelTime: '30 mins',
    averageDistanceKm: 3.5,
  ),
  Destination(
    id: 'temple_of_leah',
    name: 'Temple of Leah',
    description: 'A romantic palace with grand architecture, perfect for sunset views and photo tours.',
    region: DestinationRegion.cebuCity,
    images: [
      'https://images.unsplash.com/photo-1770462957658-313131728014?auto=format&fit=crop&w=900&q=80',
    ],
    entranceFee: 150,
    rating: 4.7,
    reviews: 1540,
    coordinates: {'lat': 10.3257, 'lng': 123.8853},
    travelTime: '45 mins',
    averageDistanceKm: 8.0,
  ),
  Destination(
    id: 'taoist_temple',
    name: 'Taoist Temple',
    description: 'A colourful hillside temple with Chinese architecture and panoramic city views.',
    region: DestinationRegion.cebuCity,
    images: [
      'https://images.unsplash.com/photo-1563245372-f21724e3856d?auto=format&fit=crop&w=900&q=80',
    ],
    entranceFee: 0,
    rating: 4.6,
    reviews: 1020,
    coordinates: {'lat': 10.3415, 'lng': 123.9002},
    travelTime: '40 mins',
    averageDistanceKm: 8.5,
  ),
  Destination(
    id: 'kawasan_falls',
    name: 'Kawasan Falls',
    description: 'Iconic turquoise waterfalls and canyoneering thrills in Badian, South Cebu.',
    region: DestinationRegion.southCebu,
    images: [
      'https://images.unsplash.com/photo-1620658927695-c33df6fb8130?auto=format&fit=crop&w=900&q=80',
    ],
    entranceFee: 500,
    rating: 4.9,
    reviews: 1240,
    coordinates: {'lat': 9.7831, 'lng': 123.4492},
    travelTime: '3 hrs',
    averageDistanceKm: 110,
  ),
  Destination(
    id: 'oslob_whale_shark',
    name: 'Oslob Whale Shark',
    description: 'Swim with gentle whale sharks and discover the marine highlight of South Cebu.',
    region: DestinationRegion.southCebu,
    images: [
      'https://images.unsplash.com/photo-1526778548025-fa2f459cd5c1?auto=format&fit=crop&w=900&q=80',
    ],
    entranceFee: 1000,
    rating: 4.8,
    reviews: 2130,
    coordinates: {'lat': 9.4225, 'lng': 123.3614},
    travelTime: '4 hrs',
    averageDistanceKm: 123,
  ),
  Destination(
    id: 'malapascua_island',
    name: 'Malapascua Island',
    description: 'Dreamy northern island known for thresher shark dives and powder-white beaches.',
    region: DestinationRegion.northCebu,
    images: [
      'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=900&q=80',
    ],
    entranceFee: 1200,
    rating: 4.9,
    reviews: 1120,
    coordinates: {'lat': 11.1185, 'lng': 124.3545},
    travelTime: '5 hrs',
    averageDistanceKm: 220,
  ),
  Destination(
    id: 'kalanggaman_island',
    name: 'Kalanggaman Island',
    description: 'A pristine sandbar paradise with crystal blue water and marine sanctuary.',
    region: DestinationRegion.northCebu,
    images: [
      'https://images.unsplash.com/photo-1493558103817-58b2924bce98?auto=format&fit=crop&w=900&q=80',
    ],
    entranceFee: 900,
    rating: 4.8,
    reviews: 980,
    coordinates: {'lat': 11.0855, 'lng': 124.3421},
    travelTime: '5 hrs',
    averageDistanceKm: 210,
  ),
  Destination(
    id: 'chocolate_hills',
    name: 'Chocolate Hills',
    description: 'The iconic Bohol landscape of rolling hills and panoramic viewpoints.',
    region: DestinationRegion.bohol,
    images: [
      'https://images.unsplash.com/photo-1476988186444-a7189cf07b3f?auto=format&fit=crop&w=900&q=80',
    ],
    entranceFee: 1000,
    rating: 4.9,
    reviews: 2100,
    coordinates: {'lat': 9.8404, 'lng': 124.0140},
    travelTime: '4 hrs',
    averageDistanceKm: 174,
  ),
  Destination(
    id: 'tarsier_sanctuary',
    name: 'Tarsier Sanctuary',
    description: 'Visit the world-famous tarsier preserve and learn about Bohol\'s smallest primates.',
    region: DestinationRegion.bohol,
    images: [
      'https://images.unsplash.com/photo-1578926288207-a90a5366759d?auto=format&fit=crop&w=900&q=80',
    ],
    entranceFee: 150,
    rating: 4.6,
    reviews: 1040,
    coordinates: {'lat': 9.6072, 'lng': 124.1678},
    travelTime: '4.5 hrs',
    averageDistanceKm: 180,
  ),
];

final List<AccommodationOption> accommodations = [
  AccommodationOption(
    id: 'acc_budget',
    title: 'Budget Stay',
    category: 'Budget',
    nightlyRate: 1200,
    description: 'Hostel-style rooms with local comfort and easy access to the city.',
  ),
  AccommodationOption(
    id: 'acc_standard',
    title: 'Standard Hotel',
    category: 'Standard',
    nightlyRate: 2200,
    description: 'Modern rooms with breakfast, city views, and premium amenities.',
  ),
  AccommodationOption(
    id: 'acc_premium',
    title: 'Premium Resort',
    category: 'Premium',
    nightlyRate: 5200,
    description: 'Luxury resort stay with pool access and curated leisure services.',
  ),
  AccommodationOption(
    id: 'acc_luxury',
    title: 'Luxury Villa',
    category: 'Luxury',
    nightlyRate: 9800,
    description: 'Private villa experience with VIP concierge and premium comforts.',
  ),
];

final List<TransportOption> transports = [
  TransportOption(
    id: 'trans_shared_van',
    title: 'Shared Van',
    description: 'Comfortable shared transfer with budget-friendly pricing.',
    price: 450,
  ),
  TransportOption(
    id: 'trans_private_sedan',
    title: 'Private Sedan',
    description: 'Personal sedan with driver and flexible pickup time.',
    price: 1300,
  ),
  TransportOption(
    id: 'trans_suv',
    title: 'Private SUV',
    description: 'Spacious SUV for families and premium road comfort.',
    price: 2400,
  ),
];

const List<TourPackage> tourPackages = [
  TourPackage(
    id: 'pkg_cebu_city',
    name: 'Cebu City Highlights',
    tagline: 'Art, temples & hillside views in one day',
    description:
        'Explore Cebu City\'s most iconic landmarks — from the enchanting Sirao Flower Garden to the grand Temple of Leah and the colourful Taoist Temple perched on the hills.',
    highlights: [
      'Sirao Flower Garden',
      'Temple of Leah',
      'Taoist Temple',
      'Tops Lookout Viewpoint',
    ],
    durationDays: 1,
    joinerPricePerPerson: 599,
    premiumPricePerPerson: 1499,
    imageUrl:
        'https://images.unsplash.com/photo-1778477501822-d4236715cd96?auto=format&fit=crop&w=900&q=80',
    region: 'Cebu City',
  ),
  TourPackage(
    id: 'pkg_south_cebu',
    name: 'South Cebu Adventure',
    tagline: 'Waterfalls, canyoneering & whale sharks',
    description:
        'The ultimate South Cebu experience — canyon through the iconic turquoise waters of Kawasan Falls, then head to Oslob to swim alongside the world\'s largest fish.',
    highlights: [
      'Kawasan Falls Canyoneering',
      'Oslob Whale Shark Watching',
      'Sumilon Island Sandbar Stop',
      'Moalboal Sardine Run',
    ],
    durationDays: 1,
    joinerPricePerPerson: 1899,
    premiumPricePerPerson: 3499,
    imageUrl:
        'https://images.unsplash.com/photo-1620658927695-c33df6fb8130?auto=format&fit=crop&w=900&q=80',
    region: 'South Cebu',
  ),
  TourPackage(
    id: 'pkg_north_islands',
    name: 'North Cebu Island Hop',
    tagline: 'Pristine sandbars & thresher shark dives',
    description:
        'A 2-day island escape to the north — discover the powder-white sands of Malapascua, dive with elusive thresher sharks at dawn, then lounge on the legendary Kalanggaman sandbar.',
    highlights: [
      'Malapascua Island Beach',
      'Thresher Shark Diving (Monad Shoal)',
      'Kalanggaman Island Sandbar',
      'Snorkeling & Marine Life',
    ],
    durationDays: 2,
    joinerPricePerPerson: 3299,
    premiumPricePerPerson: 5999,
    imageUrl:
        'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=900&q=80',
    region: 'North Cebu',
  ),
  TourPackage(
    id: 'pkg_bohol',
    name: 'Bohol Day Trip',
    tagline: 'Chocolate hills, tarsiers & river cruise',
    description:
        'Take the ferry from Cebu to Bohol for a full-day adventure — gaze over the rolling Chocolate Hills, meet the world\'s tiniest primates, and drift along the jungle-lined Loboc River.',
    highlights: [
      'Chocolate Hills Viewpoint',
      'Philippine Tarsier Sanctuary',
      'Loboc River Lunch Cruise',
      'Panglao Beach Sunset',
    ],
    durationDays: 1,
    joinerPricePerPerson: 2299,
    premiumPricePerPerson: 4199,
    imageUrl:
        'https://images.unsplash.com/photo-1476988186444-a7189cf07b3f?auto=format&fit=crop&w=900&q=80',
    region: 'Bohol',
  ),
];

const List<TourAddOn> tourAddOns = [
  TourAddOn(
    id: 'addon_photo',
    title: 'Professional Photographer',
    emoji: '📸',
    price: 800,
    perPerson: false,
  ),
  TourAddOn(
    id: 'addon_snorkel',
    title: 'Snorkeling Gear Rental',
    emoji: '🤿',
    price: 350,
    perPerson: true,
  ),
  TourAddOn(
    id: 'addon_lunch',
    title: 'Packed Lunch',
    emoji: '🍱',
    price: 280,
    perPerson: true,
  ),
  TourAddOn(
    id: 'addon_guide',
    title: 'Personal Tour Guide',
    emoji: '🗺️',
    price: 900,
    perPerson: false,
  ),
];

List<Destination> destinationsByRegion(DestinationRegion region) {
  return cebuDestinations.where((spot) => spot.region == region).toList();
}

String regionTitle(DestinationRegion region) {
  switch (region) {
    case DestinationRegion.all:
      return 'All';
    case DestinationRegion.cebuCity:
      return 'Cebu City';
    case DestinationRegion.southCebu:
      return 'South Cebu';
    case DestinationRegion.northCebu:
      return 'North Cebu';
    case DestinationRegion.bohol:
      return 'Bohol';
  }
}
