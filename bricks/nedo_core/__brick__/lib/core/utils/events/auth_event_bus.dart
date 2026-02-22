import 'dart:async';
import 'package:injectable/injectable.dart';

@lazySingleton
class AuthEventBus {
  final _controller = StreamController<void>.broadcast();
  Stream<void> get onSessionExpired => _controller.stream;

  void emitSessionExpired() {
    _controller.add(null);
  }
}
