import 'package:flutter/material.dart';

import '../theme/living_theme.dart';

/// Soft rounded surface. Backed by [Material] so ink effects from child
/// [ListTile]s and [InkWell]s render on top of the card colour.
class LivingCard extends StatelessWidget {
  const LivingCard({
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.color = LivingColors.card,
    this.radius = LivingShape.card,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) => Material(
    color: color,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
    clipBehavior: Clip.antiAlias,
    child: Padding(padding: padding, child: child),
  );
}

/// Dark hero surface. Children must set their own light text colours.
class LivingHeroCard extends StatelessWidget {
  const LivingHeroCard({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => LivingCard(
    color: LivingColors.ink,
    radius: LivingShape.hero,
    padding: const EdgeInsets.all(22),
    child: child,
  );
}

/// Tappable [LivingCard] that announces itself as a button.
class LivingTile extends StatelessWidget {
  const LivingTile({
    required this.onTap,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    super.key,
  });

  final VoidCallback? onTap;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    container: true,
    child: Material(
      color: LivingColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(LivingShape.card),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    ),
  );
}
