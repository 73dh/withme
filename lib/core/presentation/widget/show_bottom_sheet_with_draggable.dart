import '../core_presentation_import.dart';

Future<bool?> showBottomSheetWithDraggable({
  required BuildContext context,
  Widget Function(ScrollController)? builder,
  Widget? child,
  VoidCallback? onClosed,
  Color? backgroundColor, // 추가: 외부에서 색상 지정 가능
}) async {
  assert(
    (child != null) ^ (builder != null),
    'Either child or builder must be provided, but not both.',
  );

  final result = await showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (modalContext) {
      return _KeyboardResponsiveBottomSheet(
        builder: builder,
        child: child,
        backgroundColor:
            backgroundColor ?? Theme.of(context).colorScheme.surface,
      );
    },
  );

  if (onClosed != null) {
    Future.microtask(onClosed);
  }
  return result;
}

class _KeyboardResponsiveBottomSheet extends StatefulWidget {
  final Widget Function(ScrollController)? builder;
  final Widget? child;
  final Color backgroundColor;

  const _KeyboardResponsiveBottomSheet({
    this.builder,
    this.child,
    required this.backgroundColor,
  });

  @override
  State<_KeyboardResponsiveBottomSheet> createState() =>
      _KeyboardResponsiveBottomSheetState();
}

class _KeyboardResponsiveBottomSheetState
    extends State<_KeyboardResponsiveBottomSheet>
    with WidgetsBindingObserver {
  double _keyboardInset = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _keyboardInset = WidgetsBinding.instance.window.viewInsets.bottom;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    if (_keyboardInset != bottomInset) {
      setState(() => _keyboardInset = bottomInset);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaBottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardOpen = mediaBottomInset > 0;
    final maxSize = isKeyboardOpen ? 0.95 : 0.57;
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedPadding(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.only(bottom: mediaBottomInset),
          curve: Curves.easeOut,
          child: DraggableScrollableSheet(
            expand: true,
            initialChildSize: 0.57,
            maxChildSize: maxSize,
            minChildSize: 0.4,
            builder: (context, scrollController) {
              return ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Material(
                  color: widget.backgroundColor, // Theme 적용
                  child: DefaultTextStyle(
                    style: TextStyle(color: colorScheme.onSurface),
                    child:
                        widget.builder != null
                            ? widget.builder!(scrollController)
                            : SingleChildScrollView(
                              controller: scrollController,
                              child: widget.child!,
                            ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
