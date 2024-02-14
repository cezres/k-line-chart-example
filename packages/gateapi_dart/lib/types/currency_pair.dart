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

  final String id;
  final String base;
  final String quote;
  final String fee;
  @JsonKey(name: 'min_base_amount')
  final String minBaseAmount;
  @JsonKey(name: 'min_quote_amount')
  final String minQuoteAmount;
  @JsonKey(name: 'max_base_amount')
  final String maxBaseAmount;
  @JsonKey(name: 'max_quote_amount')
  final String maxQuoteAmount;
  @JsonKey(name: 'amount_precision')
  final int amountPrecision;
  final int precision;
  @JsonKey(name: 'trade_status')
  final String tradeStatus;
  @JsonKey(name: 'sell_start')
  final int sellStart;
  @JsonKey(name: 'buy_start')
  final int buyStart;

  factory CurrencyPair.fromJson(Map<String, dynamic> json) =>
      _$CurrencyPairFromJson(json);

  Map<String, dynamic> toJson() => _$CurrencyPairToJson(this);
}
