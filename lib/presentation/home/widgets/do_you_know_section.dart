import 'package:flutter/material.dart';
import 'package:rail_one/core/theme/app_colors.dart';

class DoYouKnowSection extends StatelessWidget {
  const DoYouKnowSection({super.key});

  static const _horizontalPadding = 8.0;

  static const _facts = [
    _DoYouKnowFact(
      imagePath: 'assets/images/first_ever_train.png',
      description:
          'First ever passenger train was run between Bori Bandar to Thane on April 16, 1853.',
    ),
    _DoYouKnowFact(
      imagePath: 'assets/images/chenab.jpg',
      description:
          "Chenab Railway Bridge in Dharot, Jammu & Kashmir is the World's highest Railway Bridge.",
    ),
    _DoYouKnowFact(
      imagePath: 'assets/images/noney_bridge.webp',
      description:
          'Noney Bridge in Manipur is one of the tallest pier bridges on the Indian Railways network.',
    ),
    _DoYouKnowFact(
      imagePath: 'assets/images/hubbulli_railway.png',
      description:
          'Hubbulli Railway Station is the highest railway station in the world.',
    ),
    _DoYouKnowFact(
      imagePath: 'assets/images/electric.jpeg',
      description:
          'Indian Railways operates one of the largest electrified railway networks in the world.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
            child: Text(
              'Do You know?',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.heading,
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 210,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: _horizontalPadding,
              ),
              itemCount: _facts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return _DoYouKnowCard(fact: _facts[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DoYouKnowFact {
  const _DoYouKnowFact({required this.imagePath, required this.description});

  final String imagePath;
  final String description;
}

class _DoYouKnowCard extends StatelessWidget {
  const _DoYouKnowCard({required this.fact});

  final _DoYouKnowFact fact;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              fact.imagePath,
              width: 180,
              height: 110,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 180,
                height: 110,
                color: AppColors.journeyCardBg,
                alignment: Alignment.center,
                child: const Icon(Icons.image_not_supported_outlined),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            fact.description,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: AppColors.bodyText,
            ),
          ),
        ],
      ),
    );
  }
}
