import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gateapi_dart/gateapi_dart.dart';
import 'package:gateio_flutter/modules/trade/spot/currency_pair/providers.dart';
import 'package:gateio_flutter/modules/trade/spot/order_book/providers.dart';
import 'package:gateio_flutter/modules/trade/spot/ticker/providers.dart';
import 'package:gateio_flutter/utils/format_decimal.dart';

class OrderBookView extends ConsumerWidget {
  const OrderBookView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pair = ref.watch(currentCurrencyPairProvider);
    if (pair == null) {
      return const SizedBox.shrink();
    }

    final orderBook = ref.watch(orderBookStreamProvider);
    return SizedBox(
      width: 240,
      child: orderBook.when(
        data: (data) {
          return Column(
            children: [
              Row(
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
              ),
              _OrderBookChartView(
                currencyPair: pair,
                data: data.asks,
                width: 240,
                height: 200,
                priceColor: Colors.green,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Consumer(
                  builder: (context, ref, child) {
                    return ref.watch(tickerStreamProvider).when(
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
                      error: (error, stackTrace) {
                        return const SizedBox.shrink();
                      },
                      loading: () {
                        return const SizedBox.shrink();
                      },
                    );
                  },
                ),
              ),
              _OrderBookChartView(
                currencyPair: pair,
                data: data.bids,
                width: 240,
                height: 200,
                priceColor: Colors.red,
                reversedChart: true,
              ),
            ],
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (error, _) => const SizedBox.shrink(),
      ),
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
          Positioned(
            left: (width - height) / 2,
            top: (height - width) / 2,
            child: Transform.rotate(
              angle: -pi / 2,
              child: SizedBox(
                width: height,
                height: width,
                child: _buildChart(
                  height / data.length,
                ),
              ),
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

  Widget _buildChart(double rowWidth) {
    final List<BarChartGroupData> barGroups = [];
    double value = 0;
    for (var i = 0; i < data.length; i++) {
      value += data[i][1].toDouble();
      barGroups.add(
        BarChartGroupData(
          x: i,
          barsSpace: 0,
          barRods: [
            BarChartRodData(
              toY: value,
              color: Colors.green[50],
              width: rowWidth,
              borderRadius: const BorderRadius.all(
                Radius.zero,
              ),
            )
          ],
        ),
      );
    }
    return BarChart(
      BarChartData(
        maxY: value,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(show: false),
        barGroups: reversedChart ? barGroups.reversed.toList() : barGroups,
      ),
    );
  }
}
