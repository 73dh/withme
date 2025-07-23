import 'package:go_router/go_router.dart';

import '../core_presentation_import.dart'; // MyCircularIndicator 위치에 맞게 import

class CommonConfirmDialog extends StatelessWidget {
  final String text;
  final String confirmButtonText;
  final String cancelButtonText;
  final Future<void> Function() onConfirm;

  const CommonConfirmDialog({
    super.key,
    required this.text,
    required this.confirmButtonText,
    required this.cancelButtonText,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border.all(color: Colors.grey.shade500, width: 1.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 20.0,
                    left: 12,
                    right: 12,
                  ),
                  child: Text(text, textAlign: TextAlign.center),
                ),
                height(20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Cancel Button: Only pops the dialog itself with 'false'
                 if(cancelButtonText.isNotEmpty)
                    FilledButton(
                      onPressed: () {
                        if (context.mounted) {
                          Navigator.of(context).pop(false);
                        }
                      },
                      child: Text(cancelButtonText),
                    ),
                    width(10),
                    // Confirm Button: Executes onConfirm, then pops the dialog with 'true'
                    FilledButton(
                      onPressed: () async {
                        await onConfirm();
                        if (context.mounted) {
                          Navigator.of(context).pop(true);
                        }
                      },
                      child: Text(confirmButtonText),
                    ),
                  ],
                ),
                height(10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}