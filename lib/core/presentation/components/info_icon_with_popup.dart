import '../core_presentation_import.dart';

class InfoIconWithPopup extends StatefulWidget {
  final String message;
  final Color color;

  const InfoIconWithPopup({
    super.key,
    required this.message,
    required this.color,
  });

  @override
  State<InfoIconWithPopup> createState() => _InfoIconWithPopupState();
}

class _InfoIconWithPopupState extends State<InfoIconWithPopup> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  void _showOverlay() {
    if (_overlayEntry != null) return; // 중복 방지
    final overlay = Overlay.of(context);
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset position = box.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx, // 버튼 왼쪽 기준
        top: position.dy + box.size.height + 4, // 버튼 아래쪽 + 약간 여백
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColorDark,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              widget.message,
              style: Theme.of(context).textTheme.labelSmall,
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
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleOverlay,
        child: Icon(Icons.info_outline, size: 15, color: widget.color),
      ),
    );
  }
}
