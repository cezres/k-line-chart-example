import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gateio_flutter/widgets/custom_chart/custom_chart_calculator.dart';
import 'package:gateio_flutter/widgets/custom_chart/k_line_calculator.dart';

class CustomChart extends StatelessWidget {
  const CustomChart({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SizedBox(
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: RepaintBoundary(
                child: Consumer(
                  builder: (context, ref, child) {
                    // final calculator =
                    //     ref.read(customChartCalculatorProvider.notifier);
                    // calculator.setup(
                    //   displayWidth: constraints.maxWidth,
                    // );
                    // ref.watch(customChartCalculatorProvider
                    //     .select((value) => value.drawTag));

                    // final state = ref.read(customChartCalculatorProvider);
                    // return CustomPaint(
                    //   isComplex: true,
                    //   willChange: true,
                    //   painter: CustomChartPainter(state: state),
                    // );

                    final calculator = ref.watch(kLineCalculatorProvider);
                    calculator.setSize(
                      constraints.maxWidth,
                      constraints.maxHeight,
                    );
                    return StreamBuilder(
                      stream: calculator.stream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState !=
                            ConnectionState.active) {
                          return const SizedBox.shrink();
                        }
                        return CustomPaint(
                          painter: CustomChartPainter(
                            state: snapshot.requireData,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            const Positioned.fill(child: CustomChartGestureDetector()),
          ],
        ),
      ),
    );
  }
}

abstract class Paintable {
  void paint(Canvas canvas, Size size, Paint paint);
}

class CustomChartPainter extends CustomPainter {
  CustomChartPainter({required this.state});

  final CustomChartData state;

  @override
  void paint(Canvas canvas, Size size) {
    // debugPrint("draw - a");
    if (size.isEmpty) {
      return;
    }

    final groups = state.displayGroups;

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    /// 绘制背景
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    final double segmentWidth = size.width / groups.length;

    /// 绘制图表

    /// 计算显示的数据

    /// 计算值范围
    final maxPrice = max(state.maxDisplayPrice, state.lastPrice);
    final minPrice = min(state.minDisplayPrice, state.lastPrice);
    final double priceRange = maxPrice - minPrice;
    final double xRange = state.maxDisplayX - state.minDisplayX;

    final double priceHeight = size.height * 0.7;
    final double priceBaseY = size.height * 0.3;
    final double priceYScale = priceHeight / priceRange;

    final double volumeHeight = size.height * 0.25;
    final double volumeYScale = volumeHeight / state.maxDisplayVolume;

    /// 绘制分割线
    paint.color = Colors.grey[300]!;
    paint.strokeWidth = 1;
    canvas.drawLine(
      Offset(0, size.height * 0.725),
      Offset(size.width, size.height * 0.725),
      paint,
    );

    for (var group in groups) {
      final x = ((group.x - state.minDisplayX) / xRange * size.width +
          state.drawOffset);

      /// 绘制价格
      for (var element in group.rods) {
        final minY =
            (element.minY - state.minDisplayPrice) * priceYScale + priceBaseY;
        final maxY =
            (element.maxY - state.minDisplayPrice) * priceYScale + priceBaseY;

        paint.color = element.color;
        paint.strokeWidth =
            max((segmentWidth * element.width).floorToDouble(), 1);

        // [size.height] 翻转Y轴坐标系
        canvas.drawLine(
          Offset(x, size.height - minY),
          Offset(x, size.height - maxY),
          paint,
        );
      }

      /// 绘制成交量
      // final volumeMaxY = group.volumeRod.maxY * volumeYScale;
      // paint.strokeWidth = max(segmentWidth, 1).floorToDouble();
      // canvas.drawLine(
      //   Offset(x, size.height),
      //   Offset(x, size.height - volumeMaxY),
      //   paint,
      // );
    }

    state.paint(canvas, size, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class CustomChartGestureDetector extends ConsumerStatefulWidget {
  const CustomChartGestureDetector({super.key});

  @override
  ConsumerState<CustomChartGestureDetector> createState() =>
      _CustomChartGestureDetectorState();
}

class _CustomChartGestureDetectorState
    extends ConsumerState<CustomChartGestureDetector>
    with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _controller.addListener(() {
      debugPrint('controller value: ${_controller.value}');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gestureDetector =
        ref.read(customChartGestureDetectorProvider.notifier);
    return GestureDetector(
      onPanStart: (details) {
        gestureDetector.onPanStart(details);
      },
      onPanUpdate: (details) {
        gestureDetector.onPanUpdate(details);
      },
      onPanEnd: (details) {
        gestureDetector.onPanEnd(details, _controller);
      },
      // onScaleStart: (details) {
      //   debugPrint('onScaleStart');
      // },
      // onScaleUpdate: (details) {
      //   debugPrint('onScaleUpdate - ${details.scale}');
      // },
      // onScaleEnd: (details) {
      //   debugPrint('onScaleEnd');
      // },
      // child: const ChartScrollControl(),
    );
  }
}
