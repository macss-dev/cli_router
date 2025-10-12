import 'package:cli_router/cli_router.dart';

CliRouter buildUsersModule() {
  final r = CliRouter();

  r.cmd(
    'list',
    handler((req) {
      final limit = req.flagInt('limit') ?? 10;
      final activeOnly = req.flagBool('active', defaultValue: false);
      req.stdout.writeln('Users.list(limit=$limit, activeOnly=$activeOnly)');
      req.stdout.writeln('- u#1  Alice');
      req.stdout.writeln('- u#2  Bob');
    }),
    description: 'Lista usuarios (opciones: --limit N, --active)',
  );

  r.cmd(
    'show <id>',
    handler((req) {
      final id = req.param('id');
      req.stdout.writeln('Users.show(id=$id)');
    }),
    description: 'Muestra un usuario por id',
  );

  r.cmd(
    'create <name>',
    handler((req) {
      final name = req.param('name');
      final admin = req.flagBool('admin'); // --admin o -a
      req.stdout.writeln('Users.create(name=$name, admin=$admin)');
    }),
    description: 'Crea un usuario (opciones: --admin | -a)',
  );

  // alias -a para --admin (ejemplo de cómo mapear ambos)
  r.use((next) {
    return (req) {
      if (req.flags.containsKey('a') && !req.flags.containsKey('admin')) {
        req.flags['admin'] = req.flags['a'];
      }
      return next(req);
    };
  });

  return r;
}