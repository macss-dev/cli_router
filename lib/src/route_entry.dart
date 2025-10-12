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

class ListedCommand {
  ListedCommand(this.command, this.description);
  final String command;
  final String? description;
}
