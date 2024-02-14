import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gateapi_dart/gateapi_dart.dart';
import 'package:gateio_flutter/modules/trade/spot/ticker/providers.dart';
import 'package:gateio_flutter/utils/format_decimal.dart';

class TickerView extends ConsumerWidget {
  const TickerView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(tickerStreamProvider).when(
      data: (data) {
        return _buildContent(data);
      },
      error: (error, stackTrace) {
        return const SizedBox.shrink();
      },
      loading: () {
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildContent(Ticker ticker) {
    return Row(
      children: [
        _buildRowItem([
          Text(
            ticker.last,
            style: TextStyle(
              color: ticker.changePercentage > Decimal.zero
                  ? Colors.red
                  : Colors.green,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Text(""),
        ]),
        _buildRowItem([
          _buildTitle('涨跌幅'),
          _buildValue(
            '${ticker.changePercentage}%',
            color: ticker.changePercentage > Decimal.zero
                ? Colors.red
                : Colors.green,
          ),
        ]),
        _buildRowItem([
          _buildTitle('24H 最高价'),
          _buildValue(ticker.high24h),
        ]),
        _buildRowItem([
          _buildTitle('24H 最低价'),
          _buildValue(ticker.low24h),
        ]),
        _buildRowItem([
          _buildTitle('24H 成交量 (${ticker.currencyPair.split('_').first})'),
          _buildValue(formatAmountDecimal(ticker.baseVolume)),
        ]),
        _buildRowItem([
          _buildTitle('24H 成交量 (${ticker.currencyPair.split('_').last})'),
          _buildValue(formatAmountDecimal(ticker.quoteVolume)),
        ]),
      ],
    );
  }

  Widget _buildTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey[500],
      ),
    );
  }

  Widget _buildValue(
    String value, {
    Color? color,
  }) {
    return Text(
      value,
      style: TextStyle(
        fontSize: 12,
        color: color,
      ),
    );
  }

  Widget _buildRowItem(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
