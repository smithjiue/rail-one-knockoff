import 'package:flutter/material.dart';
import 'package:rail_one/core/theme/app_colors.dart';

class FollowUsSection extends StatelessWidget {
  const FollowUsSection({super.key});

  static const _horizontalPadding = 8.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        _horizontalPadding,
        24,
        _horizontalPadding,
        24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Follow Us On Social Media Platforms',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: SizedBox(
              height: 140,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/hubbulli_railway.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.heading,
                    ),
                  ),
                  Container(
                    color: Colors.black.withValues(alpha: 0.25),
                  ),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _SocialIcon.twitter(),
                        const SizedBox(width: 16),
                        _SocialIcon.facebook(),
                        const SizedBox(width: 16),
                        _SocialIcon.instagram(),
                        const SizedBox(width: 16),
                        _SocialIcon.youtube(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  const _SocialIcon._({required this.child});

  final Widget child;

  factory _SocialIcon.twitter() {
    return _SocialIcon._(
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Text(
          '𝕏',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  factory _SocialIcon.facebook() {
    return _SocialIcon._(
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Color(0xFF1877F2),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Text(
          'f',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            fontFamily: 'Arial',
          ),
        ),
      ),
    );
  }

  factory _SocialIcon.instagram() {
    return _SocialIcon._(
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(
            colors: [
              Color(0xFFF58529),
              Color(0xFFDD2A7B),
              Color(0xFF8134AF),
            ],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.camera_alt_outlined,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }

  factory _SocialIcon.youtube() {
    return _SocialIcon._(
      child: Container(
        width: 48,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xFFFF0000),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.play_arrow_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        customBorder: const CircleBorder(),
        child: child,
      ),
    );
  }
}
