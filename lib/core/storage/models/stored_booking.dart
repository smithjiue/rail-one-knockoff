import 'dart:math';

import 'package:equatable/equatable.dart';

/// Ticket details collected on the journey page before payment.
class TicketBookingDraft {
  const TicketBookingDraft({
    required this.sourceStationName,
    required this.sourceStationCode,
    required this.destinationStationName,
    required this.destinationStationCode,
    required this.distanceKm,
    required this.fullFare,
    required this.isSeasonTicket,
    required this.trainTypeLabel,
    required this.travelClassLabel,
    required this.ticketTypeLabel,
    required this.adultCount,
    required this.childCount,
    this.seasonDurationLabel,
    this.discountPercent = 3,
    this.bookingStartDate,
  });

  final String sourceStationName;
  final String sourceStationCode;
  final String destinationStationName;
  final String destinationStationCode;
  final double distanceKm;
  final double fullFare;
  final bool isSeasonTicket;
  final String trainTypeLabel;
  final String travelClassLabel;
  final String ticketTypeLabel;
  final int adultCount;
  final int childCount;
  final String? seasonDurationLabel;
  final int discountPercent;
  final DateTime? bookingStartDate;
}

/// Persisted booking for a user (Hive / local DB).
class StoredBooking extends Equatable {
  const StoredBooking({
    required this.id,
    required this.userId,
    required this.utsReference,
    required this.status,
    required this.sourceStationName,
    required this.sourceStationCode,
    required this.destinationStationName,
    required this.destinationStationCode,
    required this.distanceKm,
    required this.fullFare,
    required this.paidAmount,
    required this.paymentMethod,
    required this.isSeasonTicket,
    required this.trainTypeLabel,
    required this.travelClassLabel,
    required this.ticketTypeLabel,
    required this.adultCount,
    required this.childCount,
    required this.bookedAt,
    required this.expiresAt,
    this.seasonDurationLabel,
    this.seasonEndDate,
    this.discountPercent = 3,
  });

