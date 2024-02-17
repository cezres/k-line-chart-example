import 'package:flutter/material.dart';
import 'package:gateio_flutter/widgets/kline/kline_controller.dart';

class KlineGestureDetector extends StatefulWidget {
  const KlineGestureDetector({
    super.key,
    required this.controller,
    required this.child,
    required this.willChangeScroll,
    required this.onChangedScroll,
    required this.willChangeScale,
    required this.onChangedScale,
  });

  final bool Function(double offset) willChangeScroll;
  final bool Function(double scale) willChangeScale;
  final void Function(double offset) onChangedScroll;
  final void Function(double scale) onChangedScale;

  final KlineController controller;
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

  double get scrollOffset => widget.controller.data.scrollOffset;
  set scrollOffset(double offset) {
    widget.controller.scroll(offset);
  }

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
      onTap: () {
        debugPrint('azusa - onTap');
      },
      onScaleStart: (details) {
        // debugPrint("${details.pointerCount} - ${details.localFocalPoint.dx}");
        _velocity = null;
        _startOffset = details.localFocalPoint.dx;
        _tempScrollOffset = scrollOffset;
        _controller.stop();
      },
      onScaleUpdate: (details) {
        debugPrint("${details.pointerCount} - ${details.scale}");
        final offset = details.localFocalPoint.dx - _startOffset;
        setNewScrollOffset(_tempScrollOffset + offset);
      },
      onScaleEnd: (details) {
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
    if (widget.willChangeScroll(offset)) {
      scrollOffset = offset;
      // widget.onChangedScroll(scrollOffset);
      return true;
    }
    return false;
  }
}
