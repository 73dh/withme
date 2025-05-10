import 'package:flutter/material.dart';

import '../../domain/enum/history_content.dart';

class SelectHistoryMenu extends StatefulWidget {
  final MenuController menuController;
  final TextEditingController textController;
  final void Function(TextEditingController controller) onTap;

  const SelectHistoryMenu({
    super.key,
    required this.menuController,
    required this.textController,
    required this.onTap,
  });

  @override
  State<SelectHistoryMenu> createState() => _SelectHistoryMenuState();
}

class _SelectHistoryMenuState extends State<SelectHistoryMenu> {
  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      controller: widget.menuController,
      menuChildren:
          HistoryContent.values.map((content) {
            return MenuItemButton(
              child: Text(content.toString()),
              onPressed:
              // ()=>widget.onTap(widget.textEditingController)
              () {
                setState(() {
                  if (content == HistoryContent.etc) {
                    widget.textController.clear();
                  } else {
                    widget.textController.text = content.toString().trim();
                  }
                  widget.onTap(widget.textController);
                  widget.menuController.close();
                });
              },
            );
          }).toList(),
    );
  }
}
