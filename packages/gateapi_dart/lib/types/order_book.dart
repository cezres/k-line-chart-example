import 'package:decimal/decimal.dart';
import 'package:json_annotation/json_annotation.dart';

part 'order_book.g.dart';

@JsonSerializable()
final class OrderBook {
  const OrderBook({
    required this.id,
    required this.current,
    required this.update,
    required this.asks,
    required this.bids,
  });

  final int id; // 深度更新ID。深度每发生一次变化，ID 就会更新一次。仅在 with_id 设置为 true 该值有效
  final int current; // 接口数据返回 ms 时间戳
  final int update; // 深度变化 ms 时间戳
  final List<List<Decimal>> asks; // 卖方深度列表
  final List<List<Decimal>> bids; // 买方深度列表

  factory OrderBook.fromJson(Map<String, dynamic> json) =>
      _$OrderBookFromJson(json);

  Map<String, dynamic> toJson() => _$OrderBookToJson(this);
}
