import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rail_one/core/auth/biometric_auth_service.dart';
import 'package:rail_one/core/di/injection.dart';
import 'package:rail_one/core/storage/local_storage_service.dart';
import 'package:rail_one/core/theme/app_colors.dart';
import 'package:rail_one/presentation/auth/pages/login_page.dart';
import 'package:rail_one/presentation/auth/pages/registration_page.dart';
import 'package:rail_one/presentation/auth/widgets/auth_validation_dialog.dart';
import 'package:rail_one/presentation/auth/widgets/mpin_input_row.dart';
import 'package:rail_one/presentation/home/pages/home_page.dart';
import 'package:rail_one/presentation/home/widgets/home_header.dart';

class MpinLoginPage extends StatefulWidget {
  const MpinLoginPage({super.key});

  @override
  State<MpinLoginPage> createState() => _MpinLoginPageState();
}

class _MpinLoginPageState extends State<MpinLoginPage> {
  String? _userName;
  String _mpin = '';
  bool _authInProgress = false;
  int _mpinInputKey = 0;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final storage = sl<LocalStorageService>();
    final name =
        await storage.getRegisteredName() ??
        (await storage.getUserProfile())?.displayName;

    if (!mounted) return;
    final trimmed = name?.trim();
    setState(
      () =>
          _userName = trimmed != null && trimmed.isNotEmpty ? trimmed : 'User',
    );
  }

  void _goHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const HomePage()),
    );
  }

  Future<void> _onMpinCompleted(String mpin) async {
    setState(() => _mpin = mpin);
    await _submitLogin();
  }

  Future<void> _loginWithBiometric() async {
    if (_authInProgress) return;
    _authInProgress = true;
    try {
      final result = await sl<BiometricAuthService>().authenticate(
        localizedReason: 'Authenticate to sign in to RailOne',
      );
      if (!mounted) return;

      switch (result.status) {
        case BiometricAuthStatus.success:
          _goHome();
        case BiometricAuthStatus.canceled:
          break;
        case BiometricAuthStatus.notEnrolled:
          await showAuthValidationDialog(
            context,
            message:
                'No fingerprint or face unlock is set up on this device. '
                'Add biometrics in device settings, then try again.',
          );
        case BiometricAuthStatus.notAvailable:
          await showAuthValidationDialog(
            context,
            message: 'Biometric login is not available on this device.',
          );
        case BiometricAuthStatus.failed:
          await showAuthValidationDialog(
            context,
            message: 'Could not open biometric login. Please try again.',
          );
      }
    } finally {
      _authInProgress = false;
    }
  }

  Future<void> _submitLogin() async {
    if (_mpin.length != 6 || _authInProgress) return;

    _authInProgress = true;
    try {
      final valid = await sl<LocalStorageService>().verifyMpin(_mpin);
      if (!mounted) return;

      if (valid) {
        _goHome();
        return;
      }

      await showAuthValidationDialog(
        context,
        message: 'Incorrect mPIN. Please try again.',
      );
      setState(() {
        _mpin = '';
        _mpinInputKey++;
      });
    } finally {
      _authInProgress = false;
    }
  }

  Future<void> _switchUser() async {
    await sl<LocalStorageService>().clearSession();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const RegistrationPage()),
      (_) => false,
    );
  }

  void _goToPasswordLogin() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    final greetingName = _userName ?? 'User';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.authBackground,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                const Center(child: RailOneLogo(height: 44)),
                const SizedBox(height: 80),
                const Text(
                  'Login using mPIN',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.authPrimaryDark,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Welcome $greetingName!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: AppColors.bodyText,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Enter mPIN below',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.authHint,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 28),
                MpinInputRow(
                  key: ValueKey(_mpinInputKey),
                  onCompleted: _onMpinCompleted,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    TextButton(
                      onPressed: _goToPasswordLogin,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.authPrimaryDark,
                        ),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Reset mPIN?',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.authPrimaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const _DottedDividerLabel(label: 'Or login using biometric'),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        _BiometricIconButton(
                          imageAsset: 'assets/images/Face_ID_logo.png',
                          onTap: _loginWithBiometric,
                        ),
                        const SizedBox(width: 16),
                        _BiometricIconButton(
                          icon: Icons.fingerprint_rounded,
                          onTap: _loginWithBiometric,
                        ),
                      ],
                    ),
                    const Spacer(),
                    _MpinLoginButton(onPressed: () => _loginWithBiometric()),
                  ],
                ),
                const SizedBox(height: 36),
                Center(
                  child: TextButton(
                    onPressed: _switchUser,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Different User?',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.authPrimaryDark,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DottedDividerLabel extends StatelessWidget {
  const _DottedDividerLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: _DottedLine()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.authHint,
            ),
          ),
        ),
        const Expanded(child: _DottedLine()),
      ],
    );
  }
}

class _DottedLine extends StatelessWidget {
  const _DottedLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: AppColors.authHint.withValues(alpha: 0.5),
    );
  }
}

class _BiometricIconButton extends StatelessWidget {
  const _BiometricIconButton({required this.onTap, this.icon, this.imageAsset})
    : assert(icon != null || imageAsset != null);

  final VoidCallback onTap;
  final IconData? icon;
  final String? imageAsset;

  static const _size = 36.0;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: _size,
          height: _size,
          child: imageAsset != null
              ? Image.asset(
                  imageAsset!,
                  width: _size,
                  height: _size,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.face_retouching_natural_outlined,
                    size: _size,
                    color: AppColors.authFieldIcon,
                  ),
                )
              : Icon(icon, size: _size, color: AppColors.authFieldIcon),
        ),
      ),
    );
  }
}

class _MpinLoginButton extends StatelessWidget {
  const _MpinLoginButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        customBorder: const StadiumBorder(),
        splashColor: AppColors.authPrimary.withValues(alpha: 0.12),
        child: Ink(
          decoration: ShapeDecoration(
            color: AppColors.authRegistrationCard,
            shape: StadiumBorder(side: BorderSide(color: AppColors.authLink)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 8),
            child: const Text(
              'Login',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.authLink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
