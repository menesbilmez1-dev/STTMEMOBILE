import 'package:flutter/foundation.dart';

import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:http/http.dart' as http;

import '../models/pending_entry.dart';
import '../models/app_config.dart';

/// Base exception for all API-related errors
class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => 'ApiException: $message';
}

/// Exception thrown when there is a network connectivity issue
class NetworkException extends ApiException {
  NetworkException(super.message);
}

/// Exception thrown when the server returns an error status code
class ServerException extends ApiException {
  final int statusCode;
  ServerException(this.statusCode, super.message);
  @override
  String toString() => 'ServerException ($statusCode): $message';
}

/// Exception thrown when the response format is unexpected
class DataFormatException extends ApiException {
  DataFormatException(super.message);
}

class ApiService {
  String _baseUrl;

  ApiService({required String baseUrl}) : _baseUrl = _sanitizeUrl(baseUrl);

  String get baseUrl => _baseUrl;

  void updateBaseUrl(String newUrl) {
    _baseUrl = _sanitizeUrl(newUrl);
  }

  static String _sanitizeUrl(String url) {
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  Uri _getUri(String path) {
    return Uri.parse('$_baseUrl$path');
  }

  Future<void> sendEntries(List<PendingEntry> entries) async {
    if (entries.isEmpty) return;

    final batchIds = entries.map((entry) => entry.batchId).toSet();
    if (batchIds.length != 1) {
      throw ApiException(
        'Each request must contain exactly one command batch.',
      );
    }

    try {
      final List<Map<String, dynamic>> payloadList = entries
          .map(
            (entry) => {
              'category': entry.category,
              'type': entry.type,
              'value': entry.value,
              'batchId': entry.batchId,
            },
          )
          .toList();

      final response = await http
          .post(
            _getUri('/command'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payloadList),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return;
      } else {
        throw ServerException(
          response.statusCode,
          _responseErrorMessage(
            response.body,
            'Failed to send entries. Server responded with ${response.statusCode}',
          ),
        );
      }
    } on SocketException catch (e) {
      debugPrint('Network error sending entries: $e');
      throw NetworkException('No internet connection or server unreachable.');
    } on TimeoutException catch (e) {
      debugPrint('Timeout sending entries: $e');
      throw NetworkException('Connection timed out.');
    } on ApiException {
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error sending entries: $e');
      throw ApiException('An unexpected error occurred: $e');
    }
  }

  String _responseErrorMessage(String body, String fallback) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic> && decoded['message'] is String) {
        return decoded['message'] as String;
      }
    } on FormatException {
      return fallback;
    }
    return fallback;
  }

  Future<AppConfig> fetchLatestConfig() async {
    try {
      final response = await http
          .get(_getUri('/config'))
          .timeout(const Duration(seconds: 10));
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> data = jsonDecode(response.body);

          final categoriesData = data['Categories'] ?? data['categories'];
          if (categoriesData == null) {
            throw DataFormatException(
              'Missing "Categories" in configuration data.',
            );
          }

          final categories = (categoriesData as List).map((cat) {
            return CategoryConfig(
              name: cat['Name'] ?? cat['name'] ?? 'Unknown',
              types: List<String>.from(cat['Types'] ?? cat['types'] ?? []),
            );
          }).toList();

          return AppConfig(categories: categories);
        } catch (e) {
          throw DataFormatException('Failed to parse configuration data: $e');
        }
      } else {
        throw ServerException(
          response.statusCode,
          'Failed to fetch config. Server responded with ${response.statusCode}',
        );
      }
    } on SocketException catch (e) {
      debugPrint('Network error fetching config: $e');
      throw NetworkException('No internet connection or server unreachable.');
    } on TimeoutException catch (e) {
      debugPrint('Timeout fetching config: $e');
      throw NetworkException('Connection timed out.');
    } on ApiException {
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error fetching config: $e');
      throw ApiException('An unexpected error occurred: $e');
    }
  }

  Future<void> testConnection([String? url]) async {
    final targetUrl = url ?? _baseUrl;
    final sanitizedTarget = _sanitizeUrl(targetUrl);
    try {
      final response = await http
          .get(Uri.parse('$sanitizedTarget/config'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return;
      } else {
        throw ServerException(
          response.statusCode,
          'Connection test failed. Server responded with ${response.statusCode}',
        );
      }
    } on SocketException catch (e) {
      debugPrint('Network error during connection test: $e');
      throw NetworkException('No internet connection or server unreachable.');
    } on TimeoutException catch (e) {
      debugPrint('Timeout during connection test: $e');
      throw NetworkException('Connection timed out.');
    } on ApiException {
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error during connection test: $e');
      throw ApiException('An unexpected error occurred: $e');
    }
  }
}
