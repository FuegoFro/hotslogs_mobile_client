import 'package:flutter/material.dart';

IndexedWidgetBuilder listBuilderWithDividers(
    IndexedWidgetBuilder underlyingBuilder) {
  return (BuildContext context, int index) {
    if (index.isOdd) {
      return Divider();
    }
    final logicalIndex = index ~/ 2;
    return underlyingBuilder(context, logicalIndex);
  };
}
