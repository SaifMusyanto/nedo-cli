import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../core_ui/extension/extensions.dart';
import '../l10n/generated/app_localizations.dart';
import 'exceptions.dart';

sealed class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];

  String getLocalizedMessage(BuildContext context) {
    _logError();

    final l10n = context.appLocalizations;
    if (l10n == null) return message;

    return switch (this) {
      NetworkFailure(type: final type) => _getNetworkErrorMessage(l10n, type),
      NullFailure() => l10n.errorNullResponse,
      ServerFailure(code: final code) => _getServerErrorMessage(l10n, code),
      UnknownFailure() => l10n.errorUnknown,
      _ => message,
    };
  }

  String _getNetworkErrorMessage(AppLocalizations l10n, NetworkErrorType type) {
    return switch (type) {
      NetworkErrorType.connectTimeout => l10n.errorConnectTimeout,
      NetworkErrorType.sendTimeout => l10n.errorSendTimeout,
      NetworkErrorType.receiveTimeout => l10n.errorReceiveTimeout,
      NetworkErrorType.cancel => l10n.errorRequestCanceled,
      NetworkErrorType.other =>
        message.isNotEmpty ? message : l10n.errorRequestToServer,
    };
  }

  String _getServerErrorMessage(AppLocalizations l10n, int? code) {
    return switch (code) {
      400 => message.isNotEmpty ? message : l10n.errorBadRequest,
      401 => l10n.errorUnauthorized,
      403 => l10n.errorForbidden,
      404 => l10n.errorNotFound,
      422 => message.isNotEmpty ? message : l10n.errorValidation,
      429 => l10n.errorTooManyRequests,
      500 => l10n.errorInternalServer,
      502 => l10n.errorBadGateway,
      503 => l10n.errorMaintenance,
      504 => l10n.errorGatewayTimeout,
      _ => l10n.errorUnknown,
    };
  }

  void _logError() {
    if (kReleaseMode) return;

    debugPrint('==================== API ERROR LOG ====================');
    debugPrint('Type        : $runtimeType');
    debugPrint('Message     : $message');

    if (this is ServerFailure) {
      debugPrint('Status Code : ${(this as ServerFailure).code}');
    }

    if (this is NetworkFailure) {
      debugPrint('Net Type    : ${(this as NetworkFailure).type}');
    }
    debugPrint('=======================================================');
  }
}

class ServerFailure extends Failure {
  final int? code;
  const ServerFailure(super.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}

class NetworkFailure extends Failure {
  final NetworkErrorType type;

  const NetworkFailure(super.message, {required this.type});

  @override
  List<Object?> get props => [message, type];
}

class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message);
}

class AuthorizationFailure extends Failure {
  const AuthorizationFailure(super.message);
}

class DependencyFailure extends Failure {
  const DependencyFailure(super.message);
}

class NullFailure extends Failure {
  const NullFailure(super.message);
}
