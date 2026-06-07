import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:rail_one/core/storage/models/stored_booking.dart';

/// Builds an encrypted ticket payload for UTS-style QR codes.
class TicketQrCrypto {
  TicketQrCrypto._();

  // AES-256 requires a 32-byte key.
  static const _aesKey = 'RailOneUTSTicketEncryptKey2026!!';

  static String buildEncryptedPayload({
    required StoredBooking booking,
    required String passengerName,
    required String passengerMobile,
    String passengerAge = '23 years',
    String idType = 'Govt. issued Icard',
    String idNumber = '686364284314',
  }) {
    final payload = <String, dynamic>{
      'utsReference': booking.utsReference,
      'receiptCode': booking.receiptCode,
      'ticketCategory': booking.ticketCategoryLabel,
      'status': booking.status,
      'sourceStationName': booking.sourceStationName,
      'sourceStationCode': booking.sourceStationCode,
      'destinationStationName': booking.destinationStationName,
      'destinationStationCode': booking.destinationStationCode,
      'distanceKm': booking.distanceKm,
      'fullFare': booking.fullFare,
      'paidAmount': booking.paidAmount,
      'paymentMethod': booking.paymentMethod,
      'isSeasonTicket': booking.isSeasonTicket,
      'trainTypeLabel': booking.trainTypeLabel,
      'travelClassLabel': booking.travelClassLabel,
      'ticketTypeLabel': booking.ticketTypeLabel,
      'adultCount': booking.adultCount,
      'childCount': booking.childCount,
      'bookedAt': booking.bookedAt.toUtc().toIso8601String(),
      'expiresAt': booking.expiresAt.toUtc().toIso8601String(),
      'validFrom': booking.formattedValidFrom,
      'validTill': booking.formattedValidTill,
      'bookedOnLine': booking.formattedBookedOnLine,
      'bookedOnDateTime': booking.formattedBookedOnDateTime,
      'fareSummary': booking.fareSummaryLine,
      'passengerName': passengerName,
      'passengerMobile': passengerMobile,
      'passengerAge': passengerAge,
      'idType': idType,
      'idNumber': idNumber,
      if (booking.seasonDurationLabel != null)
        'seasonDurationLabel': booking.seasonDurationLabel,
      if (booking.seasonEndDate != null)
        'seasonEndDate': booking.seasonEndDate!.toUtc().toIso8601String(),
      'discountPercent': booking.discountPercent,
    };

    final encrypted = _encrypt(jsonEncode(payload));
    return '$encrypted#${_buildQrTag(booking.utsReference)}';
  }

  static String _encrypt(String plainText) {
    final key = Key.fromUtf8(_aesKey);
    final iv = IV.fromSecureRandom(16);
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    final combined = Uint8List.fromList([...iv.bytes, ...encrypted.bytes]);
    return base64Encode(combined);
  }

  static String _buildQrTag(String utsReference) {
    final hash = utsReference.codeUnits.fold<int>(
      0,
      (value, unit) => (value * 31 + unit) & 0x7fffffff,
    );
    final digits = (hash % 10000000000).toString().padLeft(10, '0');
    return 'QR$digits';
  }
}
