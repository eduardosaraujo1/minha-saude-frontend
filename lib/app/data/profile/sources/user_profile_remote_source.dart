import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:minha_saude_frontend/app/data/profile/models/user.dart';

/// Remote data source for user profile
/// Handles API communication for user profile operations
class UserProfileRemoteSource {
  final http.Client _client;
  final String _baseUrl;

  UserProfileRemoteSource(this._client, this._baseUrl);

  /// Fetch user profile from API
  Future<User?> fetchUserProfile() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/api/user/profile'),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        return User.fromJson(userData);
      } else {
        // Handle error responses based on status code
        _handleErrorResponse(response);
        return null;
      }
    } catch (e) {
      // Handle network or parsing errors
      rethrow;
    }
  }

  /// Update a specific field in user profile
  Future<User?> updateUserField({
    required String field,
    required dynamic value,
  }) async {
    try {
      final response = await _client.patch(
        Uri.parse('$_baseUrl/api/user/profile'),
        headers: await _getAuthHeaders(),
        body: jsonEncode({field: value}),
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        return User.fromJson(userData);
      } else {
        _handleErrorResponse(response);
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get authentication headers for API requests
  Future<Map<String, String>> _getAuthHeaders() async {
    // In a real implementation, you would get this from your auth provider
    // For now, we'll return a placeholder
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer TOKEN_HERE',
    };
  }

  /// Handle error responses from API
  void _handleErrorResponse(http.Response response) {
    // Handle different error codes appropriately
    // This could throw custom exceptions based on status codes
    if (response.statusCode == 401) {
      throw Exception('Unauthorized');
    } else if (response.statusCode == 404) {
      throw Exception('User profile not found');
    } else {
      throw Exception('Failed to fetch profile: ${response.statusCode}');
    }
  }
}
