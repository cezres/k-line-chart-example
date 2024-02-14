import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:gateio_flutter/modules/trade/spot/candlesticks/chart_data.dart';
import 'package:gateio_flutter/modules/trade/spot/candlesticks/providers.dart';

// part 'bar_chart_data_calculator.g.dart';

// @riverpod
// class BarChartDataCalculator extends _$BarChartDataCalculator {
//   @override
//   List<BarChartGroupData> build() {
//     final configuration = ref.watch(kLineChartConfigurationProvider);
//     final loaded = ref.watch(chartDataLoaderProvider);

//     if (loaded.hasValue) {
//       final entity = loaded.requireValue;
//       final datas = entity.datas;
//       List<BarChartGroupData> groups = [];

//       for (var i = 0; i < datas.length; i++) {
//         final data = datas[i];

//         groups.add(BarChartGroupData(
//           x: i,
//           groupVertically: true,
//           barsSpace: 0,
//           barRods: [
//             configuration.defaultChartRodData.copyWith(
//               toY: max(data.open, data.close),
//               fromY: min(data.open, data.close),
//               color: data.close > data.open ? Colors.red : Colors.green,
//             ),
//             configuration.defaultChartRodData.copyWith(
//               toY: data.high,
//               fromY: data.low,
//               color: data.close > data.open ? Colors.red : Colors.green,
//               width: 2,
//             ),
//           ],
//         ));
//       }

//       for (var i = 0; i < 5; i++) {
//         groups.add(BarChartGroupData(
//           x: datas.length + i,
//           barRods: [
//             BarChartRodData(toY: entity.maxPrice, fromY: entity.maxPrice),
//           ],
//         ));
//       }

//       return groups;
//     }

//     return [];
//   }

//   void append(List<ChartDataEntity> datas) {
//     //
//   }

//   void reset({required String interval, required List<ChartDataEntity> datas}) {
//     //
//   }
// }

final class BarChartDataCalculatorState {
  const BarChartDataCalculatorState({
    required this.configuration,
    required this.interval,
    required this.datas,
    required this.barGroups,
    required this.displayMaxPrice,
    required this.displayMinPrice,
    required this.displayMaxVolume,
    this.displayMaxCount = 100,
  });

  final KLineChartConfiguration configuration;

  final String interval;
  final List<ChartDataEntity> datas;
  final Map<int, BarChartGroupData> barGroups;

  final double displayMaxPrice;
  final double displayMinPrice;
  final double displayMaxVolume;
  final int displayMaxCount;

  int? get lastTimestamp => datas.isEmpty ? null : datas.last.timestamp;
}

class DisplayedChartDataList {
  const DisplayedChartDataList({
    required this.interval,
    required this.datas,
    required this.displayMaxPrice,
    required this.displayMinPrice,
    required this.displayMaxVolume,
  });

  final String interval;
  final List<ChartDataEntity> datas;
  // final int limit;
  final double displayMaxPrice;
  final double displayMinPrice;
  final double displayMaxVolume;

  DisplayedChartDataList append({required List<ChartDataEntity> datas}) {
    if (datas.isEmpty) {
      return this;
    }
    if (this.datas.isEmpty) {
      double displayMaxPrice = 0;
      double displayMinPrice = double.infinity;
      double displayMaxVolume = 0;
      for (var i = 0; i < datas.length; i++) {
        final data = datas[i];
        displayMaxPrice = max(displayMaxPrice, data.high);
        displayMinPrice = min(displayMinPrice, data.low);
        displayMaxVolume = max(displayMaxVolume, data.baseVolume);
      }
      return DisplayedChartDataList(
        interval: interval,
        datas: datas,
        displayMaxPrice: displayMaxPrice,
        displayMinPrice: displayMinPrice,
        displayMaxVolume: displayMaxVolume,
      );
    }
    return this;
  }

  double calculateMaxPrice() {
    return datas
        .map((e) => e.high)
        .reduce((value, element) => value > element ? value : element);
  }
}
