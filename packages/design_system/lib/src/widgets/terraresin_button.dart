import 'package:flutter/material.dart';

import '../colors.dart';

class TerraResinButton extends StatelessWidget {
  const TerraResinButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
  });

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,

      decoration: BoxDecoration(
        gradient: TerraResinColors.brandGradient,

        borderRadius: BorderRadius.circular(12),
      ),

      child: ElevatedButton(
        onPressed: onPressed,

        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: TerraResinColors.white,

          shadowColor: Colors.transparent,

          elevation: 0,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,

          mainAxisSize: MainAxisSize.min,

          children: [
            if (icon != null) ...[Icon(icon), const SizedBox(width: 8)],

            Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
