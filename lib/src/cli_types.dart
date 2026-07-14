part of 'cli_router.dart';

/// Handler type. Returns an exit code (0 OK, 64 invalid usage, etc.)
typedef CliHandler = FutureOr<int> Function(CliRequest req);

/// Shelf-like middleware: receives the next handler and returns a wrapped one.
typedef CliMiddleware = CliHandler Function(CliHandler next);

/// An invocation that matched no route, anywhere in the router tree.
class CliNotFound {
  CliNotFound({required this.args, required this.stdout, required this.stderr});

  /// Args as passed to [CliRouter.run], not the unmatched remainder.
  final List<String> args;

  final io.IOSink stdout;
  final io.IOSink stderr;
}

/// Decides how an unmatched invocation is reported, and with which exit code.
///
/// The router knows *what* failed to match; how that is presented to a human
/// belongs to the application on top of it.
typedef CliNotFoundHandler = FutureOr<int> Function(CliNotFound notFound);
