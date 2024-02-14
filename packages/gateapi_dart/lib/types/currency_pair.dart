import 'package:json_annotation/json_annotation.dart';

part 'currency_pair.g.dart';

/// 现货交易对
@JsonSerializable()
final class CurrencyPair {
  const CurrencyPair({
    required this.id,
    required this.base,
    required this.quote,
    required this.fee,
    required this.minBaseAmount,
    required this.minQuoteAmount,
    required this.maxBaseAmount,
    required this.maxQuoteAmount,
    required this.amountPrecision,
    required this.precision,
    required this.tradeStatus,
    required this.sellStart,
    required this.buyStart,
  });

  final String id; // 交易对
  final String base; // 交易货币
  final String quote; // 计价货币
  final String fee; // 交易费率
  @JsonKey(name: 'min_base_amount')
  final String? minBaseAmount; // 交易货币最低交易数量，null 表示无限制
  @JsonKey(name: 'min_quote_amount')
  final String? minQuoteAmount; // 计价货币最低交易数量，null 表示无限制
  @JsonKey(name: 'max_base_amount')
  final String? maxBaseAmount; // 交易货币最大交易数量，null 表示无限制
  @JsonKey(name: 'max_quote_amount')
  final String? maxQuoteAmount; // 计价货币最大交易数量，null 表示无限制
  @JsonKey(name: 'amount_precision')
  final int amountPrecision; // 数量精度
  final int precision; // 价格精度
  @JsonKey(name: 'trade_status')
  final TradeStatus tradeStatus; // 交易状态
  @JsonKey(name: 'sell_start')
  final int sellStart; // 允许卖出时间，秒级 Unix 时间戳
  @JsonKey(name: 'buy_start')
  final int buyStart; // 允许买入时间，秒级 Unix 时间戳

  factory CurrencyPair.fromJson(Map<String, dynamic> json) =>
      _$CurrencyPairFromJson(json);

  Map<String, dynamic> toJson() => _$CurrencyPairToJson(this);
}

@JsonEnum()
enum TradeStatus {
  untradable, // 不可交易
  buyable, // 可买
  sellable, // 可卖
  tradable, // 买卖均可交易
}
