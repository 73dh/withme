import '../../../../core/presentation/core_presentation_import.dart';

class SmallFab extends StatelessWidget {
  final bool fabExpanded;
  final void Function(void Function())? overlaySetStateFold;
  final void Function(void Function())? overlaySetState;

  const SmallFab({
    super.key,
    required this.fabExpanded,
    this.overlaySetState,
    this.overlaySetStateFold,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 132, // main FAB보다 위
      right: 16,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child:
            fabExpanded
                ? AnimatedContainer(
                  key: const ValueKey('searchIcon'),
                  duration: Duration(milliseconds: 300),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: FloatingActionButton.small(
                    heroTag: 'fabSecondary',
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    onPressed: () {
                      overlaySetStateFold?.call(() {
                        // 상태 전환
                      });
                    },
                    child: const Icon(Icons.search),
                  ),
                )
                : AnimatedContainer(
                  key: const ValueKey('collapseText'),
                  duration: Duration(milliseconds: 300),
                  width: 100,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: FloatingActionButton.small(
                    heroTag: 'fabSecondary',
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    onPressed: () {
                      overlaySetState?.call(() {
                        // 상태 전환
                      });
                    },
                    child: const Text(
                      '검색 접기',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                ),
      ),
    );
  }
}
