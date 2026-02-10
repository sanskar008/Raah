import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../storage/secure_storage_service.dart';
import '../constants/app_constants.dart';
import 'api_exceptions.dart';

/// Centralized API service for all HTTP requests.
/// Handles token injection, response parsing, and error mapping.
class ApiService {
  final http.Client _client;
  final SecureStorageService _storage;

  ApiService({
    http.Client? client,
    required SecureStorageService storage,
  })  : _client = client ?? http.Client(),
        _storage = storage;

  // ── Headers ──
  Future<Map<String, String>> _getHeaders({bool auth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (auth) {
      final token = await _storage.read(AppConstants.tokenKey);
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // ── GET ──
  Future<dynamic> get(
    String url, {
    bool auth = true,
    Map<String, String>? queryParams,
  }) async {
    final uri = Uri.parse(url).replace(queryParameters: queryParams);
    final startTime = DateTime.now();
    
    // Log API call initiation
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('📡 API CALL: GET');
    debugPrint('📍 URL: $uri');
    if (queryParams != null && queryParams.isNotEmpty) {
      debugPrint('🔍 Query Params: $queryParams');
    }
    debugPrint('🔐 Auth Required: $auth');
    debugPrint('⏰ Time: ${startTime.toIso8601String()}');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    
    try {
      final response = await _client.get(
        uri,
        headers: await _getHeaders(auth: auth),
      );
      final duration = DateTime.now().difference(startTime);
      return _handleResponse(response, 'GET', uri.toString(), duration);
    } on SocketException catch (e) {
      final duration = DateTime.now().difference(startTime);
      _logFailure('GET', uri.toString(), NetworkException(), duration, e.toString());
      throw NetworkException();
    } catch (e) {
      final duration = DateTime.now().difference(startTime);
      _logFailure('GET', uri.toString(), e is ApiException ? e : ServerException(), duration, e.toString());
      rethrow;
    }
  }

  // ── POST ──
  Future<dynamic> post(
    String url, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    final uri = Uri.parse(url);
    final startTime = DateTime.now();
    
    // Log API call initiation
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('📡 API CALL: POST');
    debugPrint('📍 URL: $uri');
    if (body != null && body.isNotEmpty) {
      debugPrint('📦 Request Body: ${jsonEncode(body)}');
    }
    debugPrint('🔐 Auth Required: $auth');
    debugPrint('⏰ Time: ${startTime.toIso8601String()}');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    
    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: await _getHeaders(auth: auth),
        body: body != null ? jsonEncode(body) : null,
      );
      final duration = DateTime.now().difference(startTime);
      return _handleResponse(response, 'POST', uri.toString(), duration);
    } on SocketException catch (e) {
      final duration = DateTime.now().difference(startTime);
      _logFailure('POST', uri.toString(), NetworkException(), duration, e.toString());
      throw NetworkException();
    } catch (e) {
      final duration = DateTime.now().difference(startTime);
      _logFailure('POST', uri.toString(), e is ApiException ? e : ServerException(), duration, e.toString());
      rethrow;
    }
  }

  // ── PUT ──
  Future<dynamic> put(
    String url, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    final uri = Uri.parse(url);
    final startTime = DateTime.now();
    
    // Log API call initiation
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('📡 API CALL: PUT');
    debugPrint('📍 URL: $uri');
    if (body != null && body.isNotEmpty) {
      debugPrint('📦 Request Body: ${jsonEncode(body)}');
    }
    debugPrint('🔐 Auth Required: $auth');
    debugPrint('⏰ Time: ${startTime.toIso8601String()}');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    
    try {
      final response = await _client.put(
        Uri.parse(url),
        headers: await _getHeaders(auth: auth),
        body: body != null ? jsonEncode(body) : null,
      );
      final duration = DateTime.now().difference(startTime);
      return _handleResponse(response, 'PUT', uri.toString(), duration);
    } on SocketException catch (e) {
      final duration = DateTime.now().difference(startTime);
      _logFailure('PUT', uri.toString(), NetworkException(), duration, e.toString());
      throw NetworkException();
    } catch (e) {
      final duration = DateTime.now().difference(startTime);
      _logFailure('PUT', uri.toString(), e is ApiException ? e : ServerException(), duration, e.toString());
      rethrow;
    }
  }

  // ── DELETE ──
  Future<dynamic> delete(
    String url, {
    bool auth = true,
  }) async {
    final uri = Uri.parse(url);
    final startTime = DateTime.now();
    
    // Log API call initiation
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('📡 API CALL: DELETE');
    debugPrint('📍 URL: $uri');
    debugPrint('🔐 Auth Required: $auth');
    debugPrint('⏰ Time: ${startTime.toIso8601String()}');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    
    try {
      final response = await _client.delete(
        Uri.parse(url),
        headers: await _getHeaders(auth: auth),
      );
      final duration = DateTime.now().difference(startTime);
      return _handleResponse(response, 'DELETE', uri.toString(), duration);
    } on SocketException catch (e) {
      final duration = DateTime.now().difference(startTime);
      _logFailure('DELETE', uri.toString(), NetworkException(), duration, e.toString());
      throw NetworkException();
    } catch (e) {
      final duration = DateTime.now().difference(startTime);
      _logFailure('DELETE', uri.toString(), e is ApiException ? e : ServerException(), duration, e.toString());
      rethrow;
    }
  }

  // ── Multipart (for image uploads) ──
  Future<dynamic> uploadMultipart(
    String url, {
    required List<http.MultipartFile> files,
    Map<String, String>? fields,
    bool auth = true,
  }) async {
    final uri = Uri.parse(url);
    final startTime = DateTime.now();
    
    // Log API call initiation
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('📡 API CALL: POST (Multipart)');
    debugPrint('📍 URL: $uri');
    debugPrint('📎 Files: ${files.length} file(s)');
    if (fields != null && fields.isNotEmpty) {
      debugPrint('📦 Fields: $fields');
    }
    debugPrint('🔐 Auth Required: $auth');
    debugPrint('⏰ Time: ${startTime.toIso8601String()}');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    
    try {
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(await _getHeaders(auth: auth));
      request.files.addAll(files);
      if (fields != null) request.fields.addAll(fields);

      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);
      final duration = DateTime.now().difference(startTime);
      return _handleResponse(response, 'POST (Multipart)', uri.toString(), duration);
    } on SocketException catch (e) {
      final duration = DateTime.now().difference(startTime);
      _logFailure('POST (Multipart)', uri.toString(), NetworkException(), duration, e.toString());
      throw NetworkException();
    } catch (e) {
      final duration = DateTime.now().difference(startTime);
      _logFailure('POST (Multipart)', uri.toString(), e is ApiException ? e : ServerException(), duration, e.toString());
      rethrow;
    }
  }

