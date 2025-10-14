import 'package:cli_router/cli_router.dart';

CliRouter buildSystemModule() {
  final r = CliRouter();

  r.cmd(
    'version',
    handler((req) {
      req.stdout.writeln('system.version = 1.0.0');
    }),
    description: 'Muestra la versión',
  );

  r.cmd(
    'ping',
    handler((req) async {
      req.stdout.writeln('pong');
    }),
    description: 'Ping/pong',
  );

  return r;
}
