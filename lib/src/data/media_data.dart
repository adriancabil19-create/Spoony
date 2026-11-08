// GENERATED from Wikimedia Commons metadata. All photos are openly licensed;
// credits are shown in the app via Footer → Photo Credits.

class PhotoCredit {
  final String subject;
  final String author;
  final String license;
  final String licenseUrl;
  final String sourceUrl;
  /// True when Spoony altered the image (faces / plate numbers blurred), as CC licenses require noting.
  final bool modified;
  const PhotoCredit(this.subject, this.author, this.license, this.licenseUrl, this.sourceUrl, [this.modified = false]);
}

class HeroSlide {
  final String title;
  final String location;
  /// Network URL (3840px / 4K) or an `assets/` path.
  final String image;
  const HeroSlide(this.title, this.location, this.image);
  bool get isAsset => image.startsWith('assets/');
}

const List<HeroSlide> heroSlides = [
  HeroSlide('Osmeña Peak', 'Dalaguete, South Cebu', 'assets/images/home_bg.jpg'),
  HeroSlide('Kawasan Falls', 'Badian, South Cebu', 'https://thumb.wikimedia.org/wikipedia/commons/thumb/8/8b/Kawasan_Falls_Cebu.jpg/3840px-Kawasan_Falls_Cebu.jpg'),
  HeroSlide('Sumilon Island Sandbar', 'Oslob, South Cebu', 'https://thumb.wikimedia.org/wikipedia/commons/thumb/c/c0/Sumilon_Island_sandbar.jpg/3840px-Sumilon_Island_sandbar.jpg'),
  HeroSlide('Kalanggaman Island', 'Palompon, off North Cebu', 'https://thumb.wikimedia.org/wikipedia/commons/thumb/e/ef/Kalanggaman_Island_2024.jpg/3840px-Kalanggaman_Island_2024.jpg'),
  HeroSlide('Moalboal', 'Panagsama Beach, West Cebu', 'https://thumb.wikimedia.org/wikipedia/commons/thumb/8/8f/Moalboal_2025-07-05_021.jpg/3840px-Moalboal_2025-07-05_021.jpg'),
  HeroSlide('Malapascua Island', 'Daanbantayan, North Cebu', 'https://thumb.wikimedia.org/wikipedia/commons/thumb/1/1f/Malapascua_%28island%29%2C_Tropical_lagoon%2C_Pure_tropical_bliss%2C_Philippines.jpg/3840px-Malapascua_%28island%29%2C_Tropical_lagoon%2C_Pure_tropical_bliss%2C_Philippines.jpg'),
  HeroSlide('Bantayan Island', 'Santa Fe, North Cebu', 'https://thumb.wikimedia.org/wikipedia/commons/thumb/3/31/White_sand_bantayan_island.jpg/3840px-White_sand_bantayan_island.jpg'),
  HeroSlide('Oslob Whale Sharks', 'Tan-awan, Oslob', 'https://upload.wikimedia.org/wikipedia/commons/7/71/Whale_shark_in_Oslob%2C_Cebu_02.jpg'),
  HeroSlide('Tumalog Falls', 'Oslob, South Cebu', 'https://thumb.wikimedia.org/wikipedia/commons/thumb/d/d2/Tumalog_Falls_in_Oslob%2C_Cebu_06.jpg/3840px-Tumalog_Falls_in_Oslob%2C_Cebu_06.jpg'),
  HeroSlide('Temple of Leah', 'Busay, Cebu City', 'https://thumb.wikimedia.org/wikipedia/commons/thumb/d/d4/Temple_of_Leah_2025-08-24_014.jpg/3840px-Temple_of_Leah_2025-08-24_014.jpg'),
];

