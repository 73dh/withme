import '../core_presentation_import.dart';

Future<bool?> showBottomSheetWithDraggable({
  required BuildContext context,
   Widget Function(ScrollController)? builder,
   Widget? child,
}) {

  assert(
  (child != null) ^ (builder != null),
  'Either child or builder must be provided, but not both.',
  );
  return showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (modalContext) {
      final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
      return Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: DraggableScrollableSheet(
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
                child: builder != null
                    ? builder(scrollController)
                    : child,
              ),
            );
          },
        ),
      );
    },
  );
}
