import 'package:flutter/material.dart';
import 'package:gateio_flutter/widgets/kline/calculator/calculator.dart';
import 'package:gateio_flutter/widgets/kline/data/kline_data.dart';

class KlineDrawData {
  KlineDrawData({
    required this.kline,
    int? displayOffset,
    int? displayLimit,
    required this.drawWidth,
    required this.drawHeight,
    required this.scrollOffset,
    required this.segmentWidth,
    required this.points,
    required this.last,
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

  final List<KlinePointDrawData> points;
  final KlineLastDrawData last;

  KlineDrawData copyWith({
    KlineData? kline,
    int? displayOffset,
    int? displayLimit,
    double? drawWidth,
    double? drawHeight,
    double? scrollOffset,
    double? segmentWidth,
    List<KlinePointDrawData>? points,
    KlineLastDrawData? last,
  }) {
    return KlineDrawData(
      kline: kline ?? this.kline,
      displayOffset: displayOffset ?? this.displayOffset,
      displayLimit: displayLimit ?? this.displayLimit,
      drawWidth: drawWidth ?? this.drawWidth,
      drawHeight: drawHeight ?? this.drawHeight,
      scrollOffset: scrollOffset ?? this.scrollOffset,
      segmentWidth: segmentWidth ?? this.segmentWidth,
      points: points ?? this.points,
      last: last ?? this.last,
    );
  }

  KlineDrawData copyWithKlineData(KlineData kline) {
    if (kline.points.isEmpty) {
      return this;
    }

    final minPrice = kline.valueRange.minPrice;
    final priceHeight = drawHeight * 0.7;
    final priceBaseY = drawHeight * 0.3;
    final priceYScale = priceHeight / kline.valueRange.priceRange;

    final last = kline.last;
    final lastY = drawHeight - (priceBaseY + (last - minPrice) * priceYScale);

    return copyWith(
      kline: kline,
      points: calculatePointDrawDatas(
        kline: kline,
        drawHeight: drawHeight,
        segmentWidth: segmentWidth,
      ),
      last: KlineLastDrawData(
        last: last,
        y: lastY,
      ),
    );
  }

  KlineDrawData copyWithScrollOffset(double scrollOffset) {
    return copyWith(
      scrollOffset: scrollOffset,
      displayOffset: calculateDisplayPointsOffset(segmentWidth, scrollOffset),
    );
  }

  /// 在数据变化时，重新计算对应的绘制数据
  /// 影响：K线点、画布尺寸、分段宽度
  static List<KlinePointDrawData> calculatePointDrawDatas({
    required KlineData kline,
    required double drawHeight,
    required double segmentWidth,
  }) {
    final points = kline.points;

    /// 首个K线点数据距离最新数据的索引偏移
    final distance = kline.points.length - 1 + kline.offset;

    final minPrice = kline.valueRange.minPrice;
    final priceHeight = drawHeight * 0.7;
    final priceBaseY = drawHeight * 0.3;
    final priceYScale = priceHeight / kline.valueRange.priceRange;
    final volumeHeight = drawHeight * 0.25;
    final volumeScale = volumeHeight / kline.valueRange.maxVolume;

    final List<KlinePointDrawData> list = [];
    for (var i = 0; i < points.length; i++) {
      final distanceIndex = distance - i;

      final point = points[i];
      final openY =
          drawHeight - (priceBaseY + (point.open - minPrice) * priceYScale);
      final closeY =
          drawHeight - (priceBaseY + (point.close - minPrice) * priceYScale);
      final lowY =
          drawHeight - (priceBaseY + (point.low - minPrice) * priceYScale);
      final highY =
          drawHeight - (priceBaseY + (point.high - minPrice) * priceYScale);
      final volumeY = drawHeight - point.baseVolume * volumeScale;

      list.add(KlinePointDrawData(
        distance: distanceIndex - i,
        distanceX: segmentWidth * distanceIndex,
        openPriceY: openY,
        closePriceY: closeY,
        lowPriceY: lowY,
        highPriceY: highY,
        volumeY: volumeY,
      ));
    }
    return list;
  }

  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.fill;

    /// 绘制背景
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    /// 绘制价格和交易量分割线
    paint.color = Colors.grey[300]!;
    paint.strokeWidth = 1;
    canvas.drawLine(
      Offset(0, size.height * 0.725),
      Offset(size.width, size.height * 0.725),
      paint,
    );

    if (kline.points.isEmpty) {
      return;
    }

    paint.style = PaintingStyle.stroke;

    for (var element in points) {
      final displayX = size.width - (element.distanceX - scrollOffset);
      if (displayX > size.width + segmentWidth || displayX < 0) {
        continue;
      }
      final x = displayX - segmentWidth / 2;

      paint.color =
          element.closePriceY < element.openPriceY ? Colors.red : Colors.green;

      paint.strokeWidth = segmentWidth;
      canvas.drawLine(
        Offset(x, element.openPriceY),
        Offset(x, element.closePriceY),
        paint,
      );

      canvas.drawLine(
        Offset(x, size.height),
        Offset(x, element.volumeY),
        paint,
      );

      paint.strokeWidth = 1;
      canvas.drawLine(
        Offset(x, element.highPriceY),
        Offset(x, element.lowPriceY),
        paint,
      );
    }

    last.paint(canvas, size, paint);
  }
}

class KlinePointDrawData {
  KlinePointDrawData({
    required this.distance,
    required this.distanceX,
    // required this.x,
    required this.openPriceY,
    required this.closePriceY,
    required this.lowPriceY,
    required this.highPriceY,
    required this.volumeY,
  });

