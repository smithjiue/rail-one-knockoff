import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rail_one/core/di/injection.dart';
import 'package:rail_one/core/storage/local_storage_service.dart';
import 'package:rail_one/core/theme/app_colors.dart';
import 'package:rail_one/presentation/home/pages/my_bookings_page.dart';
import 'package:rail_one/presentation/home/widgets/home_bottom_nav.dart';
import 'package:rail_one/presentation/home/widgets/menu_side_sheet.dart';

class YouPage extends StatefulWidget {
  const YouPage({super.key});

  @override
  State<YouPage> createState() => _YouPageState();
}

class _YouPageState extends State<YouPage> {
  final _storage = sl<LocalStorageService>();

  String _displayName = '';
  String _userId = '';
  String _mobile = '';
  String _email = '';
  double _walletBalance = 0;
  bool _biometricEnabled = false;
  int _profileCompletePercent = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final name = await _storage.getRegisteredName();
    final userId = await _storage.getRegisteredUserId();
    final mobile = await _storage.getRegisteredMobile();
    final email = await _storage.getRegisteredEmail();
    final profile = await _storage.getUserProfile();
    final wallet = await _storage.getRWalletBalance();
    final biometric = await _storage.isBiometricLoginEnabled();

    final resolvedName =
        _firstNonEmpty(name, profile?.displayName) ?? 'Guest User';
    final resolvedUserId = _firstNonEmpty(userId, profile?.id) ?? '';
    final resolvedMobile = _firstNonEmpty(mobile, profile?.mobile) ?? '';
    final resolvedEmail = _firstNonEmpty(email, profile?.email) ?? '';

    if (!mounted) return;
    setState(() {
      _displayName = resolvedName;
      _userId = resolvedUserId;
      _mobile = resolvedMobile;
      _email = resolvedEmail;
      _walletBalance = wallet;
      _biometricEnabled = biometric;
      _profileCompletePercent = _calculateProfileComplete(
        name: resolvedName,
        userId: resolvedUserId,
        mobile: resolvedMobile,
        email: resolvedEmail,
      );
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

  int _calculateProfileComplete({
    required String name,
    required String userId,
    required String mobile,
    required String email,
  }) {
    final fields = [name, userId, mobile, email];
    final filled = fields
        .where((value) => value.trim().isNotEmpty && value != 'Guest User')
        .length;
    if (filled == 0) return 0;
    return ((filled / fields.length) * 100).round();
  }

  void _showProfileDetails({required bool editable}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.paddingOf(context).bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                editable ? 'Edit Details' : 'View Details',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.heading,
                ),
              ),
              const SizedBox(height: 16),
              _detailRow('Name', _displayName),
              _detailRow('User ID', _userId.isEmpty ? '—' : _userId),
              _detailRow('Mobile', _mobile.isEmpty ? '—' : _mobile),
              _detailRow('Email', _email.isEmpty ? '—' : _email),
              if (editable) ...[
                const SizedBox(height: 12),
                Text(
                  'Profile editing will be available in a future update.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: AppColors.logoMuted.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              color: AppColors.logoMuted,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.heading,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleBiometric(bool value) async {
    await _storage.setBiometricLoginEnabled(value);
    if (!mounted) return;
    setState(() => _biometricEnabled = value);
  }

  void _onBottomNavTap(int index) {
    if (index == 0) {
      Navigator.of(context).pop();
      return;
    }
    if (index == 1) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const MyBookingsPage()));
      return;
    }
    if (index == 2) return;
    if (index == 3) {
      MenuSideSheet.show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _ProfileHeader(
                              displayName: _displayName,
                              walletBalance: _walletBalance,
                              onViewDetails: () =>
                                  _showProfileDetails(editable: false),
                              onEditDetails: () =>
                                  _showProfileDetails(editable: true),
                              onRefreshWallet: _loadProfile,
                            ),
                            _ProfileCompleteCard(
                              percent: _profileCompletePercent,
                            ),
                            const SizedBox(height: 16),
                            _ActionGrid(
                              biometricEnabled: _biometricEnabled,
                              onBiometricChanged: _toggleBiometric,
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
              ),
              HomeBottomNav(currentIndex: 2, onTap: _onBottomNavTap),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.displayName,
    required this.walletBalance,
    required this.onViewDetails,
    required this.onEditDetails,
    required this.onRefreshWallet,
  });

  final String displayName;
  final double walletBalance;
  final VoidCallback onViewDetails;
  final VoidCallback onEditDetails;
  final VoidCallback onRefreshWallet;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.authRegistrationCard,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: AppColors.borderLight),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              size: 40,
              color: AppColors.authFieldIcon,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            displayName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.heading,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _HeaderLink(
                icon: Icons.visibility_outlined,
                label: 'View Details',
                onTap: onViewDetails,
              ),
              Container(
                width: 1,
                height: 14,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                color: AppColors.borderLight,
              ),
              _HeaderLink(
                icon: Icons.edit_outlined,
                label: 'Edit Details',
                onTap: onEditDetails,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            elevation: 1,
            shadowColor: Colors.black.withValues(alpha: 0.08),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/r_wallet_icon.svg',
                    width: 28,
                    height: 24,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'R-Wallet',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.heading,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '₹ ${walletBalance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.heading,
                    ),
                  ),
                  const Spacer(),
                  Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: onRefreshWallet,
                      customBorder: const CircleBorder(),
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(
                          Icons.refresh_rounded,
                          size: 22,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(20),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        child: Text(
                          'Add',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
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
        ],
      ),
    );
  }
}

