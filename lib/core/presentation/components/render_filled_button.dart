import 'package:flutter/material.dart';
import 'package:withme/presentation/home/search/enum/coming_birth.dart';
import 'package:withme/presentation/home/search/enum/no_contact_month.dart';
import 'package:withme/presentation/home/search/enum/upcoming_insurance_age.dart';

import '../../ui/color/color_style.dart';
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
  final double? width; // 추가 옵션

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
    final style = FilledButton.styleFrom(
      backgroundColor: backgroundColor ?? colorScheme.primary,
      foregroundColor: foregroundColor ?? colorScheme.onPrimary,
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
              Icon(icon, size: 18),
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
                    color: foregroundColor ?? colorScheme.onPrimary,
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
        style: TextStyle(
          fontSize: 14,
          color: foregroundColor ?? colorScheme.onPrimary,
        ),
      ),
    );
  }

  Icon _getMenuIcon(ColorScheme colorScheme) {
    if (menuItems != null && menuItems!.isNotEmpty) {
      final firstItem = menuItems!.first;

      if (firstItem is PopupMenuItem<NoContactMonth>) {
        return Icon(Icons.schedule, size: 22, color: colorScheme.onPrimary);
      } else if (firstItem is PopupMenuItem<ComingBirth>) {
        return Icon(Icons.cake_outlined, size: 22, color: colorScheme.onPrimary);
      } else if (firstItem is PopupMenuItem<UpcomingInsuranceAge>) {
        return Icon(Icons.calendar_today, size: 22, color: colorScheme.onPrimary);
      }
    }
    return Icon(Icons.arrow_drop_down, size: 25, color: colorScheme.onPrimary);
  }
}

//
// class RenderFilledButton extends StatelessWidget {
//   final void Function()? onPressed;
//   final String text;
//   final IconData? icon;
//   final double borderRadius;
//   final Color? backgroundColor;
//   final Color? foregroundColor;
//   final List<PopupMenuEntry<dynamic>>? menuItems;
//   final void Function(dynamic)? onMenuSelected;
//   final String? selectedMenu;
//   final double? width; // 추가 옵션
//
//   const RenderFilledButton({
//     super.key,
//     required this.onPressed,
//     required this.text,
//     this.icon,
//     this.borderRadius = 2,
//     this.backgroundColor,
//     this.foregroundColor = Colors.black87,
//     this.menuItems,
//     this.onMenuSelected,
//     this.selectedMenu,
//     this.width,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: width ?? double.infinity, // 외부에서 전달 시 사용
//       child: _buildButton(),
//     );
//   }
//
//   Widget _buildButton() {
//     final style = FilledButton.styleFrom(
//       backgroundColor: backgroundColor,
//       foregroundColor: foregroundColor,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(borderRadius),
//       ),
//       padding: const EdgeInsets.symmetric(
//         horizontal: 6,
//         vertical: 10,
//       ), // 최소 패딩 조정
//     );
//
//     if (menuItems != null && menuItems!.isNotEmpty) {
//       return FilledButton(
//         onPressed: onPressed,
//         style: style,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           mainAxisSize: MainAxisSize.max,
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(right: 4),
//               child: SizedBox(
//                 width: 20,
//                 height: 20,
//                 child: PopupMenuButton<dynamic>(
//                   itemBuilder: (context) => menuItems!,
//                   onSelected: onMenuSelected,
//                   icon: _getMenuIcon(),
//                   padding: EdgeInsets.zero,
//                   splashRadius: 18,
//                 ),
//               ),
//             ),
//             if (icon != null) ...[
//               Icon(icon, size: 18),
//               const SizedBox(width: 2),
//             ],
//             Expanded(
//               child: FittedBox(
//                 fit: BoxFit.scaleDown,
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   selectedMenu ?? text,
//                   style: const TextStyle(fontSize: 14),
//                 ),
//               ),
//             ),
//
//           ],
//         ),
//       );
//     }
//
//     return FilledButton(
//       onPressed: onPressed,
//       style: style,
//       child: Text(
//         text,
//         textAlign: TextAlign.center,
//         overflow: TextOverflow.ellipsis,
//         maxLines: 1,
//         style: const TextStyle(fontSize: 14),
//       ),
//     );
//   }
//
//   Icon _getMenuIcon() {
//     if (menuItems != null && menuItems!.isNotEmpty) {
//       final firstItem = menuItems!.first;
//
//       if (firstItem is PopupMenuItem<NoContactMonth>) {
//         return Icon(
//           Icons.schedule,
//           size: 22,
//           color: ColorStyles.menuButtonColor,
//         );
//       } else if (firstItem is PopupMenuItem<ComingBirth>) {
//         return Icon(
//           Icons.cake_outlined,
//           size: 22,
//           color: ColorStyles.menuButtonColor,
//         );
//       } else if (firstItem is PopupMenuItem<UpcomingInsuranceAge>) {
//         return Icon(
//           Icons.calendar_today,
//           size: 22,
//           color: ColorStyles.menuButtonColor,
//         );
//       }
//     }
//
//     return const Icon(Icons.arrow_drop_down, size: 25); // 기본 아이콘
//   }
// }
