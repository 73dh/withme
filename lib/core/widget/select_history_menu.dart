import 'package:flutter/material.dart';

import '../../presentation/registration/enum/history_content.dart';

class SelectHistoryMenu extends StatefulWidget {
  final MenuController menuController;
  final TextEditingController textEditingController;

  const SelectHistoryMenu({
    super.key,
    required this.menuController,
    required this.textEditingController,
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
              onPressed: () {
                setState(() {
                  if (content == HistoryContent.etc) {
                    widget.textEditingController.clear();
                  } else {
                    widget.textEditingController.text = content.toString().trim();
                  }
                  widget.menuController.close();
                });
              },
            );
          }).toList(),
    );
  }
}
