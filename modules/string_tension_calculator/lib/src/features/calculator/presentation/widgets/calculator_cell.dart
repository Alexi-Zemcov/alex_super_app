import 'package:flutter/material.dart';

const double calculatorCellWidth = 80;
const double calculatorCellHeight = 80;
const double calculatorCellGap = 8;

class CalculatorCell extends StatelessWidget {
  const CalculatorCell({
    required this.child,
    this.onIncrement,
    this.onDecrement,
    super.key,
  });

  final Widget child;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  @override
  Widget build(BuildContext context) {
    final isAdjustable = onIncrement != null || onDecrement != null;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A33),
        borderRadius: BorderRadius.circular(6),
      ),
      child: SizedBox(
        width: calculatorCellWidth,
        height: calculatorCellHeight,
        child: isAdjustable
            ? Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _ArrowButton(
                    icon: Icons.keyboard_arrow_up_rounded,
                    onPressed: onIncrement,
                  ),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: child,
                      ),
                    ),
                  ),
                  _ArrowButton(
                    icon: Icons.keyboard_arrow_down_rounded,
                    onPressed: onDecrement,
                  ),
                ],
              )
            : Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: child,
                ),
              ),
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({required this.icon, this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (onPressed == null) {
      return const SizedBox(height: 18);
    }

    return SizedBox(
      height: 18,
      width: double.infinity,
      child: InkWell(
        onTap: onPressed,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        child: Icon(icon, size: 16, color: Colors.white),
      ),
    );
  }
}
