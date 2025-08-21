import '../core_presentation_import.dart';

import '../core_presentation_import.dart';

class InfoIconWithPopup extends StatefulWidget {
  final String message;
  final Color? color; // nullable로 두고 기본은 theme 색상 사용

  const InfoIconWithPopup({
    super.key,
    required this.message,
    this.color,
  });

  @override
  State<InfoIconWithPopup> createState() => _InfoIconWithPopupState();
}

class _InfoIconWithPopupState extends State<InfoIconWithPopup> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  void _showOverlay() {
    if (_overlayEntry != null) return;
    final overlay = Overlay.of(context);
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset position = box.localToGlobal(Offset.zero);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx,
        top: position.dy + box.size.height + 4,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant, // 팝업 배경
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            child: Text(
              widget.message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant, // 대비 색상
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _toggleOverlay() {
    if (_overlayEntry == null) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleOverlay,
        child: Icon(
          Icons.info_outline,
          size: 16,
          color: widget.color ?? colorScheme.primary, // 기본 아이콘 색상은 primary
        ),
      ),
    );
  }
}

