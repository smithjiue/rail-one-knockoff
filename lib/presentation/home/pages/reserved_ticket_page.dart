import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rail_one/core/theme/app_colors.dart';

class ReservedTicketPage extends StatefulWidget {
  const ReservedTicketPage({super.key});

  @override
  State<ReservedTicketPage> createState() => _ReservedTicketPageState();
}

class _ReservedTicketPageState extends State<ReservedTicketPage> {
  final _sourceController = TextEditingController();
  final _destinationController = TextEditingController();
  String _selectedClass = 'All';
  String _selectedQuota = 'General';
  late DateTime _departureDate = _dateOnly(DateTime.now());
  bool _dateFromCalendar = false;

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static const _classOptions = ['All', '2S', 'VS', 'SL', 'CC', 'VC'];
  static const _quotaOptions = [
    'General',
    'Tatkal',
    'Premium Tatkal',
    'Ladies',
    'Senior Citizen / Female 45+',
    'Divyangjan',
    'Pooled',
  ];
  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  List<DateTime> get _quickDates {
    final today = DateTime.now();
    final base = DateTime(today.year, today.month, today.day);
    return List.generate(3, (index) => base.add(Duration(days: index + 1)));
  }

  String _formatQuickDate(DateTime date) {
    return '${date.day} ${_months[date.month - 1]}';
  }

  String _formatDepartureDate(DateTime date) {
    return '${_weekdays[date.weekday - 1]}, ${date.day} ${_months[date.month - 1]}';
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Widget _buildDateChip(
    DateTime date, {
    required bool isSelected,
    bool fromQuickPick = false,
  }) {
    return Material(
      color: isSelected ? AppColors.authRegistrationCard : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.borderLight,
        ),
      ),
      child: InkWell(
        onTap: () => setState(() {
          _departureDate = _dateOnly(date);
          if (fromQuickPick) _dateFromCalendar = false;
        }),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            _formatQuickDate(date),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? AppColors.primary : AppColors.bodyText,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDepartureDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _departureDate,
      firstDate: _dateOnly(DateTime.now()),
      lastDate: _dateOnly(DateTime.now()).add(const Duration(days: 120)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.logoDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _departureDate = _dateOnly(picked);
        _dateFromCalendar = true;
      });
    }
  }

  Future<void> _showQuotaPicker() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Select Quota',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.logoDark,
                  ),
                ),
              ),
              for (final option in _quotaOptions)
                ListTile(
                  title: Text(
                    option,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: _selectedQuota == option
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: _selectedQuota == option
                          ? AppColors.primary
                          : AppColors.logoDark,
                    ),
                  ),
                  trailing: _selectedQuota == option
                      ? Icon(Icons.check_rounded, color: AppColors.primary)
                      : null,
                  onTap: () => Navigator.of(context).pop(option),
                ),
              SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    if (selected != null) {
      setState(() => _selectedQuota = selected);
    }
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  void _swapStations() {
    final source = _sourceController.text;
    _sourceController.text = _destinationController.text;
    _destinationController.text = source;
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
                          Column(
                            children: [
                              Text(
                                'Reserved Ticket',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      fontSize: 20,
                                      color: AppColors.authPrimaryDark,
                                    ),
                              ),
                              SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/IR_logo_blue.png',
                                    height: 18,
                                    width: 18,
                                    errorBuilder: (_, __, ___) => Icon(
                                      Icons.train_rounded,
                                      size: 18,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Powered by IRCTC',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.bodyText,
                                    ),
                                  ),
                                ],
                              ),
                            ],
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
                    child: Container(
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
                          Material(
                            color: AppColors.authRegistrationCard,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: AppColors.primary),
                            ),
                            child: InkWell(
                              onTap: () {},
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 14,
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      'Search Using Saved Preferences',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '(Source, Destination, Class and Quota)',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.authHint,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '· OR ·',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.authHint,
                            ),
                          ),
                          SizedBox(height: 4),
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(right: 44),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'From',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.cyanBlue,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.train_outlined,
                                          size: 22,
                                          color: AppColors.authFieldIcon,
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: TextField(
                                            controller: _sourceController,
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.logoDark,
                                            ),
                                            decoration: InputDecoration(
                                              isDense: true,
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.zero,
                                              hintText: 'Source',
                                              hintStyle: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: AppColors.authHint,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12),
                                    Divider(
                                      height: 1,
                                      thickness: 1,
                                      color: AppColors.borderLight,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'To',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.cyanBlue,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.train_outlined,
                                          size: 22,
                                          color: AppColors.authFieldIcon,
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: TextField(
                                            controller: _destinationController,
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.logoDark,
                                            ),
                                            decoration: InputDecoration(
                                              isDense: true,
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.zero,
                                              hintText: 'Destination',
                                              hintStyle: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: AppColors.authHint,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12),
                                    Divider(
                                      height: 1,
                                      thickness: 1,
                                      color: AppColors.borderLight,
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
                                          color: AppColors.cyanBlue,
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24),
                          Text(
                            'Departure Date',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.cyanBlue,
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Text(
                                _formatDepartureDate(_departureDate),
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.logoDark,
                                ),
                              ),
                              SizedBox(width: 8),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _pickDepartureDate,
                                  borderRadius: BorderRadius.circular(20),
                                  child: Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(
                                      Icons.calendar_today_outlined,
                                      size: 18,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      if (_dateFromCalendar)
                                        _buildDateChip(
                                          _departureDate,
                                          isSelected: true,
                                        )
                                      else
                                        for (final date in _quickDates) ...[
                                          _buildDateChip(
                                            date,
                                            isSelected: _isSameDay(
                                              date,
                                              _departureDate,
                                            ),
                                            fromQuickPick: true,
                                          ),
                                          SizedBox(width: 8),
                                        ],
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24),
                          Text(
                            'Class',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.cyanBlue,
                            ),
                          ),
                          SizedBox(height: 10),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                for (final option in _classOptions) ...[
                                  Material(
                                    color: _selectedClass == option
                                        ? AppColors.authRegistrationCard
                                        : Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: BorderSide(
                                        color: _selectedClass == option
                                            ? AppColors.primary
                                            : AppColors.borderLight,
                                      ),
                                    ),
                                    child: InkWell(
                                      onTap: () => setState(
                                        () => _selectedClass = option,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 6,
                                        ),
                                        child: Text(
                                          option,
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: _selectedClass == option
                                                ? AppColors.primary
                                                : AppColors.bodyText,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                ],
                              ],
                            ),
                          ),
                          SizedBox(height: 24),
                          Text(
                            'Quota',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.cyanBlue,
                            ),
                          ),
                          SizedBox(height: 8),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _showQuotaPicker,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _selectedQuota,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.logoDark,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: AppColors.primary,
                                    size: 24,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: AppColors.borderLight,
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Other Options',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.authHint,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Please Select',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.logoDark,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: AppColors.primary,
                                size: 24,
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: AppColors.borderLight,
                          ),
                          SizedBox(height: 28),
                          Material(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(24),
                            child: InkWell(
                              onTap: () {},
                              borderRadius: BorderRadius.circular(24),
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(vertical: 14),
                                alignment: Alignment.center,
                                child: Text(
                                  'Search',
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
                        ],
                      ),
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