  // ── Response handler ──
  // Backend returns: { success, statusCode, message, data }
  dynamic _handleResponse(
    http.Response response,
    String method,
    String url,
    Duration duration,
  ) {
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;

    // Check if response indicates failure
    if (body != null && body['success'] == false) {
      final message = body['message'] ?? 'Request failed';
      final statusCode = body['statusCode'] ?? response.statusCode;

      ApiException exception;
      switch (statusCode) {
        case 401:
          exception = UnauthorizedException(message: message);
          break;
        case 404:
          exception = NotFoundException(message: message);
          break;
        case 400:
        case 422:
          exception = ValidationException(
            message: message,
            errors: body['errors'],
          );
          break;
        case 403:
          exception = UnauthorizedException(message: message);
          break;
        case 409:
          exception = ValidationException(message: message);
          break;
        default:
          exception = ServerException(message: message);
      }
      
      _logFailure(method, url, exception, duration, response.body);
      throw exception;
    }

    switch (response.statusCode) {
      case 200:
      case 201:
        // Log success
        _logSuccess(method, url, response.statusCode, body?['data'] ?? body, duration);
        // Return the data field if present, otherwise return the whole body
        return body?['data'] ?? body;
      case 401:
        final exception = UnauthorizedException(
          message: body?['message'] ?? 'Unauthorized',
        );
        _logFailure(method, url, exception, duration, response.body);
        throw exception;
      case 404:
        final exception = NotFoundException(
          message: body?['message'] ?? 'Not found',
        );
        _logFailure(method, url, exception, duration, response.body);
        throw exception;
      case 422:
        final exception = ValidationException(
          message: body?['message'] ?? 'Validation failed',
          errors: body?['errors'],
        );
        _logFailure(method, url, exception, duration, response.body);
        throw exception;
      case 500:
      default:
        final exception = ServerException(
          message: body?['message'] ?? 'Something went wrong',
        );
        _logFailure(method, url, exception, duration, response.body);
        throw exception;
    }
  }

  // ── Success logging ──
  void _logSuccess(
    String method,
    String url,
    int statusCode,
    dynamic data,
    Duration duration,
  ) {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('✅ API SUCCESS: $method');
    debugPrint('📍 URL: $url');
    debugPrint('📊 Status Code: $statusCode');
    debugPrint('⏱️  Duration: ${duration.inMilliseconds}ms');
    if (data != null) {
      try {
        final dataStr = data is Map || data is List
            ? jsonEncode(data)
            : data.toString();
        // Truncate long responses for readability
        final truncatedData = dataStr.length > 500
            ? '${dataStr.substring(0, 500)}... (truncated)'
            : dataStr;
        debugPrint('📦 Response Data: $truncatedData');
      } catch (e) {
        debugPrint('📦 Response Data: [Unable to serialize]');
      }
    }
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  // ── Failure logging ──
  void _logFailure(
    String method,
    String url,
    ApiException exception,
    Duration duration,
    String? responseBody,
  ) {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('❌ API FAILURE: $method');
    debugPrint('📍 URL: $url');
    debugPrint('📊 Status Code: ${exception.statusCode ?? 'N/A'}');
    debugPrint('⏱️  Duration: ${duration.inMilliseconds}ms');
    debugPrint('💥 Error Type: ${exception.runtimeType}');
    debugPrint('📝 Error Message: ${exception.message}');
    if (exception is ValidationException && exception.errors != null) {
      debugPrint('🔍 Validation Errors: ${jsonEncode(exception.errors)}');
    }
    if (responseBody != null && responseBody.isNotEmpty) {
      try {
        final truncatedBody = responseBody.length > 500
            ? '${responseBody.substring(0, 500)}... (truncated)'
            : responseBody;
        debugPrint('📦 Response Body: $truncatedBody');
      } catch (e) {
        debugPrint('📦 Response Body: [Unable to parse]');
      }
    }
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }
}
