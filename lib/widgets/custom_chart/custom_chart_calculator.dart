import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gateio_flutter/modules/trade/spot/k-line/chart_data_loader.dart';
import 'package:gateio_flutter/utils/merge_sorted_arrays.dart';
import 'package:gateio_flutter/widgets/custom_chart/custom_chart.dart';
import 'package:gateio_flutter/widgets/custom_chart/custom_chart_animation_controller.dart';
import 'package:gateio_flutter/widgets/custom_chart/custom_chart_data.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'custom_chart_calculator.g.dart';

@Riverpod(keepAlive: true)
class CustomChartCalculator extends _$CustomChartCalculator {
  @override
  CustomChartData build() {
    final dataSubscription =
        ref.listen(chartDataLoaderProvider, (previous, next) {
      if (next.hasValue) {
        final value = next.requireValue;
        if (previous != null &&
            previous.hasValue &&
            previous.requireValue.interval == value.interval) {
          state = state.append(value.datas);
        } else {
          state = state.reset().append(value.datas);
        }
      }
    });
    final gestureDetectorSubscription =
        ref.listen(customChartGestureDetectorProvider, (previous, next) {
      //

      state = state.copyWith(offset: next.offset)._calculateDisplayGroups();
    });
    ref.onDispose(() {
      dataSubscription.close();
      gestureDetectorSubscription.close();
    });

    // final datas = ref.read(chartDataLoaderProvider);
    // if (datas.hasValue) {
    //   return state.append(datas.requireValue.datas);
    // } else {
    //   return const CustomChartData();
    // }
    return CustomChartData();
  }

  void reset() {
    state = CustomChartData();
  }

  void setup({double? scale, double? offset, double? displayWidth}) {
    if (scale != null) {
      // TODO:
    }
    if (offset != null) {
      if (offset != state.offset) {
        debugPrint('chart offset: $offset');
        state = state.copyWith(offset: offset)._calculateDisplayGroups();
      }
    }
    if (displayWidth != null) {
      if (displayWidth != state.displayWidth) {
        Future.delayed(Duration.zero).then((value) {
          state = state
              .copyWith(displayWidth: displayWidth)
              ._calculateDisplayGroups();
        });
      }
    }
  }

  /// 根据屏幕宽度获取展示的数据
  List<CustomChartGroupData> getDisplayGroups(double width) {
    if (state.displayWidth != width) {
      state = state.copyWith(displayWidth: width)._calculateDisplayGroups();
    }
    return state.displayGroups;
  }
}

class CustomChartData extends Paintable {
  CustomChartData({
    List<CustomChartGroupData> groups = const [],
    this.displayGroups = const [],
    this.scale = 1,
    this.offset = 0,
    this.displayWidth = 0,
    this.maxDisplayX = 0,
    this.minDisplayX = 0,
    this.maxDisplayPrice = 0,
    this.minDisplayPrice = 0,
    this.maxDisplayVolume = 0,
    this.lastPrice = 0,
    this.drawOffset = 0,
    this.distanceIndex,
    this.drawTag = 0,
    this.last,
    this.points = const [],
  }) : _groups = groups;

  @override
  void paint(Canvas canvas, Size size, Paint paint) {
    // 绘制K线
    for (var group in points) {
      // group.paint(canvas, size, paint, 0, 0);
    }

    /// 绘制当前价格
    if (last != null) {
      last?.paint(canvas, size, paint);
    }
  }

  final List<KLinePointChartData> points;
  final KLineLastChartData? last;

  final List<CustomChartGroupData> _groups;

  final List<CustomChartGroupData> displayGroups;

  /// 图表缩放
  final double scale;

  /// 图表滚动
  final double offset;

  final double maxDisplayX;
  final double minDisplayX;
  final double maxDisplayPrice;
  final double minDisplayPrice;
  final double maxDisplayVolume;
  final double lastPrice;

  final double drawOffset;
  final double displayWidth;

  /// 缓存
  final int? distanceIndex;
  final int drawTag;

