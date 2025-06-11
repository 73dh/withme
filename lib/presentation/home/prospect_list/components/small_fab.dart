import 'package:withme/core/ui/const/duration.dart';

import '../../../../core/presentation/core_presentation_import.dart';
import '../../../../core/ui/core_ui_import.dart';

class SmallFab extends StatefulWidget {
  final bool fabVisibleLocal;
  final bool fabExpanded;
  final void Function(void Function())? overlaySetStateFold;
  final void Function(void Function())? overlaySetState;

  const SmallFab({
    super.key,
    required this.fabExpanded,
    this.overlaySetState,
    this.overlaySetStateFold,
    required this.fabVisibleLocal,
  });

  @override
  State<SmallFab> createState() => _SmallFabState();
}

class _SmallFabState extends State<SmallFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _sizeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDurations.duration300,
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _sizeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_fadeAnimation);
  }

  @override
  void didUpdateWidget(covariant SmallFab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.fabExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: widget.fabVisibleLocal ? 1.0 : 0.0,
      duration: AppDurations.duration300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 리스트는 애니메이션으로 숨김/표시
          SizeTransition(
            sizeFactor: _sizeAnimation,
            axis: Axis.vertical,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildExpandedContent(),
            ),
          ),

          // FAB는 항상 렌더링하되, 펼쳐졌을 때 숨김
          AnimatedSwitcher(
            duration: AppDurations.duration300,
            child:
                widget.fabExpanded
                    ? const SizedBox.shrink()
                    : FloatingActionButton.small(
                      key: const ValueKey('fabMain'),
                      heroTag: 'fabSecondary',
                      backgroundColor: ColorStyles.fabColor,
                      onPressed: () {
                        widget.overlaySetState?.call(() {});
                      },
                      child: Icon(Icons.sort_outlined, color: Colors.black87),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent() {
    return SizeTransition(
      sizeFactor: _sizeAnimation,
      axis: Axis.vertical,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.2), // 시작 위치: 아래쪽
            end: Offset.zero, // 끝 위치: 제자리
          ).animate(_fadeAnimation),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildMiniAction('Edit', Icons.edit),
              _buildMiniAction('Delete', Icons.delete),
              _buildMiniAction('Share', Icons.share),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                heroTag: 'fabClose',
                backgroundColor: ColorStyles.fabColor,
                onPressed: () {
                  widget.overlaySetStateFold?.call(() {});
                },
                child: Icon(Icons.close, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniAction(String label, IconData icon) {
    return Container(
      width: 110, // 동일한 너비 지정
      height: 32, // 적당한 높이 지정 (필요에 따라 조절)
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: ColorStyles.fabColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        padding: EdgeInsets.symmetric(horizontal: 8),
        onPressed: () {},
        icon: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: Colors.black),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(color: Colors.black, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }


}
