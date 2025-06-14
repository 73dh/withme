import 'package:flutter/material.dart';
import 'package:withme/presentation/home/search/enum/no_contact_month.dart';

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
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (menuItems != null)
              PopupMenuButton<dynamic>(
                itemBuilder: (context) => menuItems!,
                onSelected: onMenuSelected as dynamic,
                icon:  Icon(Icons.arrow_drop_down, size: 20,color: ColorStyles.menuButtonColor,),
                padding: EdgeInsets.zero,
                splashRadius: 20,
              ),
            Text(
              menuItems != null ? (selectedMenu ?? text) : text,
              textAlign: menuItems != null ? TextAlign.left : TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
