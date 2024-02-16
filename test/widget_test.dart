// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:gateio_flutter/modules/trade/spot/k-line/chart_data_loader.dart';

void main() {
  test('list', () {
    /// 合并两个正序并且数据连续的数组
    /// 优先保留[list1]的数据
    ///

    expect(
      ChartDataLoadedEntity.mergeSortedArrays(
        [1, 2, 3, 4],
        [5, 4],
      ),
      [1, 2, 3, 4, 5, 4],
    );

    expect(
      ChartDataLoadedEntity.mergeSortedArrays(
        [1, 2, 3, 4],
        [5, 6],
      ),
      [1, 2, 3, 4, 5, 6],
    );

    expect(
      ChartDataLoadedEntity.mergeSortedArrays(
        [1, 2, 3, 4],
        [5, 6, 7],
      ),
      [1, 2, 3, 4, 5, 6, 7],
    );

    expect(
      ChartDataLoadedEntity.mergeSortedArrays(
        [1, 2, 3, 4],
        [0, 5, 6, 7, 8],
      ),
      [0, 1, 2, 3, 4, 5, 6, 7, 8],
    );

    expect(
      ChartDataLoadedEntity.mergeSortedArrays(
        [1, 2, 3, 4],
        [-4, 0, 5, 6, 7, 8, 9],
      ),
      [-4, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
    );
  });
}
