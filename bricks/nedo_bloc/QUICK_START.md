# Advanced BLoC - Quick Start Guide

Get started with full-featured BLoC generation in 5 minutes!

## Installation

```bash
# Install Mason CLI (if not installed)
dart pub global activate mason_cli

# Add the brick
mason add advanced_bloc --path /path/to/advanced_bloc_brick

# Verify
mason list
```

## 5-Minute Tutorial

### Scenario: User Management (Full CRUD)

We'll create a complete user management BLoC with:

- ✅ Fetch users
- ✅ Create user
- ✅ Update user
- ✅ Delete user
- ✅ Empty state for no users

#### Step 1: Generate the BLoC (1 minute)

```bash
cd lib/features/user/presentation/bloc

mason make advanced_bloc \
  --name user \
  --data_type "List<User>" \
  --datasource_name UserDatasource \
  --include_fetch \
  --include_create \
  --include_update \
  --include_delete \
  --include_empty_state \
  --include_creating_state \
  --include_deleting_state
```

**Generated:**

- ✅ `user_bloc.dart` - Complete BLoC
- ✅ `user_event.dart` - 4 events
- ✅ `user_state.dart` - 7 states

#### Step 2: Create the Datasource (2 minutes)

```dart
// lib/features/user/data/datasources/user_datasource.dart

abstract class UserDatasource {
  Future<List<User>> getUsers();
  Future<void> createUser(User data);
  Future<void> updateUser(User data);
  Future<void> deleteUser(String id);
}

class UserDatasourceImpl implements UserDatasource {
  final http.Client client;

  UserDatasourceImpl(this.client);

  @override
  Future<List<User>> getUsers() async {
    final response = await client.get(
      Uri.parse('https://api.example.com/users'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => User.fromJson(json)).toList();
    }
    throw Exception('Failed to load users');
  }

  @override
  Future<void> createUser(User data) async {
    final response = await client.post(
      Uri.parse('https://api.example.com/users'),
      body: json.encode(data.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create user');
    }
  }

  @override
  Future<void> updateUser(User data) async {
    final response = await client.put(
      Uri.parse('https://api.example.com/users/${data.id}'),
      body: json.encode(data.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update user');
    }
  }

  @override
  Future<void> deleteUser(String id) async {
    final response = await client.delete(
      Uri.parse('https://api.example.com/users/$id'),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete user');
    }
  }
}
```

#### Step 3: Use in Your App (2 minutes)

```dart
// lib/features/user/presentation/pages/user_page.dart

class UserPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserBloc(
        datasource: UserDatasourceImpl(http.Client()),
      )..add(const FetchUser()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Users')),
        body: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            // Loading
            if (state is UserLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // Creating
            if (state is UserCreating) {
              return const Center(child: Text('Creating user...'));
            }

            // Deleting
            if (state is UserDeleting) {
              return const Center(child: Text('Deleting user...'));
            }

            // Empty
            if (state is UserEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.person_off, size: 64),
                    const SizedBox(height: 16),
                    const Text('No users found'),
                    ElevatedButton(
                      onPressed: () => _showCreateDialog(context),
                      child: const Text('Add First User'),
                    ),
                  ],
                ),
              );
            }

            // Loaded
            if (state is UserLoaded) {
              return ListView.builder(
                itemCount: state.data.length,
                itemBuilder: (context, index) {
                  final user = state.data[index];
                  return ListTile(
                    leading: CircleAvatar(child: Text(user.name[0])),
                    title: Text(user.name),
                    subtitle: Text(user.email),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showEditDialog(context, user),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => context
                              .read<UserBloc>()
                              .add(DeleteUser(user.id)),
                        ),
                      ],
                    ),
                  );
                },
              );
            }

            // Error
            if (state is UserError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: ${state.message}'),
                    ElevatedButton(
                      onPressed: () => context
                          .read<UserBloc>()
                          .add(const FetchUser()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox();
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showCreateDialog(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    // Show dialog to create new user
    showDialog(
      context: context,
      builder: (_) => CreateUserDialog(
        onSubmit: (user) {
          context.read<UserBloc>().add(CreateUser(user));
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, User user) {
    // Show dialog to edit user
    showDialog(
      context: context,
      builder: (_) => EditUserDialog(
        user: user,
        onSubmit: (updatedUser) {
          context.read<UserBloc>().add(UpdateUser(updatedUser));
          Navigator.pop(context);
        },
      ),
    );
  }
}
```

