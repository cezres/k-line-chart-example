import 'package:flutter/material.dart';
import 'package:k_line_chart_example/modules/trade/spot/kline/kline_configs.dart';
import 'package:k_line_chart_example/modules/trade/spot/kline/painter/kline_paint_data.dart';
import 'package:k_line_chart_example/modules/trade/spot/kline/kline_controller.dart';
import 'package:k_line_chart_example/modules/trade/spot/kline/kline_gesture_detector.dart';

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

  Size get chartSize => Size(widget.size.width, widget.size.height - 20);

  @override
  void initState() {
    super.initState();

    _controller = KlineController(
      currencyPair: widget.currencyPair,
      interval: widget.interval,
      size: chartSize,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant KlineView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.size != widget.size) {
      _controller.resize(chartSize);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('KlineView build - $chartSize');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 20,
          padding: const EdgeInsets.only(left: 12),
          alignment: Alignment.centerLeft,
          child: StreamBuilder(
            stream: _controller.stream,
            builder: (context, snapshot) {
              final point = snapshot.data?.lastPoint;
              if (point == null) {
                return const SizedBox.shrink();
              }
              if (point.timestamp == 0) {
                return const SizedBox.shrink();
              }
              final color = point.close > point.open ? KlineConfigs.riseColor : KlineConfigs.fallColor;
              return Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'Open:'),
                    TextSpan(
                      text: point.open.toStringAsFixed(1),
                      style: TextStyle(color: color),
                    ),
                    const TextSpan(text: ' High:'),
                    TextSpan(
                      text: point.high.toStringAsFixed(1),
                      style: TextStyle(color: color),
                    ),
                    const TextSpan(text: ' Low:'),
                    TextSpan(
                      text: point.low.toStringAsFixed(1),
                      style: TextStyle(color: color),
                    ),
                    const TextSpan(text: ' Close:'),
                    TextSpan(
                      text: point.close.toStringAsFixed(1),
                      style: TextStyle(color: color),
                    ),
                  ],
                ),
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              );
            },
          ),
        ),
        KlineGestureDetector(
          controller: _controller,
          child: RepaintBoundary(
            child: StreamBuilder(
              initialData: _controller.data,
              stream: _controller.stream,
              builder: (context, snapshot) => CustomPaint(
                willChange: true,
                size: chartSize,
                painter: KlinePainter(
                  data: snapshot.requireData,
                ),
              ),
            ),
          ),
        ),
      ],
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