  CustomChartData copyWith({
    List<CustomChartGroupData>? groups,
    List<CustomChartGroupData>? displayGroups,
    double? scale,
    double? offset,
    double? displayWidth,
    double? maxDisplayX,
    double? minDisplayX,
    double? maxDisplayPrice,
    double? minDisplayPrice,
    double? maxDisplayVolume,
    double? lastPrice,
    double? drawOffset,
    int? distanceIndex,
    int? drawTag,
  }) {
    return CustomChartData(
      groups: groups ?? _groups,
      displayGroups: displayGroups ?? this.displayGroups,
      scale: scale ?? this.scale,
      offset: offset ?? this.offset,
      displayWidth: displayWidth ?? this.displayWidth,
      maxDisplayX: maxDisplayX ?? this.maxDisplayX,
      minDisplayX: minDisplayX ?? this.minDisplayX,
      maxDisplayPrice: maxDisplayPrice ?? this.maxDisplayPrice,
      minDisplayPrice: minDisplayPrice ?? this.minDisplayPrice,
      maxDisplayVolume: maxDisplayVolume ?? this.maxDisplayVolume,
      lastPrice: lastPrice ?? this.lastPrice,
      drawOffset: drawOffset ?? this.drawOffset,
      distanceIndex: distanceIndex ?? this.distanceIndex,
      drawTag: drawTag ?? this.drawTag,
    );
  }

  CustomChartData reset() {
    return copyWith(
      groups: [],
      displayGroups: [],
      maxDisplayX: 0,
      minDisplayX: 0,
      maxDisplayPrice: 0,
      minDisplayPrice: 0,
      maxDisplayVolume: 0,
      lastPrice: 0,
      drawOffset: 0,
      distanceIndex: -1,
    );
  }

  /// 添加数据
  /// 向当前有序但不一定连续的数组中添加一段有序且连续的数据
  /// 对于重复的元素将使用新数据覆盖旧数据
  CustomChartData append(List<ChartDataEntity> datas) {
    if (datas.isEmpty) {
      return this;
    }

    final newGroups = datas
        .map(
          (e) => CustomChartGroupData.fromData(e),
        )
        .toList();
    final groups = mergeSortedArrays(newGroups, _groups);

    return copyWith(groups: groups, lastPrice: groups.last.object.close)
        ._calculateDisplayGroups();
  }

  /// 计算需要展示的数据和绘制的偏移量
  CustomChartData _calculateDisplayGroups() {
    if (_groups.isEmpty || displayWidth == 0) {
      return this;
    }

    /// 根据缩放和滚动偏移计算需要展示的数据，以及绘制的偏移量
    const displayLimit = 100;
    final segmentWidth = displayWidth / displayLimit;
    final distance = offset / segmentWidth;
    final distanceIndex = distance.floor();
    final drawOffset = (distance - distanceIndex) * segmentWidth;
    // debugPrint('distance: $distance');

    if (this.distanceIndex == distanceIndex) {
      /// 滑动变化较小时无需重新计算需要显示的数据
      /// 仅需要更新绘图偏移量
      return copyWith(
        drawOffset: drawOffset,
        drawTag: drawTag + 1,
      );
    } else {
      final displayStart =
          max(0, _groups.length - displayLimit - distanceIndex);
      final displayEnd = displayStart + displayLimit;
      // debugPrint("Start: $displayStart");

      final displayGroups = _groups.sublist(displayStart, displayEnd);

      return copyWith(
        distanceIndex: distanceIndex,
        drawOffset: drawOffset,
        displayGroups: displayGroups,
        drawTag: drawTag + 1,
      )._calculateDisplayValueRange();
    }
  }

  /// 计算展示数据的最大最小值
  CustomChartData _calculateDisplayValueRange() {
    if (displayGroups.isEmpty) {
      return this;
    }
    final groups = displayGroups;

    var maxDisplayX = groups.last.x;
    var minDisplayX = groups.first.x;
    var maxDisplayPrice = groups.first.object.high;
    var minDisplayPrice = groups.first.object.low;
    var maxDisplayVolume = groups.first.object.baseVolume;

    for (var group in groups) {
      if (group.object.high > maxDisplayPrice) {
        maxDisplayPrice = group.object.high;
      }
      if (group.object.low < minDisplayPrice) {
        minDisplayPrice = group.object.low;
      }
      if (group.object.baseVolume > maxDisplayVolume) {
        maxDisplayVolume = group.object.baseVolume;
      }
    }

    return copyWith(
      maxDisplayX: maxDisplayX,
      minDisplayX: minDisplayX,
      maxDisplayPrice: maxDisplayPrice,
      minDisplayPrice: minDisplayPrice,
      maxDisplayVolume: maxDisplayVolume,
      drawTag: drawTag + 1,
    );
  }
}

