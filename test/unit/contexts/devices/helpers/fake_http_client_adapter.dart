import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Records the requests issued by a real [Dio] and replays scripted responses,
/// so gateway tests exercise real Dio plumbing without opening a socket.
class FakeHttpClientAdapter implements HttpClientAdapter {
  /// Every request observed by the adapter, in order.
  final List<RequestOptions> requests = [];

  final List<Object?> _responses = [];
  final List<Object> _errors = [];

  /// Queues a JSON body answered with [statusCode].
  void enqueueJson(Object? body, {int statusCode = 200}) {
    _responses.add(_ScriptedResponse(body: body, statusCode: statusCode));
  }

  /// Queues an empty body answered with [statusCode] (for example 204).
  void enqueueEmpty({int statusCode = 204}) {
    _responses.add(_ScriptedResponse(body: null, statusCode: statusCode));
  }

  /// Queues a [DioException] to be thrown by the next call.
  void enqueueError(Object error) {
    _errors.add(error);
  }

  /// The single recorded request; fails loudly when the count is not one.
  RequestOptions get singleRequest {
    if (requests.length != 1) {
      throw StateError('Expected exactly one request but got ${requests.length}');
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

    if (_responses.isEmpty) {
      throw StateError('No scripted response left for ${options.method} ${options.path}');
    }

    final scripted = _responses.removeAt(0) as _ScriptedResponse;
    final headers = <String, List<String>>{
      Headers.contentTypeHeader: [Headers.jsonContentType],
    };

    if (scripted.body == null) {
      return ResponseBody.fromString(
        '',
        scripted.statusCode,
        headers: headers,
      );
    }

    return ResponseBody.fromString(
      jsonEncode(scripted.body),
      scripted.statusCode,
      headers: headers,
    );
  }
}

class _ScriptedResponse {
  final Object? body;
  final int statusCode;

  const _ScriptedResponse({required this.body, required this.statusCode});
}