import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rail_one/core/storage/models/stored_booking.dart';
import 'package:rail_one/core/theme/app_colors.dart';
import 'package:rail_one/core/utils/fare_calculator.dart';
import 'package:rail_one/presentation/home/pages/make_payment_page.dart';

enum _TrainType { ordinary, acEmu }

enum _JourneyTicketType { journey, returnTicket }

enum _TravelClass { second, first }

enum _SeasonDuration { monthly, quarterly, halfYearly, yearly }

class UnreservedJourneyPage extends StatefulWidget {
  const UnreservedJourneyPage({
    super.key,
    required this.sourceStation,
    required this.destinationStation,
    this.isSeasonTicket = false,
    this.seasonDateText,
  });

  final String sourceStation;
  final String destinationStation;
  final bool isSeasonTicket;
  final String? seasonDateText;

  static String formatJourneyStation(String fieldDisplay) {
    final parts = fieldDisplay.split(' - ');
    if (parts.length == 2) {
      return '${parts[1].trim().toUpperCase()} (${parts[0].trim()})';
    }
    return fieldDisplay.toUpperCase();
  }

  static ({String name, String code}) parseStationField(String fieldDisplay) {
    final parts = fieldDisplay.split(' - ');
    if (parts.length == 2) {
      return (
        name: parts[1].trim().toUpperCase(),
        code: parts[0].trim().toUpperCase(),
      );
    }
    return (name: fieldDisplay.toUpperCase(), code: '');
  }

  @override
  State<UnreservedJourneyPage> createState() => _UnreservedJourneyPageState();
}

class _UnreservedJourneyPageState extends State<UnreservedJourneyPage> {
  _TrainType _trainType = _TrainType.ordinary;
  _JourneyTicketType _ticketType = _JourneyTicketType.journey;
  _TravelClass _travelClass = _TravelClass.second;
  _SeasonDuration _duration = _SeasonDuration.monthly;
  int _adultCount = 1;
  int _childCount = 0;
  bool _availConcession = false;

  bool _showMaxWarning = false;
  Timer? _warningTimer;

  @override
  void dispose() {
    _warningTimer?.cancel();
    super.dispose();
  }

