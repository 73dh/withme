import 'package:flutter/material.dart';
import 'package:withme/core/utils/shortened_text.dart';

class HistoryButton extends StatelessWidget {
  final MenuController menuController;
  final TextEditingController textController;
  final void Function()? onPressed;

  const HistoryButton({
    super.key,
    required this.menuController,
    required this.textController,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () {
        onPressed;
        if (menuController.isOpen) {
          menuController.close();
        } else {
          onPressed;
          menuController.open();
        }
      },
      style: FilledButton.styleFrom(
        backgroundColor: Colors.grey,

        padding: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.7,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            shortenedText(textController.text),
            textAlign: TextAlign.left,
          ),
        ),
      ),
    );
  }
}
