{{#use_equatable}}
import 'package:equatable/equatable.dart';
{{/use_equatable}}

abstract class {{name.pascalCase()}}State {{#use_equatable}}extends Equatable{{/use_equatable}} {
  const {{name.pascalCase()}}State();
  
  {{#use_equatable}}
  @override
  List<Object?> get props => [];
  {{/use_equatable}}
}

/// State awal saat BLoC pertama kali dibuat
final class {{name.pascalCase()}}Initial extends {{name.pascalCase()}}State {
  const {{name.pascalCase()}}Initial();
}

/// State saat proses pengambilan data (Fetch)
final class {{name.pascalCase()}}Loading extends {{name.pascalCase()}}State {
  const {{name.pascalCase()}}Loading();
}

/// State saat data berhasil dimuat
final class {{name.pascalCase()}}Loaded extends {{name.pascalCase()}}State {
  final {{{data_type}}} data;
  
  const {{name.pascalCase()}}Loaded(this.data);
  
  {{#use_equatable}}
  @override
  List<Object?> get props => [data];
  {{/use_equatable}}
}

/// State saat data kosong (Empty)
final class {{name.pascalCase()}}Empty extends {{name.pascalCase()}}State {
  const {{name.pascalCase()}}Empty();
}

/// State saat sedang memproses (Create/Update/Delete)
final class {{name.pascalCase()}}Submitting extends {{name.pascalCase()}}State {
  const {{name.pascalCase()}}Submitting();
}

/// State saat operasi CRUD berhasil dilakukan
final class {{name.pascalCase()}}Success extends {{name.pascalCase()}}State {
  final String message;
  const {{name.pascalCase()}}Success(this.message);

  {{#use_equatable}}
  @override
  List<Object?> get props => [message];
  {{/use_equatable}}
}

/// State saat terjadi kesalahan
final class {{name.pascalCase()}}Error extends {{name.pascalCase()}}State {
  final String message;
  
  const {{name.pascalCase()}}Error(this.message);
  
  {{#use_equatable}}
  @override
  List<Object?> get props => [message];
  {{/use_equatable}}
}