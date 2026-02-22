{{#use_equatable}}
import 'package:equatable/equatable.dart';
{{/use_equatable}}

part of '{{name.snakeCase()}}_bloc.dart';

{{#use_equatable}}
abstract class {{name.pascalCase()}}Event extends Equatable {
  const {{name.pascalCase()}}Event();
  
  @override
  List<Object?> get props => [];
}

{{#include_fetch}}
class Fetch{{name.pascalCase()}} extends {{name.pascalCase()}}Event {
  const Fetch{{name.pascalCase()}}();
}

{{/include_fetch}}
{{#include_create}}
class Create{{name.pascalCase()}} extends {{name.pascalCase()}}Event {
  final {{{data_type}}} data;
  
  const Create{{name.pascalCase()}}(this.data);
  
  @override
  List<Object?> get props => [data];
}

{{/include_create}}
{{#include_update}}
class Update{{name.pascalCase()}} extends {{name.pascalCase()}}Event {
  final {{{data_type}}} data;
  
  const Update{{name.pascalCase()}}(this.data);
  
  @override
  List<Object?> get props => [data];
}

{{/include_update}}
{{#include_delete}}
class Delete{{name.pascalCase()}} extends {{name.pascalCase()}}Event {
  final String id;
  
  const Delete{{name.pascalCase()}}(this.id);
  
  @override
  List<Object?> get props => [id];
}

{{/include_delete}}
{{#include_refresh}}
class Refresh{{name.pascalCase()}} extends {{name.pascalCase()}}Event {
  const Refresh{{name.pascalCase()}}();
}

{{/include_refresh}}
{{/use_equatable}}
{{^use_equatable}}
abstract class {{name.pascalCase()}}Event {
  const {{name.pascalCase()}}Event();
}

{{#include_fetch}}
class Fetch{{name.pascalCase()}} extends {{name.pascalCase()}}Event {
  const Fetch{{name.pascalCase()}}();
}

{{/include_fetch}}
{{#include_create}}
class Create{{name.pascalCase()}} extends {{name.pascalCase()}}Event {
  final {{{data_type}}} data;
  
  const Create{{name.pascalCase()}}(this.data);
}

{{/include_create}}
{{#include_update}}
class Update{{name.pascalCase()}} extends {{name.pascalCase()}}Event {
  final {{{data_type}}} data;
  
  const Update{{name.pascalCase()}}(this.data);
}

{{/include_update}}
{{#include_delete}}
class Delete{{name.pascalCase()}} extends {{name.pascalCase()}}Event {
  final String id;
  
  const Delete{{name.pascalCase()}}(this.id);
}

{{/include_delete}}
{{#include_refresh}}
class Refresh{{name.pascalCase()}} extends {{name.pascalCase()}}Event {
  const Refresh{{name.pascalCase()}}();
}

{{/include_refresh}}
{{/use_equatable}}