  void _showMaxPassengerError() {
    setState(() {
      _showMaxWarning = true;
    });
    _warningTimer?.cancel();
    _warningTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showMaxWarning = false;
        });
      }
    });
  }

  void _selectTrainType(_TrainType trainType) {
    setState(() {
      _trainType = trainType;
      if (trainType == _TrainType.acEmu) {
        _travelClass = _TravelClass.first;
      }
    });
  }

  int _calculateFare() {
    final srcCode = UnreservedJourneyPage.parseStationField(
      widget.sourceStation,
    ).code;
    final destCode = UnreservedJourneyPage.parseStationField(
      widget.destinationStation,
    ).code;

    final result = FareCalculatorService.instance.calculate(srcCode, destCode);
    // Base second-class fare from the graph route.
    int baseFare = result?.secondClassFare ?? 5;
    if (_travelClass == _TravelClass.first) {
      baseFare = result?.firstClassFare ?? 5;
    }
    if (_trainType == _TrainType.acEmu) {
      baseFare = result?.acEmuFare ?? 5;
    }
    final int singleChildFare = (baseFare / 2).round();

    if (widget.isSeasonTicket) {
      final category = switch ((_trainType, _travelClass)) {
        (_TrainType.acEmu, _) => SeasonTravelCategory.acEmu,
        (_, _TravelClass.first) => SeasonTravelCategory.firstClass,
        _ => SeasonTravelCategory.secondClass,
      };
      final duration = switch (_duration) {
        _SeasonDuration.monthly => SeasonTicketDuration.monthly,
        _SeasonDuration.quarterly => SeasonTicketDuration.quarterly,
        _SeasonDuration.halfYearly => SeasonTicketDuration.halfYearly,
        _SeasonDuration.yearly => SeasonTicketDuration.yearly,
      };

      return calculateSeasonFare(
        sourceCode: srcCode,
        destinationCode: destCode,
        category: category,
        duration: duration,
      );
    } else {
      int total = (baseFare * _adultCount) + (singleChildFare * _childCount);
      if (_ticketType == _JourneyTicketType.returnTicket) total *= 2;
      return total;
    }
  }

  Widget _buildPassengerDetailsCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Passenger Details',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: AppColors.authHint,
              ),
            ),
            InkWell(
              onTap: () {},
              child: Row(
                children: [
                  Icon(Icons.edit, size: 12, color: AppColors.authLink),
                  SizedBox(width: 4),
                  Text(
                    'Edit ID',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: AppColors.authLink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Govt Issued ID-Card: 686364284314',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                color: AppColors.authLink,
              ),
            ),
            Text(
              'Carry this ID during journey',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                color: AppColors.authHint,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.person, size: 14, color: AppColors.authLink),
                  SizedBox(width: 8),
                  Text(
                    'Smith Stanny Jiue',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: AppColors.logoDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    ', 23 yrs, M',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: AppColors.authHint,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on, size: 14, color: AppColors.authLink),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '505 Jiue House Nr Possa Hospital, , Thane, India',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: AppColors.authHint,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToggleChip({
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
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
              color: isSelected ? Colors.white : AppColors.logoDark,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.bodyText,
      ),
    );
  }

  Widget _buildOptionSection({
    required String title,
    required List<Widget> chips,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(title),
        SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 4, children: chips),
      ],
    );
  }

  Widget _buildStationBlock({
    required String name,
    required String code,
    required CrossAxisAlignment alignment,
  }) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          name,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.authPrimaryDark,
            letterSpacing: 0.3,
          ),
        ),
        SizedBox(height: 2),
        Text(
          code,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.logoDark,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildRouteBanner({
    required String sourceName,
    required String sourceCode,
    required String destinationName,
    required String destinationCode,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.journeyCardBg,
        border: Border(top: BorderSide(color: AppColors.primary, width: 2)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: _buildStationBlock(
              name: sourceName,
              code: sourceCode,
              alignment: CrossAxisAlignment.start,
            ),
          ),
          Icon(Icons.arrow_right_alt, size: 20, color: AppColors.authHint),
          Expanded(
            child: _buildStationBlock(
              name: destinationName,
              code: destinationCode,
              alignment: CrossAxisAlignment.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerRow({
    required String label,
    required int count,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
    required bool canDecrement,
    required bool canIncrement,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.logoDark,
            ),
          ),
          Spacer(),
          _buildCounterButton(icon: Icons.remove, onTap: onDecrement),
          Container(
            width: 48,
            height: 30,
            margin: EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(24),
            ),
            alignment: Alignment.center,
            child: Text(
              '$count',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          _buildCounterButton(icon: Icons.add, onTap: onIncrement),
        ],
      ),
    );
  }

  Widget _buildCounterButton({
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
      ),
    );
  }

  String _seasonDurationLabel() => switch (_duration) {
    _SeasonDuration.monthly => 'MONTHLY',
    _SeasonDuration.quarterly => 'QUARTERLY',
    _SeasonDuration.halfYearly => 'HALF YEARLY',
    _SeasonDuration.yearly => 'YEARLY',
  };

  void _openMakePaymentPage({
    required String sourceName,
    required String sourceCode,
    required String destinationName,
    required String destinationCode,
    required int totalFare,
    required double distanceKm,
  }) {
    const discountPercent = 3;
    final draft = TicketBookingDraft(
      sourceStationName: sourceName,
      sourceStationCode: sourceCode,
      destinationStationName: destinationName,
      destinationStationCode: destinationCode,
      distanceKm: distanceKm,
      fullFare: totalFare.toDouble(),
      isSeasonTicket: widget.isSeasonTicket,
      trainTypeLabel: _trainType == _TrainType.acEmu
          ? 'AC EMU TRAIN'
          : 'ORDINARY',
      travelClassLabel: _travelClass == _TravelClass.first ? 'FIRST' : 'SECOND',
      ticketTypeLabel: widget.isSeasonTicket
          ? _seasonDurationLabel()
          : (_ticketType == _JourneyTicketType.returnTicket
                ? 'RETURN'
                : 'JOURNEY'),
      adultCount: _adultCount,
      childCount: _childCount,
      seasonDurationLabel: widget.isSeasonTicket
          ? _seasonDurationLabel()
          : null,
      discountPercent: discountPercent,
    );

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MakePaymentPage(
          routeLabel: '$sourceCode → $destinationCode',
          payAmount: totalFare.toDouble(),
          bookingDetails: draft,
          discountPercent: discountPercent,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final source = UnreservedJourneyPage.parseStationField(
      widget.sourceStation,
    );
    final destination = UnreservedJourneyPage.parseStationField(
      widget.destinationStation,
    );
    final int totalFare = _calculateFare();
    final routeResult = FareCalculatorService.instance.calculate(
      source.code,
      destination.code,
    );
    final distanceKm = routeResult?.totalDistanceKm ?? 0;

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
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.isSeasonTicket
                                ? 'Unreserved Season Ticket'
                                : 'Unreserved Journey',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            widget.isSeasonTicket
                                ? (widget.seasonDateText ?? '')
                                : 'E-Ticket',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _buildRouteBanner(
              sourceName: source.name,
              sourceCode: source.code,
              destinationName: destination.name,
              destinationCode: destination.code,
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildOptionSection(
                      title: 'Train Type',
                      chips: [
                        _buildToggleChip(
                          label: 'ORDINARY',
                          isSelected: _trainType == _TrainType.ordinary,
                          onTap: () => _selectTrainType(_TrainType.ordinary),
                        ),
                        _buildToggleChip(
                          label: 'AC EMU TRAIN',
                          isSelected: _trainType == _TrainType.acEmu,
                          onTap: () => _selectTrainType(_TrainType.acEmu),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    if (widget.isSeasonTicket) ...[
                      _buildOptionSection(
                        title: 'Duration',
                        chips: [
                          _buildToggleChip(
                            label: 'MONTHLY',
                            isSelected: _duration == _SeasonDuration.monthly,
                            onTap: () => setState(
                              () => _duration = _SeasonDuration.monthly,
                            ),
                          ),
                          _buildToggleChip(
                            label: 'QUARTERLY',
                            isSelected: _duration == _SeasonDuration.quarterly,
                            onTap: () => setState(
                              () => _duration = _SeasonDuration.quarterly,
                            ),
                          ),
                          _buildToggleChip(
                            label: 'HALF YEARLY',
                            isSelected: _duration == _SeasonDuration.halfYearly,
                            onTap: () => setState(
                              () => _duration = _SeasonDuration.halfYearly,
                            ),
                          ),
                          _buildToggleChip(
                            label: 'YEARLY',
                            isSelected: _duration == _SeasonDuration.yearly,
                            onTap: () => setState(
                              () => _duration = _SeasonDuration.yearly,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      _buildPassengerDetailsCard(),
                    ] else ...[
                      _buildOptionSection(
                        title: 'Ticket Type',
                        chips: [
                          _buildToggleChip(
                            label: 'JOURNEY',
                            isSelected:
                                _ticketType == _JourneyTicketType.journey,
                            onTap: () => setState(
                              () => _ticketType = _JourneyTicketType.journey,
                            ),
                          ),
                          _buildToggleChip(
                            label: 'RETURN',
                            isSelected:
                                _ticketType == _JourneyTicketType.returnTicket,
                            onTap: () => setState(
                              () =>
                                  _ticketType = _JourneyTicketType.returnTicket,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      _buildPassengerRow(
                        label: 'Adult',
                        count: _adultCount,
                        canDecrement: _adultCount > 1,
                        canIncrement: _adultCount + _childCount < 4,
                        onDecrement: () {
                          if (_adultCount > 1) {
                            setState(() => _adultCount--);
                          }
                        },
                        onIncrement: () {
                          if (_adultCount + _childCount >= 4) {
                            _showMaxPassengerError();
                          } else {
                            setState(() => _adultCount++);
                          }
                        },
                      ),
                      SizedBox(height: 8),
                      _buildPassengerRow(
                        label: 'Child',
                        count: _childCount,
                        canDecrement: _childCount > 0,
                        canIncrement: _adultCount + _childCount < 4,
                        onDecrement: () {
                          if (_childCount > 0) {
                            setState(() => _childCount--);
                          }
                        },
                        onIncrement: () {
                          if (_adultCount + _childCount >= 4) {
                            _showMaxPassengerError();
                          } else {
                            setState(() => _childCount++);
                          }
                        },
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Aged between 5 and 12 years on the day of Travel',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: AppColors.authHint,
                        ),
                      ),
                    ],

                    SizedBox(height: 16),
                    _buildOptionSection(
                      title: 'Class',
                      chips: [
                        if (_trainType == _TrainType.ordinary)
                          _buildToggleChip(
                            label: 'SECOND',
                            isSelected: _travelClass == _TravelClass.second,
                            onTap: () => setState(
                              () => _travelClass = _TravelClass.second,
                            ),
                          ),
                        _buildToggleChip(
                          label: 'FIRST',
                          isSelected: _travelClass == _TravelClass.first,
                          onTap: _trainType == _TrainType.acEmu
                              ? () {}
                              : () => setState(
                                  () => _travelClass = _TravelClass.first,
                                ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () => setState(
                          () => _availConcession = !_availConcession,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: 14,
                          ),

                          child: Row(
                            children: [
                              Icon(
                                _availConcession
                                    ? Icons.radio_button_checked_rounded
                                    : Icons.radio_button_off_rounded,
                                color: _availConcession
                                    ? AppColors.primary
                                    : AppColors.authHint,
                                size: 22,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Avail Concession',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.logoDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              color: AppColors.authRegistrationCard,
              padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  Icon(
                    Icons.confirmation_number,
                    color: AppColors.primary,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Text(
                    widget.isSeasonTicket ? 'Total Fare' : 'Fare',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.authPrimaryDark,
                    ),
                  ),
                  Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '₹ $totalFare',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.authPrimaryDark,
                        ),
                      ),
                      SizedBox(height: 2),
                      Material(
                        color: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: AppColors.logoDark.withValues(alpha: 0.5),
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            child: Text(
                              'Fare Breakup',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: AppColors.logoDark.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: SafeArea(
                top: false,
                child: Material(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(24),
                  child: InkWell(
                    onTap: () => _openMakePaymentPage(
                      sourceName: source.name,
                      sourceCode: source.code,
                      destinationName: destination.name,
                      destinationCode: destination.code,
                      totalFare: totalFare,
                      distanceKm: distanceKm,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      alignment: Alignment.center,
                      child: Text(
                        widget.isSeasonTicket ? 'Proceed to Pay' : 'Book Now',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (_showMaxWarning)
              Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: SafeArea(
                  top: false,
                  child: Container(
                    height: 50,
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12, right: 12),
                            child: Material(
                              color: Colors.white,
                              shape: CircleBorder(
                                side: BorderSide(color: AppColors.borderLight),
                              ),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _showMaxWarning = false;
                                  });
                                  _warningTimer?.cancel();
                                },
                                customBorder: const CircleBorder(),
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Icon(
                                    Icons.close,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            'Maximum 4 passengers allowed',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.logoDark,
                            ),
                          ),
                        ),
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
