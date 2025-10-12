import 'dart:io';
import 'package:cli_router/cli_router.dart';

import 'middlewares/logging.dart';
import 'modules/order/order.dart';
import 'modules/system/system.dart';
import 'modules/user/user.dart';

/// Entrypoint:
///   dart run example/example.dart command [args...]
/// Examples:
///   dart run example/example.dart user list
///   dart run example/example.dart user show 42
///   dart run example/example.dart order process 900 --dry-run --threads 4
///   dart run example/example.dart system version
Future<void> main(List<String> args) async {
  final root = CliRouter();

  // Logging middleware
  root.use(loggingMiddleware);

  // ---- MModules (each contributes its own subrouter) ----
  root.mount('user', buildUsersModule());
  root.mount('order', buildOrdersModule());
  root.mount('system', buildSystemModule());

  // Comando de ayuda del root
  root.cmd(
    'help',
    handler((req) {
      req.stdout.writeln('Example CLI with modular architecture\n');
      root.printHelp(req.stdout, title: 'Help (root):');
      req.stdout.writeln('\nExamples:');
      req.stdout.writeln('  dart run example/example.dart users list');
      req.stdout.writeln('  dart run example/example.dart orders process <id> --dry-run');
    }),
    description: 'Shows general help',
  );

  final code =  await root.run(args);
  exit(code);
}
