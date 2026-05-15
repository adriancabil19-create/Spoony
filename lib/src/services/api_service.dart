import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class ApiService {
  static const String _baseUrl = 'https://spoony.onrender.com/api';

  static bool get isAuthenticated =>
      Supabase.instance.client.auth.currentSession != null;

  static Map<String, String> get _headers {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> get(String path) async {
    final response = await http.get(
      Uri.parse('$_baseUrl$path'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await http.put(
      Uri.parse('$_baseUrl$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> delete(String path) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl$path'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }
    throw ApiException(
      body['message'] as String? ?? 'Request failed',
      response.statusCode,
    );
  }

  // Auth — use Supabase directly; register helper kept for server-side validation ops
  static Future<Map<String, dynamic>> register(
          String name, String email, String password) =>
      post('/auth/register', {'name': name, 'email': email, 'password': password});

  // Destinations
  static Future<Map<String, dynamic>> getDestinations() =>
      get('/destinations');

  static Future<Map<String, dynamic>> getAllDestinations() =>
      get('/destinations?all=true');

  static Future<Map<String, dynamic>> updateDestination(String id, Map<String, dynamic> data) =>
      put('/destinations/$id', data);

  static Future<Map<String, dynamic>> addDestination(Map<String, dynamic> data) =>
      post('/destinations', data);

  static Future<Map<String, dynamic>> getDestinationById(String id) =>
      get('/destinations/$id');

  // Tours
  static Future<Map<String, dynamic>> getTours() => get('/tours');

  static Future<Map<String, dynamic>> createTour(
          Map<String, dynamic> tourData) =>
      post('/tours', tourData);

  // Bookings
  static Future<Map<String, dynamic>> createBooking(
          Map<String, dynamic> bookingData) =>
      post('/bookings', bookingData);

  static Future<Map<String, dynamic>> getMyBookings() =>
      get('/bookings/my');

  static Future<Map<String, dynamic>> cancelBooking(String bookingId) =>
      put('/bookings/$bookingId/cancel', {});

  static Future<Map<String, dynamic>> getAllBookings() =>
      get('/bookings');

  static Future<Map<String, dynamic>> approveBooking(String bookingId) =>
      put('/bookings/$bookingId/approve', {});

  static Future<Map<String, dynamic>> rejectBooking(String bookingId) =>
      put('/bookings/$bookingId/reject', {});

  // Payments
  static Future<Map<String, dynamic>> uploadPaymentReceipt(
          String bookingId, String receiptUrl) =>
      post('/payments', {'bookingId': bookingId, 'receiptUrl': receiptUrl});

  static Future<Map<String, dynamic>> verifyPayment(String paymentId) =>
      put('/payments/$paymentId/verify', {});

  // Reviews
  static Future<Map<String, dynamic>> addReview(
          String destinationId, int rating, String comment) =>
      post('/reviews', {
        'destinationId': destinationId,
        'rating': rating,
        'comment': comment,
      });

  static Future<Map<String, dynamic>> getReviews(String destinationId) =>
      get('/reviews/$destinationId');

  // Tourist spots via Overpass API (proxied through backend)
  static Future<Map<String, dynamic>> getTouristSpots(
    double lat,
    double lng, {
    int radius = 5000,
  }) =>
      get('/destinations/tourist-spots?lat=$lat&lng=$lng&radius=$radius');
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException($statusCode): $message';
}