class _HeaderLink extends StatelessWidget {
  const _HeaderLink({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCompleteCard extends StatelessWidget {
  const _ProfileCompleteCard({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile Complete',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.heading,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: percent / 100,
                    minHeight: 8,
                    backgroundColor: AppColors.borderLight,
                    color: AppColors.unreservedGreen,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$percent%',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.heading,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionGrid extends StatelessWidget {
  const _ActionGrid({
    required this.biometricEnabled,
    required this.onBiometricChanged,
  });

  final bool biometricEnabled;
  final ValueChanged<bool> onBiometricChanged;

  static const _items = <_ActionItem>[
    _ActionItem(
      label: 'Change\nPassword',
      icon: Icons.lock_outline_rounded,
      color: AppColors.offeringBlue,
    ),
    _ActionItem(
      label: 'My\nAccount',
      icon: Icons.credit_card_outlined,
      color: AppColors.offeringGreen,
    ),
    _ActionItem(
      label: 'Biometric',
      icon: Icons.fingerprint_rounded,
      color: AppColors.offeringRose,
      isBiometric: true,
    ),
    _ActionItem(
      label: 'Transfer\nTicket',
      icon: Icons.swap_horiz_rounded,
      color: AppColors.offeringBlue,
    ),
    _ActionItem(
      label: 'My\nTransaction',
      icon: Icons.receipt_long_outlined,
      color: AppColors.offeringYellow,
    ),
    _ActionItem(
      label: 'Link Your\nAadhar',
      icon: Icons.badge_outlined,
      color: AppColors.offeringGrey,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.95,
        ),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return _ActionTile(
            label: item.label,
            icon: item.icon,
            backgroundColor: item.color,
            isBiometric: item.isBiometric,
            biometricEnabled: biometricEnabled,
            onBiometricChanged: onBiometricChanged,
          );
        },
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    this.isBiometric = false,
    this.biometricEnabled = false,
    this.onBiometricChanged,
  });

  final String label;
  final IconData icon;
  final Color backgroundColor;
  final bool isBiometric;
  final bool biometricEnabled;
  final ValueChanged<bool>? onBiometricChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: isBiometric ? null : () {},
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 28,
                color: AppColors.heading.withValues(alpha: 0.75),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  color: AppColors.heading,
                ),
              ),
              if (isBiometric) ...[
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.scale(
                      scale: 0.75,
                      child: Switch(
                        value: biometricEnabled,
                        onChanged: onBiometricChanged,
                        activeThumbColor: Colors.white,
                        activeTrackColor: AppColors.primary,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    Text(
                      biometricEnabled ? 'On' : 'Off',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionItem {
  const _ActionItem({
    required this.label,
    required this.icon,
    required this.color,
    this.isBiometric = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool isBiometric;
}
