import 'package:flutter/material.dart';
import 'package:rail_one/core/di/injection.dart';
import 'package:rail_one/core/storage/local_storage_service.dart';
import 'package:rail_one/core/theme/app_colors.dart';
import 'package:rail_one/presentation/auth/pages/create_account_page.dart';
import 'package:rail_one/presentation/auth/widgets/auth_page_header.dart';
import 'package:rail_one/presentation/auth/widgets/auth_text_field.dart';
import 'package:rail_one/presentation/auth/widgets/auth_validation_dialog.dart';
import 'package:rail_one/presentation/auth/widgets/slide_captcha.dart';
import 'package:rail_one/presentation/home/pages/home_page.dart';

enum _LoginMethod { mPin, password }

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  _LoginMethod _method = _LoginMethod.password;
  final _userIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _loginInProgress = false;
  int _captchaSeed = 0;

  @override
  void dispose() {
    _userIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _refreshCaptcha() => setState(() => _captchaSeed++);

  Future<void> _onCaptchaMismatch() async {
    setState(() => _captchaSeed++);
    await showAuthValidationDialog(context, message: 'Captcha Not Matched');
  }

  void _goHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const HomePage()),
    );
  }

  Future<void> _onPasswordLogin() async {
    if (_loginInProgress) return;

    _loginInProgress = true;
    try {
      final error = await sl<LocalStorageService>().loginWithPassword(
        identifier: _userIdController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;

      if (error == null) {
        _goHome();
        return;
      }

      setState(() => _captchaSeed++);
      await showAuthValidationDialog(context, message: error);
    } finally {
      _loginInProgress = false;
    }
  }

  void _goToCreateAccount() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const CreateAccountPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.authBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    AuthPageHeader(
                      onBack: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(height: 28),
                    _LoginMethodToggle(
                      method: _method,
                      onChanged: (method) => setState(() => _method = method),
                    ),
                    const SizedBox(height: 24),
                    if (_method == _LoginMethod.mPin) ...[
                      AuthTextField(
                        controller: _userIdController,
                        hint: 'User ID /Mobile Number',
                        prefixIcon: Icons.person_outline_rounded,
                        prefixIconColor: AppColors.authFieldIcon,
                        keyboardType: TextInputType.text,
                      ),
                      const SizedBox(height: 24),
                      _ProceedButton(onPressed: _goHome),
                      const SizedBox(height: 40),
                    ] else ...[
                      AuthTextField(
                        controller: _userIdController,
                        hint: 'User ID /Mobile Number',
                        prefixIcon: Icons.person_outline_rounded,
                        prefixIconColor: AppColors.authFieldIcon,
                        keyboardType: TextInputType.text,
                      ),
                      const SizedBox(height: 14),
                      AuthTextField(
                        controller: _passwordController,
                        hint: 'Password',
                        prefixIcon: Icons.lock_outline_rounded,
                        prefixIconColor: AppColors.authFieldIcon,
                        obscureText: _obscurePassword,
                        suffix: AuthTextField.visibilityToggle(
                          obscured: _obscurePassword,
                          filled: false,
                          iconColor: AppColors.authFieldIcon,
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontFamily: 'NotoSans',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.authLink,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      const SlideMatchLabel(actionText: 'Sign In'),
                      const SizedBox(height: 14),
                      SlideCaptcha(
                        key: ValueKey(_captchaSeed),
                        onMatched: _onPasswordLogin,
                        onMismatch: _onCaptchaMismatch,
                      ),
                      const SizedBox(height: 12),
                      CaptchaActionRow(onRefresh: _refreshCaptcha),
                      const SizedBox(height: 32),
                    ],
                    GestureDetector(
                      onTap: _goToCreateAccount,
                      child: Text.rich(
                        TextSpan(
                          style: const TextStyle(
                            fontFamily: 'NotoSans',
                            fontSize: 14,
                            color: AppColors.authPrimaryDark,
                          ),
                          children: const [
                            TextSpan(text: "Don't have an account? "),
                            TextSpan(
                              text: 'Sign Up',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.authLink,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            if (_method == _LoginMethod.password)
              const ColoredBox(
                color: AppColors.authPrimary,
                child: SizedBox(width: double.infinity, height: 6),
              ),
          ],
        ),
      ),
    );
  }
}

class _LoginMethodToggle extends StatelessWidget {
  const _LoginMethodToggle({required this.method, required this.onChanged});

  final _LoginMethod method;
  final ValueChanged<_LoginMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Login with',
          style: TextStyle(
            fontFamily: 'NotoSans',
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.authPrimaryDark,
          ),
        ),
        const Spacer(),
        _MethodChip(
          label: 'mPIN',
          selected: method == _LoginMethod.mPin,
          onTap: () => onChanged(_LoginMethod.mPin),
        ),
        const SizedBox(width: 8),
        _MethodChip(
          label: 'Password',
          selected: method == _LoginMethod.password,
          onTap: () => onChanged(_LoginMethod.password),
        ),
      ],
    );
  }
}

class _ProceedButton extends StatelessWidget {
  const _ProceedButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.authPrimary,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          child: const Text(
            'Proceed',
            style: TextStyle(
              fontFamily: 'NotoSans',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _MethodChip extends StatelessWidget {
  const _MethodChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.authPrimary : Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'NotoSans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.bodyText,
            ),
          ),
        ),
      ),
    );
  }
}
