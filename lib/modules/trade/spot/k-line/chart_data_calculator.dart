import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gateio_flutter/modules/trade/spot/k-line/chart_data_loader.dart';
import 'package:gateio_flutter/utils/calculate_interval_of_numbers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chart_data_calculator.g.dart';

@riverpod
class ChartDataCalculator extends _$ChartDataCalculator {
  final List<ChartDataEntity> datas = [];

  @override
  ChartData? build() {
    // final configuration = ref.watch(kLineChartConfigurationProvider);
    // TODO:
    final loader = ref.watch(chartDataLoaderProvider);

    if (loader.hasValue) {
      final entity = loader.requireValue;
      final datas = entity.datas;
      if (datas.isEmpty) {
        return null;
      }

      return ChartData(
        datas: datas,
        klineGroups: _buildKlineGroups(datas),
        volumeGroups: _buildVolumeGroups(datas),
        klineInterval: calculateIntervalOfNumbers(
          entity.maxPrice,
          entity.minPrice,
          5,
        ),
        volumeInterval: calculateIntervalOfNumbers(
          entity.maxVolume,
          entity.minVolume,
          5,
        ),
        timestampInterval: calculateIntervalOfNumbers(
          datas.last.timestamp.toDouble(),
          datas.first.timestamp.toDouble(),
          8,
          60,
        ),
      );
    }

    return null;
  }

  List<BarChartGroupData> _buildKlineGroups(List<ChartDataEntity> datas) {
    return datas.map((e) {
      return BarChartGroupData(
        x: e.timestamp,
        groupVertically: true,
        barsSpace: 0,
        barRods: [
          BarChartRodData(
            toY: max(e.open, e.close),
            fromY: min(e.open, e.close),
            color: e.close > e.open ? Colors.red : Colors.green,
            borderRadius: BorderRadius.zero,
          ),
          BarChartRodData(
            toY: e.high,
            fromY: e.low,
            color: e.close > e.open ? Colors.red : Colors.green,
            width: 2,
            borderRadius: BorderRadius.zero,
          ),
        ],
      );
    }).toList();
  }

  List<BarChartGroupData> _buildVolumeGroups(List<ChartDataEntity> datas) {
    return datas.map((e) {
      return BarChartGroupData(
        x: e.timestamp,
        barRods: [
          BarChartRodData(
            toY: e.baseVolume,
            fromY: 0,
            color: e.close > e.open ? Colors.red : Colors.green,
            borderRadius: BorderRadius.zero,
          ),
        ],
      );
    }).toList();
  }
}

final class ChartData {
  const ChartData({
    required this.datas,
    required this.klineGroups,
    required this.volumeGroups,
    required this.klineInterval,
    required this.volumeInterval,
    required this.timestampInterval,
  });

  final List<ChartDataEntity> datas;

  final List<BarChartGroupData> klineGroups;
  final List<BarChartGroupData> volumeGroups;

  final IntervalOfNumbers klineInterval;
  final IntervalOfNumbers volumeInterval;
  final IntervalOfNumbers timestampInterval;
}
