import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rail_one/core/di/injection.dart';
import 'package:rail_one/core/storage/local_storage_service.dart';
import 'package:rail_one/core/theme/app_colors.dart';
import 'package:rail_one/presentation/auth/pages/mpin_login_page.dart';

class MenuSideSheet {
  MenuSideSheet._();

  static const _appVersion = 'V-2.1.56-223';

  static Future<void> show(BuildContext context) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Menu',
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerRight,
          child: _MenuSideSheetPanel(
            onClose: () => Navigator.of(context).pop(),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        );
      },
    );
  }
}

class _MenuSideSheetPanel extends StatefulWidget {
  const _MenuSideSheetPanel({required this.onClose});

  final VoidCallback onClose;

  @override
  State<_MenuSideSheetPanel> createState() => _MenuSideSheetPanelState();
}

class _MenuSideSheetPanelState extends State<_MenuSideSheetPanel> {
  final _storage = sl<LocalStorageService>();

  String _displayName = '';
  double _walletBalance = 0;
  bool _loading = true;

  static const _headerBg = Color(0xFFE8E4F5);
  static const _walletBg = Color(0xFFEDE7F8);
  static const _menuIconColor = Color(0xFF6B5BC8);

  static const _menuItems = [
    _MenuItem(
      label: 'Show/Hide Services',
      icon: Icons.bookmark_outline_rounded,
    ),
    _MenuItem(label: 'FAQs', icon: Icons.forum_outlined),
    _MenuItem(label: 'Help & Support', icon: Icons.support_agent_outlined),
    _MenuItem(label: 'About', icon: Icons.info_outline_rounded),
    _MenuItem(label: 'Rate Us', icon: Icons.thumb_up_outlined),
    _MenuItem(label: 'Share', icon: Icons.share_outlined),
    _MenuItem(label: 'Log Out', icon: Icons.logout_rounded, isLogout: true),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final name = await _storage.getRegisteredName();
    final profile = await _storage.getUserProfile();
    final wallet = await _storage.getRWalletBalance();

    if (!mounted) return;
    setState(() {
      _displayName = _firstNonEmpty(name, profile?.displayName) ?? 'Guest User';
      _walletBalance = wallet;
      _loading = false;
    });
  }

  String? _firstNonEmpty(String? a, String? b) {
    final first = a?.trim();
    if (first != null && first.isNotEmpty) return first;
    final second = b?.trim();
    if (second != null && second.isNotEmpty) return second;
    return null;
  }

  Future<void> _logout() async {
    await _storage.setLoggedIn(false);
    if (!mounted) return;
    widget.onClose();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const MpinLoginPage()),
      (_) => false,
    );
  }

  void _onMenuTap(_MenuItem item) {
    if (item.isLogout) {
      _logout();
      return;
    }
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width * 0.78;

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Container(
          width: width,
          height: double.infinity,
          margin: const EdgeInsets.only(left: 8),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
          ),
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: _headerBg,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.authRegisterButton,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.person_outline_rounded,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                _displayName,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.heading,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: _walletBg,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/images/r_wallet_icon.svg',
                              width: 26,
                              height: 22,
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'R-Wallet',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.heading,
                                  ),
                                ),
                                Text(
                                  '₹ ${_walletBalance.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.heading,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Material(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20),
                              child: InkWell(
                                onTap: () {},
                                borderRadius: BorderRadius.circular(20),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  child: Text(
                                    'Add Money',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
                        itemCount: _menuItems.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 2),
                        itemBuilder: (context, index) {
                          final item = _menuItems[index];
                          return ListTile(
                            onTap: () => _onMenuTap(item),
                            leading: Icon(
                              item.icon,
                              color: _menuIconColor,
                              size: 22,
                            ),
                            title: Text(
                              item.label,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: item.isLogout
                                    ? AppColors.heading
                                    : AppColors.heading,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 0,
                            ),
                            minLeadingWidth: 28,
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Text(
                        MenuSideSheet._appVersion,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: AppColors.logoMuted.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _MenuItem {
  const _MenuItem({
    required this.label,
    required this.icon,
    this.isLogout = false,
  });

  final String label;
  final IconData icon;
  final bool isLogout;
}
