import 'package:flutter/material.dart';
import 'package:withme/presentation/home/search/enum/selected_menu_no_contact.dart';

class RenderFilledButton extends StatelessWidget {
  final void Function() onPressed;
  final String text;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final List<PopupMenuEntry<SelectedMenuNoContact>>? menuItems;
  final void Function(SelectedMenuNoContact)? onMenuSelected;
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
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: SizedBox(
          width: double.infinity,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment:  MainAxisAlignment.center,
            children: [
              if (menuItems != null)
                PopupMenuButton<SelectedMenuNoContact>(
                  itemBuilder: (context) => menuItems!,
                  onSelected: onMenuSelected,
                  icon: const Icon(Icons.more_vert, size: 20),
                  padding: EdgeInsets.zero,
                  splashRadius: 20,
                ),
              Text(
              menuItems!=null? (selectedMenu??text):  text,
                textAlign:menuItems!=null?TextAlign.left: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
