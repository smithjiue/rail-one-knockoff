import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rail_one/core/constants/mumbai_local_stations.dart';
import 'package:rail_one/core/theme/app_colors.dart';
import 'package:rail_one/presentation/auth/widgets/auth_validation_dialog.dart';
import 'package:rail_one/presentation/home/pages/search_station_page.dart';
import 'package:rail_one/presentation/home/pages/unreserved_journey_page.dart';

enum _TicketType { normal, season }

enum _BookingLocation { outsideStation, atStation }

enum _SeasonTicketAction { issue, renew }

enum _SeasonDateOption { nextDate, currentDate }

enum _StationField { source, destination }

class _UnreservedETicketSession {
  static _TicketType ticketType = _TicketType.normal;
  static _BookingLocation bookingLocation = _BookingLocation.outsideStation;
  static _SeasonTicketAction seasonTicketAction = _SeasonTicketAction.issue;
  static _SeasonDateOption seasonDateOption = _SeasonDateOption.nextDate;
}

class UnreservedETicketPage extends StatefulWidget {
  const UnreservedETicketPage({super.key});

  @override
  State<UnreservedETicketPage> createState() => _UnreservedETicketPageState();
}

class _UnreservedETicketPageState extends State<UnreservedETicketPage> {
  late _TicketType _ticketType = _UnreservedETicketSession.ticketType;
  late _BookingLocation _bookingLocation =
      _UnreservedETicketSession.bookingLocation;
  late _SeasonTicketAction _seasonTicketAction =
      _UnreservedETicketSession.seasonTicketAction;
  late _SeasonDateOption _seasonDateOption =
      _UnreservedETicketSession.seasonDateOption;
  final _sourceController = TextEditingController();
  final _destinationController = TextEditingController();

  @override
  void dispose() {
    _UnreservedETicketSession.ticketType = _ticketType;
    _UnreservedETicketSession.bookingLocation = _bookingLocation;
    _UnreservedETicketSession.seasonTicketAction = _seasonTicketAction;
    _sourceController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _openStationSearch(_StationField field) async {
    final result = await Navigator.of(context).push<MumbaiLocalStation>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => SearchStationPage(
          fieldLabel: field == _StationField.source ? 'Source' : 'Destination',
        ),
      ),
    );

    if (result == null || !mounted) return;

