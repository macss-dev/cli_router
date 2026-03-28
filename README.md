[![pub package](https://img.shields.io/pub/v/cli_router.svg)](https://pub.dev/packages/cli_router)

# cli_router

Router for CLIs inspired by `shelf_router`, using **spaces** between segments instead of `/`.

> Designed for the MACSS ecosystem: define commands like routes (`cmd('module use-case', handler)`), nest routers with `mount`, and parse GNU-style flags.

---

## ✨ Features

- `cmd('route subroute', handler)` to register commands.
- `mount('prefix', subRouter)` to nest routers (using `cmd('prefix', subRouter)` also works as syntactic sugar).
- Dynamic segments with `<id>` and trailing wildcard `*`.
- Shelf-like middleware with `use()` (logging, metrics, auth, etc.).
- GNU-style flag parsing: `--k v`, `--k=v`, `-k v`, `-abc`, `--no-k`, and `--` to end options.
- Clean API with helpers: `flagInt`, `flagBool`, `flagString`, `param('id')`.
- Simple help with `printHelp()` and command listing.
- Exit codes: `0` (OK), `64` (invalid usage/not found).

---

## 📦 Installation

In your `pubspec.yaml`:

```yaml
dependencies:
  cli_router: ^0.0.2
```

Or, if you prefer the command line, you can use:

```bash
dart pub add cli_router
```

Run:

```bash
dart pub get
```

---

## 🚀 Quick start

```dart
import 'package:cli_router/cli_router.dart';

Future<int> main(List<String> args) async {
  final cli = CliRouter();

  // Simple command
  cli.cmd('module use-case', handler((req) {
    final p1 = req.flagInt('param1');
    final p2 = req.flagBool('param2');
    final p3 = req.flagString('param3');
    req.stdout.writeln('p1=$p1 p2=$p2 p3=$p3');
  }), description: 'Main use-case for the module');

  // Subrouter (nested)
  final sub = CliRouter()
    ..cmd('use-case', handler((req) {
      req.stdout.writeln('OK from subrouter: module use-case');
    }));
  cli.mount('module', sub);

  // Help
  cli.cmd('help', handler((req) {
    cli.printHelp(req.stdout, title: 'Help:');
  }));

  return cli.run(args);
}
```

Example invocation:

```bash
dart run bin/main.dart module use-case --param1 1234 --param2 true --param3 "text"
```

---

## 🧭 Route definition

- **Segments** are separated by **spaces**: `'users show <id>'`.
- **Dynamic parameters**: `<id>` captures a token (e.g. `42`).
- **Wildcard**: `*` at the end of the route matches the rest of tokens.
- **Priority**: the **longest match** is attempted first; if none match, the longest prefix `mount` is tried.

---

## 🚩 Flags and positionals

- `--k v`, `--k=v`, `-k v`, `-abc` (`a/b/c=true`), `--no-k` ⇒ `k=false`.
- `--` marks the end of options; everything after it is raw positionals.
- Helpers on `CliRequest`: `flagBool`, `flagInt`, `flagDouble`, `flagString` and `param`.

```dart
final dry = req.flagBool('dry-run');
final threads = req.flagInt('threads') ?? 1;
final id = req.param('orderId');
```

---

## 🧩 Middlewares

```dart
cli.use((next) {
  return (req) async {
    final t0 = DateTime.now();
    final code = await next(req);
    final dt = DateTime.now().difference(t0);
    req.stderr.writeln('[${DateTime.now().toIso8601String()}] '
        '"${req.matchedCommand.join(' ')}" -> $code in ${dt.inMilliseconds}ms');
    return code;
  };
});
```

---

## 🧱 Modular example (the `example/` folder)

```dart
import 'dart:io';
import 'package:cli_router/cli_router.dart';

Future<void> main(List<String> args) async {
  final code = await runExample(args);
  exit(code);
}

Future<int> runExample(List<String> args) async {
  final root = CliRouter();

  // Modules
  root.cmd('users', buildUsersModule());
  root.cmd('orders', buildOrdersModule());
  root.cmd('system', buildSystemModule());

  // Global help
  root.cmd('help', handler((req) {
    req.stdout.writeln('Example CLI with modular architecture');
    root.printHelp(req.stdout, title: 'Help (root):');
  }));

  return root.run(args);
}

// ---- Users ----
CliRouter buildUsersModule() {
  final r = CliRouter()
    ..cmd('list', handler((req) {
      final limit = req.flagInt('limit') ?? 10;
      final activeOnly = req.flagBool('active');
      req.stdout.writeln('Users.list(limit=$limit, activeOnly=$activeOnly)');
    }), description: 'List users')
    ..cmd('show <id>', handler((req) {
      req.stdout.writeln('Users.show(id=${req.param('id')})');
    }), description: 'Show a user');
  return r;
}

// ---- Orders ----
CliRouter buildOrdersModule() {
  final r = CliRouter()
    ..cmd('process <orderId>', handler((req) {
      final dryRun = req.flagBool('dry-run');
      final threads = req.flagInt('threads') ?? 1;
      req.stdout.writeln('Orders.process(id=${req.param('orderId')}, '
          'dryRun=$dryRun, threads=$threads)');
    }), description: 'Process an order')
    ..cmd('report daily', handler((req) {
      req.stdout.writeln('Orders.report.daily()');
    }), description: 'Daily report')
    ..cmd('report monthly <yyyy-mm>', handler((req) {
      req.stdout.writeln('Orders.report.monthly(${req.param('yyyy-mm')})');
    }), description: 'Monthly report');
  return r;
}

// ---- System ----
CliRouter buildSystemModule() {
  final r = CliRouter()
    ..cmd('version', handler((req) {
      req.stdout.writeln('system.version = 1.0.0');
    }), description: 'Show version')
    ..cmd('ping', handler((req) async {
      req.stdout.writeln('pong');
    }), description: 'Ping/pong');
  return r;
}
```

Examples:

```bash
dart run example/example.dart users list --limit 5 --active
dart run example/example.dart users show 42
dart run example/example.dart orders process 900 --dry-run --threads 4
dart run example/example.dart orders report daily
dart run example/example.dart orders report monthly 2025-09
dart run example/example.dart system version
```

---

## 🆘 Built-in help

```dart
cli.printHelp(stdout, title: 'Help:');
```

Typical output:

```
Help:
Available commands:
  module use-case           - Main use-case for the module
  users list                - List users
  users show <id>           - Show a user
  orders process <orderId>  - Process an order
  ...
```

---

## 🔚 Exit codes

- `0` → Success.
- `64` → Invalid usage / command not found (similar to `EX_USAGE`).

---

## 🛠️ Compile to executable

- **Windows**
  ```bash
  dart compile exe example/example.dart -o build/cli_example.exe
  ```

- **Linux**
  ```bash
  dart compile exe example/example.dart -o build/cli_example
  ```

---

## 📄 License
MIT © [ccisne.dev](https://www.ccisne.dev)