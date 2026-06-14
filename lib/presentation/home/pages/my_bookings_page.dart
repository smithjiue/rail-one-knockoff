import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rail_one/core/di/injection.dart';
import 'package:rail_one/core/storage/local_storage_service.dart';
import 'package:rail_one/core/storage/models/stored_booking.dart';
import 'package:rail_one/core/theme/app_colors.dart';
import 'package:rail_one/presentation/home/pages/booking_details_page.dart';
import 'package:rail_one/presentation/home/pages/unreserved_e_ticket_page.dart';

enum _BookingFilter { upcoming, completed, cancelled, all }

enum _BookingStatus { upcoming, completed, cancelled }

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  _BookingFilter _filter = _BookingFilter.upcoming;
  List<StoredBooking> _bookings = [];
  bool _loading = true;

  static const _upcomingOrange = Color(0xFFE8870B);
  static const _filterUpcomingHighlight = Color(0xFFE9AB6A);
  static const _completedGreen = Color(0xFF2E9E5B);
  static const _upcomingBorder = _upcomingOrange;
  static const _ticketBg = Color(0xFFF6F6F6);
  static const _pageBg = Color(0xFFF5F5F5);
  static const _referenceMuted = Color(0xFF6B7280);
  static const _actionMuted = Color(0xFF757575);

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _loading = true);
    final stored = await sl<LocalStorageService>().getActiveBookings();
    if (!mounted) return;
    setState(() {
      _bookings = stored;
      _loading = false;
    });
  }

  _BookingStatus _statusFromStored(StoredBooking booking) {
    return switch (booking.status) {
      'completed' => _BookingStatus.completed,
      'cancelled' => _BookingStatus.cancelled,
      _ => _BookingStatus.upcoming,
    };
  }

  void _openBookingDetails(StoredBooking booking) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => BookingDetailsPage(booking: booking),
      ),
    );
  }

  List<StoredBooking> get _filteredBookings {
    return switch (_filter) {
      _BookingFilter.upcoming =>
        _bookings
            .where((b) => _statusFromStored(b) == _BookingStatus.upcoming)
            .toList(),
      _BookingFilter.completed =>
        _bookings
            .where((b) => _statusFromStored(b) == _BookingStatus.completed)
            .toList(),
      _BookingFilter.cancelled =>
        _bookings
            .where((b) => _statusFromStored(b) == _BookingStatus.cancelled)
            .toList(),
      _BookingFilter.all => _bookings,
    };
  }

  Widget _dashedDivider() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 2.0;
        const dashSpace = 2.0;
        final dashCount = (constraints.maxWidth / (dashWidth + dashSpace))
            .floor()
            .clamp(1, 100);
        return Row(
          children: List.generate(dashCount, (index) {
            return Padding(
              padding: const EdgeInsets.only(right: dashSpace),
              child: SizedBox(
                width: dashWidth,
                height: 0.5,
                child: ColoredBox(color: _upcomingBorder),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _sectionHeader({
    required String title,
    required Color color,
    bool showRefresh = false,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          if (showRefresh)
            Positioned(
              right: 0,
              child: InkWell(
                onTap: _loadBookings,
                customBorder: const CircleBorder(),
                child: Icon(
                  Icons.refresh_rounded,
                  size: 18,
                  color: color.withValues(alpha: 0.8),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _bookingCard(StoredBooking booking) {
    final status = _statusFromStored(booking);
    final borderColor = status == _BookingStatus.upcoming
        ? _upcomingBorder
        : status == _BookingStatus.completed
        ? _completedGreen
        : AppColors.authHint;

    const kindBg = Color(0xFFF0EBFF);
    const kindText = Color(0xFF7B5BB5);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: _ticketBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _openBookingDetails(booking),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: kindBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Unreserved',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: kindText,
                              ),
                            ),
                          ),
                          const Spacer(),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                height: 1.2,
                              ),
                              children: [
                                const TextSpan(
                                  text: 'UTS: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: _referenceMuted,
                                  ),
                                ),
                                TextSpan(
                                  text: booking.utsReference,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.heading,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _infoColumn(
                              'Ticket Type',
                              booking.ticketTypeLabel,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _infoColumn(
                              'Booking Date',
                              booking.formattedBookingDate,
                              alignEnd: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              booking.sourceStationName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: AppColors.logoDark,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: _routeMetaDivider(booking.routeMeta),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              booking.destinationStationName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: AppColors.logoDark,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _dashedDivider(),
                ),
                Positioned(
                  left: -9,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _pageBg,
                      shape: BoxShape.circle,
                      border: Border.all(color: borderColor, width: 1),
                    ),
                  ),
                ),
                Positioned(
                  right: -9,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _pageBg,
                      shape: BoxShape.circle,
                      border: Border.all(color: borderColor, width: 1),
                    ),
                  ),
                ),
              ],
            ),
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          _openBookingDetails(booking);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'Book Again',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: _actionMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: AppColors.borderLight,
                  ),
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _openBookingDetails(booking),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'View Details',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _routeMetaDivider(String routeMeta) {
    return Row(
      children: [
        Expanded(
          child: Container(height: 1, width: 4, color: AppColors.borderLight),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            routeMeta,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: AppColors.logoMuted,
            ),
          ),
        ),
        Expanded(
          child: Container(height: 1, width: 4, color: AppColors.borderLight),
        ),
      ],
    );
  }

  Widget _infoColumn(String label, String value, {bool alignEnd = false}) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.authFieldIcon,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.logoDark,
          ),
        ),
      ],
    );
  }

  Widget _buildBookingList() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final items = _filteredBookings;
    if (items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'No bookings found',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: AppColors.logoMuted,
            ),
          ),
        ),
      );
    }

    if (_filter != _BookingFilter.all) {
      final (title, color, showRefresh) = switch (_filter) {
        _BookingFilter.upcoming => (
          'Upcoming (${items.length})',
          _upcomingOrange,
          true,
        ),
        _BookingFilter.completed => (
          'Completed (${items.length})',
          _completedGreen,
          false,
        ),
        _BookingFilter.cancelled => (
          'Cancelled (${items.length})',
          AppColors.authError,
          false,
        ),
        _BookingFilter.all => ('', _upcomingOrange, false),
      };

      return ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          _sectionHeader(title: title, color: color, showRefresh: showRefresh),
          ...items.map(_bookingCard),
        ],
      );
    }

    final upcoming = items
        .where((b) => _statusFromStored(b) == _BookingStatus.upcoming)
        .toList();
    final completed = items
        .where((b) => _statusFromStored(b) == _BookingStatus.completed)
        .toList();
    final cancelled = items
        .where((b) => _statusFromStored(b) == _BookingStatus.cancelled)
        .toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        if (upcoming.isNotEmpty) ...[
          _sectionHeader(
            title: 'Upcoming (${upcoming.length})',
            color: _upcomingOrange,
            showRefresh: true,
          ),
          ...upcoming.map(_bookingCard),
        ],
        if (completed.isNotEmpty) ...[
          _sectionHeader(
            title: 'Completed (${completed.length})',
            color: _completedGreen,
          ),
          ...completed.map(_bookingCard),
        ],
        if (cancelled.isNotEmpty) ...[
          _sectionHeader(
            title: 'Cancelled (${cancelled.length})',
            color: AppColors.authHint,
          ),
          ...cancelled.map(_bookingCard),
        ],
      ],
    );
  }

  (Color iconColor, Color labelColor) _filterTabColors(
    _BookingFilter filter, {
    required bool isSelected,
  }) {
    if (!isSelected) {
      return (AppColors.logoMuted, AppColors.logoMuted);
    }
    return switch (filter) {
      _BookingFilter.upcoming => (
        _filterUpcomingHighlight,
        _filterUpcomingHighlight,
      ),
      _BookingFilter.completed => (_completedGreen, _completedGreen),
      _BookingFilter.cancelled => (AppColors.authError, AppColors.authError),
      _BookingFilter.all => (AppColors.primary, AppColors.logoDark),
    };
  }

  Widget _filterBar() {
    const filters = [
      (_BookingFilter.upcoming, 'Upcoming'),
      (_BookingFilter.completed, 'Completed'),
      (_BookingFilter.cancelled, 'Cancelled'),
      (_BookingFilter.all, 'All'),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: filters.map((entry) {
            final (filter, label) = entry;
            final isSelected = _filter == filter;
            final (iconColor, labelColor) = _filterTabColors(
              filter,
              isSelected: isSelected,
            );
            return Expanded(
              child: Material(
                color: isSelected
                    ? AppColors.journeyCardBg
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => setState(() => _filter = filter),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.confirmation_number_outlined,
                          size: 22,
                          color: iconColor,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          label,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: labelColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
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
        backgroundColor: _pageBg,
        body: Column(
          children: [
            ColoredBox(
              color: AppColors.primary,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
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
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'My Bookings',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        shape: CircleBorder(
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                        child: InkWell(
                          onTap: () {},
                          customBorder: const CircleBorder(),
                          child: const SizedBox(
                            width: 36,
                            height: 36,
                            child: Icon(
                              Icons.sort_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(child: _buildBookingList()),
            _filterBar(),
          ],
        ),
      ),
    );
  }
}
