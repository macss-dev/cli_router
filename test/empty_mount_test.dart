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
  group('empty mount behavior', () {
    test('empty mount with cmd("") matches empty args', () async {
      final global = CliRouter();
      global.cmd('', (req) async {
        req.stdout.writeln('TUI');
        return 0;
      });

      final root = CliRouter();
      root.mount('', global);

      final result = await _run(root, []);
      expect(result.exitCode, equals(0));
      expect(result.stdout, contains('TUI'));
    });

    test('empty mount does NOT intercept named mounts', () async {
      final global = CliRouter();
      global.cmd('', (req) async {
        req.stdout.writeln('TUI');
        return 0;
      });

      final target = CliRouter();
      target.cmd('get', (req) async {
        req.stdout.writeln('TARGET_GET');
        return 0;
      });

      final root = CliRouter();
      root.mount('', global);
      root.mount('target', target);

      final result = await _run(root, ['target', 'get']);
      expect(result.exitCode, equals(0));
      expect(result.stdout, contains('TARGET_GET'));
      expect(result.stdout, isNot(contains('TUI')));
    });

    test('empty mount does NOT match unrecognized positionals', () async {
      final global = CliRouter();
      global.cmd('', (req) async {
        req.stdout.writeln('TUI');
        return 0;
      });

      final root = CliRouter();
      root.mount('', global);

      final result = await _run(root, ['unknown', 'command']);
      expect(result.exitCode, equals(64));
      expect(result.stdout, isNot(contains('TUI')));
    });

    test('empty mount does NOT match flags-only args', () async {
      final global = CliRouter();
      global.cmd('', (req) async {
        req.stdout.writeln('TUI');
        return 0;
      });

      final root = CliRouter();
      root.mount('', global);

      final result = await _run(root, ['--help']);
      expect(result.exitCode, equals(64));
      expect(result.stdout, isNot(contains('TUI')));
    });

    test('named mounts take precedence over empty mount', () async {
      final global = CliRouter();
      global.cmd('target', (req) async {
        req.stdout.writeln('GLOBAL_TARGET');
        return 0;
      });

      final target = CliRouter();
      target.cmd('get', (req) async {
        req.stdout.writeln('TARGET_GET');
        return 0;
      });

      final root = CliRouter();
      root.mount('', global);
      root.mount('target', target);

      final result = await _run(root, ['target', 'get']);
      expect(result.exitCode, equals(0));
      expect(result.stdout, contains('TARGET_GET'));
      expect(result.stdout, isNot(contains('GLOBAL_TARGET')));
    });

    test('named commands in empty mount are reachable', () async {
      final global = CliRouter();
      global.cmd('version', (req) async {
        req.stdout.writeln('VERSION');
        return 0;
      });

      final root = CliRouter();
      root.mount('', global);

      final result = await _run(root, ['version']);
      expect(result.exitCode, equals(0));
      expect(result.stdout, contains('VERSION'));
    });

    test('named commands in empty mount do NOT shadow named mounts', () async {
      final global = CliRouter();
      global.cmd('target', (req) async {
        req.stdout.writeln('GLOBAL_TARGET');
        return 0;
      });

      final target = CliRouter();
      target.cmd('get', (req) async {
        req.stdout.writeln('TARGET_GET');
        return 0;
      });

      final root = CliRouter();
      root.mount('', global);
      root.mount('target', target);

      final result = await _run(root, ['target', 'get']);
      expect(result.exitCode, equals(0));
      expect(result.stdout, contains('TARGET_GET'));
      expect(result.stdout, isNot(contains('GLOBAL_TARGET')));
    });
  });
}
