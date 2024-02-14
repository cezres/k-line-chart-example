import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gateio_flutter/modules/trade/spot/candlesticks/providers.dart';

class CandlesticksView extends ConsumerWidget {
  const CandlesticksView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final candlesticks = ref.watch(candlesticksStreamProvider);
    return SizedBox(
      height: 400,
      child: candlesticks.when(
        data: (data) => _buildChart(data),
        error: (error, stackTrace) => const SizedBox.shrink(),
        loading: () => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildChart(List<List<String>> candlesticks) {
    final List<BarChartGroupData> barGroups = [];

    const double totalProgress = 10000;
    double priceRatio = 0.65;
    double volumeRatio = 0.25;

    double totalMaxPrice = 0;
    double totalMinPrice = double.infinity;
    double totalMaxVolume = 0;
    for (var element in candlesticks) {
      totalMaxVolume = max(totalMaxVolume, double.parse(element[6]));
      totalMaxPrice = max(totalMaxPrice, double.parse(element[3]));
      totalMinPrice = min(totalMinPrice, double.parse(element[4]));
    }

    for (var i = 0; i < candlesticks.length; i++) {
      final List<String> candlestick = candlesticks[i];

      final open = double.parse(candlestick[5]);
      final close = double.parse(candlestick[2]);

      final maxPrice = double.parse(candlestick[3]);
      final minPrice = double.parse(candlestick[4]);

      final volume = double.parse(candlestick[6]);

      final openProgress = totalProgress * 0.35 +
          (totalProgress * priceRatio) *
              ((open - totalMinPrice) / (totalMaxPrice - totalMinPrice));
      final closeProgress = totalProgress * 0.35 +
          (totalProgress * priceRatio) *
              ((close - totalMinPrice) / (totalMaxPrice - totalMinPrice));

      final maxPriceProgress = totalProgress * 0.35 +
          totalProgress *
              priceRatio *
              ((maxPrice - totalMinPrice) / (totalMaxPrice - totalMinPrice));
      final minPriceProgress = totalProgress * 0.35 +
          totalProgress *
              priceRatio *
              ((minPrice - totalMinPrice) / (totalMaxPrice - totalMinPrice));

      final volumeProgress =
          totalProgress * volumeRatio * (volume / totalMaxVolume);

      barGroups.add(BarChartGroupData(
        x: i,
        groupVertically: true,
        barRods: [
          BarChartRodData(
            toY: max(openProgress, closeProgress),
            fromY: min(openProgress, closeProgress),
            borderRadius: const BorderRadius.all(Radius.zero),
            color: close > open ? Colors.red : Colors.green,
          ),
          BarChartRodData(
            toY: maxPriceProgress,
            fromY: minPriceProgress,
            borderRadius: const BorderRadius.all(Radius.zero),
            color: close > open ? Colors.red : Colors.green,
            width: 2,
          ),
          BarChartRodData(
            toY: volumeProgress,
            fromY: 0,
            borderRadius: const BorderRadius.all(Radius.zero),
            color: close > open ? Colors.red[200] : Colors.green[200],
          ),
        ],
      ));
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barGroups: barGroups,
        titlesData: const FlTitlesData(show: false),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: 3000,
              color: Colors.grey[300],
              strokeWidth: 1,
            ),
            HorizontalLine(
              y: 9000,
              color: Colors.red,
              strokeCap: StrokeCap.butt,
              dashArray: [2, 2],
              strokeWidth: 1,
            ),
          ],
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          getDrawingHorizontalLine: (value) => const FlLine(
            color: Color.fromARGB(255, 220, 220, 220),
            strokeWidth: 0.4,
            dashArray: [8, 4],
          ),
          getDrawingVerticalLine: (value) => const FlLine(
            color: Color.fromARGB(255, 220, 220, 220),
            strokeWidth: 0.4,
            dashArray: [8, 4],
          ),
        ),
        barTouchData: BarTouchData(
          // enabled: false,
          mouseCursorResolver:
              (FlTouchEvent event, BarTouchResponse? response) {
            debugPrint('event: ${event.localPosition}');
            return MouseCursor.defer;
          },
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) => null,
          ),
        ),
      ),
    );
  }
}
