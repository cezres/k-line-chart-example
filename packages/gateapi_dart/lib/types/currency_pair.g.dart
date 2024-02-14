// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency_pair.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CurrencyPair _$CurrencyPairFromJson(Map<String, dynamic> json) => CurrencyPair(
      id: json['id'] as String,
      base: json['base'] as String,
      quote: json['quote'] as String,
      fee: json['fee'] as String,
      minBaseAmount: json['min_base_amount'] as String,
      minQuoteAmount: json['min_quote_amount'] as String,
      maxBaseAmount: json['max_base_amount'] as String,
      maxQuoteAmount: json['max_quote_amount'] as String,
      amountPrecision: json['amount_precision'] as int,
      precision: json['precision'] as int,
      tradeStatus: json['trade_status'] as String,
      sellStart: json['sell_start'] as int,
      buyStart: json['buy_start'] as int,
    );

Map<String, dynamic> _$CurrencyPairToJson(CurrencyPair instance) =>
    <String, dynamic>{
      'id': instance.id,
      'base': instance.base,
      'quote': instance.quote,
      'fee': instance.fee,
      'min_base_amount': instance.minBaseAmount,
      'min_quote_amount': instance.minQuoteAmount,
      'max_base_amount': instance.maxBaseAmount,
      'max_quote_amount': instance.maxQuoteAmount,
      'amount_precision': instance.amountPrecision,
      'precision': instance.precision,
      'trade_status': instance.tradeStatus,
      'sell_start': instance.sellStart,
      'buy_start': instance.buyStart,
    };
