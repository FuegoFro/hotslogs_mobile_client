import 'package:flutter/material.dart';

IndexedWidgetBuilder itemBuilderWithDividers(
    IndexedWidgetBuilder underlyingBuilder,
    {Widget divider: null}) {
  if (divider == null) {
    divider = Divider();
  }
  return (BuildContext context, int index) {
    if (index.isOdd) {
      return divider;
    }
    final logicalIndex = index ~/ 2;
    return underlyingBuilder(context, logicalIndex);
  };
}

int itemCountWithDividers(int undividedItemCount) {
  return undividedItemCount + (undividedItemCount - 1);
}

List<Widget> intersperseDivider(Iterable<Widget> items, Widget divider) {
  final interspersed = <Widget>[];
  bool first = true;
  for (final item in items) {
    if (!first) {
      interspersed.add(divider);
    }
    first = false;
    interspersed.add(item);
  }
  return interspersed;
}

class HorizSpace extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SizedBox(width: 8.0);
}

class VertSpace extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SizedBox(height: 8.0);
}
