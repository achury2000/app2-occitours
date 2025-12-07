import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _FakeHttpClient();
}

class _FakeHttpClient implements HttpClient {
  // Provide common properties used by Flutter's NetworkImage code
  @override
  set autoUncompress(bool v) {}

  @override
  bool get autoUncompress => false;

  @override
  void addCredentials(Uri url, String realm, HttpClientCredentials credentials) {}

  @override
  void addProxyCredentials(String host, int port, String realm, HttpClientCredentials credentials) {}

  @override
  Future<bool> Function(Uri url, String scheme, String realm)? authenticate;

  @override
  Future<bool> Function(String host, int port, String scheme, String realm)? authenticateProxy;

  @override
  void close({bool force = false}) {}

  String? _userAgent;
  @override
  set userAgent(String? v) { _userAgent = v; }

  @override
  String? get userAgent => _userAgent;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _FakeHttpClientRequest();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpClientRequest implements HttpClientRequest {
  final _controller = StreamController<List<int>>();
  final _headers = _FakeHttpHeaders();

  @override
  HttpHeaders get headers => _headers;

  @override
  Future<HttpClientResponse> close() async {
    // return a minimal 1x1 transparent PNG response so image codecs succeed
    _controller.close();
    final pngBase64 = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGNgYAAAAAMAASsJTYQAAAAASUVORK5CYII=';
    final bytes = base64Decode(pngBase64);
    return _FakeHttpClientResponse(Stream<List<int>>.value(bytes));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpHeaders implements HttpHeaders {
  final Map<String, List<String>> _map = {};

  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {
    final key = name;
    _map.putIfAbsent(key, () => []).add(value.toString());
  }

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {
    _map[name] = [value.toString()];
  }

  @override
  String? value(String name) {
    final v = _map[name];
    return (v == null || v.isEmpty) ? null : v.first;
  }

  @override
  List<String>? operator [](String name) => _map[name];

  @override
  void remove(String name, Object value) {
    _map[name]?.remove(value.toString());
    if (_map[name]?.isEmpty ?? false) _map.remove(name);
  }

  @override
  void forEach(void Function(String name, List<String> values) action) {
    _map.forEach(action);
  }

  @override
  void clear() => _map.clear();

  // The remaining HttpHeaders members are not needed for tests; provide
  // basic stub implementations.
  @override
  DateTime? date;

  @override
  DateTime? expires;

  @override
  String? host;

  @override
  int? port;

  @override
  ContentType? contentType;

  @override
  int get contentLength => -1;

  @override
  set contentLength(int _){ }

  @override
  bool chunkedTransferEncoding = false;

  @override
  bool persistentConnection = false;

  @override
  void noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpClientResponse extends Stream<List<int>> implements HttpClientResponse {
  final Stream<List<int>> _stream;
  _FakeHttpClientResponse(this._stream);

  @override
  int get statusCode => 200;

  @override
  HttpClientResponseCompressionState get compressionState => HttpClientResponseCompressionState.notCompressed;

  @override
  int get contentLength => 0;

  @override
  HttpConnectionInfo? get connectionInfo => null;

  @override
  X509Certificate? get certificate => null;

  @override
  HttpHeaders get headers => throw UnimplementedError('Fake response has no headers in tests');

  @override
  bool get isRedirect => false;

  @override
  bool get persistentConnection => false;

  @override
  String get reasonPhrase => 'OK';

  @override
  List<RedirectInfo> get redirects => [];

  @override
  StreamSubscription<List<int>> listen(void Function(List<int>)? onData, {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return _stream.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError ?? false);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void initTestHttpOverrides() {
  HttpOverrides.global = _FakeHttpOverrides();
}

/// Initialize common test environment: binding, SharedPreferences mock and http overrides
Future<void> initTestEnvironment() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  initTestHttpOverrides();
  // allow a short delay to ensure async init settles
  await Future.delayed(Duration(milliseconds: 10));
}
