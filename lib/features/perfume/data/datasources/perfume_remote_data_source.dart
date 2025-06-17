import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/error/exceptions.dart';
import '../models/perfume_model.dart';
import '../../domain/repositories/perfume_repository.dart';

abstract class PerfumeRemoteDataSource {
  Future<PerfumeList> getPerfumes({
    String? gender,
    String? searchQuery,
    double? minPrice,
    double? maxPrice,
    int? page,
    int? pageSize,
  });

  // Updated to return Map<String, dynamic>
  Future<Map<String, dynamic>> placeOrder({
    required int perfumeId,
    required int quantity,
    String? orderMessage,
    required String token,
  });
}

class PerfumeRemoteDataSourceImpl implements PerfumeRemoteDataSource {
  final http.Client client;
  static const String BASE_URL = 'https://server-production-45af.up.railway.app/api';

  PerfumeRemoteDataSourceImpl({required this.client});

  @override
  Future<PerfumeList> getPerfumes({
    String? gender,
    String? searchQuery,
    double? minPrice,
    double? maxPrice,
    int? page,
    int? pageSize,
  }) async {
    final Map<String, String> queryParams = {};
    if (gender != null && gender.isNotEmpty) queryParams['gender'] = gender;
    if (searchQuery != null && searchQuery.isNotEmpty) queryParams['search'] = searchQuery;
    if (minPrice != null) queryParams['minPrice'] = minPrice.toString();
    if (maxPrice != null) queryParams['maxPrice'] = maxPrice.toString();
    queryParams['page'] = (page ?? 1).toString();
    queryParams['pageSize'] = (pageSize ?? 10).toString();

    final uri = Uri.parse('$BASE_URL/parfume').replace(queryParameters: queryParams);

    print('Attempting to fetch perfumes from URL: $uri'); // DEBUG
    print('Headers: ${{'Content-Type': 'application/json'}}'); // DEBUG

    try {
      final response = await client.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      print('Response status code: ${response.statusCode}'); // DEBUG
      print('Response body: ${response.body}'); // DEBUG

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<PerfumeModel> perfumes = (jsonResponse['perfumes'] as List)
            .map((e) => PerfumeModel.fromJson(e))
            .toList();
        final int totalCount = jsonResponse['totalCount'];
        final int currentPage = jsonResponse['currentPage'];
        final int totalPages = jsonResponse['totalPages'];

        print('Successfully parsed perfume data.'); // DEBUG
        return PerfumeList(
          perfumes: perfumes,
          totalCount: totalCount,
          currentPage: currentPage,
          totalPages: totalPages,
        );
      } else if (response.statusCode == 404) {
        print('Server Exception: Not found (404)'); // DEBUG
        throw ServerException(message: 'Not found');
      } else {
        print('Server Exception: Failed to load perfumes (${response.statusCode})'); // DEBUG
        throw ServerException(message: 'Failed to load perfumes');
      }
    } catch (e) {
      print('Error during API call in PerfumeRemoteDataSource: $e'); // DEBUG
      // Re-throw to be caught by the repository
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(message: 'Network error or unexpected response: $e'); // Generic error for unexpected issues
    }
  }

  @override
  // Changed return type from Future<void> to Future<Map<String, dynamic>>
  Future<Map<String, dynamic>> placeOrder({
    required int perfumeId,
    required int quantity,
    String? orderMessage,
    required String token,
  }) async {
    final uri = Uri.parse('$BASE_URL/order');
    print('Attempting to place order to URL: $uri'); // DEBUG
    print('Order Payload: ${json.encode({
      'perfumeId': perfumeId,
      'quantity': quantity,
      'orderMessage': orderMessage,
    })}'); // DEBUG
    print('Auth Token (first 10 chars): ${token.substring(0, token.length > 10 ? 10 : token.length)}...'); // DEBUG

    try {
      final response = await client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'perfumeId': perfumeId,
          'quantity': quantity,
          'orderMessage': orderMessage,
        }),
      );

      print('Order response status code: ${response.statusCode}'); // DEBUG
      print('Order response body: ${response.body}'); // DEBUG


      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Order placed successfully. Returning order data.'); // DEBUG
        final decodedBody = json.decode(response.body);
        // Ensure the decoded body is a Map<String, dynamic> before returning
        if (decodedBody is Map<String, dynamic>) {
          return decodedBody;
        } else {
          throw ServerException(message: 'Invalid response format for order placement. Expected JSON object.');
        }
      } else if (response.statusCode == 401) {
        print('Server Exception: Unauthorized (401)'); // DEBUG
        throw ServerException(message: 'Unauthorized: Please log in.');
      } else {
        // Attempt to decode error message from body if available
        String errorMessage = 'Failed to place order.';
        try {
          final errorData = json.decode(response.body);
          if (errorData is Map<String, dynamic> && errorData.containsKey('message')) {
            errorMessage = errorData['message'];
          }
        } catch (_) {
          // Fallback to generic message if error body is not valid JSON
        }
        print('Server Exception: Failed to place order (${response.statusCode}) - $errorMessage'); // DEBUG
        throw ServerException(message: errorMessage);
      }
    } catch (e) {
      print('Error during API call for placeOrder: $e'); // DEBUG
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(message: 'Network error or unexpected response for order: $e');
    }
  }
}