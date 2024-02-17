import 'package:flutter/material.dart';
import 'package:gateio_flutter/widgets/custom_chart/custom_chart.dart';
import 'package:gateio_flutter/widgets/custom_chart/custom_chart_calculator.dart';
import 'package:gateio_flutter/widgets/custom_chart/k_line_data_loader.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'k_line_paint_data.g.dart';

// @Riverpod(keepAlive: true)
// KlinePaintDataState klinePaintData(KlinePaintDataRef ref) {
//   final offset = ref.watch(
//       customChartGestureDetectorProvider.select((value) => value.offset));
//   final data = ref.watch(klineDataProvider);

//   debugPrint('azusa - offset: $offset');

//   return KlinePaintDataState(
//     points: data.value?.points ?? [],
//   );
// }

@Riverpod(keepAlive: true)
class KlinePaintData extends _$KlinePaintData {
  @override
  KlinePaintDataState build() {
    ref.listen(
      customChartGestureDetectorProvider.select((value) => value.offset),
      (previous, next) => _listenScrollOffset(next),
    );
    ref.listen(klineDataProvider, (previous, next) {
      _listenKlineData(next.requireValue);
    });

    return KlinePaintDataState();
  }

  void _listenScrollOffset(double offset) {
    debugPrint('azusa - offset: $offset');
  }

  void _listenKlineData(KlineData data) {
    debugPrint('azusa - klineDataProvider: $data');
  }
}

class KlinePaintDataState extends Paintable {
  KlinePaintDataState({
    this.points = const [],
    this.width = 0,
    this.height = 0,
  });

  final List<KlinePoint> points;
  final double width;
  final double height;

  @override
  void paint(Canvas canvas, Size size, Paint paint) {
    // canvas.translate(dx, dy)
    // canvas.scale(sx)
    if (size.isEmpty) {
      return;
    }

    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
    // TODO: implement paint
  }
}
