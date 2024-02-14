import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gateapi_dart/gateapi_dart.dart';
import 'package:gateio_flutter/modules/trade/spot/candlesticks/chart_data.dart';
import 'package:gateio_flutter/modules/trade/spot/candlesticks/providers.dart';
import 'package:gateio_flutter/modules/trade/spot/ticker/providers.dart';
import 'package:gateio_flutter/utils/calculate_interval_of_numbers.dart';

class CandlesticksView extends ConsumerWidget {
  const CandlesticksView({super.key});

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
          child: Consumer(
            builder: (context, ref, child) {
              final entity = ref.watch(chartDataLoaderProvider);
              final ticker = ref.watch(tickerStreamProvider);
              return Column(
                children: [
                  Expanded(
                    child: _buildChartWithGroups(
                      entity.value,
                      gridData: gridData,
                      barTouchData: barTouchData,
                      ticker: ticker.value,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 64),
                    child: Divider(height: 1, color: Colors.grey[300]),
                  ),
                  SizedBox(
                    height: 150,
                    child: _buildVolumeChart(
                      entity.value,
                      gridData: gridData,
                      barTouchData: barTouchData,
                    ),
                  )
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChartWithGroups(
    ChartDataLoadedEntity? entity, {
    required FlGridData gridData,
    required BarTouchData barTouchData,
    required Ticker? ticker,
  }) {
    if (entity == null) {
      return const SizedBox.shrink();
    }
    final datas = entity.datas;
    if (datas.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<BarChartGroupData> groups = [];
    for (var i = 0; i < datas.length; i++) {
      final data = datas[i];
      groups.add(BarChartGroupData(
        x: i,
        groupVertically: true,
        barsSpace: 0,
        barRods: [
          BarChartRodData(
            toY: max(data.open, data.close),
            fromY: min(data.open, data.close),
            color: data.close > data.open ? Colors.red : Colors.green,
            borderRadius: BorderRadius.zero,
          ),
          BarChartRodData(
            toY: data.high,
            fromY: data.low,
            color: data.close > data.open ? Colors.red : Colors.green,
            width: 2,
            borderRadius: BorderRadius.zero,
          ),
        ],
      ));
    }

    var interval =
        calculateIntervalOfNumbers(entity.maxPrice, entity.minPrice, 5);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barGroups: groups,
        maxY: interval.max,
        minY: interval.min,
        extraLinesData: ExtraLinesData(
          extraLinesOnTop: true,
          horizontalLines: [
            if (ticker != null)
              HorizontalLine(
                y: double.parse(ticker.last),
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
              interval: interval.interval,
              getTitlesWidget: (value, meta) {
                if (value == interval.min) {
                  return const SizedBox.shrink();
                }
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 10,
                  ),
                );
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
    ChartDataLoadedEntity? entity, {
    required FlGridData gridData,
    required BarTouchData barTouchData,
  }) {
    if (entity == null) {
      return const SizedBox.shrink();
    }
    final datas = entity.datas;
    if (datas.isEmpty) {
      return const SizedBox.shrink();
    }
    final List<BarChartGroupData> groups = [];
    for (var i = 0; i < datas.length; i++) {
      final data = datas[i];
      groups.add(BarChartGroupData(
        x: data.timestamp,
        groupVertically: true,
        barsSpace: 0,
        barRods: [
          BarChartRodData(
            toY: data.baseVolume,
            color: data.close > data.open ? Colors.red[200] : Colors.green[200],
            borderRadius: BorderRadius.zero,
          ),
        ],
      ));
    }

    final maxTimestamp = datas.last.timestamp;
    final minTimestamp = datas.first.timestamp;

    // var timestampSegment = (maxTimestamp - minTimestamp) / 10;
    // debugPrint('timestampSegment: $timestampSegment');
    // if (timestampSegment < 60) {
    //   timestampSegment = 60;
    // } else if (timestampSegment < 300) {
    //   timestampSegment = 300;
    // } else if (timestampSegment < 900) {
    //   timestampSegment = 900;
    // } else if (timestampSegment < 1800) {
    //   timestampSegment = 1800;
    // } else if (timestampSegment < 3600) {
    //   timestampSegment = 3600;
    // } else if (timestampSegment < 7200) {
    //   timestampSegment = 7200;
    // } else if (timestampSegment < 14400) {
    //   timestampSegment = 14400;
    // } else if (timestampSegment < 21600) {
    //   timestampSegment = 21600;
    // } else if (timestampSegment < 43200) {
    //   timestampSegment = 43200;
    // } else if (timestampSegment < 86400) {
    //   timestampSegment = 86400;
    // } else {
    //   timestampSegment = 86400;
    // }

    final volumeInterval =
        calculateIntervalOfNumbers(entity.maxVolume, entity.minVolume, 5);

    final timestampInterval = calculateIntervalOfNumbers(
        maxTimestamp.toDouble(), minTimestamp.toDouble(), 5, 60);
    debugPrint('timestampInterval: $timestampInterval');

    return BarChart(
      BarChartData(
        barGroups: groups,
        borderData: FlBorderData(show: false),
        maxY: volumeInterval.max,
        minY: volumeInterval.min,
        titlesData: FlTitlesData(
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              reservedSize: 64,
              showTitles: true,
              interval: volumeInterval.interval,
              getTitlesWidget: (value, meta) {
                if (value == volumeInterval.min ||
                    value == volumeInterval.max) {
                  return const SizedBox.shrink();
                }
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              reservedSize: 44,
              showTitles: true,
              interval: timestampInterval.interval,
              getTitlesWidget: (value, meta) {
                if (value % timestampInterval.interval == 0) {
                  final date =
                      DateTime.fromMillisecondsSinceEpoch(value.toInt() * 1000);
                  final String string;
                  if (date.hour != 0) {
                    string =
                        "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
                  } else if (date.minute != 0) {
                    string = date.minute.toString().padLeft(2, '0');
                  } else {
                    string = "${date.day - 1}";
                  }
                  return Text(
                    string,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 10,
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
        ),
        gridData: gridData,
        barTouchData: barTouchData,
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
        _buildButton('分时'),
        _buildButton('1m'),
        _buildButton('5m'),
        _buildButton('30m'),
        _buildButton('1h'),
        _buildButton('1D'),
      ],
    );
  }

  Widget _buildButton(String text) {
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
        //
      },
    );
  }
}
