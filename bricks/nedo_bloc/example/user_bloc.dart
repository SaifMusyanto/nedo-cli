import 'package:flutter_bloc/flutter_bloc.dart';
{{#use_equatable}}
import 'package:equatable/equatable.dart';
{{/use_equatable}}

part '{{name.snakeCase()}}_event.dart';
part '{{name.snakeCase()}}_state.dart';

class {{name.pascalCase()}}Bloc extends Bloc<{{name.pascalCase()}}Event, {{name.pascalCase()}}State> {
{{#use_repository}}
  final {{name.pascalCase()}}Repository repository;

  {{name.pascalCase()}}Bloc({
    required this.repository,
  }) : super(const {{name.pascalCase()}}Initial()) {
{{#include_fetch}}
    on<Fetch{{name.pascalCase()}}>(_onFetch{{name.pascalCase()}});
{{/include_fetch}}
{{#include_create}}
    on<Create{{name.pascalCase()}}>(_onCreate{{name.pascalCase()}});
{{/include_create}}
{{#include_update}}
    on<Update{{name.pascalCase()}}>(_onUpdate{{name.pascalCase()}});
{{/include_update}}
{{#include_delete}}
    on<Delete{{name.pascalCase()}}>(_onDelete{{name.pascalCase()}});
{{/include_delete}}
{{#include_refresh}}
    on<Refresh{{name.pascalCase()}}>(_onRefresh{{name.pascalCase()}});
{{/include_refresh}}
  }

{{#include_fetch}}
  Future<void> _onFetch{{name.pascalCase()}}(
    Fetch{{name.pascalCase()}} event,
    Emitter<{{name.pascalCase()}}State> emit,
  ) async {
    emit(const {{name.pascalCase()}}Loading());
    
    try {
      final data = await repository.{{{fetch_method}}}();
{{#include_empty_state}}
      if (data == null || (data is List && data.isEmpty)) {
        emit(const {{name.pascalCase()}}Empty());
      } else {
        emit({{name.pascalCase()}}Loaded(data));
      }
{{/include_empty_state}}
{{^include_empty_state}}
      emit({{name.pascalCase()}}Loaded(data));
{{/include_empty_state}}
    } catch (e) {
      emit({{name.pascalCase()}}Error(e.toString()));
    }
  }

{{/include_fetch}}
{{#include_create}}
  Future<void> _onCreate{{name.pascalCase()}}(
    Create{{name.pascalCase()}} event,
    Emitter<{{name.pascalCase()}}State> emit,
  ) async {
{{#include_creating_state}}
    emit(const {{name.pascalCase()}}Creating());
{{/include_creating_state}}
{{^include_creating_state}}
    emit(const {{name.pascalCase()}}Loading());
{{/include_creating_state}}
    
    try {
      await repository.{{{create_method}}}(event.data);
{{#include_fetch}}
      // Refresh data after create
      add(const Fetch{{name.pascalCase()}}());
{{/include_fetch}}
{{^include_fetch}}
      emit(const {{name.pascalCase()}}Initial());
{{/include_fetch}}
    } catch (e) {
      emit({{name.pascalCase()}}Error(e.toString()));
    }
  }

{{/include_create}}
{{#include_update}}
  Future<void> _onUpdate{{name.pascalCase()}}(
    Update{{name.pascalCase()}} event,
    Emitter<{{name.pascalCase()}}State> emit,
  ) async {
{{#include_updating_state}}
    emit(const {{name.pascalCase()}}Updating());
{{/include_updating_state}}
{{^include_updating_state}}
    emit(const {{name.pascalCase()}}Loading());
{{/include_updating_state}}
    
    try {
      await repository.{{{update_method}}}(event.data);
{{#include_fetch}}
      // Refresh data after update
      add(const Fetch{{name.pascalCase()}}());
{{/include_fetch}}
{{^include_fetch}}
      emit(const {{name.pascalCase()}}Initial());
{{/include_fetch}}
    } catch (e) {
      emit({{name.pascalCase()}}Error(e.toString()));
    }
  }

{{/include_update}}
{{#include_delete}}
  Future<void> _onDelete{{name.pascalCase()}}(
    Delete{{name.pascalCase()}} event,
    Emitter<{{name.pascalCase()}}State> emit,
  ) async {
{{#include_deleting_state}}
    emit(const {{name.pascalCase()}}Deleting());
{{/include_deleting_state}}
{{^include_deleting_state}}
    emit(const {{name.pascalCase()}}Loading());
{{/include_deleting_state}}
    
    try {
      await repository.{{{delete_method}}}(event.id);
{{#include_fetch}}
      // Refresh data after delete
      add(const Fetch{{name.pascalCase()}}());
{{/include_fetch}}
{{^include_fetch}}
      emit(const {{name.pascalCase()}}Initial());
{{/include_fetch}}
    } catch (e) {
      emit({{name.pascalCase()}}Error(e.toString()));
    }
  }

{{/include_delete}}
{{#include_refresh}}
  Future<void> _onRefresh{{name.pascalCase()}}(
    Refresh{{name.pascalCase()}} event,
    Emitter<{{name.pascalCase()}}State> emit,
  ) async {
    emit(const {{name.pascalCase()}}Loading());
    
    try {
      final data = await repository.{{{fetch_method}}}();
{{#include_empty_state}}
      if (data == null || (data is List && data.isEmpty)) {
        emit(const {{name.pascalCase()}}Empty());
      } else {
        emit({{name.pascalCase()}}Loaded(data));
      }
{{/include_empty_state}}
{{^include_empty_state}}
      emit({{name.pascalCase()}}Loaded(data));
{{/include_empty_state}}
    } catch (e) {
      emit({{name.pascalCase()}}Error(e.toString()));
    }
  }

{{/include_refresh}}
{{/use_repository}}
{{^use_repository}}
  final {{{datasource_name}}} datasource;

  {{name.pascalCase()}}Bloc({
    required this.datasource,
  }) : super(const {{name.pascalCase()}}Initial()) {
{{#include_fetch}}
    on<Fetch{{name.pascalCase()}}>(_onFetch{{name.pascalCase()}});
{{/include_fetch}}
{{#include_create}}
    on<Create{{name.pascalCase()}}>(_onCreate{{name.pascalCase()}});
{{/include_create}}
{{#include_update}}
    on<Update{{name.pascalCase()}}>(_onUpdate{{name.pascalCase()}});
{{/include_update}}
{{#include_delete}}
    on<Delete{{name.pascalCase()}}>(_onDelete{{name.pascalCase()}});
{{/include_delete}}
{{#include_refresh}}
    on<Refresh{{name.pascalCase()}}>(_onRefresh{{name.pascalCase()}});
{{/include_refresh}}
  }

{{#include_fetch}}
  Future<void> _onFetch{{name.pascalCase()}}(
    Fetch{{name.pascalCase()}} event,
    Emitter<{{name.pascalCase()}}State> emit,
  ) async {
    emit(const {{name.pascalCase()}}Loading());
    
    try {
      final data = await datasource.{{{fetch_method}}}();
{{#include_empty_state}}
      if (data == null || (data is List && data.isEmpty)) {
        emit(const {{name.pascalCase()}}Empty());
      } else {
        emit({{name.pascalCase()}}Loaded(data));
      }
{{/include_empty_state}}
{{^include_empty_state}}
      emit({{name.pascalCase()}}Loaded(data));
{{/include_empty_state}}
    } catch (e) {
      emit({{name.pascalCase()}}Error(e.toString()));
    }
  }

{{/include_fetch}}
{{#include_create}}
  Future<void> _onCreate{{name.pascalCase()}}(
    Create{{name.pascalCase()}} event,
    Emitter<{{name.pascalCase()}}State> emit,
  ) async {
{{#include_creating_state}}
    emit(const {{name.pascalCase()}}Creating());
{{/include_creating_state}}
{{^include_creating_state}}
    emit(const {{name.pascalCase()}}Loading());
{{/include_creating_state}}
    
    try {
      await datasource.{{{create_method}}}(event.data);
{{#include_fetch}}
      // Refresh data after create
      add(const Fetch{{name.pascalCase()}}());
{{/include_fetch}}
{{^include_fetch}}
      emit(const {{name.pascalCase()}}Initial());
{{/include_fetch}}
    } catch (e) {
      emit({{name.pascalCase()}}Error(e.toString()));
    }
  }

{{/include_create}}
{{#include_update}}
  Future<void> _onUpdate{{name.pascalCase()}}(
    Update{{name.pascalCase()}} event,
    Emitter<{{name.pascalCase()}}State> emit,
  ) async {
{{#include_updating_state}}
    emit(const {{name.pascalCase()}}Updating());
{{/include_updating_state}}
{{^include_updating_state}}
    emit(const {{name.pascalCase()}}Loading());
{{/include_updating_state}}
    
    try {
      await datasource.{{{update_method}}}(event.data);
{{#include_fetch}}
      // Refresh data after update
      add(const Fetch{{name.pascalCase()}}());
{{/include_fetch}}
{{^include_fetch}}
      emit(const {{name.pascalCase()}}Initial());
{{/include_fetch}}
    } catch (e) {
      emit({{name.pascalCase()}}Error(e.toString()));
    }
  }

{{/include_update}}
{{#include_delete}}
  Future<void> _onDelete{{name.pascalCase()}}(
    Delete{{name.pascalCase()}} event,
    Emitter<{{name.pascalCase()}}State> emit,
  ) async {
{{#include_deleting_state}}
    emit(const {{name.pascalCase()}}Deleting());
{{/include_deleting_state}}
{{^include_deleting_state}}
    emit(const {{name.pascalCase()}}Loading());
{{/include_deleting_state}}
    
    try {
      await datasource.{{{delete_method}}}(event.id);
{{#include_fetch}}
      // Refresh data after delete
      add(const Fetch{{name.pascalCase()}}());
{{/include_fetch}}
{{^include_fetch}}
      emit(const {{name.pascalCase()}}Initial());
{{/include_fetch}}
    } catch (e) {
      emit({{name.pascalCase()}}Error(e.toString()));
    }
  }

{{/include_delete}}
{{#include_refresh}}
  Future<void> _onRefresh{{name.pascalCase()}}(
    Refresh{{name.pascalCase()}} event,
    Emitter<{{name.pascalCase()}}State> emit,
  ) async {
    emit(const {{name.pascalCase()}}Loading());
    
    try {
      final data = await datasource.{{{fetch_method}}}();
{{#include_empty_state}}
      if (data == null || (data is List && data.isEmpty)) {
        emit(const {{name.pascalCase()}}Empty());
      } else {
        emit({{name.pascalCase()}}Loaded(data));
      }
{{/include_empty_state}}
{{^include_empty_state}}
      emit({{name.pascalCase()}}Loaded(data));
{{/include_empty_state}}
    } catch (e) {
      emit({{name.pascalCase()}}Error(e.toString()));
    }
  }

{{/include_refresh}}
{{/use_repository}}
}