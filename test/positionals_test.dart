import 'dart:convert';
import 'dart:io';

import 'package:cli_router/cli_router.dart';
import 'package:test/test.dart';

Future<List<String>> _positionalsOf(List<String> args) async {
  late List<String> seen;
  final router = CliRouter();
  router.cmd('help', (req) async {
    seen = req.positionals;
    return 0;
  });
  await router.run(args, stdout: _TestSink(), stderr: _TestSink());
  return seen;
}

void main() {
  group('positionals after the matched route', () {
    test('are captured when the invocation carries no flags', () async {
      expect(await _positionalsOf(['help', 'math']), equals(['math']));
    });

    test('are captured when the invocation also carries flags', () async {
      expect(
        await _positionalsOf(['help', 'math', '--json']),
        equals(['math']),
      );
    });

    test('are empty when the route stands alone', () async {
      expect(await _positionalsOf(['help']), isEmpty);
    });
  });
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
