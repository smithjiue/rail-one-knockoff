import 'package:flutter/material.dart';
import 'package:rail_one/core/theme/app_colors.dart';

class JourneyPlannerSection extends StatelessWidget {
  const JourneyPlannerSection({super.key});

  static const _items = [
    _JourneyItem(
      label: 'Reserved',
      imagePath: 'assets/images/reserve_card.png',
    ),
    _JourneyItem(
      label: 'Unreserved',
      imagePath: 'assets/images/unreserve_card.png',
    ),
    _JourneyItem(
      label: 'Platform',
      imagePath: 'assets/images/platform_card.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Journey Planner',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SizedBox(
              height: 132,
              child: Row(
                children: [
                  for (var i = 0; i < _items.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    Expanded(child: _JourneyCard(item: _items[i])),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _JourneyItem {
  const _JourneyItem({required this.label, required this.imagePath});

  final String label;
  final String imagePath;
}

class _JourneyCard extends StatelessWidget {
  const _JourneyCard({required this.item});

  final _JourneyItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              item.imagePath,
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
        const SizedBox(height: 4),
        Text(
          item.label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w300,
            color: AppColors.logoDark,
          ),
        ),
      ],
    );
  }
}
