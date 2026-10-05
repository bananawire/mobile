import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/iam/infrastructure/persistence/local/token_local_storage.dart';
import 'package:mocktail/mocktail.dart';

/// `TokenLocalStorage` is backed by a platform plugin channel, so it is
/// mocked instead of instantiated. The real class is never constructed in a
/// test, which keeps `flutter_secure_storage` off the test path entirely.
class MockTokenLocalStorage extends Mock implements TokenLocalStorage {}

/// A [DotEnv] replacement that answers from a plain in-memory map.
///
/// `ApiConstants.baseUrl` is a dotenv-backed getter, so merely constructing
/// `DioClient` reads configuration that does not exist in a test process.
/// Rather than parsing an environment file (or calling `dotenv.load()`, which
/// would read the real bundled `.env` and its real backend URL and client id),
/// the global `dotenv` reference is swapped for this stub so the lookup is
/// satisfied by a hard-coded literal.
///
/// Nothing here touches the filesystem, the asset bundle, the real `.env`, or
/// any network. Use [installFakeDotEnv] and always pair it with the returned
/// restore callback in teardown.
class FakeDotEnv extends DotEnv {
  FakeDotEnv(this._values);

  final Map<String, String> _values;

  @override
  Map<String, String> get env => Map<String, String>.unmodifiable(_values);
}

/// Keys `ApiConstants` reads. Only the values below are ever visible to a
/// test, and both point at the reserved, non-routable `.test` TLD.
const String fakeBackendBaseUrl = 'https://unit-test.invalid';

/// Swaps the global `dotenv` for a [FakeDotEnv] holding only the configuration
/// `ApiConstants` requires, and returns a callback that restores the original.
///
/// The restore callback must be invoked in teardown so the substitution cannot
/// leak into another test file running in the same isolate.
void Function() installFakeDotEnv({
  String baseUrl = fakeBackendBaseUrl,
  String googleServerClientId = 'unit-test-client',
}) {
  final DotEnv original = dotenv;
  dotenv = FakeDotEnv(<String, String>{
    'CLAIR_BACKEND_BASE_URL': baseUrl,
    'GOOGLE_OAUTH_WEB_CLIENT_ID': googleServerClientId,
  });
  return () => dotenv = original;
}

/// Builds a JSON [ResponseBody] for [RecordingHttpClientAdapter].
ResponseBody jsonResponseBody(
  Object? payload, {
  int statusCode = 200,
}) {
  return ResponseBody.fromString(
    jsonEncode(payload),
    statusCode,
    headers: const <String, List<String>>{
      Headers.contentTypeHeader: <String>['application/json'],
    },
  );
}

/// Decides what the transport should answer for the [index]-th request.
///
/// The index makes out-of-order scenarios (401 first, retried request second)
/// expressible without any real timing.
typedef DioResponder = ResponseBody Function(
  RequestOptions options,
  int index,
);

/// A [HttpClientAdapter] that records every [RequestOptions] the interceptor
/// chain handed to the transport and answers with canned [ResponseBody]s.
///
/// Installing this on a client under test exposes exactly what was sent:
/// method, path, headers and decoded body, after the interceptors ran.
class RecordingHttpClientAdapter implements HttpClientAdapter {
  RecordingHttpClientAdapter(this._responder);

  /// Requests in the order the transport was asked to perform them.
  final List<RequestOptions> requests = <RequestOptions>[];

  final DioResponder _responder;

  /// The request the transport received last.
  RequestOptions get lastRequest => requests.last;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return _responder(options, requests.length - 1);
  }

  @override
  void close({bool force = false }) {}
}

/// A canned HTTP response replayed by [FakeHttpClient] for every exchange.
class CannedHttpResponse {
  const CannedHttpResponse({
    required this.statusCode,
    this.body = '',
    this.contentType = 'application/json',
    this.reasonPhrase = 'OK',
  });

  final int statusCode;
  final String body;
  final String contentType;
  final String reasonPhrase;
}

/// One HTTP request/response cycle observed at the `dart:io` layer.
class RecordedHttpExchange {
  RecordedHttpExchange({
    required this.method,
    required this.uri,
    required this.headers,
  });

  final String method;
  final Uri uri;
  final RecordingHttpHeaders headers;
  final List<int> bodyBytes = <int>[];

  String get bodyAsString => utf8.decode(bodyBytes, allowMalformed: true);
}

