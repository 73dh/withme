import 'package:flutter/material.dart';
import 'package:withme/presentation/home/search/enum/coming_birth.dart';
import 'package:withme/presentation/home/search/enum/no_contact_month.dart';
import 'package:withme/presentation/home/search/enum/upcoming_insurance_age.dart';

import '../../ui/color/color_style.dart';
import 'package:flutter/material.dart';
import 'package:withme/presentation/home/search/enum/coming_birth.dart';
import 'package:withme/presentation/home/search/enum/no_contact_month.dart';
import 'package:withme/presentation/home/search/enum/upcoming_insurance_age.dart';
import 'package:flutter/material.dart';
import 'package:withme/presentation/home/search/enum/coming_birth.dart';
import 'package:withme/presentation/home/search/enum/no_contact_month.dart';
import 'package:withme/presentation/home/search/enum/upcoming_insurance_age.dart';

class RenderFilledButton extends StatelessWidget {
  final void Function()? onPressed;
  final String text;
  final IconData? icon;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final List<PopupMenuEntry<dynamic>>? menuItems;
  final void Function(dynamic)? onMenuSelected;
  final String? selectedMenu;
  final double? width;

  const RenderFilledButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.borderRadius = 2,
    this.backgroundColor,
    this.foregroundColor,
    this.menuItems,
    this.onMenuSelected,
    this.selectedMenu,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: width ?? double.infinity,
      child: _buildButton(context, colorScheme),
    );
  }

  Widget _buildButton(BuildContext context, ColorScheme colorScheme) {
    final bgColor = backgroundColor ?? colorScheme.primary;
    final fgColor = foregroundColor ?? colorScheme.onPrimary;

    final style = FilledButton.styleFrom(
      backgroundColor: bgColor,
      foregroundColor: fgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
    );

    if (menuItems != null && menuItems!.isNotEmpty) {
      return FilledButton(
        onPressed: onPressed,
        style: style,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: SizedBox(
                width: 20,
                height: 20,
                child: PopupMenuButton<dynamic>(
                  itemBuilder: (context) => menuItems!,
                  onSelected: onMenuSelected,
                  icon: _getMenuIcon(colorScheme),
                  padding: EdgeInsets.zero,
                  splashRadius: 18,
                ),
              ),
            ),
            if (icon != null) ...[
              Icon(icon, size: 18, color: fgColor),
              const SizedBox(width: 2),
            ],
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  selectedMenu ?? text,
                  style: TextStyle(
                    fontSize: 14,
                    color: fgColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return FilledButton(
      onPressed: onPressed,
      style: style,
      child: Text(
        text,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: TextStyle(fontSize: 14, color: fgColor),
      ),
    );
  }

  Icon _getMenuIcon(ColorScheme colorScheme) {
    if (menuItems != null && menuItems!.isNotEmpty) {
      final firstItem = menuItems!.first;

      if (firstItem is PopupMenuItem<NoContactMonth>) {
        return Icon(Icons.schedule, size: 16, color: colorScheme.onSurface);
      } else if (firstItem is PopupMenuItem<ComingBirth>) {
        return Icon(Icons.cake_outlined, size: 16, color: colorScheme.onSurface);
      } else if (firstItem is PopupMenuItem<UpcomingInsuranceAge>) {
        return Icon(Icons.calendar_today, size: 16, color: colorScheme.onSurface);
      }
    }
    return Icon(Icons.arrow_drop_down, size: 25, color: colorScheme.onPrimary);
  }
}