  /// K线点数据距离最新数据的索引偏移
  final int distance;

  /// K线点数据距离最新数据的X坐标偏移 distance * segmentWidth
  final double distanceX;
  // final double x;

  final double openPriceY;
  final double closePriceY;
  final double lowPriceY;
  final double highPriceY;
  final double volumeY;
}

/// K线最新数据和绘制信息
class KlineLastDrawData {
  KlineLastDrawData({
    required this.last,
    required this.y,
  });

  final double last;
  final double y;

  /// 缓存，需要在主 Isolate 中执行
  TextPainter? _textPainter;
  Offset? _textOffset;
  RRect? _textBackgroundRect;
  Path? _linePath;

  void paint(Canvas canvas, Size size, Paint paint) {
    if (last == 0 || size.isEmpty) {
      return;
    }

    if (_textPainter == null) {
      final textSpan = TextSpan(
        text: '$last',
        style: const TextStyle(color: Colors.black, fontSize: 12),
      );

      _textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );

      _textPainter!.layout(
        minWidth: 0,
        maxWidth: size.width,
      );

      _textOffset = Offset(
        size.width * 0.25,
        y - _textPainter!.height / 2,
      );

      final rect = Rect.fromLTWH(
        _textOffset!.dx - 4,
        _textOffset!.dy - 2,
        _textPainter!.width + 8,
        _textPainter!.height + 4,
      );
      _textBackgroundRect = RRect.fromRectAndRadius(
        rect,
        const Radius.circular(4),
      );

      const dashWidth = 2.0;
      const dashSpace = 2.0;
      double startX = 0;

      final path = Path();
      while (startX < size.width) {
        if (startX > (rect.left - 4) &&
            (startX + dashWidth) < (rect.right + 4)) {
          startX += dashWidth + dashSpace;
          continue;
        }

        path.moveTo(startX, y);
        path.lineTo(startX + dashWidth, y);

        startX += dashWidth + dashSpace;
      }

      _linePath = path;
    }

    /// 绘制文本背景
    paint.color = Colors.grey[300]!;
    paint.style = PaintingStyle.fill;
    canvas.drawRRect(_textBackgroundRect!, paint);

    /// 绘制文本
    _textPainter!.paint(
      canvas,
      _textOffset!,
    );

    // 绘制虚线
    paint.color = Colors.red;
    paint.strokeWidth = 1;
    paint.style = PaintingStyle.stroke;
    canvas.drawPath(_linePath!, paint);
  }
}
