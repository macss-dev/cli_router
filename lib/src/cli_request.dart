part of 'cli_router.dart';

/// Represents a concrete invocation of a command.
class CliRequest {
  CliRequest({
    required this.originalArgs,
    required this.matchedCommand,
    required this.params,
    required this.flags,
    required this.positionals,
    io.IOSink? stdout,
    io.IOSink? stderr,
  })  : stdout = stdout ?? io.stdout,
        stderr = stderr ?? io.stderr;

  /// Original args that were passed to main()
  final List<String> originalArgs;

  /// Command segments that matched (eg: ['module','use-case'])
  final List<String> matchedCommand;

  /// Parameters for dynamic segments (eg: {'id': '42'})
  final Map<String, String> params;

  /// Parsed flags: --k v, --k=v, -k v, -abc => {a:true,b:true,c:true}
  final Map<String, String?> flags;

  /// Positionals that are not part of the route or flags (or that come after `--`)
  final List<String> positionals;

  /// Output sinks
  final io.IOSink stdout;
  final io.IOSink stderr;

  // ---- Flag helpers ----

  String? flagString(String name, {List<String> aliases = const []}) {
    for (final k in [name, ...aliases]) {
      if (flags.containsKey(k)) return flags[k];
    }
    return null;
  }

  bool flagBool(
    String name, {
    List<String> aliases = const [],
    bool defaultValue = false,
  }) {
    final v = flagString(name, aliases: aliases);
    if (v == null) return defaultValue;
    final s = v.toLowerCase();
    if (s.isEmpty) return true;
    if (s == 'true' || s == '1' || s == 'yes' || s == 'on') return true;
    if (s == 'false' || s == '0' || s == 'no' || s == 'off') return false;
    return defaultValue;
  }

  int? flagInt(String name, {List<String> aliases = const []}) {
    final v = flagString(name, aliases: aliases);
    return v == null ? null : int.tryParse(v);
  }

  double? flagDouble(String name, {List<String> aliases = const []}) {
    final v = flagString(name, aliases: aliases);
    return v == null ? null : double.tryParse(v);
  }

  String? param(String name) => params[name];

  bool get isHelpRequested =>
      flagBool('help', aliases: const ['h']) ||
      (positionals.isNotEmpty && positionals.first == 'help');
}
