// Openly licensed travel videos (Wikimedia Commons), played in-app.
// Privacy-reviewed: scenery/underwater footage without identifiable faces or plates.

class TravelVideo {
  final String id;
  final String title;
  final String place;
  final String author;
  final String license;
  final String licenseUrl;
  final String sourceUrl;
  final String posterUrl;
  final String videoUrl;
  final int durationSec;
  /// H.264 fallback for browsers without VP9 WebM (older Safari).
  final String altVideoUrl;
  const TravelVideo({
    required this.id,
    required this.title,
    required this.place,
    required this.author,
    required this.license,
    required this.licenseUrl,
    required this.sourceUrl,
    required this.posterUrl,
    required this.videoUrl,
    required this.durationSec,
    required this.altVideoUrl,
  });
}

const List<TravelVideo> travelVideos = [
  TravelVideo(
    id: 'thresher_malapascua',
    title: 'Thresher Sharks of Malapascua',
    place: 'Malapascua Island',
    author: 'Bo Mancao',
    license: 'CC0',
    licenseUrl: 'http://creativecommons.org/publicdomain/zero/1.0/deed.en',
    sourceUrl: 'https://commons.wikimedia.org/wiki/File:Pelagic_thresher_shark_(Alopias_pelagicus).webm',
    posterUrl: 'https://thumb.wikimedia.org/wikipedia/commons/thumb/c/c7/Pelagic_thresher_shark_%28Alopias_pelagicus%29.webm/960px--Pelagic_thresher_shark_%28Alopias_pelagicus%29.webm.jpg',
    videoUrl: 'https://upload.wikimedia.org/wikipedia/commons/transcoded/c/c7/Pelagic_thresher_shark_%28Alopias_pelagicus%29.webm/Pelagic_thresher_shark_%28Alopias_pelagicus%29.webm.1080p.vp9.webm',
    altVideoUrl: 'https://upload.wikimedia.org/wikipedia/commons/transcoded/c/c7/Pelagic_thresher_shark_%28Alopias_pelagicus%29.webm/Pelagic_thresher_shark_%28Alopias_pelagicus%29.webm.360p.mpeg4.mov',
    durationSec: 45,
  ),
  TravelVideo(
    id: 'thresher_monad',
    title: 'Dawn Dive at Monad Shoal',
    place: 'Malapascua Island (Monad Shoal)',
    author: 'Arun Katiyar',
    license: 'CC BY-SA 2.0',
    licenseUrl: 'https://creativecommons.org/licenses/by-sa/2.0',
    sourceUrl: 'https://commons.wikimedia.org/wiki/File:Pelagic_thresher_(Alopias_pelagicus).webm',
    posterUrl: 'https://thumb.wikimedia.org/wikipedia/commons/thumb/9/9e/Pelagic_thresher_%28Alopias_pelagicus%29.webm/960px--Pelagic_thresher_%28Alopias_pelagicus%29.webm.jpg',
    videoUrl: 'https://upload.wikimedia.org/wikipedia/commons/transcoded/9/9e/Pelagic_thresher_%28Alopias_pelagicus%29.webm/Pelagic_thresher_%28Alopias_pelagicus%29.webm.480p.vp9.webm',
    altVideoUrl: 'https://upload.wikimedia.org/wikipedia/commons/transcoded/9/9e/Pelagic_thresher_%28Alopias_pelagicus%29.webm/Pelagic_thresher_%28Alopias_pelagicus%29.webm.360p.mpeg4.mov',
    durationSec: 103,
  ),
  TravelVideo(
    id: 'sardine_run_1',
    title: 'Moalboal Sardine Run',
    place: 'Moalboal',
    author: 'Lady01v',
    license: 'CC BY-SA 4.0',
    licenseUrl: 'https://creativecommons.org/licenses/by-sa/4.0',
    sourceUrl: 'https://commons.wikimedia.org/wiki/File:Sardine_Run_in_Moalboal_Cebu_Coastal_Heritage1.webm',
    posterUrl: 'https://thumb.wikimedia.org/wikipedia/commons/thumb/0/0c/Sardine_Run_in_Moalboal_Cebu_Coastal_Heritage1.webm/960px--Sardine_Run_in_Moalboal_Cebu_Coastal_Heritage1.webm.jpg',
    videoUrl: 'https://upload.wikimedia.org/wikipedia/commons/transcoded/0/0c/Sardine_Run_in_Moalboal_Cebu_Coastal_Heritage1.webm/Sardine_Run_in_Moalboal_Cebu_Coastal_Heritage1.webm.1080p.vp9.webm',
    altVideoUrl: 'https://upload.wikimedia.org/wikipedia/commons/transcoded/0/0c/Sardine_Run_in_Moalboal_Cebu_Coastal_Heritage1.webm/Sardine_Run_in_Moalboal_Cebu_Coastal_Heritage1.webm.360p.mpeg4.mov',
    durationSec: 14,
  ),
  TravelVideo(
    id: 'sardine_run_2',
    title: 'Swimming with the Sardines',
    place: 'Moalboal',
    author: 'Lady01v',
    license: 'CC BY-SA 4.0',
    licenseUrl: 'https://creativecommons.org/licenses/by-sa/4.0',
    sourceUrl: 'https://commons.wikimedia.org/wiki/File:Sardine_run_in_Moalboal_Cebu_coastal_heritage.webm',
    posterUrl: 'https://thumb.wikimedia.org/wikipedia/commons/thumb/b/b0/Sardine_run_in_Moalboal_Cebu_coastal_heritage.webm/960px--Sardine_run_in_Moalboal_Cebu_coastal_heritage.webm.jpg',
    videoUrl: 'https://upload.wikimedia.org/wikipedia/commons/transcoded/b/b0/Sardine_run_in_Moalboal_Cebu_coastal_heritage.webm/Sardine_run_in_Moalboal_Cebu_coastal_heritage.webm.1080p.vp9.webm',
    altVideoUrl: 'https://upload.wikimedia.org/wikipedia/commons/transcoded/b/b0/Sardine_run_in_Moalboal_Cebu_coastal_heritage.webm/Sardine_run_in_Moalboal_Cebu_coastal_heritage.webm.360p.mpeg4.mov',
    durationSec: 13,
  ),
  TravelVideo(
    id: 'cauliflower_jelly',
    title: 'Cauliflower Jellyfish, Bugtong Bato',
    place: 'Malapascua Island',
    author: 'Alexander R. Jenner',
    license: 'CC BY-SA 4.0',
    licenseUrl: 'https://creativecommons.org/licenses/by-sa/4.0',
    sourceUrl: 'https://commons.wikimedia.org/wiki/File:Cephea_cephea.webm',
    posterUrl: 'https://thumb.wikimedia.org/wikipedia/commons/thumb/3/32/Cephea_cephea.webm/960px--Cephea_cephea.webm.jpg',
    videoUrl: 'https://upload.wikimedia.org/wikipedia/commons/transcoded/3/32/Cephea_cephea.webm/Cephea_cephea.webm.480p.vp9.webm',
    altVideoUrl: 'https://upload.wikimedia.org/wikipedia/commons/transcoded/3/32/Cephea_cephea.webm/Cephea_cephea.webm.360p.mpeg4.mov',
    durationSec: 16,
  ),
];
