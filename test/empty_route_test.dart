import 'dart:convert';
import 'dart:io';

import 'package:cli_router/cli_router.dart';
import 'package:test/test.dart';

/// Captures stdout/stderr from a router run.
Future<({int exitCode, String stdout, String stderr})> _run(
  CliRouter router,
  List<String> args,
) async {
  final out = _TestSink();
  final err = _TestSink();
  final code = await router.run(args, stdout: out, stderr: err);
  return (exitCode: code, stdout: out.toString(), stderr: err.toString());
}

class _TestSink implements IOSink {
  final _buffer = StringBuffer();

  @override
  void write(Object? object) => _buffer.write(object);
  @override
  void writeln([Object? object = '']) => _buffer.writeln(object);
  @override
  void writeAll(Iterable objects, [String separator = '']) =>
      _buffer.writeAll(objects, separator);
  @override
  void writeCharCode(int charCode) => _buffer.writeCharCode(charCode);
  @override
  void add(List<int> data) {}
  @override
  void addError(Object error, [StackTrace? stackTrace]) {}
  @override
  Future addStream(Stream<List<int>> stream) => Future.value();
  @override
  Future flush() => Future.value();
  @override
  Future close() => Future.value();
  @override
  Future get done => Future.value();
  @override
  Encoding get encoding => utf8;
  @override
  set encoding(Encoding value) {}

  @override
  String toString() => _buffer.toString();
}

void main() {
  group('empty route behavior', () {
    test('empty route matches when args is empty', () async {
      final router = CliRouter();
      router.cmd('', (req) async {
        req.stdout.writeln('BANNER');
        return 0;
      });

      final result = await _run(router, []);
      expect(result.exitCode, equals(0));
      expect(result.stdout, contains('BANNER'));
    });

    test('empty route does NOT match when args has flags', () async {
      final router = CliRouter();
      router.cmd('', (req) async {
        req.stdout.writeln('BANNER');
        return 0;
      });

      final result = await _run(router, ['--help']);
      expect(result.exitCode, equals(64),
          reason: 'flag-only args should not match empty route');
      expect(result.stdout, isNot(contains('BANNER')));
    });

    test('empty route does NOT match when args has positionals', () async {
      final router = CliRouter();
      router.cmd('', (req) async {
        req.stdout.writeln('BANNER');
        return 0;
      });

      final result = await _run(router, ['target', 'get']);
      expect(result.exitCode, equals(64),
          reason: 'positional args should not match empty route');
      expect(result.stdout, isNot(contains('BANNER')));
    });

    test('mount is reachable when empty route is also registered', () async {
      final router = CliRouter();
      router.cmd('', (req) async {
        req.stdout.writeln('BANNER');
        return 0;
      });

      final sub = CliRouter();
      sub.cmd('get', (req) async {
        req.stdout.writeln('TARGET_GET');
        return 0;
      });
      router.mount('target', sub);

      final result = await _run(router, ['target', 'get']);
      expect(result.exitCode, equals(0));
      expect(result.stdout, contains('TARGET_GET'));
      expect(result.stdout, isNot(contains('BANNER')));
    });
  });
}
