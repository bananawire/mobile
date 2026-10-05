import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Records every request issued through [Dio] and replays canned responses.
class FakeHttpClientAdapter implements HttpClientAdapter {
  FakeHttpClientAdapter({
    required this.statusCode,
    this.body,
    this.headers = const <String, List<String>>{'content-type': ['application/json']},
    this.error,
  });

  /// Status code of the replayed response.
  final int statusCode;

  /// Raw response body; when null an empty body is replayed (useful for 204).
  final String? body;

  /// Response headers of the replayed response.
  final Map<String, List<String>> headers;

  /// When set, [fetch] completes with this error instead of a response.
  final Object? error;

  /// All requests captured by this adapter, in order.
  final List<RequestOptions> requests = <RequestOptions>[];

  /// Bodies captured as raw JSON strings, in the same order as [requests].
  final List<String?> rawBodies = <String?>[];

  RequestOptions get lastRequest => requests.last;

  /// The single request captured; fails loudly when more than one was made.
  RequestOptions get singleRequest {
    if (requests.length != 1) {
      throw StateError('Expected exactly one request but got ${requests.length}');
    }
    return requests.last;
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    rawBodies.add(await _readBody(requestStream));

    final failure = error;
    if (failure != null) {
      if (failure is DioException) {
        throw failure.copyWith(requestOptions: options);
      }
      throw failure;
    }

    return ResponseBody.fromString(
      body ?? '',
      statusCode,
      headers: headers,
    );
  }

  @override
  void close({bool force = false}) {}

  Future<String?> _readBody(Stream<Uint8List>? requestStream) async {
    if (requestStream == null) {
      return null;
    }
    final buffer = StringBuffer();
    await for (final chunk in requestStream) {
      buffer.write(utf8.decode(chunk));
    }
    return buffer.toString();
  }
}