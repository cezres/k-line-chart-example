import 'package:decimal/decimal.dart';

String formatAmountDecimal(Decimal decimal) {
  if (decimal >= Decimal.fromInt(100000000)) {
    final result = (decimal / Decimal.fromInt(100000000)).toDecimal();
    return "${result.toStringAsFixed(2)}亿";
  } else if (decimal >= Decimal.fromInt(10000)) {
    final result = (decimal / Decimal.fromInt(10000)).toDecimal();
    return "${result.toStringAsFixed(2)}万";
  } else {
    return decimal.toStringAsFixed(2);
  }
}
