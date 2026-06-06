import 'package:flutter/material.dart';
import 'package:rail_one/core/theme/app_colors.dart';
import 'package:rail_one/presentation/home/pages/reserved_ticket_page.dart';
import 'package:rail_one/presentation/home/pages/unreserved_e_ticket_page.dart';

class JourneyPlannerSection extends StatelessWidget {
  const JourneyPlannerSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Journey Planner',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(8, 14, 8, 0),
            child: SizedBox(
              height: 132,
              child: Row(
                spacing: 8,
                children: [
                  Expanded(
                    child: _journeyCard(
                      context,
                      label: 'Reserved',
                      imagePath: 'assets/images/reserve_card.png',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const ReservedTicketPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: _journeyCard(
                      context,
                      label: 'Unreserved',
                      imagePath: 'assets/images/unreserve_card.png',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const UnreservedETicketPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: _journeyCard(
                      context,
                      label: 'Platform',
                      imagePath: 'assets/images/platform_card.png',
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

Widget _journeyCard(
  BuildContext context, {
  required String label,
  required String imagePath,
  VoidCallback? onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: Column(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              imagePath,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.journeyCardBg,
                alignment: Alignment.center,
                child: const Icon(Icons.image_not_supported_outlined),
              ),
            ),
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w300,
            color: AppColors.logoDark,
          ),
        ),
      ],
    ),
  );
}
