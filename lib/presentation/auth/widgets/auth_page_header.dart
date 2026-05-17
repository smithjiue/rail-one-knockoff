import 'package:flutter/material.dart';
import 'package:rail_one/core/theme/app_colors.dart';
import 'package:rail_one/presentation/home/widgets/home_header.dart';

class AuthPageHeader extends StatelessWidget {
  const AuthPageHeader({
    super.key,
    required this.onBack,
    this.showLanguage = false,
    this.onLanguageTap,
  });

  final VoidCallback onBack;
  final bool showLanguage;
  final VoidCallback? onLanguageTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Material(
            color: Colors.white,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onBack,
              customBorder: const CircleBorder(),
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20,
                  color: AppColors.authPrimary,
                ),
              ),
            ),
          ),
        ),
        const RailOneLogo(),
        if (showLanguage)
          Align(
            alignment: Alignment.centerRight,
            child: _LanguageButton(onTap: onLanguageTap ?? () {}),
          )
        else
          const SizedBox(width: 44),
      ],
    );
  }
}

class _LanguageButton extends StatelessWidget {
  const _LanguageButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: ClipOval(
          child: Image.asset(
            'assets/icons/language_icon.png',
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: AppColors.borderLight),
              ),
              alignment: Alignment.center,
              child: const Text(
                'A | अ',
                style: TextStyle(
                  fontFamily: 'NotoSans',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.authPrimaryDark,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
