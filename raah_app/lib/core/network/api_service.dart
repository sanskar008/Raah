import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
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
    try {
      final uri = Uri.parse(url).replace(queryParameters: queryParams);
      final response = await _client.get(
        uri,
        headers: await _getHeaders(auth: auth),
      );
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException();
    }
  }

  // ── POST ──
  Future<dynamic> post(
    String url, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: await _getHeaders(auth: auth),
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException();
    }
  }

  // ── PUT ──
  Future<dynamic> put(
    String url, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    try {
      final response = await _client.put(
        Uri.parse(url),
        headers: await _getHeaders(auth: auth),
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException();
    }
  }

  // ── DELETE ──
  Future<dynamic> delete(
    String url, {
    bool auth = true,
  }) async {
    try {
      final response = await _client.delete(
        Uri.parse(url),
        headers: await _getHeaders(auth: auth),
      );
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException();
    }
  }

  // ── Multipart (for image uploads) ──
  Future<dynamic> uploadMultipart(
    String url, {
    required List<http.MultipartFile> files,
    Map<String, String>? fields,
    bool auth = true,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(await _getHeaders(auth: auth));
      request.files.addAll(files);
      if (fields != null) request.fields.addAll(fields);

      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException();
    }
  }

  // ── Response handler ──
  dynamic _handleResponse(http.Response response) {
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;

    switch (response.statusCode) {
      case 200:
      case 201:
        return body;
      case 401:
        throw UnauthorizedException(
          message: body?['message'] ?? 'Unauthorized',
        );
      case 404:
        throw NotFoundException(
          message: body?['message'] ?? 'Not found',
        );
      case 422:
        throw ValidationException(
          message: body?['message'] ?? 'Validation failed',
          errors: body?['errors'],
        );
      case 500:
      default:
        throw ServerException(
          message: body?['message'] ?? 'Something went wrong',
        );
    }
  }
}
