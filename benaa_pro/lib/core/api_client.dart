// lib/core/api_client.dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class ApiClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:8000/api/v1',
      connectTimeout: const Duration(seconds: 5),
    ),
  );
  static Dio get instance => _dio;
  static void initInterceptor() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('access_token');
          if (token != null) options.headers['Authorization'] = 'Bearer $token';
          return handler.next(options);
        },

        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401 &&
              e.requestOptions.path != '/auth/refresh') {
            final prefs = await SharedPreferences.getInstance();
            final refreshToken = prefs.getString('refresh_token');

            if (refreshToken != null) {
              try {
                final refreshDio = Dio(
                  BaseOptions(baseUrl: 'http://10.0.2.2:8000/api/v1'),
                );
                final refreshResponse = await _dio.post(
                  '/auth/refresh',
                  options: Options(headers: {'refresh-token': refreshToken}),
                );

                final newAccessToken = refreshResponse.data['access_token'];
                await prefs.setString('access_token', newAccessToken);

                final opts = e.requestOptions;
                opts.headers['Authorization'] = 'Bearer $newAccessToken';
                final retryResponse = await _dio.fetch(opts);
                return handler.resolve(retryResponse);
              } catch (err) {
                await prefs.clear();
                navigatorKey.currentState?.pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              }
            }
          }
          return handler.next(e);
        },
      ),
    );
  }
}
