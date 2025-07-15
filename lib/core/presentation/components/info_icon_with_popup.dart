import '../core_presentation_import.dart';

class InfoIconWithPopup extends StatefulWidget {
  final String message;
  final Color color;
  const InfoIconWithPopup({super.key, required this.message, required this.color});

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
        left: position.dx + box.size.width + 8,
        top: position.dy,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              widget.message,
              style: const TextStyle(color: Colors.black87, fontSize: 10),
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
        child: Icon(
          Icons.info_outline,
          size: 15,
          color: widget.color,
        ),
      ),
    );
  }
}
