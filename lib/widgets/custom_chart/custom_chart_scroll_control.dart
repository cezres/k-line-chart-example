import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gateio_flutter/widgets/custom_chart/custom_chart_calculator.dart';

class ChartScrollControl extends ConsumerStatefulWidget {
  const ChartScrollControl({super.key});

  @override
  ConsumerState<ChartScrollControl> createState() => _ChartScrollControlState();
}

class _ChartScrollControlState extends ConsumerState<ChartScrollControl> {
  final ScrollController controller =
      ScrollController(initialScrollOffset: 4500);

  @override
  void initState() {
    super.initState();

    controller.addListener(() {
      ref.read(customChartCalculatorProvider.notifier).setup(
            offset:
                max(controller.position.maxScrollExtent - controller.offset, 0),
          );
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      controller: controller,
      itemBuilder: (context, index) {
        return Container(
          width: 200,
          // color: index % 2 == 0 ? Colors.transparent : Colors.transparent,
          color: index % 2 == 0
              ? Colors.green.withOpacity(0.2)
              : Colors.amber.withOpacity(0.2),
        );
      },
      itemCount: 20,
    );
  }
}
