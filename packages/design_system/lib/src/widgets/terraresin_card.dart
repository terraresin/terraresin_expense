import 'package:flutter/material.dart';

import '../colors.dart';

class TerraResinCard extends StatelessWidget {
  const TerraResinCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,

      decoration: BoxDecoration(
        color: TerraResinColors.white,

        borderRadius: BorderRadius.circular(16),

        border: Border.all(color: TerraResinColors.border),
      ),

      child: child,
    );
  }
}
