/// 合并两个升序数据集
/// 优先保留[list1]的数据
/// [list1] 必须是升序且数据连续的数据集
/// [list2] 必须是升序的数据集
List<T> mergeSortedArrays<T extends Comparable>(List<T> list1, List<T> list2) {
  if (list1.isEmpty) {
    return list2;
  }

  /// list2中比list1大的数据
  final larger = <T>[];

  /// list2中比list1小的数据
  final smaller = <T>[];

  for (var element in list2) {
    if (element.compareTo(list1.last) > 0) {
      larger.add(element);
    } else if (element.compareTo(list1.first) < 0) {
      smaller.add(element);
    }
  }

  return [
    // 比list2小的数据
    ...smaller,
    // list1
    ...list1,
    // 比list1大的数据
    ...larger,
  ];
}
