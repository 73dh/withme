import 'package:go_router/go_router.dart';

import '../core_presentation_import.dart'; // MyCircularIndicator 위치에 맞게 import

class ConfirmDialog extends StatefulWidget {
  final String text;
  final Future<void> Function() onConfirm;

  const ConfirmDialog({super.key, required this.text, required this.onConfirm});

  @override
  State<ConfirmDialog> createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<ConfirmDialog> {
  bool isDeleting = false;

  void _onDeletePressed() async {
    setState(() => isDeleting = true);

    try {
      await widget.onConfirm(); // 외부에서 주입된 로직 실행
      if (mounted) context.pop(true);
    } catch (e) {
      // 에러 처리 원하면 여기에 추가 가능
      if (mounted) {
        setState(() => isDeleting = false); // 실패 시 다시 활성화
      }
    }
  }

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
                  child: Text(widget.text, textAlign: TextAlign.center),
                ),
                height(20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilledButton(
                      onPressed: isDeleting ? null : () => context.pop(),
                      child: const Text('취소'),
                    ),
                    width(20),
                    FilledButton(
                      onPressed: isDeleting ? null : _onDeletePressed,
                      child: const Text('삭제'),
                    ),
                  ],
                ),
                height(10),
              ],
            ),
          ),
          if (isDeleting)
            const Positioned(
              left: 40,
              top: 33,
              child: MyCircularIndicator(size: 10),
            ),
        ],
      ),
    );
  }
}