const List<PhotoCredit> photoCredits = [
  PhotoCredit('Sirao Garden', 'Maria Glenda Perico', 'CC BY-SA 4.0', 'https://creativecommons.org/licenses/by-sa/4.0', 'https://commons.wikimedia.org/wiki/File:Sirao_Garden.jpg'),
  PhotoCredit('Temple of Leah', 'Martin Michlmayr', 'CC BY-SA 4.0', 'https://creativecommons.org/licenses/by-sa/4.0', 'https://commons.wikimedia.org/wiki/File:Temple_of_Leah_2025-08-24_014.jpg', true),
  PhotoCredit('Taoist Temple', 'Neigo Genetiano', 'CC BY-SA 4.0', 'https://creativecommons.org/licenses/by-sa/4.0', 'https://commons.wikimedia.org/wiki/File:Taoist_Temple,_Cebu.jpg', true),
  PhotoCredit('Tops Lookout', 'Bjeweld', 'CC BY-SA 4.0', 'https://creativecommons.org/licenses/by-sa/4.0', 'https://commons.wikimedia.org/wiki/File:Wikinights_Cebu_-_Tops_Lookout_(019).jpg'),
  PhotoCredit('Magellan\'s Cross', 'LMP 2001', 'CC BY-SA 4.0', 'https://creativecommons.org/licenses/by-sa/4.0', 'https://commons.wikimedia.org/wiki/File:Magellan%27s_Cross_2024-07-05.jpg', true),
  PhotoCredit('Basilica del Santo Niño', 'LMP 2001', 'CC BY-SA 4.0', 'https://creativecommons.org/licenses/by-sa/4.0', 'https://commons.wikimedia.org/wiki/File:Basilica_del_Santo_Ni%C3%B1o_2024-07-05.jpg', true),
  PhotoCredit('Fort San Pedro', 'xiquinhosilva', 'CC BY 2.0', 'https://creativecommons.org/licenses/by/2.0', 'https://commons.wikimedia.org/wiki/File:Fort_San_Pedro,_Cebu-City_(49063919082).jpg'),
  PhotoCredit('Cebu Metropolitan Cathedral', 'LMP 2001', 'CC BY-SA 4.0', 'https://creativecommons.org/licenses/by-sa/4.0', 'https://commons.wikimedia.org/wiki/File:Cebu_Cathedral_2024-07-07.jpg', true),
  PhotoCredit('Heritage of Cebu Monument', 'Headshop5', 'CC0', 'http://creativecommons.org/publicdomain/zero/1.0/deed.en', 'https://commons.wikimedia.org/wiki/File:Heritage_of_Cebu_monument.jpg'),
  PhotoCredit('Casa Gorordo Museum', 'CharMel Creations', 'CC BY-SA 4.0', 'https://creativecommons.org/licenses/by-sa/4.0', 'https://commons.wikimedia.org/wiki/File:Casa_Gorordo_Cebu.jpg', true),
  PhotoCredit('Yap-Sandiego Ancestral House', 'Subhashish Panigrahi', 'CC BY-SA 4.0', 'https://creativecommons.org/licenses/by-sa/4.0', 'https://commons.wikimedia.org/wiki/File:Yap-Sandiego_Ancestral_House,_Cebu_City.jpg', true),
  PhotoCredit('Museo Sugbo', 'Aries Eroles', 'CC BY-SA 3.0', 'https://creativecommons.org/licenses/by-sa/3.0', 'https://commons.wikimedia.org/wiki/File:Museo_Sugbu.jpg'),
  PhotoCredit('Colon Street', 'Patrickroque01', 'CC BY-SA 4.0', 'https://creativecommons.org/licenses/by-sa/4.0', 'https://commons.wikimedia.org/wiki/File:Colon_Street-Osme%C3%B1a_Boulevard_intersection_close-up_(Cebu_City;_09-05-2022).jpg', true),
  PhotoCredit('Carbon Market', 'Patrickroque01', 'CC BY-SA 4.0', 'https://creativecommons.org/licenses/by-sa/4.0', 'https://commons.wikimedia.org/wiki/File:Carbon_Market_(MC_Briones,_Cebu_City;_01-21-2023).jpg', true),
  PhotoCredit('Cebu Provincial Capitol', 'Andrewhaimerl', 'CC BY-SA 4.0', 'https://creativecommons.org/licenses/by-sa/4.0', 'https://commons.wikimedia.org/wiki/File:Cebu_Capitol_Compund.jpg'),
  PhotoCredit('Ayala Center & Cebu Business Park', 'PaulGorduiz106', 'CC BY-SA 4.0', 'https://creativecommons.org/licenses/by-sa/4.0', 'https://commons.wikimedia.org/wiki/File:Ayala_Center_Cebu_(10-05-2022).jpg', true),
  PhotoCredit('Il Corso & SRP Seaside', 'Wide Awake!', 'CC BY 4.0', 'https://creativecommons.org/licenses/by/4.0', 'https://commons.wikimedia.org/wiki/File:IL_Corso_Lifemalls_in_Cebu_City_(2026-06-20).jpg'),
  PhotoCredit('CCLEX Bridge', 'Patrickroque01', 'CC BY-SA 4.0', 'https://creativecommons.org/licenses/by-sa/4.0', 'https://commons.wikimedia.org/wiki/File:CCLEX_Bridge_drone_2_(Cebu_City;_01-19-2026).jpg'),
  PhotoCredit('Jumalon Butterfly Sanctuary', 'William Cho', 'CC BY-SA 2.0', 'https://creativecommons.org/licenses/by-sa/2.0', 'https://commons.wikimedia.org/wiki/File:Butterfly_Sanctuary,_Cebu_(1185107453).jpg'),
  PhotoCredit('Mactan Shrine', 'Rabosajr', 'CC BY-SA 3.0', 'https://creativecommons.org/licenses/by-sa/3.0', 'https://commons.wikimedia.org/wiki/File:Ferdinand_Magellan%27s_death_plaque_in_Lapu-Lapu_City,_Mactan_Island,_Cebu,_Philippines.jpg'),
  PhotoCredit('Mactan Island Beaches', 'Lsj', 'CC BY-SA 3.0', 'https://creativecommons.org/licenses/by-sa/3.0', 'https://commons.wikimedia.org/wiki/File:Mactan-beach.jpg'),
  PhotoCredit('Olango Island Wildlife Sanctuary', 'Herbert Kikoy', 'CC BY-SA 4.0', 'https://creativecommons.org/licenses/by-sa/4.0', 'https://commons.wikimedia.org/wiki/File:Wildlife_Sanctuary_in_Olango_Island.jpg'),
  PhotoCredit('Kawasan Falls', 'Rollymagpayo', 'CC BY-SA 4.0', 'https://creativecommons.org/licenses/by-sa/4.0', 'https://commons.wikimedia.org/wiki/File:Kawasan_Falls_Cebu.jpg'),
  PhotoCredit('Oslob Whale Shark', 'Iampjanz', 'CC BY-SA 4.0', 'https://creativecommons.org/licenses/by-sa/4.0', 'https://commons.wikimedia.org/wiki/File:Whale_shark_in_Oslob,_Cebu_02.jpg'),
  PhotoCredit('Tumalog Falls', 'Iampjanz', 'CC BY-SA 4.0', 'https://creativecommons.org/licenses/by-sa/4.0', 'https://commons.wikimedia.org/wiki/File:Tumalog_Falls_in_Oslob,_Cebu_06.jpg'),
  PhotoCredit('Sumilon Island', 'Warrendering', 'CC BY-SA 4.0', 'https://creativecommons.org/licenses/by-sa/4.0', 'https://commons.wikimedia.org/wiki/File:Sumilon_Island_sandbar.jpg'),
  PhotoCredit('Cuartel Ruins', 'Patrickroque01', 'CC BY-SA 4.0', 'https://creativecommons.org/licenses/by-sa/4.0', 'https://commons.wikimedia.org/wiki/File:Cuartel_Ruins_Museo_Oslob_inside_(Eternidad,_Oslob,_Cebu;_01-18-2023).jpg'),
  PhotoCredit('Oslob Church', 'Jowowie', 'CC BY-SA 4.0', 'https://creativecommons.org/licenses/by-sa/4.0', 'https://commons.wikimedia.org/wiki/File:IMMACULATE_CONCEPTION_PARISH_OSLOB_CEBU,_PHILIPPINES.jpg'),
  PhotoCredit('Osmeña Peak', 'Doyyyyyj', 'CC BY-SA 4.0', 'https://creativecommons.org/licenses/by-sa/4.0', 'https://commons.wikimedia.org/wiki/File:Osmena_Peak_-_Cebu.jpg'),
  PhotoCredit('Badian Island', 'Patrickroque01', 'CC BY-SA 4.0', 'https://creativecommons.org/licenses/by-sa/4.0', 'https://commons.wikimedia.org/wiki/File:Badian_Island_view_from_Osme%C3%B1a_Peak_(Badian,_Cebu;_01-20-2023).jpg'),
  PhotoCredit('Lambug Beach', 'Su--May from London, UK', 'CC BY 2.0', 'https://creativecommons.org/licenses/by/2.0', 'https://commons.wikimedia.org/wiki/File:Lambug_beach,_Badian,_Cebu,_Philippines_-_Flickr.jpg'),
  PhotoCredit('Moalboal Sardine Run', 'Martin Michlmayr', 'CC BY-SA 4.0', 'https://creativecommons.org/licenses/by-sa/4.0', 'https://commons.wikimedia.org/wiki/File:Moalboal_2025-07-05_021.jpg'),
  PhotoCredit('Pescador Island', 'P199', 'CC BY-SA 4.0', 'https://creativecommons.org/licenses/by-sa/4.0', 'https://commons.wikimedia.org/wiki/File:Pescador_Island.JPG'),
  PhotoCredit('Inambakan Falls', 'WanderMheL', 'CC BY-SA 4.0', 'https://creativecommons.org/licenses/by-sa/4.0', 'https://commons.wikimedia.org/wiki/File:IMG-20200306-WA0133.jpg'),
  PhotoCredit('Mantayupan Falls', 'StrangerNbystander', 'CC BY-SA 4.0', 'https://creativecommons.org/licenses/by-sa/4.0', 'https://commons.wikimedia.org/wiki/File:Mantayupan_Falls_of_Barili,_Cebu.jpg'),
  PhotoCredit('Bojo River', 'Warrendering', 'CC BY-SA 4.0', 'https://creativecommons.org/licenses/by-sa/4.0', 'https://commons.wikimedia.org/wiki/File:Bojo_River.jpg'),
  PhotoCredit('Simala Shrine', 'Wide Awake!', 'CC BY 4.0', 'https://creativecommons.org/licenses/by/4.0', 'https://commons.wikimedia.org/wiki/File:The_top_of_the_Simala_Shrine_(2025-04-20).jpg', true),
  PhotoCredit('Sibonga Church', 'LMP 2001', 'CC BY-SA 4.0', 'https://creativecommons.org/licenses/by-sa/4.0', 'https://commons.wikimedia.org/wiki/File:Sibonga_Church_2024-07-06.jpg'),
  PhotoCredit('Carcar Heritage Town', 'Joannerfabregas', 'CC BY-SA 4.0', 'https://creativecommons.org/licenses/by-sa/4.0', 'https://commons.wikimedia.org/wiki/File:Carcar_Town_Complex.jpg'),
  PhotoCredit('Argao Church', 'Patrickroque01', 'CC BY-SA 4.0', 'https://creativecommons.org/licenses/by-sa/4.0', 'https://commons.wikimedia.org/wiki/File:Saint_Michael_the_Archangel_Church_Argao_(Rizal_Street,_Argao,_Cebu;_01-18-2023).jpg'),
  PhotoCredit('Dalaguete Church', 'Patrickroque01', 'CC BY-SA 4.0', 'https://creativecommons.org/licenses/by-sa/4.0', 'https://commons.wikimedia.org/wiki/File:San_Guillermo_Church_Dalaguete_(San_Guillermo_Street,_Dalaguete,_Cebu;_01-18-2023).jpg'),
  PhotoCredit('Boljoon Church', 'Patrickroque01', 'CC BY-SA 4.0', 'https://creativecommons.org/licenses/by-sa/4.0', 'https://commons.wikimedia.org/wiki/File:Patrocinio_de_Maria_Church_facade_(Cebu_South_Road,_Bonjoon,_Cebu;_01-18-2023).jpg'),
  PhotoCredit('Naga Church', 'Patrickroque01', 'CC BY-SA 4.0', 'https://creativecommons.org/licenses/by-sa/4.0', 'https://commons.wikimedia.org/wiki/File:Saint_Francis_of_Assisi_Parish_Naga_Cebu_inside_(Cebu_South_Road,_Naga,_Cebu;_09-07-2022).jpg'),
  PhotoCredit('Mount Manunggal', 'Risemerc', 'CC BY-SA 4.0', 'https://creativecommons.org/licenses/by-sa/4.0', 'https://commons.wikimedia.org/wiki/File:Ramon_Magsaysay_historical_marker_in_Balamban,_Cebu.jpg'),
  PhotoCredit('Malapascua Island', 'Vyacheslav Argenberg', 'CC BY 4.0', 'https://creativecommons.org/licenses/by/4.0', 'https://commons.wikimedia.org/wiki/File:Malapascua_(island),_Tropical_lagoon,_Pure_tropical_bliss,_Philippines.jpg'),
  PhotoCredit('Gato Island', 'Tol.lynx', 'CC BY-SA 4.0', 'https://creativecommons.org/licenses/by-sa/4.0', 'https://commons.wikimedia.org/wiki/File:Gato_Island.jpg'),
  PhotoCredit('Bantayan Island', 'Dennisj73', 'CC BY-SA 4.0', 'https://creativecommons.org/licenses/by-sa/4.0', 'https://commons.wikimedia.org/wiki/File:White_sand_bantayan_island.jpg'),
  PhotoCredit('Santa Fe Beach', 'SYKE Travel & Tours', 'CC BY-SA 4.0', 'https://creativecommons.org/licenses/by-sa/4.0', 'https://commons.wikimedia.org/wiki/File:Beach_in_Santa_Fe,_Bantayan_Island.jpg'),
  PhotoCredit('Virgin Island', 'MikelleBandin', 'CC BY-SA 4.0', 'https://creativecommons.org/licenses/by-sa/4.0', 'https://commons.wikimedia.org/wiki/File:Virgin_Island_(Sillon_Island),_Santa_Fe,_Bantayan,_Cebu.jpg', true),
  PhotoCredit('Hilantagaan Island', 'Unbuttered Parsnip', 'CC BY-SA 4.0', 'https://creativecommons.org/licenses/by-sa/4.0', 'https://commons.wikimedia.org/wiki/File:Hilantagaan_Island,_Santa_Fe_seen_from_the_south.jpg'),
  PhotoCredit('Capitancillo Island', 'tacit requiem (joanneQEscober ) from Marikina City, Philippines', 'CC BY 2.0', 'https://creativecommons.org/licenses/by/2.0', 'https://commons.wikimedia.org/wiki/File:Capitancillo_Islet_(5751157394).jpg'),
  PhotoCredit('Kalanggaman Island', 'Gcabig2024', 'CC BY-SA 4.0', 'https://creativecommons.org/licenses/by-sa/4.0', 'https://commons.wikimedia.org/wiki/File:Kalanggaman_Island_2024.jpg'),
  PhotoCredit('Camotes Islands', 'Headshop5', 'CC0', 'http://creativecommons.org/publicdomain/zero/1.0/deed.en', 'https://commons.wikimedia.org/wiki/File:Pacijan_island_from_the_sea.jpg'),
  PhotoCredit('Lake Danao', 'choypictures', 'CC0', 'http://creativecommons.org/publicdomain/zero/1.0/deed.en', 'https://commons.wikimedia.org/wiki/File:Lake_Danao_in_Camotes_Island.jpg'),
  PhotoCredit('Mangodlong Rock', 'The Wandering Angel', 'CC BY 2.0', 'https://creativecommons.org/licenses/by/2.0', 'https://commons.wikimedia.org/wiki/File:Mangodlong_Resort.jpg'),
  PhotoCredit('Cebu Safari and Adventure Park', 'Carl Kho', 'CC BY-SA 4.0', 'https://creativecommons.org/licenses/by-sa/4.0', 'https://commons.wikimedia.org/wiki/File:Crocodiles_fighting_for_life.jpg'),
  PhotoCredit('Danao Church', 'Patrickroque01', 'CC BY-SA 4.0', 'https://creativecommons.org/licenses/by-sa/4.0', 'https://commons.wikimedia.org/wiki/File:Santo_Tomas_de_Villanueva_Church_Danao_(Cebu_North_Road,_Danao,_Cebu;_01-17-2023).jpg'),
  PhotoCredit('Chocolate Hills', 'P199', 'CC BY-SA 3.0', 'https://creativecommons.org/licenses/by-sa/3.0', 'https://commons.wikimedia.org/wiki/File:Chocolate_Hills_Bohol.JPG'),
  PhotoCredit('Tarsier Sanctuary', 'Charles J. Sharp', 'CC BY-SA 4.0', 'https://creativecommons.org/licenses/by-sa/4.0', 'https://commons.wikimedia.org/wiki/File:Philippine_tarsier_(Carlito_syrichta_fraterculus)_Bohol.jpg'),
  PhotoCredit('Kawasan Falls (4K banner)', 'Rollymagpayo', 'CC BY-SA 4.0', 'https://creativecommons.org/licenses/by-sa/4.0', 'https://commons.wikimedia.org/wiki/File:Kawasan_Falls_Cebu.jpg'),
  PhotoCredit('Sumilon Island Sandbar (4K banner)', 'Warrendering', 'CC BY-SA 4.0', 'https://creativecommons.org/licenses/by-sa/4.0', 'https://commons.wikimedia.org/wiki/File:Sumilon_Island_sandbar.jpg'),
  PhotoCredit('Kalanggaman Island (4K banner)', 'Gcabig2024', 'CC BY-SA 4.0', 'https://creativecommons.org/licenses/by-sa/4.0', 'https://commons.wikimedia.org/wiki/File:Kalanggaman_Island_2024.jpg'),
  PhotoCredit('Moalboal (4K banner)', 'Martin Michlmayr', 'CC BY-SA 4.0', 'https://creativecommons.org/licenses/by-sa/4.0', 'https://commons.wikimedia.org/wiki/File:Moalboal_2025-07-05_021.jpg'),
  PhotoCredit('Malapascua Island (4K banner)', 'Vyacheslav Argenberg', 'CC BY 4.0', 'https://creativecommons.org/licenses/by/4.0', 'https://commons.wikimedia.org/wiki/File:Malapascua_(island),_Tropical_lagoon,_Pure_tropical_bliss,_Philippines.jpg'),
  PhotoCredit('Bantayan Island (4K banner)', 'Dennisj73', 'CC BY-SA 4.0', 'https://creativecommons.org/licenses/by-sa/4.0', 'https://commons.wikimedia.org/wiki/File:White_sand_bantayan_island.jpg'),
  PhotoCredit('Oslob Whale Sharks (4K banner)', 'Iampjanz', 'CC BY-SA 4.0', 'https://creativecommons.org/licenses/by-sa/4.0', 'https://commons.wikimedia.org/wiki/File:Whale_shark_in_Oslob,_Cebu_02.jpg'),
  PhotoCredit('Tumalog Falls (4K banner)', 'Iampjanz', 'CC BY-SA 4.0', 'https://creativecommons.org/licenses/by-sa/4.0', 'https://commons.wikimedia.org/wiki/File:Tumalog_Falls_in_Oslob,_Cebu_06.jpg'),
  PhotoCredit('Temple of Leah (4K banner)', 'Martin Michlmayr', 'CC BY-SA 4.0', 'https://creativecommons.org/licenses/by-sa/4.0', 'https://commons.wikimedia.org/wiki/File:Temple_of_Leah_2025-08-24_014.jpg', true),
];
