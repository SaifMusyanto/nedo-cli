# Example Generated Code

This example shows what gets generated when you run:

```bash
mason make simple_bloc \
  --name user \
  --data_type "List<User>" \
  --datasource_name UserDatasource \
  --datasource_method getUsers \
  --use_equatable true
```

## Generated Files

See the following files in this directory:

- `user_bloc.dart` - Main BLoC class with fetch event handler
- `user_event.dart` - Event classes
- `user_state.dart` - State classes

## How to Use

1. Copy these files to your project:

   ```
   lib/features/user/presentation/bloc/
   ```

2. Create the datasource:

   ```dart
   abstract class UserDatasource {
     Future<List<User>> getUsers();
   }
   ```

3. Implement the datasource:

   ```dart
   class UserDatasourceImpl implements UserDatasource {
     @override
     Future<List<User>> getUsers() async {
       // Your API call here
     }
   }
   ```

4. Use the BLoC in your widget:
   ```dart
   BlocProvider(
     create: (context) => UserBloc(
       datasource: context.read<UserDatasource>(),
     ),
     child: UserPage(),
   )
   ```
