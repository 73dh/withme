import 'package:flutter/material.dart';
import 'package:withme/presentation/home/dash_board/components/arrow_indicator.dart';
import 'package:withme/presentation/home/dash_board/components/render_table.dart';

class RenderScrollableTable extends StatefulWidget {
  final List<TableRow> rows;
  final List<String> sortedKeys;

  const RenderScrollableTable({
    super.key,
    required this.rows,
    required this.sortedKeys,
  });

  @override
  State<RenderScrollableTable> createState() => _RenderScrollableTableState();
}

class _RenderScrollableTableState extends State<RenderScrollableTable> {
  bool showRightArrow = false;
  bool showLeftArrow = false;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateArrowVisibility);
  }

  void _updateArrowVisibility() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final current = _scrollController.offset;

    final shouldShowRight = current < maxScroll;
    final shouldShowLeft = current > 100;

    if (shouldShowRight != showRightArrow || shouldShowLeft != showLeftArrow) {
      setState(() {
        showRightArrow = shouldShowRight;
        showLeftArrow = shouldShowLeft;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateArrowVisibility();
        });
        return Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: RenderTable(
                columnWidths: {
                  0: const FixedColumnWidth(100),
                  for (int i = 1; i <= widget.sortedKeys.length; i++)
                    i: const FixedColumnWidth(50),
                },
                tableRows: widget.rows,
              ),
            ),
            if (showRightArrow)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: ArrowIndicator(isRight: true),
              ),
            if (showLeftArrow)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: ArrowIndicator(isRight: false),
              ),
          ],
        );
      },
    );
  }
}
