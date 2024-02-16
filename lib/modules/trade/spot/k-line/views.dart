import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gateio_flutter/modules/trade/spot/k-line/chart_data_calculator.dart';
import 'package:gateio_flutter/modules/trade/spot/k-line/providers.dart';
import 'package:gateio_flutter/widgets/custom_chart/custom_chart.dart';

class KLineView extends ConsumerWidget {
  const KLineView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gridData = FlGridData(
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
    );

    final barTouchData = BarTouchData(
      enabled: false,
      // mouseCursorResolver: (FlTouchEvent event, BarTouchResponse? response) {
      //   debugPrint('event: ${event.localPosition}');
      //   return MouseCursor.defer;
      // },
      // touchTooltipData: BarTouchTooltipData(
      //   getTooltipItem: (group, groupIndex, rod, rodIndex) => null,
      // ),
    );

    return Column(
      children: [
        const KLineControlView(),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) => Stack(
              children: [
                Positioned.fill(
                  child: Consumer(
                    builder: (context, ref, child) {
                      // final chartData = ref.watch(chartDataCalculatorProvider);
                      // if (chartData == null) {
                      //   return const SizedBox.shrink();
                      // }
                      // ref
                      //     .read(customChartCalculatorProvider.notifier)
                      //     .append(chartData.datas);
                      return const CustomChart();
                      // return Column(
                      //   children: [
                      //     Expanded(
                      //       flex: 2,
                      //       child: _buildChartWithGroups(
                      //         chartData,
                      //         gridData: gridData,
                      //         barTouchData: barTouchData,
                      //       ),
                      //     ),
                      //     Padding(
                      //       padding: const EdgeInsets.only(right: 64),
                      //       child: Divider(height: 1, color: Colors.grey[300]),
                      //     ),
                      //     Expanded(
                      //       flex: 1,
                      //       child: _buildVolumeChart(
                      //         chartData,
                      //         gridData: gridData,
                      //         barTouchData: barTouchData,
                      //       ),
                      //     )
                      //   ],
                      // );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChartWithGroups(
    ChartData chartData, {
    required FlGridData gridData,
    required BarTouchData barTouchData,
  }) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barGroups: chartData.klineGroups,
        maxY: chartData.klineInterval.max,
        minY: chartData.klineInterval.min,
        extraLinesData: ExtraLinesData(
          extraLinesOnTop: true,
          horizontalLines: [
            HorizontalLine(
              y: chartData.datas.last.close,
              color: Colors.red,
              strokeCap: StrokeCap.butt,
              dashArray: [2, 2],
              strokeWidth: 1,
            ),
          ],
        ),
        borderData: FlBorderData(show: false),
        gridData: gridData,
        barTouchData: barTouchData,
        titlesData: FlTitlesData(
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              reservedSize: 64,
              showTitles: true,
              interval: chartData.klineInterval.interval,
              getTitlesWidget: (value, meta) {
                if (value == chartData.klineInterval.min) {
                  return const SizedBox.shrink();
                }
                return _buildTitlesWidget(value.toInt().toString());
              },
            ),
          ),
          bottomTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
      ),
    );
  }

  Widget _buildVolumeChart(
    ChartData chartData, {
    required FlGridData gridData,
    required BarTouchData barTouchData,
  }) {
    return BarChart(
      BarChartData(
        barGroups: chartData.volumeGroups,
        borderData: FlBorderData(show: false),
        maxY: chartData.volumeInterval.max,
        minY: chartData.volumeInterval.min,
        titlesData: FlTitlesData(
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              reservedSize: 64,
              showTitles: true,
              interval: chartData.volumeInterval.interval,
              getTitlesWidget: (value, meta) {
                if (value == chartData.volumeInterval.min ||
                    value == chartData.volumeInterval.max) {
                  return const SizedBox.shrink();
                }
                return _buildTitlesWidget(value.toInt().toString());
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              reservedSize: 44,
              showTitles: true,
              interval: chartData.timestampInterval.interval,
              getTitlesWidget: (value, meta) {
                if (value % chartData.timestampInterval.interval != 0) {
                  return const SizedBox.shrink();
                }
                // final date =
                //     DateTime.fromMillisecondsSinceEpoch(value.toInt() * 1000);
                // if (date.day != lastDay) {
                //   lastDay = date.day;
                //   return _buildTitlesWidget('${date.day}');
                // } else {
                //   return _buildTitlesWidget(_formatDate(value.toInt() * 1000));
                // }
                return _buildTitlesWidget(_formatDate(value.toInt() * 1000));
              },
            ),
          ),
        ),
        gridData: gridData,
        barTouchData: barTouchData,
      ),
    );
  }

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    if (date.hour != 0) {
      return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } else if (date.minute != 0) {
      return date.minute.toString().padLeft(2, '0');
    } else {
      return "${date.day - 1}";
    }
  }

  Widget _buildTitlesWidget(String string) {
    return Text(
      string,
      style: TextStyle(
        color: Colors.grey[500],
        fontSize: 10,
      ),
    );
  }
}

class KLineControlView extends ConsumerWidget {
  const KLineControlView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        _buildButton('10s', ref),
        _buildButton('1m', ref),
        _buildButton('5m', ref),
        _buildButton('30m', ref),
        _buildButton('1h', ref),
        _buildButton('1D', ref),
      ],
    );
  }

  Widget _buildButton(String text, WidgetRef ref) {
    return CupertinoButton(
      padding: const EdgeInsets.all(0),
      child: Consumer(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
            ),
          ),
        ),
        builder: (context, ref, child) {
          final interval = ref.watch(kLineChartConfigurationProvider
              .select((value) => value.interval));
          if (interval == text) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
              child: child,
            );
          }
          return child!;
        },
      ),
      onPressed: () {
        ref.read(kLineChartConfigurationProvider.notifier).setInterval(text);
      },
    );
  }
}
