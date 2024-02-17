import 'package:flutter/material.dart';

class KlineGestureDetector extends StatefulWidget {
  const KlineGestureDetector({
    super.key,
    required this.child,
    required this.willChangeScrollOffset,
    required this.onChangedScrollOffset,
  });

  final bool Function(double offset) willChangeScrollOffset;
  final void Function(double offset) onChangedScrollOffset;
  final Widget child;

  @override
  State<KlineGestureDetector> createState() => _KlineGestureDetectorState();
}

class _KlineGestureDetectorState extends State<KlineGestureDetector>
    with TickerProviderStateMixin {
  late final AnimationController _controller;

  double? _velocity;
  double _startOffset = 0;
  double _tempScrollOffset = 0;

  double scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _controller.addListener(() {
      if (_velocity == null) {
        return;
      }
      final scrollOffset = _tempScrollOffset + _velocity! * _controller.value;
      if (!setNewScrollOffset(scrollOffset)) {
        _controller.stop();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        _velocity = null;
        _startOffset = details.globalPosition.dx;
        _tempScrollOffset = scrollOffset;
        _controller.stop();
      },
      onPanUpdate: (details) {
        final offset = details.globalPosition.dx - _startOffset;
        setNewScrollOffset(_tempScrollOffset + offset);
      },
      onPanEnd: (details) {
        _velocity = details.velocity.pixelsPerSecond.dx * 0.8;
        if (_velocity != 0) {
          _tempScrollOffset = scrollOffset;
          _controller.reset();
          _controller.animateTo(1, curve: Curves.easeOut);
        }
      },
      child: widget.child,
    );
  }

  bool setNewScrollOffset(double offset) {
    if (widget.willChangeScrollOffset(offset)) {
      scrollOffset = offset;
      widget.onChangedScrollOffset(scrollOffset);
      return true;
    }
    return false;
  }
}