class CustomChartGroupData implements Comparable {
  const CustomChartGroupData({
    required this.object,
    required this.x,
    required this.rods,
    required this.volumeRod,
  });
  final ChartDataEntity object;
  final double x;
  final List<CustomChartRodData> rods;
  final CustomChartRodData volumeRod;

  factory CustomChartGroupData.fromData(ChartDataEntity data) {
    final isRise = data.close > data.open;
    final color = isRise ? Colors.red : Colors.green;
    return CustomChartGroupData(
      object: data,
      x: data.timestamp.toDouble(),
      rods: [
        CustomChartRodData(
          minY: isRise ? data.open : data.close,
          maxY: isRise ? data.close : data.open,
          width: 1,
          color: color,
        ),
        if (_checkNeedDrawHighLowPrice(data, isRise))
          CustomChartRodData(
            minY: data.low,
            maxY: data.high,
            width: 0.2,
            color: color,
          ),
      ],
      volumeRod: CustomChartRodData(
        minY: 0,
        maxY: data.baseVolume,
        width: 1,
        color: color,
      ),
    );
  }

  /// 检查是否需要绘制最高、最低价
  static bool _checkNeedDrawHighLowPrice(ChartDataEntity data, bool isRise) {
    if (isRise) {
      return data.high > data.close || data.low < data.open;
    } else {
      return data.high > data.open || data.low < data.close;
    }
  }

  @override
  int compareTo(other) {
    if (other is CustomChartGroupData) {
      return object.timestamp.compareTo(other.object.timestamp);
    }
    return 0;
  }
}

class CustomChartRodData {
  const CustomChartRodData({
    required this.minY,
    required this.maxY,
    required this.width,
    required this.color,
  });
  final double minY;
  final double maxY;
  final double width;
  final Color color;
}

final class CustomChartExtraLinesData {
  //
}

@Riverpod(keepAlive: true)
class CustomChartGestureDetector extends _$CustomChartGestureDetector {
  @override
  CustomChartGestureDetectorState build() {
    return CustomChartGestureDetectorState();
  }

  void onPanStart(DragStartDetails details) {
    debugPrint('onPanStart: ${details.globalPosition}');
    final state = this.state;
    state.controller.stop();

    this.state = state.copyWith(
      panX: details.globalPosition.dx,
    );
  }

  void onPanUpdate(DragUpdateDetails details) {
    final newOffset =
        max(state.offset + details.globalPosition.dx - state.panX!, 0)
            .toDouble();

    state = state.copyWith(
      panX: details.globalPosition.dx,
      offset: newOffset,
    );
    debugPrint('onPanUpdate: $newOffset');
  }

  void onPanEnd(DragEndDetails details, AnimationController controller) {
    debugPrint('onPanEnd: ${details.velocity} -- ${state.panX}');

    if (details.velocity.pixelsPerSecond.dx != 0) {
      final offset = state.offset;
      state.controller.run(controller, (progress) {
        final newOffset =
            offset + progress * details.velocity.pixelsPerSecond.dx * 0.5;
        if (newOffset < 0) {
          state = state.copyWith(offset: 0);
          state.controller.stop();
        } else {
          state = state.copyWith(offset: newOffset);
        }
      });
    }
  }
}

final class CustomChartGestureDetectorState {
  CustomChartGestureDetectorState({
    this.scale = 1,
    this.offset = 0,
    this.panX,
  });

  final double scale;
  final double offset;

  final double? panX;
  final controller = CustomChartAnimationController();

  CustomChartGestureDetectorState copyWith({
    double? scale,
    double? offset,
    double? panX,
  }) {
    return CustomChartGestureDetectorState(
      scale: scale ?? this.scale,
      offset: offset ?? this.offset,
      panX: panX ?? this.panX,
    );
  }
}
