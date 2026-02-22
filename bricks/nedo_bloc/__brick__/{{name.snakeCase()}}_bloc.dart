import 'package:flutter_bloc/flutter_bloc.dart';

import '{{name.snakeCase()}}_event.dart';
import '{{name.snakeCase()}}_state.dart';

class {{name.pascalCase()}}Bloc extends Bloc<{{name.pascalCase()}}Event, {{name.pascalCase()}}State> {
  final {{name.pascalCase()}}Datasource datasource;

  {{name.pascalCase()}}Bloc({
    required this.datasource,
  }) : super(const {{name.pascalCase()}}Initial()) {
    on<{{name.pascalCase()}}Fetched>(_on{{name.pascalCase()}}Fetched);
    on<{{name.pascalCase()}}Created>(_on{{name.pascalCase()}}Created);
    on<{{name.pascalCase()}}Updated>(_on{{name.pascalCase()}}Updated);
    on<{{name.pascalCase()}}Deleted>(_on{{name.pascalCase()}}Deleted);
    on<{{name.pascalCase()}}Refreshed>(_on{{name.pascalCase()}}Refreshed);
  }

  Future<void> _on{{name.pascalCase()}}Fetched(
    {{name.pascalCase()}}Fetched event,
    Emitter<{{name.pascalCase()}}State> emit,
  ) async {
    emit(const {{name.pascalCase()}}Loading());
    try {
      // Implement your fetch method here
      // final data = await datasource.{{{fetch_method}}}();
      if ((data is List && data.isEmpty)) {
        emit(const {{name.pascalCase()}}Empty());
      } else {
        emit({{name.pascalCase()}}Loaded(data));
      }
    } catch (e) {
      emit({{name.pascalCase()}}Error(e.toString()));
    }
  }

  Future<void> _on{{name.pascalCase()}}Created(
    {{name.pascalCase()}}Created event,
    Emitter<{{name.pascalCase()}}State> emit,
  ) async {
    emit(const {{name.pascalCase()}}Submitting());
    try {
      // Implement your create method here
      // await datasource.{{{create_method}}}(event.item);
      emit(const {{name.pascalCase()}}Success('Created successfully'));
      // Optional: Refresh data after success
      add(const {{name.pascalCase()}}Fetched());
    } catch (e) {
      emit({{name.pascalCase()}}Error(e.toString()));
    }
  }

  Future<void> _on{{name.pascalCase()}}Updated(
    {{name.pascalCase()}}Updated event,
    Emitter<{{name.pascalCase()}}State> emit,
  ) async {
    emit(const {{name.pascalCase()}}Submitting());
    try {
      // Implement your update method here
      // await datasource.{{{update_method}}}(event.item);
      emit(const {{name.pascalCase()}}Success('Updated successfully'));
      add(const {{name.pascalCase()}}Fetched());
    } catch (e) {
      emit({{name.pascalCase()}}Error(e.toString()));
    }
  }

  Future<void> _on{{name.pascalCase()}}Deleted(
    {{name.pascalCase()}}Deleted event,
    Emitter<{{name.pascalCase()}}State> emit,
  ) async {
    emit(const {{name.pascalCase()}}Submitting());
    try {
      // Implement your delete method here
      // await datasource.{{{delete_method}}}(event.id);
      emit(const {{name.pascalCase()}}Success('Deleted successfully'));
      add(const {{name.pascalCase()}}Fetched());
    } catch (e) {
      emit({{name.pascalCase()}}Error(e.toString()));
    }
  }

  Future<void> _on{{name.pascalCase()}}Refreshed(
    {{name.pascalCase()}}Refreshed event,
    Emitter<{{name.pascalCase()}}State> emit,
  ) async {
    add(const {{name.pascalCase()}}Fetched());
  }
}