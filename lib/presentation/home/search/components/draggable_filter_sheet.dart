import '../../../../core/presentation/core_presentation_import.dart';

class DraggableFilterSheet extends StatefulWidget {
  final ScrollController? scrollController;
  final bool isLoadingAllData;
  final VoidCallback onExpandFetch;
  final Widget Function(ScrollController) buildFilterOptions;

  const DraggableFilterSheet({
    super.key,
    required this.isLoadingAllData,
    required this.onExpandFetch,
    required this.buildFilterOptions,
    this.scrollController,
  });

  @override
  State<DraggableFilterSheet> createState() => _DraggableFilterSheetState();
}

class _DraggableFilterSheetState extends State<DraggableFilterSheet> {
  bool _hasFetchedDataOnExpand = false;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (notification) {
        if (notification.extent < 0.2) {
          _hasFetchedDataOnExpand = false;
        }
        if (!_hasFetchedDataOnExpand && notification.extent > 0.2) {
          _hasFetchedDataOnExpand = true;
          widget.onExpandFetch();
        }
        return true;
      },
      child: DraggableScrollableSheet(
        initialChildSize: 0.1,
        minChildSize: 0.1,
        maxChildSize: 0.37,
        builder: (context, scrollController) {
          return Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
                ),
                child: widget.buildFilterOptions(scrollController),
              ),
              if (widget.isLoadingAllData)
                const Positioned(
                  top: 13,
                  right: 20,
                  child: LoadingIndicatorRow(),
                ),
            ],
          );
        },
      ),
    );
  }
}

class LoadingIndicatorRow extends StatelessWidget {
  const LoadingIndicatorRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Text('Loading'),
        SizedBox(width: 5),
        MyCircularIndicator(size: 10),
      ],
    );
  }
}
