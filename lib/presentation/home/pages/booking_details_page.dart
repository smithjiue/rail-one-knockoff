import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:rail_one/core/di/injection.dart';
import 'package:rail_one/core/storage/local_storage_service.dart';
import 'package:rail_one/core/storage/models/stored_booking.dart';
import 'package:rail_one/core/theme/app_colors.dart';
import 'package:rail_one/core/utils/ticket_qr_crypto.dart';
import 'package:rail_one/presentation/auth/widgets/auth_validation_dialog.dart';
import 'package:rail_one/presentation/home/widgets/animated_countdown.dart';

class BookingDetailsPage extends StatefulWidget {
  const BookingDetailsPage({super.key, required this.booking});

  final StoredBooking booking;

  @override
  State<BookingDetailsPage> createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetailsPage> {
  static const _previewAccent = Color(0xFF9081DA);
  static const _previewDuration = Duration(minutes: 5);
  static const _contentBg = Color(0xFFECECEC);
  static const _dateOrange = Color(0xFFE8870B);

  final _storage = sl<LocalStorageService>();
  Timer? _timer;
  Duration _previewRemaining = _previewDuration;

  String _userName = 'Guest User';
  String _mobile = '—';
  bool _previewExpiredHandled = false;
  late String _qrCodeData;

  StoredBooking get _booking => widget.booking;

  String _buildQrPayload() => TicketQrCrypto.buildEncryptedPayload(
    booking: _booking,
    passengerName: _userName,
    passengerMobile: _mobile,
  );

  @override
  void initState() {
    super.initState();
    _qrCodeData = _buildQrPayload();
    _loadUserInfo();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_previewRemaining.inSeconds <= 0) {
        _handlePreviewExpired();
        return;
      }
      setState(() => _previewRemaining -= const Duration(seconds: 1));
      if (_previewRemaining.inSeconds <= 0) {
        _handlePreviewExpired();
      }
    });
  }

  void _handlePreviewExpired() {
    if (_previewExpiredHandled) return;
    _previewExpiredHandled = true;
    _timer?.cancel();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    final name = await _storage.getRegisteredName();
    final mobile = await _storage.getRegisteredMobile();
    final profile = await _storage.getUserProfile();

    if (!mounted) return;
    setState(() {
      _userName = _firstNonEmpty(name, profile?.displayName) ?? 'Guest User';
      _mobile = _firstNonEmpty(mobile, profile?.mobile) ?? '—';
      _qrCodeData = _buildQrPayload();
    });
  }

  String? _firstNonEmpty(String? a, String? b) {
    final first = a?.trim();
    if (first != null && first.isNotEmpty) return first;
    final second = b?.trim();
    if (second != null && second.isNotEmpty) return second;
    return null;
  }

  TextStyle get _countdownStyle => const TextStyle(
    fontFamily: 'Poppins',
    fontSize: 42,
    fontWeight: FontWeight.w700,
    color: AppColors.authError,
    height: 1,
  );

  double get _previewElapsedProgress {
    final totalSeconds = _previewDuration.inSeconds;
    if (totalSeconds <= 0) return 1;
    final remaining = _previewRemaining.inSeconds.clamp(0, totalSeconds);
    return 1 - (remaining / totalSeconds);
  }

  Widget _dashedDivider({Color color = AppColors.borderLight}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 2.0;
        const dashSpace = 2.0;
        final dashCount = (constraints.maxWidth / (dashWidth + dashSpace))
            .floor()
            .clamp(1, 120);
        return Row(
          children: List.generate(dashCount, (index) {
            return Padding(
              padding: const EdgeInsets.only(right: dashSpace),
              child: SizedBox(
                width: dashWidth,
                height: 1,
                child: ColoredBox(color: color),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _verticalDashedDivider({Color color = AppColors.authFieldIcon}) {
    return SizedBox(
      width: 1,
      child: CustomPaint(painter: _VerticalDashedLinePainter(color: color)),
    );
  }

  Widget _verticalRailLabel(String text, {bool hindi = false}) {
    return SizedBox(
      width: 22,
      child: Center(
        child: RotatedBox(
          quarterTurns: 3,
          child: Text(
            text,
            style: TextStyle(
              fontFamily: hindi ? 'NotoSans' : 'Poppins',
              fontSize: hindi ? 18 : 16,
              fontWeight: hindi ? FontWeight.w700 : FontWeight.w700,
              letterSpacing: 1,
              color: AppColors.authFieldIcon,
            ),
          ),
        ),
      ),
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
        backgroundColor: _contentBg,
        body: Column(
          children: [
            ColoredBox(
              color: AppColors.primary,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
                  child: Row(
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
                          child: const SizedBox(
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
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Booking Details',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Mobile: $_mobile',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        shape: CircleBorder(
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                        child: const SizedBox(
                          width: 36,
                          height: 36,
                          child: Icon(
                            Icons.confirmation_number_outlined,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                'Thank You $_userName, Happy Journey !',
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.authFieldIcon,
                ),
              ),
            ),
            Expanded(
              child: ColoredBox(
                color: _contentBg,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          color: AppColors.logoDark,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(height: 12, color: _previewAccent),
                            IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  SizedBox(width: 4),
                                  _verticalRailLabel('INDIAN RAILWAYS'),
                                  SizedBox(width: 4),
                                  _verticalDashedDivider(),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Dynamic preview will close in',
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.borderLight,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          AnimatedCountdown(
                                            remaining: _previewRemaining,
                                            style: _countdownStyle,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Ticket Booking Date & Time',
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.authFieldIcon,
                                            ),
                                          ),
                                          Text(
                                            _booking.formattedBookedOnDateTime,
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 30,
                                              fontWeight: FontWeight.w500,
                                              color: _dateOrange,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _booking.receiptCode.toUpperCase(),
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 14,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            'Ticket is Non-Transferable',
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 14,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  _verticalDashedDivider(),
                                  SizedBox(width: 4),
                                  _verticalRailLabel('भारतीय रेल', hindi: true),
                                  SizedBox(width: 4),
                                ],
                              ),
                            ),
                            LinearProgressIndicator(
                              value: _previewElapsedProgress,
                              minHeight: 4,
                              backgroundColor: _contentBg,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                _previewAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                14,
                                12,
                                14,
                                10,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        _booking.ticketCategoryLabel,
                                        style: const TextStyle(
                                          fontFamily: 'NotoSans',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.logoDark,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        _booking.utsReference,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.logoDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _booking.sourceStationName,
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.logoDark,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '- ${_booking.distanceKm.ceil()} km -',
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 12,
                                          color: AppColors.logoMuted,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          _booking.destinationStationName,
                                          textAlign: TextAlign.end,
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.logoDark,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  _BookingDetailRow(
                                    leftLabel: 'Via',
                                    leftValue: '1RT>>',
                                    rightLabel: 'Booked on',
                                    rightValue: _booking.formattedBookedOnLine,
                                  ),
                                  const SizedBox(height: 14),
                                  _BookingDetailRow(
                                    leftLabel: 'Valid From',
                                    leftValue: _booking.formattedValidFrom,
                                    rightLabel: '*Valid Till',
                                    rightValue: _booking.formattedValidTill,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    _booking.fareSummaryLine.toUpperCase(),
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.logoDark,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                            Stack(
                              alignment: Alignment.center,
                              clipBehavior: Clip.none,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: _dashedDivider(),
                                ),
                                Positioned(
                                  left: -12,
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: _contentBg,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: -12,
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: _contentBg,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                14,
                                18,
                                14,
                                12,
                              ),
                              child: Column(
                                children: [
                                  _BookingDetailRow(
                                    leftLabel: 'Name',
                                    leftValue: _userName,
                                    rightLabel: 'Age',
                                    rightValue: '23 years',
                                  ),
                                  const SizedBox(height: 14),
                                  const _BookingDetailRow(
                                    leftLabel: 'ID Type',
                                    leftValue: 'Govt. issued Icard',
                                    rightLabel: 'ID Number',
                                    rightValue: '686364284314',
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 16,
                              decoration: BoxDecoration(
                                color: _previewAccent,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.offeringPink,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Note: This ticket is non refundable. Ticket is stored '
                          'locally on the device. Please do not change your '
                          'handset or perform factory reset.',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.authError,
                            height: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Material(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(24),
                        child: InkWell(
                          onTap: () => showAuthValidationDialog(
                            context,
                            message:
                                'Class, Train,Ticket combination for the selected source not allowed',
                          ),
                          borderRadius: BorderRadius.circular(24),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              'Upgrade to Superfast',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(48, 0, 48, 0),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final size = constraints.maxWidth * 0.72;
                              return Center(
                                child: QrImageView(
                                  data: _qrCodeData,
                                  version: QrVersions.auto,
                                  size: size,
                                  backgroundColor: Colors.white,
                                  errorCorrectionLevel: QrErrorCorrectLevel.L,
                                  eyeStyle: const QrEyeStyle(
                                    eyeShape: QrEyeShape.square,
                                    color: Colors.black,
                                  ),
                                  dataModuleStyle: const QrDataModuleStyle(
                                    dataModuleShape: QrDataModuleShape.square,
                                    color: Colors.black,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(color: Colors.white),
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Do you know?',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.logoDark,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'IR recovers only 57% of cost of travel on an average',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: AppColors.authFieldIcon,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "This ticket is booked on a personal user ID. It's "
                              'sale/purchase is an offence u/s 143 of the Railways '
                              'Act, 1989',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: AppColors.authFieldIcon,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'For enquiry and integrated railway helpline. '
                              'please dial 139.',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: AppColors.authFieldIcon,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 64),
                    ],
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

class _BookingDetailRow extends StatelessWidget {
  const _BookingDetailRow({
    required this.leftLabel,
    required this.leftValue,
    required this.rightLabel,
    required this.rightValue,
  });

  final String leftLabel;
  final String leftValue;
  final String rightLabel;
  final String rightValue;

  static const _labelStyle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.logoMuted,
  );

  static const _valueStyle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.logoDark,
  );

  Widget _detailCell(
    String label,
    String value, {
    required CrossAxisAlignment alignment,
    required TextAlign textAlign,
  }) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(label, style: _labelStyle),
        const SizedBox(height: 2),
        Text(value, textAlign: textAlign, style: _valueStyle),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _detailCell(
            leftLabel,
            leftValue,
            alignment: CrossAxisAlignment.start,
            textAlign: TextAlign.start,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _detailCell(
            rightLabel,
            rightValue,
            alignment: CrossAxisAlignment.end,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

class _VerticalDashedLinePainter extends CustomPainter {
  const _VerticalDashedLinePainter({required this.color});

  final Color color;

  static const _dashHeight = 5.0;
  static const _dashSpace = 4.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    var y = 0.0;
    while (y < size.height) {
      final endY = (y + _dashHeight).clamp(0.0, size.height);
      canvas.drawLine(Offset(0, y), Offset(0, endY), paint);
      y += _dashHeight + _dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _VerticalDashedLinePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
