import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rail_one/core/theme/app_colors.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
    this.inputFormatters,
    this.prefix,
    this.prefixIconColor = AppColors.authFieldIcon,
    this.hasError = false,
  });

  static const _fieldHeight = 44.0;

  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final Color prefixIconColor;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefix;
  final bool hasError;

  static Widget visibilityToggle({
    required bool obscured,
    required VoidCallback onPressed,
    Color iconColor = AppColors.authFieldIcon,
    bool filled = true,
  }) {
    final icon = filled
        ? (obscured
            ? Icons.visibility_off_rounded
            : Icons.visibility_rounded)
        : (obscured
            ? Icons.visibility_off_outlined
            : Icons.visibility_outlined);

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 20, color: iconColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _fieldHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: hasError ? AppColors.authError : AppColors.authRegisterButton,
          width: hasError ? 1.5 : 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (prefix != null) ...[
            prefix!,
            const SizedBox(width: 4),
          ] else ...[
            Icon(prefixIcon, size: 20, color: prefixIconColor),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscureText,
              inputFormatters: inputFormatters,
              textAlignVertical: TextAlignVertical.center,
              style: const TextStyle(
                fontFamily: 'NotoSans',
                fontSize: 12,
                color: AppColors.authPrimaryDark,
                height: 1.0,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  fontFamily: 'NotoSans',
                  fontSize: 12,
                  color: AppColors.authHint,
                  height: 1.0,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (suffix != null) suffix!,
        ],
      ),
    );
  }
}
