{{#use_equatable}}
import 'package:equatable/equatable.dart';
{{/use_equatable}}

part of '{{name.snakeCase()}}_bloc.dart';

{{#use_equatable}}
abstract class {{name.pascalCase()}}State extends Equatable {
  const {{name.pascalCase()}}State();
  
  @override
  List<Object?> get props => [];
}

class {{name.pascalCase()}}Initial extends {{name.pascalCase()}}State {
  const {{name.pascalCase()}}Initial();
}

class {{name.pascalCase()}}Loading extends {{name.pascalCase()}}State {
  const {{name.pascalCase()}}Loading();
}

class {{name.pascalCase()}}Loaded extends {{name.pascalCase()}}State {
  final {{{data_type}}} data;
  
  const {{name.pascalCase()}}Loaded(this.data);
  
  @override
  List<Object?> get props => [data];
}

class {{name.pascalCase()}}Error extends {{name.pascalCase()}}State {
  final String message;
  
  const {{name.pascalCase()}}Error(this.message);
  
  @override
  List<Object?> get props => [message];
}

{{#include_empty_state}}
class {{name.pascalCase()}}Empty extends {{name.pascalCase()}}State {
  const {{name.pascalCase()}}Empty();
}

{{/include_empty_state}}
{{#include_creating_state}}
class {{name.pascalCase()}}Creating extends {{name.pascalCase()}}State {
  const {{name.pascalCase()}}Creating();
}

{{/include_creating_state}}
{{#include_updating_state}}
class {{name.pascalCase()}}Updating extends {{name.pascalCase()}}State {
  const {{name.pascalCase()}}Updating();
}

{{/include_updating_state}}
{{#include_deleting_state}}
class {{name.pascalCase()}}Deleting extends {{name.pascalCase()}}State {
  const {{name.pascalCase()}}Deleting();
}

{{/include_deleting_state}}
{{/use_equatable}}
{{^use_equatable}}
abstract class {{name.pascalCase()}}State {
  const {{name.pascalCase()}}State();
}

class {{name.pascalCase()}}Initial extends {{name.pascalCase()}}State {
  const {{name.pascalCase()}}Initial();
}

class {{name.pascalCase()}}Loading extends {{name.pascalCase()}}State {
  const {{name.pascalCase()}}Loading();
}

class {{name.pascalCase()}}Loaded extends {{name.pascalCase()}}State {
  final {{{data_type}}} data;
  
  const {{name.pascalCase()}}Loaded(this.data);
}

class {{name.pascalCase()}}Error extends {{name.pascalCase()}}State {
  final String message;
  
  const {{name.pascalCase()}}Error(this.message);
}

{{#include_empty_state}}
class {{name.pascalCase()}}Empty extends {{name.pascalCase()}}State {
  const {{name.pascalCase()}}Empty();
}

{{/include_empty_state}}
{{#include_creating_state}}
class {{name.pascalCase()}}Creating extends {{name.pascalCase()}}State {
  const {{name.pascalCase()}}Creating();
}

{{/include_creating_state}}
{{#include_updating_state}}
class {{name.pascalCase()}}Updating extends {{name.pascalCase()}}State {
  const {{name.pascalCase()}}Updating();
}

{{/include_updating_state}}
{{#include_deleting_state}}
class {{name.pascalCase()}}Deleting extends {{name.pascalCase()}}State {
  const {{name.pascalCase()}}Deleting();
}

{{/include_deleting_state}}
{{/use_equatable}}