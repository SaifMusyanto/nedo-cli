# Knowledge Base

## Detail configuration generator

To enable the "Happy Flow" (skipping interactive prompts) and programmatically generate features, you can provide a complete JSON configuration. This is ideal for AI Agents or bulk generation.

### Complete 1-Click JSON Structure

```json
{
  "name": "FeatureName",
  "schema_url": "https://api.example.com/v1/swagger.json",
  "target_component": ["UserComponent", "AuthComponent"],
  "methods": [
    {
      "name": "login",
      "returnType": "Future<void>",
      "paramType": "LoginDto",
      "isPaginated": false
    },
    {
      "name": "getProducts",
      "returnType": "ProductData",
      "paramType": "ProductRequest",
      "isPaginated": true
    }
  ],
  "type": "bloc",
  "main_data_type": "UserEntity"
}
```

### 1. Global Configuration

| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `name` | `String` | Yes | Name of the feature in PascalCase (e.g., `Order`, `Auth`). **Important**: The generator automatically converts this to `snake_case` for directory names (e.g., `lib/features/order`), while keeping PascalCase for Class names. |
| `schema_url` | `String` | Yes | URL or local file path to the Swagger/OpenAPI JSON schema. Used to generate DTOs and Entities. |
| `target_component` | `List<String>` | No | A list of *root* component names to generate from the schema. The generator works recursively, so you only need to specify the top-level inputs/outputs you need. If empty or omitted, *all* components in the schema will be generated (use with caution on large schemas). <br><br> **Recommendation**: Target the core data objects directly, typically ending in `DTO`, `Request`, or `Data` (e.g., `AccessConfigurationLevelDTO`, `CreateAlarmRequest`). **Avoid** targeting wrapper classes like `...Response` or `...PaginationDTO` unless specifically needed, as `nedo_model` logic (and the `isPaginated` flag) handles the wrapping structure for you. |

### 2. Methods Configuration (`methods`)

The `methods` list defines the UseCases, Repository methods, and Remote Data Source methods. **Providing this list automatically skips the interactive method prompt loop.**

Each object in the `methods` list supports:

| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `name` | `String` | **Required** | The name of the method/capability (camelCase). Example: `login`, `fetchDetails`. |
| `returnType` | `String` | `void` | The return type of the method. Can be a primitive (`void`, `String`, `int`, `bool`) or a generated **Entity** name (e.g., `UserEntity`). **Do not wrap in `Future`**, the generator handles async. |
| `paramType` | `String` | `void` | The input parameter type. Can be a primitive or a generated **Params**/**Entity** name (e.g., `LoginParams`). |
| `isPaginated` | `bool` | `false` | If `true`, automatically wraps inputs in `BaseListRequestModel` and outputs in `PaginationResponseModel`. Useful for list endpoints. |

> **Tip**: When referencing types from the schema, try to use the "clean" entity name (e.g., `UserEntity`) rather than the DTO name (`UserDTO`), though the generator has some fuzzy matching logic.

### 3. State Management Configuration

| Parameter | Type | Condition | Description |
| :--- | :--- | :--- | :--- |
| `type` | `String` | `bloc` (default) | Choose between `bloc` or `cubit`. |
| `main_data_type` | `String` | `type`="bloc" | The primary data type carried by the `Success` state of the BLoC. e.g. `List<ProductEntity>`. |
| `state_props` | `List<Map>` | `type`="cubit" | **Cubit Only**. A list of properties to add to the state class. See example below. |

#### Example: Cubit with Custom State Props

```json
{
  "name": "Counter",
  "type": "cubit",
  "state_props": [
    { "name": "count", "type": "int", "default": "0" },
    { "name": "userMessage", "type": "String?", "default": "null" }
  ]
}
```

### 4. Generator Logic Insights

-   **Recursive Dependency Extraction**: If you request `UserEntity`, the generator automatically finds and generates `AddressEntity` if `User` depends on `Address`. You don't need to list every single nested component.
-   **Suffix Removal**: The generator automatically strips common suffixes like `Request`, `Response`, `DTO` when matching target components against the schema.
-   **Interactive Skip**: If `methods` is present in the input JSON, the generator bypasses the CLI prompts for adding capabilities and moves straight to generation. This is key for automated workflows.

#### A. Suffix-Based Transformation Rules

| Swagger Name | Detected Suffix | Action | Final Dart Class | Layer / Usage |
| :--- | :--- | :--- | :--- | :--- |
| `LoginRequest` | `Request` | Replaces with `Params` | `LoginParams` | **Domain**: UseCase Inputs |
| `UserDTO` | `DTO` | Replaces with `Entity` | `UserEntity` | **Domain**: Core Models |
| `ProductData` | `Data` | Replaces with `Entity` | `ProductEntity` | **Domain**: Core Models |
| `Car` | (None) | Appends `Entity` | `CarEntity` | **Domain**: Default Fallback |

#### B. Type Mapping (Swagger -> Dart)

Primitive types are mapped to their strict Dart equivalents to ensure type safety.

| Swagger Type | Swagger Format | Dart Type |
| :--- | :--- | :--- |
| `integer` | `int64` / `int32` | `int` |
| `number` | `float` / `double` | `double` |
| `string` | `date` / `date-time` | `DateTime` |
| `string` | (default) | `String` |
| `boolean` | - | `bool` |
| `array` | - | `List<T>` |

#### C. Blacklisted Components

To prevent errors from common system-generated types (often found in Protobuf/gRPC JSONs), the CLI automatically ignores generic wrappers:
- `Value`, `Any`, `ListValue`, `NullValue`

### Generated Structure Overview

A typical `nedo_feature` generation results in a complete, isolated module:

```text
lib/features/my_feature/
├── data/
│   ├── models/           # DTOs generated from Swagger (with fromJson)
│   ├── providers/        # Remote/Local data sources
│   └── repositories/     # Repository Implementation
├── domain/
│   ├── entities/         # Clean Entities (Equatable, no JSON parsing)
│   ├── repositories/     # Repository Interfaces
│   └── usecases/         # Callable classes for each method defined
└── presentation/
    └── bloc/             # BLoC/Cubit wired to UseCases
```