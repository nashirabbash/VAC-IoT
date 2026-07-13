import 'package:flutter/material.dart';
import 'package:vac_dashboard_app/asset/color_tokens.dart';

class AppStepper extends StatelessWidget {
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final double width;
  final double height;

  const AppStepper({
    super.key,
    this.onIncrement,
    this.onDecrement,
    this.width = 92.0,
    this.height = 32.0,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDecrementEnabled = onDecrement != null;
    final bool isIncrementEnabled = onIncrement != null;

    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: context.colors.fillsQuaternary, // Fills-Quaternary
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100), // Capsule shape
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Middle Separator Divider
            Positioned(
              left: (width / 2) - 0.5,
              top: 4,
              child: Container(
                width: 1,
                height: height - 8, // e.g. 24px if height is 32px
                decoration: ShapeDecoration(
                  color: context.colors.labelsTertiary, // Labels-Tertiary
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            // Tap Areas
            Row(
              children: [
                // Decrement Button (-)
                Expanded(
                  child: InkWell(
                    onTap: onDecrement,
                    child: Center(
                      child: Opacity(
                        opacity: isDecrementEnabled ? 1.0 : 0.3,
                        child: Icon(
                          Icons.remove,
                          size: 16,
                          color: context.colors.labelsPrimary, // Labels-Primary
                        ),
                      ),
                    ),
                  ),
                ),
                // Increment Button (+)
                Expanded(
                  child: InkWell(
                    onTap: onIncrement,
                    child: Center(
                      child: Opacity(
                        opacity: isIncrementEnabled ? 1.0 : 0.3,
                        child: Icon(
                          Icons.add,
                          size: 16,
                          color: context.colors.labelsPrimary, // Labels-Primary
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
