import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PopupMenuButton<dynamic>(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Icon(
              icon ?? Icons.more_vert,
              size: 18,
              color: iconColor ?? colorScheme.primary,
            ),
            itemBuilder: (context) {
              return items
                  .map(
                    (e) => PopupMenuItem<dynamic>(
                      child: GestureDetector(
                        onTap: () {
                          onSelect(e);
                          context.pop();
                        },
                        child: Text(
                          e.toString(),
                          style: textTheme.bodyMedium?.copyWith(
                            color: textColor ?? colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  )
                  .toList();
            },
          ),
          // const SizedBox(width: 4),
          Expanded(
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
    );
  }
}
