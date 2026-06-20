import 'package:flutter/material.dart';

/// MM:SS countdown with slide-down digit transitions.
class AnimatedCountdown extends StatelessWidget {
  const AnimatedCountdown({
    super.key,
    required this.remaining,
    required this.style,
  });

  final Duration remaining;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final minutes = remaining.inMinutes.remainder(60);
    final seconds = remaining.inSeconds.remainder(60);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _SlidingCountdownSegment(value: minutes, style: style),
        Text(':', style: style),
        _SlidingCountdownSegment(value: seconds, style: style),
      ],
    );
  }
}

class _SlidingCountdownSegment extends StatefulWidget {
  const _SlidingCountdownSegment({required this.value, required this.style});

  final int value;
  final TextStyle style;

  @override
  State<_SlidingCountdownSegment> createState() =>
      _SlidingCountdownSegmentState();
}

class _SlidingCountdownSegmentState extends State<_SlidingCountdownSegment>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 400);

  late AnimationController _controller;
  late int _current;
  int? _previous;

  @override
  void initState() {
    super.initState();
    _current = widget.value;
    _controller = AnimationController(vsync: this, duration: _duration);
  }

  @override
  void didUpdateWidget(covariant _SlidingCountdownSegment oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value == _current) return;
    _previous = _current;
    _current = widget.value;
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _lineHeight {
    final fontSize = widget.style.fontSize ?? 42;
    final height = widget.style.height ?? 1.0;
    return fontSize * height;
  }

  String _pad(int value) => value.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final lineHeight = _lineHeight;
    final t = _controller.isAnimating
        ? Curves.easeInOutCubic.transform(_controller.value)
        : 1.0;
    final showPrevious = _previous != null && _controller.isAnimating;

    return ClipRect(
      child: SizedBox(
        height: lineHeight,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.hardEdge,
          children: [
            if (showPrevious)
              Transform.translate(
                offset: Offset(0, t * lineHeight),
                child: Text(_pad(_previous!), style: widget.style),
              ),
            Transform.translate(
              offset: Offset(0, (t - 1) * lineHeight),
              child: Text(_pad(_current), style: widget.style),
            ),
          ],
        ),
      ),
    );
  }
}
