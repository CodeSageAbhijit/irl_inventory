import 'package:flutter/material.dart';
import 'package:irl_inventory/common/widgets/custom_shapes/containers/circular_containers.dart';
import 'package:irl_inventory/utils/constants/colors.dart';
import 'package:irl_inventory/utils/helpers/helper_functions.dart';

class TChoiceChip extends StatelessWidget {
  const TChoiceChip({
    super.key,
    required this.text,
    required this.selected,
    this.onSelected,
  });

  final String text;
  final bool selected;
  final void Function(bool)? onSelected;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
      child: ChoiceChip(
        label: THelperFunctions.getColor(text) != null ? SizedBox() : Text(text),
        selected: selected,
        onSelected: onSelected,
        labelStyle: TextStyle(color: selected ? TColors.white : null),
        avatar:THelperFunctions.getColor(text) != null ?  TCircularContainer(width: 50,height: 50,BackgroundColor: THelperFunctions.getColor(text)!,) : null,
        shape: THelperFunctions.getColor(text) != null ? const CircleBorder() : null,
        labelPadding: THelperFunctions.getColor(text) != null ? EdgeInsets.all(0) : null,
        padding: THelperFunctions.getColor(text) != null ? EdgeInsets.all(0) : null,
      backgroundColor:THelperFunctions.getColor(text) != null ? THelperFunctions.getColor(text) : null,
      selectedColor: THelperFunctions.getColor(text) != null ? THelperFunctions.getColor(text) : null,
      ),
    );
  }
}
