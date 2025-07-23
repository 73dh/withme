import '../core_presentation_import.dart';

Future<bool?> showBottomSheetWithDraggable({
  required BuildContext context,
  required Widget child,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (modalContext) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.57,
        maxChildSize: 0.57,
        minChildSize: 0.4,
        builder: (context, scrollController) {
          return ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(10),
            ),
            child: Container(
              decoration: const BoxDecoration(color: Colors.white),
              child: child,
            ),
          );
        },
      );
    },
  );
}
