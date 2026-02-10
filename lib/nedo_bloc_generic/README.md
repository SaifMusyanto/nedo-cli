# Nedo Bloc Generic

[![Powered by Mason](https://img.shields.io/endpoint?url=https%3A%2F%2Ftinyurl.com%2Fmason-badge)](https://github.com/felangel/mason)

A powerful Mason brick to generate **Clean Architecture** compliant Blocs and Cubits with **fpdart** integration and flexible state management patterns.

## Features

- **Bloc & Cubit Support**: Choose between `Bloc` or `Cubit` for your state management.
- **Flexible State Styles**:
  - **Multi**: Traditional `Initial`, `Loading`, `Success`, `Failure` states (great for simple independent actions).
  - **Single**: A single State class with `ScreenStatus` enum and copyWith (great for complex screens with shared data).
- **Advanced Event Handling** (Bloc only):
  - Configure concurrency transformers: `concurrent`, `droppable`, `restartable`, `sequential`.
- **Clean Architecture Wiring**:
  - Automatically injects `UseCases`.
  - Handles `Either<Failure, Type>` results using `fpdart`.
  - Auto-imports entities and params.

## Usage 🚀

### Variables

| Variable | Description | Default |
| :--- | :--- | :--- |
| `feature_name` | The name of the feature (e.g., `Auth`, `Cart`). | Required |
| `type` | The state management type: `bloc` or `cubit`. | `bloc` |
| `state_style` | The state style: `multi` or `single`. | `multi` |
| `methods` | A list of methods/events to generate. | `[]` |

### Interactive Mode

The brick is best used interactively to configure methods and properties dynamicallly:

```bash
mason make nedo_bloc_generic
```

### Configuration (methods)

Each method in the `methods` list has the following properties:

- `name`: Name of the method/event (e.g., `login`).
- `paramType`: Type of the parameter (e.g., `LoginParams`, `String`, `none (void)`).
- `returnType`: Type of the return value (e.g., `UserEntity`, `void`).
- `concurrency` (Bloc only): `concurrent`, `droppable`, `restartable`, `sequential`.
- `statePattern`: `standard` (Loading/Success/Failure), `optimistic`, or `simple`.

## Generated Structure

```text
lib/
└── features/
    └── <feature_name>/
        └── presentation/
            └── bloc/
                ├── <feature>_bloc.dart      // or _cubit.dart
                ├── <feature>_event.dart     // Bloc only
                └── <feature>_state.dart
```

## Dependencies

The generated code relies on several packages. Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_bloc: ^8.1.0
  equatable: ^2.0.0
  injectable: ^2.0.0      # For Dependency Injection
  fpdart: ^1.0.0          # For Functional Error Handling (Either)
  bloc_concurrency: ^0.2.0  # Optional: only if using custom transformers

dev_dependencies:
  build_runner: ^2.4.0
  injectable_generator: ^2.0.0
```

> **Note**: This brick assumes you have `Failure` class defined in `core/error/failures.dart` and `UseCase` in `core/usecase/usecase.dart`. If your project structure differs, you may need to adjust imports.

_Created by [Akbar][1] 🧱_

[1]: https://github.com/mochalifakbar