  factory StoredBooking.fromJson(Map<String, dynamic> json) {
    return StoredBooking(
      id: json['id'] as String,
      userId: json['userId'] as String,
      utsReference: json['utsReference'] as String,
      status: json['status'] as String? ?? 'upcoming',
      sourceStationName: json['sourceStationName'] as String,
      sourceStationCode: json['sourceStationCode'] as String,
      destinationStationName: json['destinationStationName'] as String,
      destinationStationCode: json['destinationStationCode'] as String,
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0,
      fullFare: (json['fullFare'] as num?)?.toDouble() ?? 0,
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0,
      paymentMethod: json['paymentMethod'] as String,
      isSeasonTicket: json['isSeasonTicket'] as bool? ?? false,
      trainTypeLabel: json['trainTypeLabel'] as String? ?? '',
      travelClassLabel: json['travelClassLabel'] as String? ?? '',
      ticketTypeLabel: json['ticketTypeLabel'] as String? ?? '',
      adultCount: json['adultCount'] as int? ?? 1,
      childCount: json['childCount'] as int? ?? 0,
      bookedAt: DateTime.parse(json['bookedAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      seasonDurationLabel: json['seasonDurationLabel'] as String?,
      seasonEndDate: json['seasonEndDate'] == null
          ? null
          : DateTime.parse(json['seasonEndDate'] as String),
      discountPercent: json['discountPercent'] as int? ?? 3,
    );
  }

  factory StoredBooking.fromPayment({
    required TicketBookingDraft draft,
    required String userId,
    required double paidAmount,
    required String paymentMethod,
  }) {
    final now = DateTime.now();
    final bookedAt = draft.bookingStartDate ?? now;
    final seasonEnd = draft.isSeasonTicket && draft.seasonDurationLabel != null
        ? _seasonEndDate(bookedAt, draft.seasonDurationLabel!)
        : null;
    final expiresAt = draft.isSeasonTicket && seasonEnd != null
        ? seasonEnd.add(const Duration(hours: 24))
        : bookedAt.add(const Duration(hours: 24));

    return StoredBooking(
      id: _generateId(),
      userId: userId,
      utsReference: _generateUtsReference(),
      status: 'upcoming',
      sourceStationName: draft.sourceStationName,
      sourceStationCode: draft.sourceStationCode,
      destinationStationName: draft.destinationStationName,
      destinationStationCode: draft.destinationStationCode,
      distanceKm: draft.distanceKm,
      fullFare: draft.fullFare,
      paidAmount: paidAmount,
      paymentMethod: paymentMethod,
      isSeasonTicket: draft.isSeasonTicket,
      trainTypeLabel: draft.trainTypeLabel,
      travelClassLabel: draft.travelClassLabel,
      ticketTypeLabel: draft.isSeasonTicket
          ? (draft.seasonDurationLabel ?? draft.ticketTypeLabel)
          : draft.ticketTypeLabel,
      adultCount: draft.adultCount,
      childCount: draft.childCount,
      bookedAt: bookedAt,
      expiresAt: expiresAt,
      seasonDurationLabel: draft.seasonDurationLabel,
      seasonEndDate: seasonEnd,
      discountPercent: draft.discountPercent,
    );
  }

  final String id;
  final String userId;
  final String utsReference;
  final String status;
  final String sourceStationName;
  final String sourceStationCode;
  final String destinationStationName;
  final String destinationStationCode;
  final double distanceKm;
  final double fullFare;
  final double paidAmount;
  final String paymentMethod;
  final bool isSeasonTicket;
  final String trainTypeLabel;
  final String travelClassLabel;
  final String ticketTypeLabel;
  final int adultCount;
  final int childCount;
  final DateTime bookedAt;
  final DateTime expiresAt;
  final String? seasonDurationLabel;
  final DateTime? seasonEndDate;
  final int discountPercent;

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  String get formattedBookingDate => _formatDisplayDate(bookedAt);

  String get routeMeta => '${distanceKm.ceil()} km';

  String get ticketCategoryLabel =>
      isSeasonTicket ? 'Season Ticket' : 'Journey Ticket';

  String get fareSummaryLine =>
      '$ticketTypeLabel | $trainTypeLabel | $travelClassLabel | '
      '₹ ${fullFare.toStringAsFixed(2)}';

  String get receiptCode =>
      'R${id.length >= 5 ? id.substring(id.length - 5) : id.padLeft(5, '0')}';

  String get formattedBookedOnDateTime => _formatDateTime(bookedAt);

  String get formattedValidFrom => _formatShortDate(bookedAt);

  String get formattedValidTill {
    if (isSeasonTicket && seasonEndDate != null) {
      return _formatShortDate(seasonEndDate!);
    }
    return _formatShortDate(bookedAt);
  }

  static String _formatShortDate(DateTime date) {
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    return '$day/$month/${local.year}';
  }

  static String _formatDateTime(DateTime date) {
    final local = date.toLocal();
    const months = [
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
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.day} ${months[local.month - 1]} ${local.year}, $hour:$minute';
  }

  static String _formatBookedOnLine(DateTime date) {
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month/${local.year} $hour:$minute';
  }

  String get formattedBookedOnLine => _formatBookedOnLine(bookedAt);

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'utsReference': utsReference,
    'status': status,
    'sourceStationName': sourceStationName,
    'sourceStationCode': sourceStationCode,
    'destinationStationName': destinationStationName,
    'destinationStationCode': destinationStationCode,
    'distanceKm': distanceKm,
    'fullFare': fullFare,
    'paidAmount': paidAmount,
    'paymentMethod': paymentMethod,
    'isSeasonTicket': isSeasonTicket,
    'trainTypeLabel': trainTypeLabel,
    'travelClassLabel': travelClassLabel,
    'ticketTypeLabel': ticketTypeLabel,
    'adultCount': adultCount,
    'childCount': childCount,
    'bookedAt': bookedAt.toUtc().toIso8601String(),
    'expiresAt': expiresAt.toUtc().toIso8601String(),
    if (seasonDurationLabel != null) 'seasonDurationLabel': seasonDurationLabel,
    if (seasonEndDate != null)
      'seasonEndDate': seasonEndDate!.toUtc().toIso8601String(),
    'discountPercent': discountPercent,
  };

  static String _generateId() =>
      DateTime.now().microsecondsSinceEpoch.toRadixString(16);

  static String _generateUtsReference() {
    const chars = '0123456789ABCDEF';
    final random = Random.secure();
    final buffer = StringBuffer('X');
    for (var i = 0; i < 9; i++) {
      buffer.write(chars[random.nextInt(chars.length)]);
    }
    return buffer.toString();
  }

  static DateTime _seasonEndDate(DateTime start, String durationLabel) {
    final months = switch (durationLabel.toUpperCase()) {
      'MONTHLY' => 1,
      'QUARTERLY' => 3,
      'HALF YEARLY' || 'HALF-YEARLY' || 'HALFYEARLY' => 6,
      'YEARLY' => 12,
      _ => 1,
    };
    final endMonthDate = DateTime(start.year, start.month + months, start.day);
    return endMonthDate.subtract(const Duration(days: 1));
  }

  static String _formatDisplayDate(DateTime date) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
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
    final local = date.toLocal();
    final weekday = weekdays[local.weekday - 1];
    final month = months[local.month - 1];
    final year = (local.year % 100).toString().padLeft(2, '0');
    return '$weekday, ${local.day.toString().padLeft(2, '0')} $month $year';
  }

  @override
  List<Object?> get props => [id, userId, utsReference, bookedAt];
}
