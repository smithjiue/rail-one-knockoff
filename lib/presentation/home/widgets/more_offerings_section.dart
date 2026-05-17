import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rail_one/core/theme/app_colors.dart';
import 'package:vector_graphics/vector_graphics.dart';

class MoreOfferingsSection extends StatelessWidget {
  const MoreOfferingsSection({super.key});

  static const _horizontalPadding = 8.0;
  static const _iconBoxSize = 64.0;
  static const _iconBoxRadius = 16.0;
  static const _iconSize = 32.0;
  static const _gapBelowIcon = 8.0;
  static const _rowSpacing = 14.0;

  static const _offerings = [
    _Offering(
      label: 'Search Trains',
      background: AppColors.offeringPink,
      assetPath: 'assets/images/train_route_map.png',
      assetType: _AssetType.png,
    ),
    _Offering(
      label: 'PNR Status',
      background: AppColors.offeringGreen,
      assetPath: 'assets/images/enquire_pnr_icon.png',
      assetType: _AssetType.png,
    ),
    _Offering(
      label: 'Coach Position',
      background: AppColors.offeringBlue,
      assetPath: 'assets/images/coachpositionNew.png',
      assetType: _AssetType.png,
    ),
    _Offering(
      label: 'Track Your Train',
      background: AppColors.offeringYellow,
      assetPath: 'assets/images/track_your_train.svg.vec',
      assetType: _AssetType.vec,
    ),
    _Offering(
      label: 'Order Food',
      background: AppColors.offeringPurple,
      assetPath: 'assets/images/order_food.svg',
      assetType: _AssetType.svg,
    ),
    _Offering(
      label: 'File Refund',
      background: AppColors.offeringGrey,
      assetPath: 'assets/images/more_file_tdr_svg.svg.vec',
      assetType: _AssetType.vec,
    ),
    _Offering(
      label: 'Rail Madad',
      background: AppColors.offeringRose,
      assetPath: 'assets/images/help_centre_register_svg.svg.vec',
      assetType: _AssetType.vec,
    ),
    _Offering(
      label: 'Go To WAVES',
      background: AppColors.offeringWaves,
      assetPath: 'assets/images/waves.png',
      assetType: _AssetType.png,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        _horizontalPadding,
        24,
        _horizontalPadding,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('More Offerings', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          _OfferingRow(offerings: _offerings.sublist(0, 4)),
          const SizedBox(height: _rowSpacing),
          _OfferingRow(offerings: _offerings.sublist(4, 8)),
        ],
      ),
    );
  }
}

class _OfferingRow extends StatelessWidget {
  const _OfferingRow({required this.offerings});

  final List<_Offering> offerings;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final offering in offerings)
          _OfferingTile(
            offering: offering,
            iconBoxSize: MoreOfferingsSection._iconBoxSize,
            iconBoxRadius: MoreOfferingsSection._iconBoxRadius,
            iconSize: MoreOfferingsSection._iconSize,
            gapBelowIcon: MoreOfferingsSection._gapBelowIcon,
          ),
      ],
    );
  }
}

enum _AssetType { png, svg, vec }

class _Offering {
  const _Offering({
    required this.label,
    required this.background,
    required this.assetPath,
    required this.assetType,
  });

  final String label;
  final Color background;
  final String assetPath;
  final _AssetType assetType;
}

class _OfferingTile extends StatelessWidget {
  const _OfferingTile({
    required this.offering,
    required this.iconBoxSize,
    required this.iconBoxRadius,
    required this.iconSize,
    required this.gapBelowIcon,
  });

  final _Offering offering;
  final double iconBoxSize;
  final double iconBoxRadius;
  final double iconSize;
  final double gapBelowIcon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: iconBoxSize,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: iconBoxSize,
            height: iconBoxSize,
            child: Material(
              color: offering.background,
              borderRadius: BorderRadius.circular(iconBoxRadius),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {},
                child: Center(
                  child: _OfferingIcon(offering: offering, iconSize: iconSize),
                ),
              ),
            ),
          ),
          SizedBox(height: gapBelowIcon),
          Text(
            offering.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.heading,
            ),
          ),
        ],
      ),
    );
  }
}

class _OfferingIcon extends StatelessWidget {
  const _OfferingIcon({required this.offering, required this.iconSize});

  final _Offering offering;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return switch (offering.assetType) {
      _AssetType.png => Image.asset(
        offering.assetPath,
        width: iconSize,
        height: iconSize,
        fit: BoxFit.contain,
      ),
      _AssetType.svg => SvgPicture.asset(
        offering.assetPath,
        width: iconSize,
        height: iconSize,
        fit: BoxFit.contain,
      ),
      _AssetType.vec => VectorGraphic(
        loader: AssetBytesLoader(offering.assetPath),
        width: iconSize,
        height: iconSize,
        fit: BoxFit.contain,
      ),
    };
  }
}
