# nedo_feature

[![Powered by Mason](https://img.shields.io/endpoint?url=https%3A%2F%2Ftinyurl.com%2Fmason-badge)](https://github.com/felangel/mason)

A powerful Mason brick to generate a **Complete Vertical Slice** for a Flutter feature using **Clean Architecture**.

It automatically scaffolds:
- **Domain Layer**: Entities, Repository Interfaces, UseCases.
- **Data Layer**: DTO Models (from Swagger/JSON), Repository Implementations, Remote Data Sources (Providers).
- **Presentation Layer**: BLoC/Cubit with pre-wired UseCases (via `nedo_bloc_generic`).

Inspired by Reso Coder's Clean Architecture & Domain-Driven Design principles.

## 📦 Features

- 🏗 **Full Vertical Slice Generation**: Creates files from UI to Data source.
- 🔌 **Strict Wiring**: Automatically connects BLoC -> UseCases -> Repository -> Data Source.
- 📜 **Swagger/OpenAPI Support**: Generates Models & Entities directly from a schema (via `nedo_model`).
- 🛡 **Functional Error Handling**: integrated with `fpdart` (Either<Failure, Success>).
- 💉 **Dependency Injection**: Ready for `injectable` & `get_it`.

## 🚀 Getting Started

### 1. Installation

```bash
mason add nedo_feature --path ./punk/nedo_feature
```

### 2. Usage

#### Interactive Mode

Run the brick and follow the prompts:

```bash
mason make nedo_feature
```

**Prompts:**
1. **Feature Name**: e.g., `Auth`, `ProductDetails`.
2. **Swagger Schema URL**: (Optional) URL or local path to `swagger.json` to generate models.
3. **Capabilities (Methods)**: define the actions your feature performs.
   - *Method Name*: e.g., `login`, `fetchProducts`.
   - *Return Type*: Select from standard types or generated Entities.
   - *Parameter Type*: Select input parameters.

#### Configuration Mode (Advanced)

You can define a `mason-make.json` to skip prompts, useful for re-generating or CI/CD.

```json
{
  "name": "Product",
  "schema_url": "http://api.example.com/swagger.json",
  "target_component": ["ProductDTO", "CategoryDTO"],
  "methods": [
    {
      "name": "getProducts",
      "returnType": "List<ProductEntity>",
      "paramType": "CategoryParams"
    },
    {
      "name": "getProductDetail",
      "returnType": "ProductEntity",
      "paramType": "String"
    }
  ]
}
```

```bash
mason make nedo_feature -c mason-make.json
```

## 📂 Generated Structure

For a feature named `Product`:

```text
lib/features/product/
├── data/
│   ├── models/
│   │   ├── product_model.dart       <-- Generated from Swagger
│   │   └── category_model.dart
│   ├── providers/
│   │   └── remote/
│   │       ├── interfaces/
│   │       │   └── i_remote_product_provider.dart
│   │       └── implementations/
│   │           └── remote_product_provider.dart
│   └── repositories/
│       └── product_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── product_entity.dart      <-- Generated from Model
│   │   └── category_entity.dart
│   ├── repositories/
│   │   └── product_repository.dart
│   └── usecases/
│       ├── get_products_usecase.dart
│       └── get_product_detail_usecase.dart
└── presentation/
    └── bloc/
        ├── product_bloc.dart
        ├── product_event.dart
        └── product_state.dart
```

## 🧩 Sub-Bricks

This brick orchestrates other bricks to do the heavy lifting:

- **[nedo_model]**: Handles parsing Swagger schemas and generating Data Models (manual fromJson/toJson) and Domain Entities (Equatable).
- **[nedo_bloc_generic]**: Generates the BLoC/Cubit files and handles state management boilerplate.

## 📋 Variables

| Variable | Description | Default |
|:---------|:------------|:--------|
| `name` | The name of the feature (PascalCase recommended). | - |
| `schema_url` | URL/Path to Swagger JSON for model generation. | - |
| `target_component` | Specific schemas to pick from the Swagger file. | All |

## 📦 Dependencies

The generated code relies on the following packages. Please ensure they are in your `pubspec.yaml`:

```yaml
dependencies:
  flutter_bloc: ^8.1.0    # State management
  equatable: ^2.0.0       # Value equality
  fpdart: ^1.0.0          # Functional programming (Either)
  injectable: ^2.0.0      # Dependency Injection
  get_it: ^7.0.0          # Service Locator
  dio: ^5.0.0             # Networking (used in Remote Providers)

dev_dependencies:
  build_runner: ^2.4.0
  injectable_generator: ^2.0.0
```

> **Note**: This brick assumes a project structure with existing Core modules (`Failure`, `UseCase`, `DioClient`, `repository_helper`).

_Created by [Akbar][1] 🧱_

[1]: https://github.com/mochalifakbar
