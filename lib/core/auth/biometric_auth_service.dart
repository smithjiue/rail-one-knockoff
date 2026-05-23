import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

enum BiometricAuthStatus {
  success,
  canceled,
  notAvailable,
  notEnrolled,
  failed,
}

class BiometricAuthResult {
  const BiometricAuthResult(this.status);

  final BiometricAuthStatus status;

  bool get isSuccess => status == BiometricAuthStatus.success;
}

/// Wraps device biometric authentication for sign-in flows.
class BiometricAuthService {
  BiometricAuthService({LocalAuthentication? localAuth})
    : _localAuth = localAuth ?? LocalAuthentication();

  final LocalAuthentication _localAuth;

  Future<BiometricAuthResult> authenticate({
    required String localizedReason,
  }) async {
    try {
      if (!await _localAuth.isDeviceSupported()) {
        return const BiometricAuthResult(BiometricAuthStatus.notAvailable);
      }

      final enrolled = await _localAuth.getAvailableBiometrics();
      if (enrolled.isEmpty) {
        return const BiometricAuthResult(BiometricAuthStatus.notEnrolled);
      }

      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: localizedReason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );

      return BiometricAuthResult(
        didAuthenticate
            ? BiometricAuthStatus.success
            : BiometricAuthStatus.canceled,
      );
    } on LocalAuthException catch (e, stack) {
      debugPrint('BiometricAuthService: ${e.code} — $e\n$stack');
      return BiometricAuthResult(_statusFromException(e.code));
    } catch (e, stack) {
      debugPrint('BiometricAuthService: $e\n$stack');
      return const BiometricAuthResult(BiometricAuthStatus.failed);
    }
  }

  BiometricAuthStatus _statusFromException(LocalAuthExceptionCode code) {
    switch (code) {
      case LocalAuthExceptionCode.userCanceled:
      case LocalAuthExceptionCode.systemCanceled:
      case LocalAuthExceptionCode.timeout:
        return BiometricAuthStatus.canceled;
      case LocalAuthExceptionCode.noBiometricsEnrolled:
      case LocalAuthExceptionCode.noCredentialsSet:
        return BiometricAuthStatus.notEnrolled;
      case LocalAuthExceptionCode.noBiometricHardware:
      case LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable:
        return BiometricAuthStatus.notAvailable;
      case LocalAuthExceptionCode.authInProgress:
      case LocalAuthExceptionCode.uiUnavailable:
      case LocalAuthExceptionCode.temporaryLockout:
      case LocalAuthExceptionCode.biometricLockout:
      case LocalAuthExceptionCode.userRequestedFallback:
      case LocalAuthExceptionCode.deviceError:
      case LocalAuthExceptionCode.unknownError:
        return BiometricAuthStatus.failed;
    }
  }
}
