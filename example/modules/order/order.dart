import 'package:cli_router/cli_router.dart';

CliRouter buildOrdersModule() {
  final r = CliRouter();

  r.cmd(
    'process <orderId>',
    handler((req) {
      final id = req.param('orderId');
      final dryRun = req.flagBool('dry-run');
      final threads = req.flagInt('threads') ?? 1;
      req.stdout.writeln('Orders.process(id=$id, dryRun=$dryRun, threads=$threads)');
    }),
    description: 'Processes an order (options: --dry-run, --threads N)',
  );

  r.cmd(
    'ship <orderId>',
    handler((req) {
      final id = req.param('orderId');
      final carrier = req.flagString('carrier') ?? 'default';
      req.stdout.writeln('Orders.ship(id=$id, carrier=$carrier)');
    }),
    description: 'Ships an order (option: --carrier name)',
  );

  // Submodule nested: orders report ...
  final report = CliRouter()
    ..cmd(
      'daily',
      handler((req) {
        req.stdout.writeln('Orders.report.daily()');
      }),
      description: 'Daily report',
    )
    ..cmd(
      'monthly <yyyy-mm>',
      handler((req) {
        req.stdout.writeln('Orders.report.monthly(month=${req.param('yyyy-mm')})');
      }),
      description: 'Monthly report',
    );

  r.cmd('report', report); // sugar for mount('report', report)

  return r;
}