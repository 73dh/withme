import 'package:flutter/material.dart';

import '../core_presentation_import.dart';
class RenderPopUpMenu extends StatelessWidget {
  final String label;
  final List<dynamic> items;
  final void Function(dynamic) onSelect;
  final IconData? icon;
  final Color? textColor;
  final Color? iconColor;

  const RenderPopUpMenu({
    super.key,
    required this.label,
    required this.items,
    required this.onSelect,
    this.icon,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return PopupMenuButton<dynamic>(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      onSelected: onSelect,
      itemBuilder: (context) {
        return items
            .map(
              (e) => PopupMenuItem<dynamic>(
            value: e,
            child: Text(
              e.toString(),
              style: textTheme.bodyMedium?.copyWith(
                color: textColor ?? colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        )
            .toList();
      },
      child: Container(
        // ✅ 부모 Expanded에서 받은 폭을 모두 사용
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, // 아이콘 + 텍스트 가운데 정렬
          children: [
            Icon(
              icon ?? Icons.more_vert,
              size: 18,
              color: iconColor ?? colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: textTheme.bodySmall?.copyWith(
                  color: textColor ?? colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
