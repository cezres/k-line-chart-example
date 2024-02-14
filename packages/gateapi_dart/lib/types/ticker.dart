import 'package:decimal/decimal.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ticker.g.dart';

@JsonSerializable()
class Ticker {
  const Ticker({
    required this.currencyPair,
    required this.last,
    required this.lowestAsk,
    required this.highestBid,
    required this.changePercentage,
    // required this.changeUtc0,
    // required this.changeUtc8,
    required this.baseVolume,
    required this.quoteVolume,
    required this.high24h,
    required this.low24h,
    required this.etfNetValue,
    this.etfPreNetValue,
    this.etfPreTimestamp,
    this.etfLeverage,
  });

  @JsonKey(name: 'currency_pair')
  final String currencyPair; // 交易对
  final String last; // 最新成交价
  @JsonKey(name: 'lowest_ask')
  final String lowestAsk; // 最新卖方最低价
  @JsonKey(name: 'highest_bid')
  final String highestBid; // 最新买方最高价
  @JsonKey(name: 'change_percentage')
  final Decimal changePercentage; // 最近24h涨跌百分比，跌用负数标识，如 -7.45
  // @JsonKey(name: 'change_utc0')
  // final String changeUtc0; // utc0时区，最近24h涨跌百分比，跌用负数标识，如 -7.45
  // @JsonKey(name: 'change_utc8')
  // final String changeUtc8; // utc8时区，最近24h涨跌百分比，跌用负数标识，如 -7.45
  @JsonKey(name: 'base_volume')
  final Decimal baseVolume; // 最近24h交易货币成交量
  @JsonKey(name: 'quote_volume')
  final Decimal quoteVolume; // 	最近24h计价货币成交量
  @JsonKey(name: 'high_24h')
  final String high24h; // 24小时最高价
  @JsonKey(name: 'low_24h')
  final String low24h; // 	24小时最低价
  @JsonKey(name: 'etf_net_value')
  final String? etfNetValue; // ETF 净值
  @JsonKey(name: 'etf_pre_net_value')
  final String? etfPreNetValue; // ETF 前一再平衡点净值
  @JsonKey(name: 'etf_pre_timestamp')
  final int? etfPreTimestamp; // ETF 前一再平衡时间
  @JsonKey(name: 'etf_leverage')
  final String? etfLeverage; // ETF 当前杠杆率

  factory Ticker.fromJson(Map<String, dynamic> json) => _$TickerFromJson(json);

  Map<String, dynamic> toJson() => _$TickerToJson(this);
}
