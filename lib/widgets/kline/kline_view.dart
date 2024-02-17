import 'package:flutter/material.dart';
import 'package:gateio_flutter/widgets/kline/paint/kline_paint_data.dart';
import 'package:gateio_flutter/widgets/kline/kline_controller.dart';
import 'package:gateio_flutter/widgets/kline/kline_gesture_detector.dart';

class KlineView extends StatefulWidget {
  const KlineView({
    super.key,
    required this.currencyPair,
    required this.interval,
    required this.size,
  });

  final String currencyPair;
  final String interval;
  final Size size;

  @override
  State<KlineView> createState() => _KlineViewState();
}

class _KlineViewState extends State<KlineView> {
  late KlineController _controller;

  @override
  void initState() {
    super.initState();

    _controller = KlineController(
      currencyPair: widget.currencyPair,
      interval: widget.interval,
      size: widget.size,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint('azusa - didChangeDependencies');
  }

  @override
  void didUpdateWidget(covariant KlineView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.size != widget.size) {
      _controller.resize(widget.size);
    }
    // debugPrint('azusa - didUpdateWidget - ${context.size}');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KlineGestureDetector(
      controller: _controller,
      child: RepaintBoundary(
        child: StreamBuilder(
          initialData: _controller.data,
          stream: _controller.stream,
          builder: (context, snapshot) => CustomPaint(
            willChange: true,
            size: widget.size,
            painter: KlinePainter(
              data: snapshot.requireData,
            ),
          ),
        ),
      ),
    );
  }
}

class KlinePainter extends CustomPainter {
  KlinePainter({required this.data});

  final KlinePaintData data;

  @override
  void paint(Canvas canvas, Size size) {
    data.paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
