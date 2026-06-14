import 'package:flutter/material.dart';
import 'package:rail_one/core/di/injection.dart';
import 'package:rail_one/core/storage/local_storage_service.dart';
import 'package:rail_one/core/storage/models/stored_booking.dart';
import 'package:rail_one/core/theme/app_colors.dart';
import 'package:rail_one/presentation/home/pages/booking_details_page.dart';
import 'package:rail_one/presentation/home/pages/unreserved_e_ticket_page.dart';
import 'package:rail_one/presentation/home/pages/unreserved_journey_page.dart';

class UpcomingJourneySection extends StatefulWidget {
  const UpcomingJourneySection({super.key});

  @override
  State<UpcomingJourneySection> createState() => _UpcomingJourneySectionState();
}

class _UpcomingJourneySectionState extends State<UpcomingJourneySection> {
  static const _horizontalPadding = 40.0;

  StoredBooking? _latestBooking;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLatestBooking();
  }

  Future<void> _loadLatestBooking() async {
    final stored = await sl<LocalStorageService>().getActiveBookings();
    if (!mounted) return;

    final upcoming = stored
        .where((b) => b.status != 'completed' && b.status != 'cancelled')
        .toList();

    setState(() {
      _latestBooking = upcoming.isNotEmpty ? upcoming.first : null;
      _loading = false;
    });
  }

  void _openBookingDetails(StoredBooking booking) {
    Navigator.of(context)
        .push<void>(
          MaterialPageRoute<void>(
            builder: (_) => BookingDetailsPage(booking: booking),
          ),
        )
        .then((_) {
          if (mounted) _loadLatestBooking();
        });
  }

  void _openBookingPage() {
    Navigator.of(context)
        .push<void>(
          MaterialPageRoute<void>(builder: (_) => UnreservedETicketPage()),
        )
        .then((_) {
          if (mounted) _loadLatestBooking();
        });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox.shrink();
    }

    if (_latestBooking == null) {
      return const SizedBox.shrink();
    }

    final booking = _latestBooking!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 24, 8, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upcoming Journey',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
            child: _TicketCard(
              booking: booking,
              onBookAgain: () => _openBookingPage(),
              onViewDetails: () => _openBookingDetails(booking),
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({
    required this.booking,
    required this.onBookAgain,
    required this.onViewDetails,
  });

  final StoredBooking booking;
  final VoidCallback onBookAgain;
  final VoidCallback onViewDetails;

  static const _divider = Divider(
    height: 1,
    thickness: 1,
    color: Colors.white38,
  );

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _TicketClipper(),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 89, 21, 161),
              Color.fromARGB(255, 201, 149, 201),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20),
              Text(
                booking.formattedBookingDate,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              _divider,
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      booking.sourceStationName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      booking.destinationStationName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _divider,
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Unreserved',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.unreservedGreen,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _TicketActionButton(
                        label: 'Book Again',
                        onTap: onBookAgain,
                      ),
                      const SizedBox(width: 8),
                      _TicketActionButton(
                        label: 'View Details',
                        onTap: onViewDetails,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _TicketActionButton extends StatelessWidget {
  const _TicketActionButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white, width: 1),
            gradient: const LinearGradient(
              colors: [
                AppColors.ticketButtonGradientStart,
                AppColors.ticketButtonGradientEnd,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                height: 1.1,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Ticket shape: rounded rect with top/bottom notches ~78% from the left.
class _TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const cornerRadius = 12.0;
    const notchRadius = 8.0;
    final notchX = size.width * 0.78;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(cornerRadius),
        ),
      )
      ..addOval(Rect.fromCircle(center: Offset(notchX, 0), radius: notchRadius))
      ..addOval(
        Rect.fromCircle(
          center: Offset(notchX, size.height),
          radius: notchRadius,
        ),
      );

    return path..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
