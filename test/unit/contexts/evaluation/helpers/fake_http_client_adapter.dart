import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Records the requests issued by a real [Dio] and replays scripted responses,
/// so the evaluation gateway can be tested through real dio plumbing without
/// ever opening a socket.
///
/// This is a self-contained copy of the pattern used by the other contexts:
/// nothing here imports across context folders.
class FakeHttpClientAdapter implements HttpClientAdapter {
  /// Every request observed by the adapter, in order.
  final List<RequestOptions> requests = <RequestOptions>[];

  final List<Object?> _scripted = <Object?>[];
  final List<Object> _errors = <Object>[];

  /// Queues a JSON body answered with [statusCode].
  void enqueueJson(Object? body, {int statusCode = 200}) {
    _scripted.add(_ScriptedResponse(body: body, statusCode: statusCode));
  }

  /// Queues a verbatim [body] answered with [statusCode].
  ///
  /// Used for malformed payloads that [enqueueJson] could never produce.
  void enqueueRawBody(
    String body, {
    int statusCode = 200,
    String contentType = Headers.jsonContentType,
  }) {
    _scripted.add(
      _ScriptedResponse(
        rawBody: body,
        statusCode: statusCode,
        contentType: contentType,
      ),
    );
  }

  /// Queues an empty body answered with [statusCode] (for example 204).
  void enqueueEmpty({int statusCode = 204}) {
    _scripted.add(_ScriptedResponse(body: null, statusCode: statusCode));
  }

  /// Queues an [error] thrown by the next transport call.
  void enqueueError(Object error) {
    _errors.add(error);
  }

  /// The single recorded request; fails loudly when the count is not one.
  RequestOptions get singleRequest {
    if (requests.length != 1) {
      throw StateError(
        'Expected exactly one request but got ${requests.length}',
      );
    }
    return requests.single;
  }

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);

    if (_errors.isNotEmpty) {
      throw _errors.removeAt(0);
    }

    if (_scripted.isEmpty) {
      throw StateError(
        'No scripted response left for ${options.method} ${options.path}',
      );
    }

    final scripted = _scripted.removeAt(0) as Object;

    final response = scripted as _ScriptedResponse;

    if (response.body == null && response.rawBody == null) {
      return ResponseBody.fromString(
        '',
        response.statusCode,
        headers: _jsonHeaders,
      );
    }

    return ResponseBody.fromString(
      response.rawBody ?? jsonEncode(response.body),
      response.statusCode,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[response.contentType],
      },
    );
  }

  static const Map<String, List<String>> _jsonHeaders = <String, List<String>>{
    Headers.contentTypeHeader: <String>[Headers.jsonContentType],
  };
}

class _ScriptedResponse {
  final Object? body;
  final int statusCode;
  final String? rawBody;
  final String contentType;

  const _ScriptedResponse({
    this.body,
    this.statusCode = 200,
    this.rawBody,
    this.contentType = Headers.jsonContentType,
  });
}
