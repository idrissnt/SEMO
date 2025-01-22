import 'dart:convert';
import 'package:http/http.dart' as http;

class NetworkUtils {
  static bool isSuccessful(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  static String getErrorMessage(http.Response response) {
    try {
      final body = json.decode(response.body);
      if (body is Map && body.containsKey('message')) {
        return body['message'];
      } else if (body is Map && body.containsKey('error')) {
        return body['error'];
      }
    } catch (e) {
      // If we can't parse the JSON or find a message, return a generic error
    }

    switch (response.statusCode) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return 'Unauthorized. Please login again.';
      case 403:
        return 'Forbidden. You don\'t have permission to access this resource.';
      case 404:
        return 'Resource not found.';
      case 500:
        return 'Internal server error. Please try again later.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  static Map<String, String> getAuthHeaders(String token) {
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  static Future<bool> hasInternetConnection() async {
    try {
      final response = await http.get(Uri.parse('https://www.google.com'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Uri buildUri(String baseUrl, String path, [Map<String, dynamic>? queryParams]) {
    final uri = Uri.parse('$baseUrl/$path');
    if (queryParams != null) {
      return uri.replace(queryParameters: queryParams.map(
        (key, value) => MapEntry(key, value.toString()),
      ));
    }
    return uri;
  }
}