    setState(() {
      if (field == _StationField.source) {
        _sourceController.text = result.fieldDisplayName;
      } else {
        _destinationController.text = result.fieldDisplayName;
      }
    });
  }

  Widget _buildStationInput({
    required String label,
    required TextEditingController controller,
    required _StationField field,
    required String hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.authLink,
          ),
        ),
        SizedBox(height: 8),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _openStationSearch(field),
            child: Row(
              children: [
                Icon(
                  Icons.train_outlined,
                  size: 22,
                  color: AppColors.authFieldIcon,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    controller.text.isEmpty ? hintText : controller.text,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: controller.text.isEmpty
                          ? AppColors.authHint
                          : AppColors.logoDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _swapStations() {
    setState(() {
      final source = _sourceController.text;
      _sourceController.text = _destinationController.text;
      _destinationController.text = source;
    });
  }

  bool get _areStationsSelected =>
      _sourceController.text.trim().isNotEmpty &&
      _destinationController.text.trim().isNotEmpty;

  DateTime? _seasonBookingStartDate() {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    return _seasonDateOption == _SeasonDateOption.nextDate
        ? startOfToday.add(const Duration(days: 1))
        : null;
  }

  Future<void> _onProceedToBook() async {
    if (!_areStationsSelected) {
      await showAuthValidationDialog(
        context,
        message: 'Please Provide all Inputs',
      );
      return;
    }

    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => UnreservedJourneyPage(
          sourceStation: _sourceController.text.trim(),
          destinationStation: _destinationController.text.trim(),
          isSeasonTicket: _ticketType == _TicketType.season,
          seasonDateText: _seasonDateOption == _SeasonDateOption.nextDate
              ? 'Next Date'
              : 'Current Date',
          bookingStartDate: _ticketType == _TicketType.season
              ? _seasonBookingStartDate()
              : null,
        ),
      ),
    );
  }

  Widget _buildSeasonTypeChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isSelected ? AppColors.primary : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: isSelected
                ? null
                : Border.all(color: AppColors.borderLight),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: isSelected ? Colors.white : AppColors.authHint,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSeasonTypeSelector() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Text(
            'Type',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.authHint,
            ),
          ),
          Spacer(),
          _buildSeasonTypeChip(
            label: 'ISSUE',
            isSelected: _seasonTicketAction == _SeasonTicketAction.issue,
            onTap: () =>
                setState(() => _seasonTicketAction = _SeasonTicketAction.issue),
          ),
          SizedBox(width: 8),
          _buildSeasonTypeChip(
            label: 'RENEW',
            isSelected: _seasonTicketAction == _SeasonTicketAction.renew,
            onTap: () =>
                setState(() => _seasonTicketAction = _SeasonTicketAction.renew),
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonDateChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: isSelected ? AppColors.authRegistrationCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.borderLight,
              ),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.authLink : AppColors.authHint,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSeasonDateSelector() {
    return Row(
      children: [
        _buildSeasonDateChip(
          label: 'Next Date',
          isSelected: _seasonDateOption == _SeasonDateOption.nextDate,
          onTap: () =>
              setState(() => _seasonDateOption = _SeasonDateOption.nextDate),
        ),
        SizedBox(width: 10),
        _buildSeasonDateChip(
          label: 'Current Date',
          isSelected: _seasonDateOption == _SeasonDateOption.currentDate,
          onTap: () =>
              setState(() => _seasonDateOption = _SeasonDateOption.currentDate),
        ),
      ],
    );
  }

  Widget _buildBookingLocationSelector() {
    return Row(
      children: [
        Expanded(
          child: Material(
            color: _bookingLocation == _BookingLocation.outsideStation
                ? AppColors.primary
                : Colors.white,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              onTap: () => setState(
                () => _bookingLocation = _BookingLocation.outsideStation,
              ),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: _bookingLocation == _BookingLocation.outsideStation
                      ? null
                      : Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        'Outside Station',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color:
                              _bookingLocation ==
                                  _BookingLocation.outsideStation
                              ? Colors.white
                              : AppColors.authHint,
                        ),
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: _bookingLocation == _BookingLocation.outsideStation
                          ? Colors.white
                          : AppColors.authHint,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Material(
            color: _bookingLocation == _BookingLocation.atStation
                ? AppColors.primary
                : Colors.white,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              onTap: () =>
                  setState(() => _bookingLocation = _BookingLocation.atStation),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: _bookingLocation == _BookingLocation.atStation
                      ? null
                      : Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        'At Station',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _bookingLocation == _BookingLocation.atStation
                              ? Colors.white
                              : AppColors.authHint,
                        ),
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: _bookingLocation == _BookingLocation.atStation
                          ? Colors.white
                          : AppColors.authHint,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.authDialogBg,
        body: SafeArea(
          child: Column(
            children: [
              ColoredBox(
                color: AppColors.background,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            'Unreserved E-Ticket',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontSize: 20,
                                  color: AppColors.authPrimaryDark,
                                ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Material(
                              color: Colors.transparent,
                              shape: CircleBorder(
                                side: BorderSide(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                              child: InkWell(
                                onTap: () => Navigator.of(context).maybePop(),
                                customBorder: const CircleBorder(),
                                child: SizedBox(
                                  width: 36,
                                  height: 36,
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 22,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.borderLight,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ColoredBox(
                  color: AppColors.authDialogBg,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: EdgeInsets.fromLTRB(16, 20, 16, 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.borderLight),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Material(
                                        color: _ticketType == _TicketType.normal
                                            ? Colors.white
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(6),
                                        child: InkWell(
                                          onTap: () => setState(
                                            () => _ticketType =
                                                _TicketType.normal,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 10,
                                            ),
                                            child: Text(
                                              'Normal',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    _ticketType ==
                                                        _TicketType.normal
                                                    ? AppColors.authLink
                                                    : AppColors.logoDark,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Material(
                                        color: _ticketType == _TicketType.season
                                            ? Colors.white
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(6),
                                        child: InkWell(
                                          onTap: () => setState(
                                            () => _ticketType =
                                                _TicketType.season,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 10,
                                            ),
                                            child: Text(
                                              'Season',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    _ticketType ==
                                                        _TicketType.season
                                                    ? AppColors.authLink
                                                    : AppColors.logoDark,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20),
                              if (_ticketType == _TicketType.normal)
                                _buildBookingLocationSelector()
                              else
                                _buildSeasonTypeSelector(),
                              SizedBox(height: 24),
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(right: 44),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildStationInput(
                                          label: 'From',
                                          controller: _sourceController,
                                          field: _StationField.source,
                                          hintText: 'Source',
                                        ),
                                        SizedBox(height: 12),
                                        Divider(
                                          height: 1,
                                          thickness: 1,
                                          color: AppColors.borderLight,
                                        ),
                                        SizedBox(height: 16),
                                        _buildStationInput(
                                          label: 'To',
                                          controller: _destinationController,
                                          field: _StationField.destination,
                                          hintText: 'Destination',
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    bottom: 0,
                                    child: Center(
                                      child: Material(
                                        color: AppColors.authRegistrationCard,
                                        shape: CircleBorder(),
                                        elevation: 0,
                                        child: InkWell(
                                          onTap: _swapStations,
                                          customBorder: CircleBorder(),
                                          child: SizedBox(
                                            width: 40,
                                            height: 40,
                                            child: Icon(
                                              Icons.swap_vert_rounded,
                                              color: AppColors.authLink,
                                              size: 22,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (_ticketType == _TicketType.season) ...[
                                SizedBox(height: 24),
                                _buildSeasonDateSelector(),
                              ],
                              SizedBox(
                                height: _ticketType == _TicketType.season
                                    ? 24
                                    : 44,
                              ),
                              Material(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(24),
                                child: InkWell(
                                  onTap: _onProceedToBook,
                                  borderRadius: BorderRadius.circular(24),
                                  child: Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Proceed To Book',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 16),
                              Material(
                                color: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  side: BorderSide(
                                    color: AppColors.primary,
                                    width: 1.5,
                                  ),
                                ),
                                child: InkWell(
                                  onTap: () {},
                                  borderRadius: BorderRadius.circular(24),
                                  child: Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Check Upcoming Trains',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 28),
                      ],
                    ),
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
