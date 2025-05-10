import 'package:flutter/material.dart';
import 'package:irl_inventory/common/widgets/custom_shapes/curved_edges/curved_edges.dart';

class CurvedEdgesWidget extends StatelessWidget {
  const CurvedEdgesWidget({
    super.key,
    this.child,
  });

  final Widget? child;
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: TCustomCurvedEdges(),
      child: child,
    );
  }
}