/// A minimal `dart:io` header bag.
///
/// `HttpHeaders` is an `abstract interface class`, so it cannot be
/// instantiated. Only the surface dio's IO adapter touches is implemented.
class RecordingHttpHeaders implements HttpHeaders {
  final Map<String, List<String>> values = <String, List<String>>{};

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {
    values[name.toLowerCase()] = <String>[value.toString()];
  }

  @override
  void forEach(void Function(String name, List<String> values) action) {
    values.forEach(action);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnsupportedError(
        'RecordingHttpHeaders was asked for ${invocation.memberName}, which '
        'no offline test scenario needs.',
      );
}

/// An offline `dart:io` [HttpClient] that never opens a socket.
///
/// `DioClient._attemptRefresh` builds its own [Dio] internally, so its adapter
/// cannot be replaced. Routing every [HttpClient] in the test zone to this
/// fake keeps that refresh POST hermetic and offline.
class FakeHttpClient implements HttpClient {
  FakeHttpClient(this.response);

  /// Every exchange performed through this client, in order.
  final List<RecordedHttpExchange> exchanges = <RecordedHttpExchange>[];

  /// The single canned response answered for every request.
  final CannedHttpResponse response;

  Duration? _connectionTimeout;

  @override
  Duration? get connectionTimeout => _connectionTimeout;

  @override
  set connectionTimeout(Duration? value) => _connectionTimeout = value;

  @override
  Duration idleTimeout = const Duration(seconds: 3);

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    final exchange = RecordedHttpExchange(
      method: method,
      uri: url,
      headers: RecordingHttpHeaders(),
    );
    exchanges.add(exchange);
    return _FakeHttpClientRequest(exchange: exchange, response: response);
  }

  @override
  void close({bool force = false }) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnsupportedError(
        'FakeHttpClient was asked for ${invocation.memberName}, which no '
        'offline test scenario needs.',
      );
}

class _FakeHttpClientRequest implements HttpClientRequest {
  _FakeHttpClientRequest({required this.exchange, required this.response});

  final RecordedHttpExchange exchange;
  final CannedHttpResponse response;

  @override
  final RecordingHttpHeaders headers = RecordingHttpHeaders();

  @override
  bool followRedirects = true;

  @override
  int maxRedirects = 5;

  @override
  bool persistentConnection = true;

  @override
  void abort([Object? exception, StackTrace? stackTrace]) {}

  @override
  Future<HttpClientResponse> close() async =>
      _FakeHttpClientResponse(response: response);

  @override
  Future<void> addStream(Stream<List<int>> stream) async {
    await for (final chunk in stream) {
      exchange.bodyBytes.addAll(chunk);
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnsupportedError(
        '_FakeHttpClientRequest was asked for ${invocation.memberName}, '
        'which no offline test scenario needs.',
      );
}

/// A [HttpClientResponse] backed by [Stream] so dio can `cast()` the payload.
class _FakeHttpClientResponse extends Stream<List<int>>
    implements HttpClientResponse {
  _FakeHttpClientResponse({required this.response})
      : headers = _buildHeaders(response);

  final CannedHttpResponse response;

  @override
  final RecordingHttpHeaders headers;

  static RecordingHttpHeaders _buildHeaders(CannedHttpResponse canned) {
    final headers = RecordingHttpHeaders();
    if (canned.contentType.isNotEmpty) {
      headers.set(HttpHeaders.contentTypeHeader, canned.contentType);
    }
    headers.set(
      HttpHeaders.contentLengthHeader,
      '${utf8.encode(canned.body).length}',
    );
    return headers;
  }

  @override
  int get statusCode => response.statusCode;

  @override
  String get reasonPhrase => response.reasonPhrase;

  @override
  bool get isRedirect => false;

  @override
  List<RedirectInfo> get redirects => const <RedirectInfo>[];

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.value(utf8.encode(response.body)).listen(
          onData,
          onError: onError,
          onDone: onDone,
          cancelOnError: cancelOnError,
        );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnsupportedError(
        '_FakeHttpClientResponse was asked for ${invocation.memberName}, '
        'which no offline test scenario needs.',
      );
}

/// Runs [body] with every [HttpClient] bound to [client].
///
/// This intercepts the refresh POST that `DioClient` issues through an
/// internally created [Dio], so no scenario can reach a real socket.
Future<T> withFakeHttpClient<T>(
  FakeHttpClient client,
  Future<T> Function() body,
) {
  return HttpOverrides.runZoned(
    body,
    createHttpClient: (_) => client,
  );
}