import 'package:flutter/material.dart';
import 'package:k_line_chart_example/modules/trade/spot/kline/calculator/calculator.dart';
import 'package:k_line_chart_example/modules/trade/spot/kline/data/kline_data.dart';
import 'package:k_line_chart_example/modules/trade/spot/kline/kline_configs.dart';
import 'package:k_line_chart_example/modules/trade/spot/kline/painter/kline_floating_text_painter.dart';
import 'package:k_line_chart_example/modules/trade/spot/kline/painter/kline_last_paint_data.dart';
import 'package:k_line_chart_example/modules/trade/spot/kline/painter/kline_mouse_position_painter.dart';
import 'package:k_line_chart_example/modules/trade/spot/kline/painter/kline_point_paint_data.dart';
import 'package:k_line_chart_example/modules/trade/spot/kline/painter/right_titles.dart';

class KlinePaintData {
  KlinePaintData({
    required this.kline,
    int? displayOffset,
    int? displayLimit,
    required this.drawWidth,
    required this.drawHeight,
    required this.scrollOffset,
    required this.segmentWidth,
    required this.points,
    required this.last,
    this.mousePositionX = 0,
    this.mousePositionY = 0,
    this.maxScrollOffset = 0,
    this.lastPoint = const KlinePoint(
      timestamp: 0,
      quoteVolume: 0,
      close: 0,
      high: 0,
      low: 0,
      open: 0,
      baseVolume: 0,
      isClose: false,
    ),
  })  : displayOffset = displayOffset ??
            calculateDisplayPointsOffset(
              segmentWidth,
              scrollOffset,
            ),
        displayLimit = displayLimit ??
            calculateDisplayPointsLimit(
              segmentWidth,
              drawWidth,
            );

  final KlineData kline;

  /// 需要显示的数据偏移
  final int displayOffset;

  /// 需要显示的数据量
  final int displayLimit;

  final double drawWidth;
  final double drawHeight;
  final double scrollOffset;
  final double segmentWidth;

  final double rightTitlesWidth = 80;
  double get pointsDrawWidth => drawWidth - rightTitlesWidth;

  final List<KlinePointPaintData> points;
  final KlineLastPaintData last;

  final double mousePositionX;
  final double mousePositionY;

  /// 根据已加载的数据总量，计算可向左滑动的最大偏移量
  final double maxScrollOffset;

  final KlinePoint lastPoint;

  KlinePaintData copyWith({
    KlineData? kline,
    int? displayOffset,
    int? displayLimit,
    double? drawWidth,
    double? drawHeight,
    double? scrollOffset,
    double? segmentWidth,
    List<KlinePointPaintData>? points,
    KlineLastPaintData? last,
    double? mousePositionX,
    double? mousePositionY,
    double? maxScrollOffset,
    KlinePoint? lastPoint,
  }) {
    return KlinePaintData(
      kline: kline ?? this.kline,
      displayOffset: displayOffset ?? this.displayOffset,
      displayLimit: displayLimit ?? this.displayLimit,
      drawWidth: drawWidth ?? this.drawWidth,
      drawHeight: drawHeight ?? this.drawHeight,
      scrollOffset: scrollOffset ?? this.scrollOffset,
      segmentWidth: segmentWidth ?? this.segmentWidth,
      points: points ?? this.points,
      last: last ?? this.last,
      mousePositionX: mousePositionX ?? this.mousePositionX,
      mousePositionY: mousePositionY ?? this.mousePositionY,
      maxScrollOffset: maxScrollOffset ?? this.maxScrollOffset,
      lastPoint: lastPoint ?? this.lastPoint,
    );
  }

  KlinePaintData copyWithKlinePaintData(KlinePaintData data) {
    var result = copyWith(
      kline: data.kline,
      points: data.points,
      last: data.last,
      maxScrollOffset: data.maxScrollOffset,
    );
    if (result.segmentWidth != data.segmentWidth) {
      result = result.copyWithSegmentWidth(data.segmentWidth);
    }
    if (result.drawWidth != data.drawWidth || result.drawHeight != data.drawHeight) {
      result = result.copyWithDrawSize(data.drawWidth, data.drawHeight);
    }
    if (mousePositionX > 0) {
      result = result.copyWith(
        lastPoint: _rebuildLastPoint(
          kline: kline,
          mouseX: mousePositionX,
          scrollOffset: scrollOffset,
          drawWidth: drawWidth,
        ),
      );
    }
    return result;
  }

  KlinePaintData copyWithKlineData(KlineData kline) {
    if (kline.points.isEmpty) {
      return copyWith(kline: kline);
    }
    return copyWith(
      kline: kline,
      maxScrollOffset: ((kline.total - displayLimit / 2) * segmentWidth),
    ).rebuildPointsAndLast();
  }

  KlinePaintData copyWithScrollOffset(double scrollOffset) {
    return copyWith(
      scrollOffset: scrollOffset,
      displayOffset: calculateDisplayPointsOffset(segmentWidth, scrollOffset),
      lastPoint: _rebuildLastPoint(
        kline: kline,
        mouseX: mousePositionX,
        scrollOffset: scrollOffset,
        drawWidth: drawWidth,
      ),
    );
  }

  KlinePaintData copyWithSegmentWidth(double newSegmentWidth) {
    final double newScrollOffset;
    if (scrollOffset > 0) {
      final indexOffset = (scrollOffset / segmentWidth);
      newScrollOffset = indexOffset * newSegmentWidth;
    } else {
      newScrollOffset = scrollOffset;
    }

    return copyWith(
      scrollOffset: newScrollOffset,
      segmentWidth: newSegmentWidth,
      displayLimit: calculateDisplayPointsLimit(newSegmentWidth, drawWidth),
      points: points.map((e) {
        return e.copyWith(distanceX: e.distance * newSegmentWidth);
      }).toList(),
      maxScrollOffset: ((kline.total - displayLimit / 2) * segmentWidth),
    );
    // TODO: _rebuildLastPoint
  }

