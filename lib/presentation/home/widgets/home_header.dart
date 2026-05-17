import 'package:flutter/material.dart';
import 'package:rail_one/core/di/injection.dart';
import 'package:rail_one/core/storage/local_storage_service.dart';
import 'package:rail_one/core/theme/app_colors.dart';

class HomeHeader extends StatefulWidget {
  const HomeHeader({super.key});

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  String? _userName;

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
      () => _userName = trimmed != null && trimmed.isNotEmpty ? trimmed : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _LanguageButton(onTap: () {}),
              const Expanded(child: Center(child: RailOneLogo())),
              _NotificationButton(onTap: () {}),
            ],
          ),
          if (_userName != null) ...[
            const SizedBox(height: 20),
            Text(
              'Hi, $_userName!',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.greeting,
                height: 1.2,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class RailOneLogo extends StatelessWidget {
  const RailOneLogo({super.key, this.useTextLogo = false, this.height});

  /// Wordmark image for auth screens; default is the compact icon mark.
  final bool useTextLogo;
  final double? height;

  static const _iconPath = 'assets/icons/rail-one-logo.png';
  static const _textPath = 'assets/images/railone_text_logo.png';

  @override
  Widget build(BuildContext context) {
    final logoHeight = height ?? (useTextLogo ? 40.0 : 32.0);
    return Image.asset(
      useTextLogo ? _textPath : _iconPath,
      height: logoHeight,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      errorBuilder: (_, __, ___) => const Text(
        'RailOne',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.logoDark,
        ),
      ),
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
                border: Border.all(color: AppColors.borderLight),
              ),
              alignment: Alignment.center,
              child: const Text(
                'A | अ',
                style: TextStyle(
                  fontFamily: 'NotoSans',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.heading,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Image.asset(
              'assets/icons/icons8-notification-bell.gif',
              width: 22,
              height: 22,
              fit: BoxFit.contain,
              gaplessPlayback: true,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.notifications_none_rounded,
                size: 22,
                color: AppColors.heading,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
