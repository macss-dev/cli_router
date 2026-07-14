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
  group('default not-found behavior (no hook)', () {
    test('unmatched args still print to stderr and exit 64', () async {
      final router = CliRouter();
      router.cmd('version', (req) async => 0, description: 'Print version');

      final result = await _run(router, ['bogus']);

      expect(result.exitCode, equals(64));
      expect(result.stderr, contains('Command not found or invalid usage.'));
      expect(result.stderr, contains('version'));
      expect(result.stdout, isEmpty);
    });
  });

  group('onNotFound hook', () {
    test('replaces the default output and decides the exit code', () async {
      final router = CliRouter(
        onNotFound: (notFound) {
          notFound.stderr.writeln("unknown command '${notFound.args.first}'");
          return 3;
        },
      );
      router.cmd('version', (req) async => 0, description: 'Print version');

      final result = await _run(router, ['bogus']);

      expect(result.exitCode, equals(3));
      expect(result.stderr, contains("unknown command 'bogus'"));
      expect(
        result.stderr,
        isNot(contains('Command not found or invalid usage.')),
        reason: 'the router must not print its own help once a hook is given',
      );
    });

    test('receives the original args, not the unmatched remainder', () async {
      late List<String> seenArgs;
      final router = CliRouter(
        onNotFound: (notFound) {
          seenArgs = notFound.args;
          return 64;
        },
      );
      final math = CliRouter();
      math.cmd('add', (req) async => 0, description: 'Add two numbers');
      router.mount('math', math);

      await _run(router, ['math', 'bogus', '--json']);

      expect(seenArgs, equals(['math', 'bogus', '--json']));
    });

    test('applies to unmatched routes inside a mounted subrouter', () async {
      final router = CliRouter(
        onNotFound: (notFound) {
          notFound.stderr.writeln('HOOK');
          return 64;
        },
      );
      final math = CliRouter();
      math.cmd('add', (req) async => 0, description: 'Add two numbers');
      router.mount('math', math);

      final result = await _run(router, ['math', 'bogus']);

      expect(result.exitCode, equals(64));
      expect(result.stderr, contains('HOOK'));
      expect(
        result.stderr,
        isNot(contains('Command not found or invalid usage.')),
        reason: 'the mounted subrouter must inherit the root hook',
      );
    });

    test('is not consulted when a route matches', () async {
      var hookCalls = 0;
      final router = CliRouter(
        onNotFound: (notFound) {
          hookCalls++;
          return 64;
        },
      );
      router.cmd('version', (req) async {
        req.stdout.writeln('1.0.0');
        return 0;
      }, description: 'Print version');

      final result = await _run(router, ['version']);

      expect(result.exitCode, equals(0));
      expect(result.stdout, contains('1.0.0'));
      expect(hookCalls, isZero);
    });
  });
}
