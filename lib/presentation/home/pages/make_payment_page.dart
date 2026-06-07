import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rail_one/core/di/injection.dart';
import 'package:rail_one/core/storage/local_storage_service.dart';
import 'package:rail_one/core/storage/models/stored_booking.dart';
import 'package:rail_one/core/theme/app_colors.dart';
import 'package:rail_one/presentation/home/pages/my_bookings_page.dart';
import 'package:rail_one/presentation/home/widgets/booking_success_dialog.dart';

enum _PaymentMethod { rWallet, upi, other }

class MakePaymentPage extends StatefulWidget {
  const MakePaymentPage({
    super.key,
    required this.routeLabel,
    required this.payAmount,
    required this.bookingDetails,
    this.discountPercent = 3,
  });

  final String routeLabel;
  final double payAmount;
  final TicketBookingDraft bookingDetails;
  final int discountPercent;

  @override
  State<MakePaymentPage> createState() => _MakePaymentPageState();
}

class _MakePaymentPageState extends State<MakePaymentPage> {
  _PaymentMethod? _selectedPaymentMethod;
  bool _reviewExpanded = false;
  bool _isProcessing = false;

  String get _formattedPayAmount => _effectivePayAmount.toStringAsFixed(2);

  double get _discountedAmount =>
      widget.payAmount * (1 - widget.discountPercent / 100.0);

  double get _effectivePayAmount =>
      _selectedPaymentMethod != null ? _discountedAmount : widget.payAmount;

  String get _paymentMethodLabel => switch (_selectedPaymentMethod) {
    _PaymentMethod.upi => 'UPI',
    _PaymentMethod.rWallet => 'R-Wallet',
    _ => 'Other Methods',
  };

  Future<void> _completePayment() async {
    if (_selectedPaymentMethod == null || _isProcessing) return;

    setState(() => _isProcessing = true);
    try {
      await sl<LocalStorageService>().saveBookingFromPayment(
        draft: widget.bookingDetails,
        paidAmount: _effectivePayAmount,
        paymentMethod: _paymentMethodLabel,
      );

      if (!mounted) return;
      await showBookingSuccessDialog(
        context,
        isSeasonTicket: widget.bookingDetails.isSeasonTicket,
      );

      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
      await Navigator.of(
        context,
      ).push<void>(MaterialPageRoute(builder: (_) => const MyBookingsPage()));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _selectPaymentMethod(_PaymentMethod method) {
    setState(() {
      _selectedPaymentMethod = method;
      _reviewExpanded = false;
    });
  }

  Widget _dashedDivider() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 6.0;
        const dashSpace = 4.0;
        final dashCount = (constraints.maxWidth / (dashWidth + dashSpace))
            .floor();
        return Row(
          children: List.generate(dashCount, (index) {
            return Padding(
              padding: EdgeInsets.only(right: dashSpace),
              child: SizedBox(
                width: dashWidth,
                height: 1,
                child: ColoredBox(color: AppColors.borderLight),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildPaymentOptionTile({
    required _PaymentMethod method,
    required Widget child,
    VoidCallback? onTap,
  }) {
    final isSelected = _selectedPaymentMethod == method;

    return Material(
      color: isSelected ? AppColors.authRegistrationCard : Colors.white,
      child: InkWell(
        onTap: onTap ?? () => _selectPaymentMethod(method),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: child,
        ),
      ),
    );
  }

  Widget _buildUpiLogo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: SvgPicture.asset('assets/icons/bhim-icon.svg'),
        ),
        SizedBox(width: 8),
        SvgPicture.asset(
          'assets/icons/upi-icon.svg',
          width: 22,
          height: 22,
          fit: BoxFit.cover,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: AppColors.primary,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.authDialogBg,
        body: Column(
          children: [
            ColoredBox(
              color: AppColors.primary,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Material(
                            color: Colors.transparent,
                            shape: CircleBorder(
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                            child: InkWell(
                              onTap: () => Navigator.of(context).maybePop(),
                              customBorder: const CircleBorder(),
                              child: SizedBox(
                                width: 36,
                                height: 36,
                                child: Icon(
                                  Icons.arrow_back_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Make Payment',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        elevation: 2,
                        shadowColor: Colors.black.withValues(alpha: 0.08),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16, 14, 16, 12),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.routeLabel,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.authPrimaryDark,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'Pay ₹ $_formattedPayAmount',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.authPrimaryDark,
                                    ),
                                  ),
                                ],
                              ),
                              if (_selectedPaymentMethod != null) ...[
                                SizedBox(height: 10),
                                InkWell(
                                  onTap: () => setState(
                                    () => _reviewExpanded = !_reviewExpanded,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 18,
                                        height: 18,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.bolt_rounded,
                                          size: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'Discount Applied: ${widget.discountPercent}%',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      Spacer(),
                                      Text(
                                        'Review',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.bodyText,
                                        ),
                                      ),
                                      Icon(
                                        _reviewExpanded
                                            ? Icons.keyboard_arrow_up_rounded
                                            : Icons.keyboard_arrow_down_rounded,
                                        size: 20,
                                        color: AppColors.bodyText,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              if (_selectedPaymentMethod != null &&
                                  _reviewExpanded) ...[
                                SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Original fare ₹ ${widget.payAmount.toStringAsFixed(2)}. '
                                    '${widget.discountPercent}% discount saves '
                                    '₹ ${(widget.payAmount - _discountedAmount).toStringAsFixed(2)}.',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.authHint,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    children: [
                      _buildPaymentOptionTile(
                        method: _PaymentMethod.rWallet,
                        child: Row(
                          children: [
                            ClipOval(
                              child: Image.asset(
                                'assets/images/IR_logo_blue.png',
                                width: 36,
                                height: 36,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 36,
                                  height: 36,
                                  color: AppColors.authRegistrationCard,
                                  child: Icon(
                                    Icons.account_balance_wallet_outlined,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'R-Wallet',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.authHint,
                                    ),
                                  ),
                                  Text(
                                    '₹ 0.00',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1B7F4E),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Insufficient Balance',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.authError,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {},
                                  child: Text(
                                    '+ Add Money',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: _dashedDivider(),
                      ),
                      _buildPaymentOptionTile(
                        method: _PaymentMethod.upi,
                        child: Row(
                          children: [
                            _buildUpiLogo(),
                            Spacer(),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.authHint,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: _dashedDivider(),
                      ),
                      _buildPaymentOptionTile(
                        method: _PaymentMethod.other,
                        child: Row(
                          children: [
                            Icon(
                              Icons.credit_card_outlined,
                              size: 28,
                              color: AppColors.authFieldIcon,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Other Payment Methods',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.logoDark,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.authHint,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SafeArea(
                child: Material(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(24),
                  child: InkWell(
                    onTap: _selectedPaymentMethod == null || _isProcessing
                        ? null
                        : _completePayment,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 8),
                      alignment: Alignment.center,
                      child: _isProcessing
                          ? SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Pay Using $_paymentMethodLabel',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
