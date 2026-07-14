part of 'cli_router.dart';

class _RouteEntry {
  _RouteEntry(this.pattern, this.handler, this.description);
  final _PathPattern pattern;
  final CliHandler handler;
  final String? description;
}

class _Mount {
  _Mount(this.prefix, this.router);
  final List<_Segment> prefix;
  final CliRouter router;
}

class _MatchedRoute {
  _MatchedRoute(this.handler, this.params);
  final CliHandler handler;
  final Map<String, String> params;
}

/// A registered route, as seen from outside the router.
///
/// Carries the structural facts the router already knows about an invocation —
/// its full route, its positional parameters, and the mount it belongs to — so
/// a caller can describe a command without re-parsing the route string.
class ListedCommand {
  ListedCommand(
    this.command,
    this.description, {
    this.positionals = const [],
    this.module,
  });

  /// Full route, mount prefix included: `math add`, `show <id>`.
  final String command;

  final String? description;

  /// Names of the route's `<param>` segments, in declaration order.
  final List<String> positionals;

  /// Mount prefix this command was registered under; `null` at the root.
  final String? module;
}
