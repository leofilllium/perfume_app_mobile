import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:perfume_app_mobile/core/error/exceptions.dart';
import '../models/order_model.dart';
import '../models/preferences_model.dart';
import '../models/user_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserModel> getUserProfile(String token);
  Future<List<OrderModel>> getUserOrders(String token);
  Future<PreferencesModel> getUserPreferences(String token);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final http.Client client;
  static const String BASE_URL = 'https://server-production-45af.up.railway.app/api';

  ProfileRemoteDataSourceImpl({required this.client});

  Map<String, String> _getAuthHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<UserModel> getUserProfile(String token) async {
    final response = await client.get(
      Uri.parse('$BASE_URL/user/profile'),
      headers: _getAuthHeaders(token),
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      throw UnauthenticatedException(message: 'Session expired. Please log in again.');
    } else {
      throw ServerException(message: 'Failed to load user profile: ${response.statusCode}');
    }
  }

  @override
  Future<List<OrderModel>> getUserOrders(String token) async {
    final response = await client.get(
      Uri.parse('$BASE_URL/order/my'),
      headers: _getAuthHeaders(token),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => OrderModel.fromJson(json)).toList();
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      throw UnauthenticatedException(message: 'Session expired. Please log in again.');
    } else {
      throw ServerException(message: 'Failed to load user orders: ${response.statusCode}');
    }
  }

  @override
  Future<PreferencesModel> getUserPreferences(String token) async {
    final response = await client.get(
      Uri.parse('$BASE_URL/preferences'),
      headers: _getAuthHeaders(token),
    );

    if (response.statusCode == 200) {
      return PreferencesModel.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      throw UnauthenticatedException(message: 'Session expired. Please log in again.');
    } else if (response.statusCode == 404 && json.decode(response.body)['message'] == 'User preferences not found') {
      throw ServerException(message: 'User preferences not found'); // Specific message for domain layer
    }
    else {
      throw ServerException(message: 'Failed to load user preferences: ${response.statusCode}');
    }
  }
}