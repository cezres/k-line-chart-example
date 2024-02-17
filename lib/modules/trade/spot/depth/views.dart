import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gateapi_dart/gateapi_dart.dart';
import 'package:gateapi_dart/types/order_book.dart';
import 'package:k_line_chart_example/modules/trade/spot/currency_pair/providers.dart';
import 'package:k_line_chart_example/modules/trade/spot/depth/providers.dart';
import 'package:k_line_chart_example/modules/trade/spot/ticker/providers.dart';
import 'package:k_line_chart_example/utils/format_decimal.dart';

class OrderBookView extends ConsumerWidget {
  const OrderBookView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pair = ref.watch(currentCurrencyPairProvider);
    if (pair == null) {
      return const SizedBox.shrink();
    }

    final orderBook = ref.watch(orderBookStreamProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) => orderBook.when(
          data: (data) {
            return _buildContent(data, pair, constraints.maxWidth);
          },
          loading: () => const SizedBox.shrink(),
          error: (error, _) => const SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget _buildContent(OrderBook data, CurrencyPair pair, double width) {
    return Column(
      children: [
        _buildTitle(pair),
        _OrderBookChartView(
          currencyPair: pair,
          data: data.asks,
          width: width,
          height: 200,
          priceColor: Colors.green,
          reversedChart: true,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: _buildPrice(),
        ),
        _OrderBookChartView(
          currencyPair: pair,
          data: data.bids,
          width: width,
          height: 200,
          priceColor: Colors.red,
        ),
      ],
    );
  }

  Widget _buildPrice() {
    return Consumer(
      builder: (context, ref, child) => ref.watch(tickerStreamProvider).when(
            data: (data) {
              return Row(
                children: [
                  Text(
                    data.last,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: data.changePercentage > Decimal.zero
                          ? Colors.red
                          : Colors.green,
                    ),
                  ),
                ],
              );
            },
            error: (error, stackTrace) => const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
          ),
    );
  }

  Widget _buildTitle(CurrencyPair pair) {
    return Row(
      children: [
        Expanded(
          child: Text(
            "价格(${pair.quote})",
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            "数量(${pair.base})",
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            "总额(${pair.quote})",
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}

class _OrderBookChartView extends StatelessWidget {
  const _OrderBookChartView({
    required this.currencyPair,
    required this.data,
    required this.width,
    required this.height,
    required this.priceColor,
    this.reversedChart = false,
  });

  final CurrencyPair currencyPair;
  final List<List<Decimal>> data;
  final double width;
  final double height;
  final Color priceColor;
  final bool reversedChart;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomDepthChart(
              values: data.map((e) => e[1].toDouble()).toList(),
              reversed: reversedChart,
            ),
          ),
          Positioned.fill(
            child: _buildListView(),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return Column(
      children: data
          .map(
            (e) => SizedBox(
              height: height / data.length,
              child: _buildListViewItem(e),
            ),
          )
          .toList(),
    );
  }

  Widget _buildListViewItem(List<Decimal> data) {
    return Row(
      children: [
        Expanded(
          child: Text(
            data[0].toString(),
            style: TextStyle(
              fontSize: 12,
              color: priceColor,
            ),
          ),
        ),
        Expanded(
          child: Text(
            data[1].toStringAsFixed(5),
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: Text(
            formatAmountDecimal(data[0] * data[1]),
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class CustomDepthChart extends ConsumerWidget {
  const CustomDepthChart({
    super.key,
    required this.values,
    required this.reversed,
  });

  final List<double> values;
  final bool reversed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomPaint(
      painter: CustomDepthChartPainter(
        values: values,
        reversed: reversed,
      ),
    );
  }
}

class CustomDepthChartPainter extends CustomPainter {
  const CustomDepthChartPainter({required this.values, required this.reversed});

  final List<double> values;
  final bool reversed;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green[50]!
      ..style = PaintingStyle.fill;

    final double segmentHeight = size.height / values.length;

    List<double> newValues = [];
    double tempValue = 0;
    for (var i = 0; i < values.length; i++) {
      tempValue += values[i];
      newValues.add(tempValue);
    }
    if (reversed) {
      newValues = newValues.reversed.toList();
    }
    final double max = reversed ? newValues.first : newValues.last;

    for (var i = 0; i < newValues.length; i++) {
      final width = size.width * newValues[i] / max;
      final x = size.width - width;
      final rect = Rect.fromLTWH(
        x,
        i * segmentHeight,
        width,
        segmentHeight,
      );
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is CustomDepthChartPainter) {
      if (reversed == oldDelegate.reversed &&
          listEquals(values, oldDelegate.values)) {
        return false;
      }
    }
    return true;
  }
}
