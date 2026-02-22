{{#use_equatable}}
import 'package:equatable/equatable.dart';
{{/use_equatable}}


sealed class {{name.pascalCase()}}Event {{#use_equatable}}extends Equatable{{/use_equatable}} {
  const {{name.pascalCase()}}Event();

  {{#use_equatable}}
  @override
  List<Object?> get props => [];
  {{/use_equatable}}
}

/// Event untuk mengambil data (Read)
final class {{name.pascalCase()}}Fetched extends {{name.pascalCase()}}Event {
  const {{name.pascalCase()}}Fetched();
}

/// Event untuk menambah data (Create)
final class {{name.pascalCase()}}Created extends {{name.pascalCase()}}Event {
  final {{{data_type}}} item;
  const {{name.pascalCase()}}Created(this.item);

  {{#use_equatable}}
  @override
  List<Object?> get props => [item];
  {{/use_equatable}}
}

/// Event untuk mengubah data (Update)
final class {{name.pascalCase()}}Updated extends {{name.pascalCase()}}Event {
  final {{{data_type}}} item;
  const {{name.pascalCase()}}Updated(this.item);

  {{#use_equatable}}
  @override
  List<Object?> get props => [item];
  {{/use_equatable}}
}

/// Event untuk menghapus data (Delete)
final class {{name.pascalCase()}}Deleted extends {{name.pascalCase()}}Event {
  final String id; // Atau sesuaikan tipe data ID-nya
  const {{name.pascalCase()}}Deleted(this.id);

  {{#use_equatable}}
  @override
  List<Object?> get props => [id];
  {{/use_equatable}}
}

/// Event untuk menyegarkan data (Refresh/Reset)
final class {{name.pascalCase()}}Refreshed extends {{name.pascalCase()}}Event {
  const {{name.pascalCase()}}Refreshed();
}