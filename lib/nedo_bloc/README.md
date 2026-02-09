# Nedo BLoC

🚀 **Opinionated BLoC generator for CRUD operations.**

Generates a feature-rich BLoC with built-in support for Fetch, Create, Update, Delete, and Refresh events, along with a comprehensive set of states.

## Features

✅ **Complete CRUD Events**
- `Fetched` (Read)
- `Created` (Create)
- `Updated` (Update)
- `Deleted` (Delete)
- `Refreshed` (Reset/Reload)

✅ **Comprehensive States**
- `Initial`
- `Loading` (for fetch operations)
- `Loaded` (success with data)
- `Empty` (no data)
- `Submitting` (for create/update/delete form actions)
- `Success` (action completed successfully)
- `Error` (failure)

## Add dependency in pubspec.yaml
  dependencies:
    flutter_bloc:   ^9.1.1

## Installation

```bash
mason add nedo_bloc
```

## Usage

```bash
mason make nedo_bloc
```

### Prompts

1.  **Feature name**: The name of your feature (e.g., `user`, `product`).
2.  **Data type**: The type of data being managed (e.g., `List<User>`, `Product`).
3.  **Use Equatable**: Whether to extend `Equatable` for value equality (default: `true`).

### Example

```bash
$ mason make nedo_bloc

? What is the feature name? user
? What is the data type? List<User>
? Use Equatable? (Y/n) Y
```

**Generates:**

-   `user_bloc.dart`: The BLoC logic handling all CRUD operations.
-   `user_event.dart`: Sealed class hierarchy for events.
-   `user_state.dart`: Sealed class hierarchy for states.

## Generated Code Overview

### Events (`user_event.dart`)

The brick generates strongly-typed events for all standard operations:

```dart
add(const UserFetched());
add(UserCreated(newUser));
add(UserUpdated(updatedUser));
add(UserDeleted(userId));
add(const UserRefreshed());
```

### States (`user_state.dart`)

The UI can easily react to various states:

```dart
BlocBuilder<UserBloc, UserState>(
  builder: (context, state) {
    if (state is UserLoading) return CircularProgressIndicator();
    if (state is UserLoaded) return UserList(users: state.data);
    if (state is UserEmpty) return Text('No users found');
    if (state is UserError) return Text(state.message);
    
    // For form actions, you might want to use BlocListener for these:
    // state is UserSubmitting
    // state is UserSuccess
    
    return SizedBox();
  },
)
```

### BLoC Logic (`user_bloc.dart`)

The generated BLoC assumes a Datasource interface exists. You will need to implement the actual data fetching logic in the placeholders provided.

```dart
// Auto-generated logic example
Future<void> _onUserCreated(...) async {
  emit(const UserSubmitting());
  try {
    // await datasource.createUser(event.item); <-- Implement this
    emit(const UserSuccess('Created successfully'));
    add(const UserFetched()); // Auto-reload
  } catch (e) {
    emit(UserError(e.toString()));
  }
}
```

## Dependencies

-   `flutter_bloc`
-   `equatable` (optional, but recommended)

## License

MIT License
