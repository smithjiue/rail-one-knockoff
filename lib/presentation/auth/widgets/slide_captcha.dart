import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rail_one/core/theme/app_colors.dart';

class SlideMatchLabel extends StatelessWidget {
  const SlideMatchLabel({super.key, required this.actionText});

  final String actionText;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.authPrimaryDark,
          height: 1.3,
        ),
        children: [
          const TextSpan(text: 'Slide & Match to '),
          TextSpan(
            text: actionText,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.authLink,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

class SlideCaptcha extends StatefulWidget {
  const SlideCaptcha({super.key, required this.onMatched, this.onMismatch});

  final VoidCallback onMatched;
  final VoidCallback? onMismatch;

  @override
  State<SlideCaptcha> createState() => _SlideCaptchaState();
}

class _SlideCaptchaState extends State<SlideCaptcha> {
  static const _thumbSize = 52.0;
  static const _trackHeight = 56.0;

  double _dragOffset = 0;
  bool _matched = false;
  bool _showArrow = true;
  late final int _targetIndex;
  late final List<String> _pieces;

  @override
  void initState() {
    super.initState();
    final random = math.Random();
    _targetIndex = random.nextInt(3);
    _pieces = _generateUniquePieces(random);
  }

  List<String> _generateUniquePieces(math.Random random) {
    const chars = '347892';
    final pool = chars.split('')..shuffle(random);
    return pool.take(3).toList();
  }

  double _maxDrag(double trackWidth) =>
      math.max(0, trackWidth - _thumbSize - 8);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth = constraints.maxWidth;
        final maxDrag = _maxDrag(trackWidth);
        final targetStart = trackWidth - 8 - (3 * 44) - (2 * 8);
        final targetCenterX =
            targetStart + _targetIndex * 52 + 22 - _thumbSize / 2;

        return Container(
          height: _trackHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.authRegisterButton, width: 1.5),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                right: 8,
                top: 0,
                bottom: 0,
                child: Row(
                  children: List.generate(3, (index) {
                    final isTarget = index == _targetIndex;
                    return Padding(
                      padding: EdgeInsets.only(left: index == 0 ? 0 : 8),
                      child: _CaptchaTarget(
                        label: _pieces[index],
                        highlighted: _matched && isTarget,
                      ),
                    );
                  }),
                ),
              ),
              Positioned(
                left: 4 + _dragOffset,
                top: 2,
                child: GestureDetector(
                  onHorizontalDragStart: _matched
                      ? null
                      : (_) => setState(() => _showArrow = false),
                  onHorizontalDragUpdate: _matched
                      ? null
                      : (details) {
                          setState(() {
                            _dragOffset = (_dragOffset + details.delta.dx)
                                .clamp(0, maxDrag);
                          });
                        },
                  onHorizontalDragEnd: _matched
                      ? null
                      : (_) {
                          final thumbCenter = _dragOffset + _thumbSize / 2;
                          final matched =
                              (thumbCenter - targetCenterX).abs() < 28;
                          if (matched) {
                            setState(() {
                              _matched = true;
                              _dragOffset = targetCenterX;
                            });
                            widget.onMatched();
                          } else {
                            setState(() {
                              _dragOffset = 0;
                              _showArrow = true;
                            });
                            widget.onMismatch?.call();
                          }
                        },
                  child: _CaptchaThumb(
                    label: _pieces[_targetIndex],
                    showArrow: _showArrow,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CaptchaActionRow extends StatelessWidget {
  const CaptchaActionRow({
    super.key,
    required this.onRefresh,
    this.showAudio = false,
    this.onAudio,
  });

  final VoidCallback onRefresh;
  final bool showAudio;
  final VoidCallback? onAudio;

  static const _linkStyle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.authLink,
    height: 1.2,
  );

  @override
  Widget build(BuildContext context) {
    final refreshButton = TextButton(
      onPressed: onRefresh,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.refresh_rounded, size: 12, color: AppColors.authLink),
          SizedBox(width: 6),
          Text(
            'Refresh Captcha',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.authLink,
            ),
          ),
        ],
      ),
    );

    if (!showAudio) {
      return Center(child: refreshButton);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        refreshButton,
        const SizedBox(height: 8),
        TextButton(
          onPressed: onAudio,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'Or Try Audio Captcha',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.authLink,
                ),
              ),
              SizedBox(width: 6),
              Icon(
                Icons.volume_up_outlined,
                size: 12,
                color: AppColors.authLink,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CaptchaThumb extends StatelessWidget {
  const _CaptchaThumb({required this.label, this.showArrow = true});

  final String label;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CaptchaCircle(label: label, size: 48, vivid: true),
        if (showArrow) ...[
          const SizedBox(width: 4),
          const Icon(
            Icons.keyboard_double_arrow_right_rounded,
            color: AppColors.authPrimary,
            size: 22,
          ),
        ],
      ],
    );
  }
}

class _CaptchaTarget extends StatelessWidget {
  const _CaptchaTarget({required this.label, required this.highlighted});

  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return _CaptchaCircle(
      label: label,
      size: 44,
      vivid: highlighted,
      muted: !highlighted,
    );
  }
}

class _CaptchaCircle extends StatelessWidget {
  const _CaptchaCircle({
    required this.label,
    required this.size,
    this.vivid = false,
    this.muted = false,
  });

  final String label;
  final double size;
  final bool vivid;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: muted ? const Color(0xFFE8ECF0) : const Color(0xFFF5F0E8),
        border: Border.all(
          color: vivid ? AppColors.authPrimary : AppColors.borderLight,
          width: vivid ? 2 : 1,
        ),
        boxShadow: vivid
            ? [
                BoxShadow(
                  color: AppColors.authPrimary.withValues(alpha: 0.2),
                  blurRadius: 6,
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: size * 0.42,
          fontWeight: FontWeight.w700,
          color: muted ? AppColors.authHint : const Color(0xFF5C4A3A),
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
