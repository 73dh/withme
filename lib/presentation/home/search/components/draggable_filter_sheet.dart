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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                decoration: BoxDecoration(
                  color: colorScheme.surface, // 다크/라이트 대응
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      color: colorScheme.shadow.withValues(
                        alpha: 0.2,
                      ), // 투명도 조정
                    ),
                  ],
                ),
                child: widget.buildFilterOptions(scrollController),
              ),
              if (widget.isLoadingAllData)
                Positioned(
                  top: 13,
                  right: 20,
                  child: LoadingIndicatorRow(colorScheme: colorScheme),
                ),
            ],
          );
        },
      ),
    );
  }
}

class LoadingIndicatorRow extends StatelessWidget {
  final ColorScheme colorScheme;

  const LoadingIndicatorRow({super.key, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Loading',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurface, // 배경 대비 자동
          ),
        ),
        const SizedBox(width: 5),
        const MyCircularIndicator(size: 10),
      ],
    );
  }
}
