part of 'cli_router.dart';

/// Handler type. Returns an exit code (0 OK, 64 invalid usage, etc.)
typedef CliHandler = FutureOr<int> Function(CliRequest req);

/// Shelf-like middleware: receives the next handler and returns a wrapped one.
typedef CliMiddleware = CliHandler Function(CliHandler next);
