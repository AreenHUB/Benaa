import 'package:dio/dio.dart';

class ApiClient {
  static final Dio _dio = Dio(
    BaseOptions(
      // استخدم 10.0.2.2 لمحاكي الأندرويد، أو 127.0.0.1 لمحاكي iOS
      baseUrl: 'http://10.0.2.2:8000/api/v1',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static Dio get instance => _dio;
}
