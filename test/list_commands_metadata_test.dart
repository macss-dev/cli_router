import 'package:cli_router/cli_router.dart';
import 'package:test/test.dart';

ListedCommand _commandNamed(List<ListedCommand> commands, String command) =>
    commands.firstWhere((c) => c.command == command);

void main() {
  group('listCommands metadata', () {
    test('exposes the positional names of a route, in order', () {
      final router = CliRouter();
      router.cmd('show <id>', (req) async => 0, description: 'Show a record');
      router.cmd('copy <from> <to>', (req) async => 0, description: 'Copy it');
      router.cmd('version', (req) async => 0, description: 'Print version');

      final commands = router.listCommands();

      expect(_commandNamed(commands, 'show <id>').positionals, equals(['id']));
      expect(
        _commandNamed(commands, 'copy <from> <to>').positionals,
        equals(['from', 'to']),
      );
      expect(_commandNamed(commands, 'version').positionals, isEmpty);
    });

    test('reports the mount a command came from', () {
      final router = CliRouter();
      router.cmd('version', (req) async => 0, description: 'Print version');

      final math = CliRouter();
      math.cmd('add', (req) async => 0, description: 'Add two numbers');
      router.mount('math', math);

      final commands = router.listCommands();

      expect(_commandNamed(commands, 'version').module, isNull);
      expect(_commandNamed(commands, 'math add').module, equals('math'));
    });

    test('keeps the route and description already published', () {
      final router = CliRouter();
      router.cmd('version', (req) async => 0, description: 'Print version');

      final listed = _commandNamed(router.listCommands(), 'version');

      expect(listed.command, equals('version'));
      expect(listed.description, equals('Print version'));
    });
  });
}