## That's It! 🎉

You now have:

- ✅ Full CRUD functionality
- ✅ Loading states for each operation
- ✅ Empty state handling
- ✅ Error handling
- ✅ Auto-refresh after mutations

## Common Scenarios

### Scenario 1: Simple Read-Only List

```bash
mason make advanced_bloc \
  --name post \
  --data_type "List<Post>" \
  --datasource_name PostDatasource \
  --include_fetch \
  --include_empty_state
```

### Scenario 2: With Repository Layer

```bash
mason make advanced_bloc \
  --name product \
  --use_repository \
  --data_type "Product" \
  --datasource_name ProductDatasource \
  --include_fetch \
  --include_update
```

Then create:

```dart
// Use repository instead of datasource
BlocProvider(
  create: (context) => ProductBloc(
    repository: ProductRepositoryImpl(
      ProductDatasourceImpl(),
    ),
  ),
  child: ProductPage(),
)
```

### Scenario 3: Detail View (Single Item)

```bash
mason make advanced_bloc \
  --name user_detail \
  --data_type "User" \
  --datasource_name UserDatasource \
  --include_fetch \
  --include_update
```

## Tips & Tricks

### Tip 1: Answer Prompts with Single Letters

```
? Include fetch event? (Y/n) Y    ← Just "Y"
? Include create event? (Y/n) n   ← Just "n"
```

NOT "Yes" or "No"!

### Tip 2: Use Flags for Consistency

Create a script for your team:

```bash
# scripts/generate_crud_bloc.sh
#!/bin/bash
mason make advanced_bloc \
  --name $1 \
  --data_type "$2" \
  --datasource_name "$3" \
  --include_fetch \
  --include_create \
  --include_update \
  --include_delete \
  --include_empty_state \
  --include_creating_state \
  --include_deleting_state
```

Use it:

```bash
./generate_crud_bloc.sh user "List<User>" UserDatasource
```

### Tip 3: Combine with v1.0 Simple BLoC

```bash
# For simple cases - use v1.0
mason make simple_bloc --name notification

# For complex cases - use v2.0
mason make advanced_bloc --name user
```

## Troubleshooting

**Issue:** Boolean prompts not working
**Solution:** Answer with `Y` or `n` (single letter), or use command-line flags

**Issue:** Generated files have errors
**Solution:** The TEMPLATES have "errors" (normal). Check the GENERATED files in your project

**Issue:** Want to add more events later
**Solution:** Regenerate with more flags, or manually add to the generated files

## Next Steps

1. **Read the full README** - See all options
2. **Check examples** - See real-world usage
3. **Customize** - Modify generated code as needed
4. **Share** - Use in your team!

## Quick Reference

### All Boolean Flags

```bash
--include_fetch          # Fetch event
--include_create         # Create event
--include_update         # Update event
--include_delete         # Delete event
--include_refresh        # Refresh event
--include_empty_state    # Empty state
--include_creating_state # Creating state
--include_updating_state # Updating state
--include_deleting_state # Deleting state
--use_repository         # Repository layer
--use_equatable          # Equatable
```

### Event Methods

```dart
context.read<UserBloc>().add(const FetchUser());
context.read<UserBloc>().add(CreateUser(newUser));
context.read<UserBloc>().add(UpdateUser(user));
context.read<UserBloc>().add(DeleteUser('id'));
context.read<UserBloc>().add(const RefreshUser());
```

Happy coding! 🚀
