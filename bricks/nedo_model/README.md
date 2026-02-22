# Nedo Model

[![Powered by Mason](https://img.shields.io/endpoint?url=https%3A%2F%2Ftinyurl.com%2Fmason-badge)](https://github.com/felangel/mason)

A comprehensive Mason brick to generate **Clean Architecture** compliant Dart components (Models, Entities, and Mappers) directly from Swagger/OpenAPI JSON schemas.

## Features

- **Clean Architecture Support**: Generates code for Data, Domain, and Mapper layers.
  - **Data Layer**: DTOs/Models with `fromJson`/`toJson` and `fromMap`/`toMap`.
  - **Domain Layer**: Pure Entities (extends Equatable) and Params.
  - **Mapper Layer**: Bidirectional extension methods (`toEntity`, `toModel`).
- **Smart Naming Conventions**:
  - `Request` objects renamed to `Params` in Domain.
  - `BaseRequest` suffix automatically stripped.
  - `Data`/`DTO` suffixes mapped to `Entity` in Domain.
- **Dependency Resolution**: Automatically resolves and generates nested object dependencies recursively.
- **Component Targeting**: Target specific components to generate only necessary models and their dependencies.
- **Type Mapping**: Handles basic types, lists, and custom object references.
- **Nullable Handling**: Respects `required` fields and `nullable` properties from the schema.

## Usage 🚀

### Variables

| Variable | Description | Default |
| :--- | :--- | :--- |
| `feature_name` | The name of the feature (e.g., `auth`, `products`). Used for directory structure (`lib/features/<feature_name>/...`). | Required |
| `schema_url` | URL to the Swagger/OpenAPI JSON file (e.g., `https://api.example.com/swagger/v1/swagger.json`). | Required |
| `target_component` | (Optional) Comma-separated list of component names to generate. If provided, only these components and their dependencies will be generated. | `""` |

### basic Usage

Generate all models from a schema for a specific feature:

```bash
mason make nedo_model --feature_name "auth" --schema_url "https://api.example.com/swagger.json"
```

### Targeting Specific Components

You can target specific components. The brick will automatically find and generate any other components referenced by your target.

```bash
mason make nedo_model --feature_name "auth" --schema_url "https://api.example.com/swagger.json" --target_component "AuthResponse,LoginRequest"
```

## Generated Structure

The brick generates files in the following structure within your project:

```text
lib/
└── features/
    └── <feature_name>/
        ├── data/
        │   ├── models/
        │   │   └── user_model.dart
        │   └── mappers/
        │       └── user_model_mapper.dart
        └── domain/
            └── entities/
                └── user_entity.dart
```

## Naming Conventions

The brick applies strict naming rules to ensure generated code fits Clean Architecture standards:

| Schema Name | Data Layer (Model) | Domain Layer (Entity) |
| :--- | :--- | :--- |
| `UserDTO` | `UserModel` | `UserEntity` |
| `ProductData` | `ProductModel` | `ProductEntity` |
| `LoginRequest` | `LoginRequestModel` | `LoginParams` |
| `CommonBaseRequest` | `Common` (BaseRequest stripped) | `Common` |

## Dependencies

The generated code requires the following dependencies in your `pubspec.yaml`:

```yaml
dependencies:
  equatable: ^2.0.0
```

> **Note**: This brick uses `equatable` for value equality in Domain Entities. It generates pure Dart code for models (no `json_serializable` or `build_runner` required), making it lightweight and fast.

_Created by [Akbar][1] 🧱_

[1]: https://github.com/mochalifakbar
