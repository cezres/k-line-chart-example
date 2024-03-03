import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k_line_chart_example/modules/trade/trade_view.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: (kIsWeb || Platform.isMacOS)
          ? null
          : AppBar(
              title: const Text('K-Line Flutter Example'),
            ),
      body: const SafeArea(child: TradeView()),
      backgroundColor: Colors.white,
    );
  }
}
