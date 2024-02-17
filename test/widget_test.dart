// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gateio_flutter/utils/merge_sorted_arrays.dart';
import 'package:gateio_flutter/widgets/custom_chart/k_line_data_loader.dart';

void main() {
  test('list', () {
    /// 合并两个正序并且数据连续的数组
    /// 优先保留[list1]的数据
    ///

    expect(
      mergeSortedArrays(
        [1, 2, 3, 4],
        [4, 5],
      ),
      [1, 2, 3, 4, 5],
    );

    expect(
      mergeSortedArrays(
        [1, 2, 3, 4],
        [5, 6],
      ),
      [1, 2, 3, 4, 5, 6],
    );

    expect(
      mergeSortedArrays(
        [7, 8, 9],
        [5, 6, 7],
      ),
      [5, 6, 7, 8, 9],
    );

    expect(
      mergeSortedArrays(
        [1, 2, 3, 4],
        [0, 5, 6, 7, 8],
      ),
      [0, 1, 2, 3, 4, 5, 6, 7, 8],
    );

    expect(
      mergeSortedArrays(
        [1, 2, 3, 4],
        [-4, 0, 5, 6, 7, 8, 9],
      ),
      [-4, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
    );
  });

  group('KlinePointRange Intersection Tests', () {
    test('No intersection when ranges are completely separate', () {
      var range1 = KlinePointRange(offset: 10, limit: 5);
      var range2 = KlinePointRange(offset: 20, limit: 5);
      expect(range1.hasIntersection(range2), isFalse);
    });

    test('Intersection when one range contains another', () {
      var range1 = KlinePointRange(offset: 10, limit: 10);
      var range2 = KlinePointRange(offset: 15, limit: 2);
      expect(range1.hasIntersection(range2), isTrue);
    });

    test('Intersection when ranges partially overlap', () {
      var range1 = KlinePointRange(offset: 10, limit: 10);
      var range2 = KlinePointRange(offset: 15, limit: 10);
      expect(range1.hasIntersection(range2), isTrue);
    });

    test('Intersection when one range starts with offset 0', () {
      var range1 = KlinePointRange(offset: 0, limit: 10);
      var range2 = KlinePointRange(offset: 20, limit: 5);
      expect(range1.hasIntersection(range2), isTrue);
    });

    test('Intersection when both ranges start with offset 0', () {
      var range1 = KlinePointRange(offset: 0, limit: 10);
      var range2 = KlinePointRange(offset: 0, limit: 5);
      expect(range1.hasIntersection(range2), isTrue);
    });
  });

  group('KlineDataLoader Tests', () {
    test('description', () async {
      final container = createContainer(
        overrides: [
          klineDataLoaderProvider,
        ],
      );

      final loader = container.read(klineDataLoaderProvider.notifier);
      loader.request(10, 20);

      final d1 = await container.next(klineDataProvider);
      expect(d1.points.length, 20);

      final futureData = container.read(klineDataProvider.future);
      final data = await futureData;
      expect(data.points.length, 20);
      expect(data.points.first.timestamp > data.points.last.timestamp, isTrue);

      loader.request(0, 50);
      final data2 = await container.next(klineDataProvider);
      expect(data2.points.length, 50);
    });
  });
}

ProviderContainer createContainer({
  ProviderContainer? parent,
  List<Override> overrides = const [],
  List<ProviderObserver>? observers,
}) {
  // 创建一个 ProviderContainer，并可选的允许指定参数。
  final container = ProviderContainer(
    parent: parent,
    overrides: overrides,
    observers: observers,
  );

  // 测试结束后，处置容器。
  addTearDown(container.dispose);

  return container;
}

extension NextProvider on ProviderContainer {
  Future<T> next<T>(StreamProvider<T> provider) {
    final completer = Completer<T>();
    final sub = listen(provider, (previous, next) {
      completer.complete(next.value);
    });
    return completer.future.whenComplete(() => sub.close());
  }
}
