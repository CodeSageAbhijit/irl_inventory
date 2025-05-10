

import 'package:flutter/material.dart';

class TProductPriceText extends StatelessWidget {
  const TProductPriceText({
    super.key,   required this.quantity,  this.maxLines = 1,  this.isLarge = false,  this.LineThrough = false,
  });

  final int quantity;
  final int maxLines;
  final bool isLarge;
  final bool LineThrough;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Quantity: ${quantity.toString()}',
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: isLarge ?  Theme.of(context).textTheme.headlineMedium!.apply(decoration: LineThrough ? TextDecoration.lineThrough : null) : Theme.of(context).textTheme.titleLarge!.apply(decoration: LineThrough ? TextDecoration.lineThrough : null),
    );
  }
}