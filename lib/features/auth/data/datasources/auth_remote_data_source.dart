import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:perfume_app_mobile/core/error/exceptions.dart';
import '../models/auth_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(String name, String password);
  Future<AuthResponseModel> register(String name, String email, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;
  static const String BASE_URL = 'https://server-production-45af.up.railway.app/api/user'; // Base path for user routes

  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<AuthResponseModel> login(String name, String password) async {
    final response = await client.post(
      Uri.parse('$BASE_URL/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return AuthResponseModel.fromJson(json.decode(response.body));
    } else {
      final errorData = json.decode(response.body);
      throw ServerException(message: errorData['message'] ?? 'Login failed.');
    }
  }

  @override
  Future<AuthResponseModel> register(String name, String email, String password) async {
    final response = await client.post(
      Uri.parse('$BASE_URL/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'email': email,
        'password': password,
        'role': 'USER',
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Assuming register might also return a token, or just a success message.
      // If it returns only a success message, you'd adjust this.
      // For now, mirroring login to return a token if applicable.
      return AuthResponseModel.fromJson(json.decode(response.body));
    } else {
      final errorData = json.decode(response.body);
      throw ServerException(message: errorData['message'] ?? 'Registration failed.');
    }
  }
}
