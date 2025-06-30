import 'package:flutter/material.dart';
import 'package:withme/presentation/home/search/enum/coming_birth.dart';
import 'package:withme/presentation/home/search/enum/no_contact_month.dart';
import 'package:withme/presentation/home/search/enum/upcoming_insurance_age.dart';

import '../../ui/color/color_style.dart';

class RenderFilledButton extends StatelessWidget {
  final void Function()? onPressed;
  final String text;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final List<PopupMenuEntry<dynamic>>? menuItems;
  final void Function(dynamic)? onMenuSelected;
  final String? selectedMenu;
  final double? width; // 추가 옵션

  const RenderFilledButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.borderRadius = 2,
    this.backgroundColor,
    this.foregroundColor = Colors.black87,
    this.menuItems,
    this.onMenuSelected,
    this.selectedMenu,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity, // 외부에서 전달 시 사용
      child: _buildButton(),
    );
  }

  Widget _buildButton() {
    final style = FilledButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );

    if (menuItems != null && menuItems!.isNotEmpty) {
      return FilledButton(
        onPressed: onPressed,
        style: style,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PopupMenuButton<dynamic>(
              itemBuilder: (context) => menuItems!,
              onSelected: onMenuSelected,
              icon: _getMenuIcon(),
              padding: EdgeInsets.zero,
              splashRadius: 20,
            ),
            Text(
              selectedMenu ?? text,
              textAlign: TextAlign.left,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }

    return FilledButton(
      onPressed: onPressed,
      style: style,
      child: Text(text, textAlign: TextAlign.center),
    );
  }

  Icon _getMenuIcon() {
    if (menuItems != null && menuItems!.isNotEmpty) {
      final firstItem = menuItems!.first;

      if (firstItem is PopupMenuItem<NoContactMonth>) {
        return const Icon(Icons.schedule, size: 22);
      } else if (firstItem is PopupMenuItem<ComingBirth>) {
        return const Icon(Icons.cake_outlined, size: 22);
      } else if (firstItem is PopupMenuItem<UpcomingInsuranceAge>) {
        return const Icon(Icons.calendar_today, size: 22);
      }
    }

    return const Icon(Icons.arrow_drop_down, size: 25); // 기본 아이콘
  }
}
