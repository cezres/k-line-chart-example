// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:k_line_chart_example/utils/merge_sorted_arrays.dart';

void main() {
  group('Test performance of Isolate', () {
    const count = 10000;
    final initialValue = List.generate(10000, (index) => index + 1);
    List<int> callback(List<int> value) {
      return value.map((e) => e + 1).toList();
    }

    test('1. Use compute', () async {
      final stopwatch = Stopwatch()..start();
      var value = initialValue;
      for (var i = 0; i < count; i++) {
        value = await compute(callback, value);
      }
      stopwatch.stop();
      final result =
          value.fold(0, (previousValue, element) => previousValue + element);
      debugPrint(
          "1. Use compute:\ntime:${stopwatch.elapsedMilliseconds}\tresult:$result");
    });

    test('2. Reuse Isolate and use SendPort to send data', () async {
      final stopwatch = Stopwatch()..start();
      final receivePort = ReceivePort();
      var value = initialValue;
      var index = 0;
      late SendPort sendPort;

      compute(
        (message) async {
          final sendPort = message;
          final receivePort = ReceivePort();
          sendPort.send(receivePort.sendPort);
          await for (var element in receivePort) {
            if (element == 0) {
              return;
            }
            sendPort.send(callback(element));
          }
        },
        receivePort.sendPort,
      );
      await for (var element in receivePort) {
        if (element is SendPort) {
          sendPort = element;
          sendPort.send(value);
        } else if (element is List<int>) {
          if (index == count) {
            sendPort.send(0); // exit
            receivePort.close();
            value = element;
          } else {
            sendPort.send(element);
          }
        }
        index += 1;
      }
      stopwatch.stop();
      final result =
          value.fold(0, (previousValue, element) => previousValue + element);
      debugPrint(
          "2. Reuse Isolate and use SendPort to send data:\ntime:${stopwatch.elapsedMilliseconds}\tresult:$result");
    });

    test('3. Send TransferableTypedData', () async {
      final stopwatch = Stopwatch()..start();
      final receivePort = ReceivePort();
      var value = Uint32List.fromList(initialValue);
      var index = 0;
      late SendPort sendPort;

      compute(
        (message) async {
          final sendPort = message;
          final receivePort = ReceivePort();
          sendPort.send(receivePort.sendPort);
          await for (var element in receivePort) {
            if (element == 0) {
              return;
            }
            sendPort.send(TransferableTypedData.fromList([
              Uint32List.fromList(callback((element as TransferableTypedData)
                  .materialize()
                  .asUint32List()))
            ]));
          }
        },
        receivePort.sendPort,
      );
      await for (var element in receivePort) {
        if (element is SendPort) {
          sendPort = element;
          sendPort.send(TransferableTypedData.fromList([value]));
          index += 1;
        } else if (element is TransferableTypedData) {
          if (index == count) {
            sendPort.send(0);
            receivePort.close();
            value = element.materialize().asUint32List();
          } else {
            sendPort.send(TransferableTypedData.fromList(
                [element.materialize().asUint32List()]));
          }
          index += 1;
        }
      }
      stopwatch.stop();
      final result =
          value.fold(0, (previousValue, element) => previousValue + element);
      debugPrint(
          "3. Send TransferableTypedData:\ntime:${stopwatch.elapsedMilliseconds}\tresult:$result");
    });
  });

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

  // group('KlinePointRange Intersection Tests', () {
  //   test('No intersection when ranges are completely separate', () {
  //     var range1 = KlinePointRange(offset: 10, limit: 5);
  //     var range2 = KlinePointRange(offset: 20, limit: 5);
  //     expect(range1.hasIntersection(range2), isFalse);
  //   });

  //   test('Intersection when one range contains another', () {
  //     var range1 = KlinePointRange(offset: 10, limit: 10);
  //     var range2 = KlinePointRange(offset: 15, limit: 2);
  //     expect(range1.hasIntersection(range2), isTrue);
  //   });

  //   test('Intersection when ranges partially overlap', () {
  //     var range1 = KlinePointRange(offset: 10, limit: 10);
  //     var range2 = KlinePointRange(offset: 15, limit: 10);
  //     expect(range1.hasIntersection(range2), isTrue);
  //   });

  //   test('Intersection when one range starts with offset 0', () {
  //     var range1 = KlinePointRange(offset: 0, limit: 10);
  //     var range2 = KlinePointRange(offset: 20, limit: 5);
  //     expect(range1.hasIntersection(range2), isTrue);
  //   });

  //   test('Intersection when both ranges start with offset 0', () {
  //     var range1 = KlinePointRange(offset: 0, limit: 10);
  //     var range2 = KlinePointRange(offset: 0, limit: 5);
  //     expect(range1.hasIntersection(range2), isTrue);
  //   });
  // });

  // group('KlineDataLoader Tests', () {
  //   test('description', () async {
  //     final container = createContainer(
  //       overrides: [
  //         klineDataLoaderProvider,
  //       ],
  //     );

  //     final loader = container.read(klineDataLoaderProvider.notifier);
  //     loader.request(10, 20);

  //     final d1 = await container.next(klineDataProvider);
  //     expect(d1.points.length, 20);

  //     final futureData = container.read(klineDataProvider.future);
  //     final data = await futureData;
  //     expect(data.points.length, 20);
  //     expect(data.points.first.timestamp > data.points.last.timestamp, isTrue);

  //     loader.request(0, 50);
  //     final data2 = await container.next(klineDataProvider);
  //     expect(data2.points.length, 50);
  //   });
  // });
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
