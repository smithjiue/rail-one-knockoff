import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rail_one/core/di/injection.dart';
import 'package:rail_one/core/storage/local_storage_service.dart';
import 'package:rail_one/core/theme/app_colors.dart';
import 'package:rail_one/presentation/auth/widgets/auth_page_header.dart';
import 'package:rail_one/presentation/auth/widgets/auth_text_field.dart';
import 'package:rail_one/presentation/auth/widgets/auth_validation_dialog.dart';
import 'package:rail_one/presentation/auth/widgets/slide_captcha.dart';
import 'package:rail_one/presentation/home/pages/home_page.dart';

enum _SignUpField { name, mobile, email, userId, password, confirmPassword }

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _userIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  int _captchaSeed = 0;
  Set<_SignUpField> _invalidFields = {};

  static final _namePattern = RegExp(r"^[a-zA-Z\s'.-]{2,}$");
  static final _emailPattern = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  static final _userIdPattern = RegExp(r'^[a-zA-Z0-9_]{4,20}$');

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => _clearFieldError(_SignUpField.name));
    _mobileController.addListener(() => _clearFieldError(_SignUpField.mobile));
    _emailController.addListener(() => _clearFieldError(_SignUpField.email));
    _userIdController.addListener(() => _clearFieldError(_SignUpField.userId));
    _passwordController.addListener(
      () => _clearFieldError(_SignUpField.password),
    );
    _confirmPasswordController.addListener(
      () => _clearFieldError(_SignUpField.confirmPassword),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _userIdController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _clearFieldError(_SignUpField field) {
    if (!_invalidFields.contains(field)) return;
    setState(() => _invalidFields = {..._invalidFields}..remove(field));
  }

  void _refreshCaptcha() => setState(() => _captchaSeed++);

  void _goHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const HomePage()),
    );
  }

  Future<void> _saveCredentialsAndGoHome() async {
    try {
      await sl<LocalStorageService>().saveRegisteredUser(
        name: _nameController.text.trim(),
        mobile: _mobileController.text.trim(),
        email: _emailController.text.trim(),
        userId: _userIdController.text.trim(),
        password: _passwordController.text,
      );
    } catch (_) {
      if (!mounted) return;
      await showAuthValidationDialog(
        context,
        message: 'Failed to save account. Please try again.',
      );
      return;
    }
    if (!mounted) return;
    _goHome();
  }

  _ValidationResult _validateForm() {
    final invalid = <_SignUpField>{};
    String? message;

    final name = _nameController.text.trim();
    if (name.isEmpty || !_namePattern.hasMatch(name)) {
      invalid.add(_SignUpField.name);
      message ??= 'Please enter valid name';
    }

    final mobile = _mobileController.text.trim();
    if (!RegExp(r'^\d{10}$').hasMatch(mobile)) {
      invalid.add(_SignUpField.mobile);
      message ??= 'Please enter valid mobile number';
    }

    final email = _emailController.text.trim();
    if (email.isEmpty || !_emailPattern.hasMatch(email)) {
      invalid.add(_SignUpField.email);
      message ??= 'Please enter valid email';
    }

    final userId = _userIdController.text.trim();
    if (userId.isEmpty || !_userIdPattern.hasMatch(userId)) {
      invalid.add(_SignUpField.userId);
      message ??= 'Please enter valid user ID';
    }

    final password = _passwordController.text;
    if (password.length < 6) {
      invalid.add(_SignUpField.password);
      message ??= 'Please enter valid password';
    }

    final confirmPassword = _confirmPasswordController.text;
    if (confirmPassword != password) {
      invalid.add(_SignUpField.confirmPassword);
      message ??= 'Passwords & Confirm Password mismatch';
    }

    return _ValidationResult(
      isValid: invalid.isEmpty,
      invalidFields: invalid,
      message: message ?? 'Please check your details',
    );
  }

  Future<void> _onCaptchaMismatch() async {
    setState(() => _captchaSeed++);
    await showAuthValidationDialog(context, message: 'Captcha Not Matched');
  }

  Future<void> _onCaptchaMatched() async {
    final result = _validateForm();
    if (!result.isValid) {
      setState(() {
        _invalidFields = result.invalidFields;
        _captchaSeed++;
      });
      await showAuthValidationDialog(context, message: result.message);
      return;
    }
    await _saveCredentialsAndGoHome();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.authBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              AuthPageHeader(
                onBack: () => Navigator.of(context).maybePop(),
                showLanguage: true,
              ),
              const SizedBox(height: 24),
              const Text(
                'Create Account',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.authPrimaryDark,
                ),
              ),
              const SizedBox(height: 20),
              AuthTextField(
                controller: _nameController,
                hint: 'Name*',
                prefixIcon: Icons.person_rounded,
                hasError: _invalidFields.contains(_SignUpField.name),
              ),
              const SizedBox(height: 12),
              _MobileField(
                controller: _mobileController,
                hasError: _invalidFields.contains(_SignUpField.mobile),
              ),
              const SizedBox(height: 12),
              AuthTextField(
                controller: _emailController,
                hint: 'Email*',
                prefixIcon: Icons.mail_rounded,
                keyboardType: TextInputType.emailAddress,
                hasError: _invalidFields.contains(_SignUpField.email),
              ),
              const SizedBox(height: 12),
              AuthTextField(
                controller: _userIdController,
                hint: 'User ID *',
                prefixIcon: Icons.badge_rounded,
                hasError: _invalidFields.contains(_SignUpField.userId),
              ),
              const SizedBox(height: 12),
              AuthTextField(
                controller: _passwordController,
                hint: 'Password*',
                prefixIcon: Icons.lock_rounded,
                obscureText: _obscurePassword,
                hasError: _invalidFields.contains(_SignUpField.password),
                suffix: AuthTextField.visibilityToggle(
                  obscured: _obscurePassword,
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 12),
              AuthTextField(
                controller: _confirmPasswordController,
                hint: 'Confirm Password*',
                prefixIcon: Icons.lock_rounded,
                obscureText: _obscureConfirmPassword,
                hasError: _invalidFields.contains(_SignUpField.confirmPassword),
                suffix: AuthTextField.visibilityToggle(
                  obscured: _obscureConfirmPassword,
                  onPressed: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const SlideMatchLabel(actionText: 'Sign Up'),
              const SizedBox(height: 10),
              SlideCaptcha(
                key: ValueKey(_captchaSeed),
                onMatched: _onCaptchaMatched,
                onMismatch: _onCaptchaMismatch,
              ),
              const SizedBox(height: 18),
              CaptchaActionRow(
                onRefresh: _refreshCaptcha,
                showAudio: true,
                onAudio: () {},
              ),
              const SizedBox(height: 28),
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                child: Text.rich(
                  TextSpan(
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.authPrimaryDark,
                    ),
                    children: const [
                      TextSpan(text: 'Already have an account? '),
                      TextSpan(
                        text: 'Sign In',
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
              const SizedBox(height: 14),
              Text.rich(
                TextSpan(
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: AppColors.authFieldIcon,
                  ),
                  children: const [
                    TextSpan(text: 'By continuing, you agree to our '),
                    TextSpan(
                      text: 'Terms Of Use',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppColors.authLink,
                        decorationColor: AppColors.authLink,
                      ),
                    ),
                    TextSpan(text: ' & '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppColors.authLink,
                        decorationColor: AppColors.authLink,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ValidationResult {
  const _ValidationResult({
    required this.isValid,
    required this.invalidFields,
    required this.message,
  });

  final bool isValid;
  final Set<_SignUpField> invalidFields;
  final String message;
}

class _MobileField extends StatelessWidget {
  const _MobileField({required this.controller, this.hasError = false});

  final TextEditingController controller;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return AuthTextField(
      controller: controller,
      hint: 'Mobile*',
      prefixIcon: Icons.phone_rounded,
      keyboardType: TextInputType.phone,
      hasError: hasError,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      prefix: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.phone_rounded, size: 20, color: AppColors.authFieldIcon),
          const SizedBox(width: 6),
          const Text(
            '+91',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.authPrimaryDark,
            ),
          ),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 20,
            color: AppColors.authFieldIcon,
          ),
        ],
      ),
    );
  }
}
