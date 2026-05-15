import 'package:flutter/material.dart';

enum DestinationRegion { all, cebuCity, southCebu, northCebu, bohol }

enum TourType { joiner, premium }

typedef LatLngCoordinate = Map<String, double>;

class Destination {
  final String id;
  final String name;
  final String description;
  final DestinationRegion region;
  final List<String> images;
  final double entranceFee;
  final double rating;
  final int reviews;
  final LatLngCoordinate coordinates;
  final String travelTime;
  final double averageDistanceKm;

  Destination({
    required this.id,
    required this.name,
    required this.description,
    required this.region,
    required this.images,
    required this.entranceFee,
    required this.rating,
    required this.reviews,
    required this.coordinates,
    required this.travelTime,
    required this.averageDistanceKm,
  });
}

class AccommodationOption {
  final String id;
  final String title;
  final String category;
  final double nightlyRate;
  final String description;

  AccommodationOption({
    required this.id,
    required this.title,
    required this.category,
    required this.nightlyRate,
    required this.description,
  });
}

class TransportOption {
  final String id;
  final String title;
  final String description;
  final double price;

  TransportOption({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
  });
}

class TourPackage {
  final String id;
  final String name;
  final String tagline;
  final String description;
  final List<String> highlights;
  final int durationDays;
  final double joinerPricePerPerson;
  final double premiumPricePerPerson;
  final String imageUrl;
  final String region;

  const TourPackage({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.highlights,
    required this.durationDays,
    required this.joinerPricePerPerson,
    required this.premiumPricePerPerson,
    required this.imageUrl,
    required this.region,
  });
}

class TourAddOn {
  final String id;
  final String title;
  final String emoji;
  final double price;
  final bool perPerson;

  const TourAddOn({
    required this.id,
    required this.title,
    required this.emoji,
    required this.price,
    required this.perPerson,
  });
}

class BookingSelection {
  final List<String> spotIds;
  final int guests;
  final String accommodationId;
  final String transportId;
  final DateTime? startDate;
  final DateTime? endDate;

  BookingSelection({
    this.spotIds = const [],
    this.guests = 2,
    this.accommodationId = 'acc_standard',
    this.transportId = 'trans_shared_van',
    this.startDate,
    this.endDate,
  });

  BookingSelection copyWith({
    List<String>? spotIds,
    int? guests,
    String? accommodationId,
    String? transportId,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return BookingSelection(
      spotIds: spotIds ?? this.spotIds,
      guests: guests ?? this.guests,
      accommodationId: accommodationId ?? this.accommodationId,
      transportId: transportId ?? this.transportId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

class AnalyticsCardData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  AnalyticsCardData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}
