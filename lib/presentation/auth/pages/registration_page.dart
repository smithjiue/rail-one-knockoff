import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rail_one/core/di/injection.dart';
import 'package:rail_one/core/storage/local_storage_service.dart';
import 'package:rail_one/core/theme/app_colors.dart';
import 'package:rail_one/presentation/auth/pages/login_page.dart';
import 'package:rail_one/presentation/auth/pages/mpin_login_page.dart';
import 'package:rail_one/presentation/home/pages/home_page.dart';
import 'package:rail_one/presentation/home/widgets/home_header.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _mobileController = TextEditingController();
  final _bannerController = PageController();
  int _bannerIndex = 0;

  static const _bannerSlides = [
    _BannerSlide(
      title: 'Get Registered to access',
      highlight: 'Rail Ticket Bookings',
      imagePath: 'assets/images/hindi_my_rail_dashboard.png',
    ),
    _BannerSlide(
      title: 'Book tickets with',
      highlight: 'Indian Railways',
      imagePath: 'assets/images/my_rail_login.png',
    ),
    _BannerSlide(
      title: 'Manage your journey',
      highlight: 'in one place',
      imagePath: 'assets/images/e_ticket.png',
    ),
    _BannerSlide(
      title: 'Secure payments with',
      highlight: 'UTS RWallet',
      imagePath: 'assets/images/r_wallet.png',
    ),
  ];

  @override
  void dispose() {
    _mobileController.dispose();
    _bannerController.dispose();
    super.dispose();
  }

  void _goHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const HomePage()),
    );
  }

  Future<void> _goToLogin() async {
    final hasStoredUser = await sl<LocalStorageService>().hasStoredUser();
    if (!mounted) return;

    final destination = hasStoredUser
        ? const MpinLoginPage()
        : const LoginPage();

    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => destination));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.authBackground,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      const _AuthHeader(),
                      const SizedBox(height: 20),
                      _LoginCard(onLoginTap: _goToLogin),
                      const SizedBox(height: 12),
                      _RegistrationCard(
                        controller: _mobileController,
                        onRegisterTap: () {},
                      ),
                      const SizedBox(height: 20),
                      _FooterLinks(onGuestTap: _goHome),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              _PromoBanner(
                controller: _bannerController,
                slides: _bannerSlides,
                currentIndex: _bannerIndex,
                onPageChanged: (index) => setState(() => _bannerIndex = index),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthHeader extends StatelessWidget {
  const _AuthHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _LanguageButton(onTap: () {}),
        const Expanded(child: Center(child: RailOneLogo())),
        const SizedBox(width: 40),
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

class _LoginCard extends StatelessWidget {
  const _LoginCard({required this.onLoginTap});

  final VoidCallback onLoginTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onLoginTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Registered user ',
                  style: TextStyle(
                    fontFamily: 'NotoSans',
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: AppColors.authPrimaryDark,
                  ),
                ),
                const Text(
                  'Login Here',
                  style: TextStyle(
                    fontFamily: 'NotoSans',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.authLink,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: AppColors.authLink,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RegistrationCard extends StatelessWidget {
  const _RegistrationCard({
    required this.controller,
    required this.onRegisterTap,
  });

  final TextEditingController controller;
  final VoidCallback onRegisterTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.authRegistrationCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'New User Registration',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'NotoSans',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.authPrimaryDark,
            ),
          ),
          const SizedBox(height: 16),
          _MobileNumberField(
            controller: controller,
            onRegisterTap: onRegisterTap,
          ),
          const SizedBox(height: 20),
          const Text(
            'Or Register with',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'NotoSans',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.authLink,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SocialRegisterButton(
                label: 'Rail Connect',
                imagePath: 'assets/images/IR_logo_blue.png',
              ),
              const SizedBox(width: 40),
              _SocialRegisterButton(
                label: 'UTS',
                imagePath: 'assets/images/uts.png',
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'To use your existing UTS RWallet, Please use same mobile number '
            'as being used in UTS Mobile App',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'NotoSans',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.authPrimaryDark,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileNumberField extends StatelessWidget {
  const _MobileNumberField({
    required this.controller,
    required this.onRegisterTap,
  });

  final TextEditingController controller;
  final VoidCallback onRegisterTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.only(left: 16, right: 6),
      child: Row(
        children: [
          Icon(Icons.phone_outlined, size: 22, color: AppColors.authHint),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 10,
              style: const TextStyle(
                fontFamily: 'NotoSans',
                fontSize: 14,
                color: AppColors.authPrimaryDark,
              ),
              decoration: const InputDecoration(
                counterText: '',
                hintText: 'Mobile Number',
                hintStyle: TextStyle(
                  fontFamily: 'NotoSans',
                  fontSize: 14,
                  color: AppColors.authHint,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          Material(
            color: AppColors.authRegisterButton,
            borderRadius: BorderRadius.circular(22),
            child: InkWell(
              onTap: onRegisterTap,
              borderRadius: BorderRadius.circular(22),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                child: const Text(
                  'Register',
                  style: TextStyle(
                    fontFamily: 'NotoSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.authPrimaryDark,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialRegisterButton extends StatelessWidget {
  const _SocialRegisterButton({required this.label, required this.imagePath});

  final String label;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.white,
          shape: const CircleBorder(),
          elevation: 0,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {},
            child: Container(
              width: 56,
              height: 56,
              padding: const EdgeInsets.all(8),
              child: ClipOval(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.train_rounded,
                    color: AppColors.authPrimary.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'NotoSans',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.bodyText,
          ),
        ),
      ],
    );
  }
}

class _FooterLinks extends StatelessWidget {
  const _FooterLinks({required this.onGuestTap});

  final VoidCallback onGuestTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _LinkRichText(
          prefix: 'By continuing, you agree to our ',
          links: [
            _InlineLink(label: 'Terms Of Use'),
            _InlineLink(label: ' & ', isPlain: true),
            _InlineLink(label: 'Privacy Policy'),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onGuestTap,
          child: _LinkRichText(
            prefix: 'Login as ',
            links: const [_InlineLink(label: 'Guest', bold: true)],
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Help & Support',
            style: TextStyle(
              fontFamily: 'NotoSans',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.authLink,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.authLink,
            ),
          ),
        ),
      ],
    );
  }
}

class _InlineLink {
  const _InlineLink({
    required this.label,
    this.bold = false,
    this.isPlain = false,
  });

  final String label;
  final bool bold;
  final bool isPlain;
}

class _LinkRichText extends StatelessWidget {
  const _LinkRichText({required this.prefix, required this.links});

  final String prefix;
  final List<_InlineLink> links;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: const TextStyle(
          fontFamily: 'NotoSans',
          fontSize: 10,
          fontWeight: FontWeight.w400,
          color: AppColors.authPrimaryDark,
          height: 1.4,
        ),
        children: [
          TextSpan(text: prefix),
          for (final link in links)
            TextSpan(
              text: link.label,
              style: TextStyle(
                fontFamily: 'NotoSans',
                fontSize: 10,
                fontWeight: link.bold ? FontWeight.w700 : FontWeight.w600,
                color: link.isPlain
                    ? AppColors.authPrimaryDark
                    : AppColors.authLink,
                decoration: link.isPlain
                    ? TextDecoration.none
                    : TextDecoration.underline,
                decorationColor: AppColors.authLink,
              ),
            ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _BannerSlide {
  const _BannerSlide({
    required this.title,
    required this.highlight,
    required this.imagePath,
  });

  final String title;
  final String highlight;
  final String imagePath;
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner({
    required this.controller,
    required this.slides,
    required this.currentIndex,
    required this.onPageChanged,
  });

  final PageController controller;
  final List<_BannerSlide> slides;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SizedBox(
            height: 100,
            child: PageView.builder(
              controller: controller,
              onPageChanged: onPageChanged,
              itemCount: slides.length,
              itemBuilder: (context, index) {
                final slide = slides[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                  decoration: BoxDecoration(
                    color: AppColors.authBannerBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontFamily: 'NotoSans',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.authPrimaryDark,
                              height: 1.35,
                            ),
                            children: [
                              TextSpan(text: '${slide.title} '),
                              TextSpan(
                                text: slide.highlight,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          slide.imagePath,
                          width: 88,
                          height: 76,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.confirmation_number_outlined,
                            size: 48,
                            color: AppColors.authPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(slides.length, (index) {
              final active = index == currentIndex;
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active ? AppColors.authPrimary : Colors.transparent,
                  border: Border.all(color: AppColors.authPrimary, width: 1.5),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