  KlinePaintData copyWithDrawSize(double drawWidth, double drawHeight) {
    var result = this;
    if (drawHeight != this.drawHeight) {
      result = result
          .copyWith(
            drawHeight: drawHeight,
          )
          .rebuildPointsAndLast();
    }
    if (result.drawWidth != drawWidth) {
      result = result.copyWith(
        drawWidth: drawWidth,
        displayLimit: calculateDisplayPointsLimit(segmentWidth, drawWidth),
      );
    }
    return result;
  }

  KlinePaintData copyWithMousePosition(double x, double y) {
    return copyWith(
      mousePositionX: x,
      mousePositionY: y,
      lastPoint: _rebuildLastPoint(
        kline: kline,
        mouseX: x,
        scrollOffset: scrollOffset,
        drawWidth: drawWidth,
      ),
    );
  }

  KlinePoint _rebuildLastPoint({
    required KlineData kline,
    required double mouseX,
    required double scrollOffset,
    required double drawWidth,
  }) {
    var point = kline.last;
    if (mouseX > 0 && mouseX < drawWidth - KlineConfigs.rightTitlesWidth) {
      final distanceX = drawWidth - mouseX + scrollOffset;
      if (distanceX >= 0) {
        final index = points.indexWhere((element) => element.distanceX < distanceX);
        if (index >= 0) {
          point = kline.points[index];
        }
      }
    }
    return point;
  }

  /// 在数据变化时，重新计算对应的绘制数据
  /// 影响：K线点数据、画布尺寸、分段宽度
  KlinePaintData rebuildPointsAndLast() {
    final points = kline.points;

    /// 首个K线点数据距离最新数据的索引偏移
    final distance = kline.points.length - 1 + kline.offset;

    final range = kline.valueRange;
    final minPrice = kline.valueRange.minPrice;
    final priceHeight = drawHeight * 0.7;
    final priceBaseY = drawHeight * 0.3;
    final priceYScale = priceHeight / kline.valueRange.priceRange;
    final maxVolumeHeight = drawHeight * 0.25;
    final volumeScale = maxVolumeHeight / kline.valueRange.maxVolume;

    final List<KlinePointPaintData> list = [];
    for (var i = 0; i < points.length; i++) {
      final distanceIndex = distance - i;
      final distanceX = segmentWidth * distanceIndex;

      final point = points[i];
      final openY = drawHeight - (priceBaseY + (point.open - minPrice) * priceYScale);
      final closeY = drawHeight - (priceBaseY + (point.close - minPrice) * priceYScale);
      final lowY = drawHeight - (priceBaseY + (point.low - minPrice) * priceYScale);
      final highY = drawHeight - (priceBaseY + (point.high - minPrice) * priceYScale);
      final volumeHeight = point.baseVolume * volumeScale;

      if (volumeHeight > maxVolumeHeight) {
        debugPrint(
            'KlinePainter 1: $volumeHeight > $maxVolumeHeight  ${kline.valueRange.maxVolume} ${point.baseVolume} x $drawHeight ${kline.points.length}');
      }

      if (volumeHeight < 0) {
        debugPrint(
            'KlinePainter 2: $volumeHeight > $maxVolumeHeight  ${kline.valueRange.maxVolume} ${point.baseVolume} x $drawHeight ${kline.points.length}');
      }

      final volumeY = drawHeight - volumeHeight;

      if (volumeY > drawHeight) {
        debugPrint(
            'KlinePainter 3: $volumeHeight > $maxVolumeHeight  ${kline.valueRange.maxVolume} ${point.baseVolume} x $drawHeight ${kline.points.length}');
      }

      list.add(KlinePointPaintData(
        distance: distanceIndex,
        distanceX: distanceX,
        openPriceY: openY,
        closePriceY: closeY,
        lowPriceY: lowY,
        highPriceY: highY,
        volumeY: volumeY,
      ));
    }

    final lastClose = kline.last.close;
    final double lastY;
    if (lastClose < range.minPrice) {
      lastY = priceHeight;
    } else if (lastClose > range.maxPrice) {
      lastY = 0;
    } else {
      lastY = drawHeight - (priceBaseY + (lastClose - minPrice) * priceYScale);
    }

    return copyWith(
      points: list,
      last: KlineLastPaintData(
        last: lastClose,
        y: lastY,
        isRise: kline.last.close > kline.last.open,
      ),
    );
  }

  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    /// 绘制背景
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    if (kline.points.isEmpty) {
      return;
    }

    // debugPrint('KlinePainter: $scrollOffset $segmentWidth $displayLimit $maxScrollOffset');

    /// 绘制K线点
    for (var element in points) {
      element.paint(canvas, size, paint, segmentWidth, scrollOffset);
    }

    /// 绘制最新价格
    last.paint(canvas, size, paint);

    /// 绘制右侧价格区间
    KlineRightTitlesPainter.paint(canvas, size, paint, kline.valueRange);

    /// 绘制价格和交易量分割线
    KlineConfigs.paintPriceVolumeDivider(canvas, size, paint);

    /// 绘制鼠标位置
    KlineMousePositionPainter.paint(canvas, size, paint, this);

    /// 绘制悬浮文字
    KlineFloatingTextPainter.paint(canvas, size, paint, this);
  }
}
