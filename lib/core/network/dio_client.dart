import 'package:dio/dio.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/iam/infrastructure/auth_session.dart';
import 'package:mobile/iam/infrastructure/persistence/local/token_local_storage.dart';
import 'package:mobile/iam/interfaces/rest/resources/authenticated_user_resource.resource.dart';

class DioClient {
  late final Dio _dio;
  final TokenLocalStorage _tokenStorage;

  DioClient({required TokenLocalStorage tokenStorage}) : _tokenStorage = tokenStorage {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final isPublicAuthEndpoint = _isPublicAuthEndpoint(options.path);
          if (!isPublicAuthEndpoint) {
            final token = await _tokenStorage.getAccessToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          final hadAuthHeader = _hasBearerHeader(error.requestOptions.headers);
          if (error.response?.statusCode == 401 && hadAuthHeader) {
            // Prevent infinite refresh loops
            if (error.requestOptions.extra.containsKey('_retry_after_refresh')) {
              await _invalidateSession();
              return handler.reject(
                DioException(
                  requestOptions: error.requestOptions,
                  error: 'Session expired. Please sign in again.',
                  type: DioExceptionType.cancel,
                ),
              );
            }

            final refreshed = await _attemptRefresh();
            if (refreshed) {
              try {
                final newToken = await _tokenStorage.getAccessToken();
                final response = await _dio.request(
                  error.requestOptions.path,
                  data: error.requestOptions.data,
                  queryParameters: error.requestOptions.queryParameters,
                  options: Options(
                    method: error.requestOptions.method,
                    headers: {
                      ...error.requestOptions.headers,
                      'Authorization': 'Bearer $newToken',
                    },
                    extra: {
                      ...error.requestOptions.extra,
                      '_retry_after_refresh': true,
                    },
                    responseType: error.requestOptions.responseType,
                    contentType: error.requestOptions.contentType,
                  ),
                );
                return handler.resolve(response);
              } catch (_) {
                // Retry failed — fall through to session invalidation
              }
            }

            await _invalidateSession();
            return handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                error: 'Session expired. Please sign in again.',
                type: DioExceptionType.cancel,
              ),
            );
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<bool> _attemptRefresh() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    try {
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {'Content-Type': 'application/json'},
        ),
      );

      final response = await refreshDio.post(
        '${ApiConstants.authBase}/refresh',
        data: {'refreshToken': refreshToken},
      );

      final resource = AuthenticatedUserResource.fromJson(
        response.data as Map<String, dynamic>,
      );

      await _tokenStorage.saveTokens(
        accessToken: resource.token,
        refreshToken: resource.refreshToken,
      );
      await _tokenStorage.saveUser(userId: resource.id, email: resource.email);
      AuthSession().setAuthenticated(true);
      return true;
    } catch (_) {
      // ignore refresh errors
    }
    return false;
  }

  Future<void> _invalidateSession() async {
    await _tokenStorage.clearAll();
    AuthSession().setAuthenticated(false);
  }

  bool _isPublicAuthEndpoint(String path) {
    final authBase = ApiConstants.authBase;
    return path.contains('$authBase/sign-up') ||
        path.contains('$authBase/confirm') ||
        path.contains('$authBase/sign-in') ||
        path.contains('$authBase/google/sign-in') ||
        path.contains('$authBase/refresh');
  }

  bool _hasBearerHeader(Map<String, dynamic> headers) {
    final auth = headers['Authorization'];
    return auth is String && auth.startsWith('Bearer ');
  }

  Dio get client => _dio;
}
