import 'package:flutter/material.dart';
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
  final _scrollController = ScrollController();

  @override
  void initState() {
    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final current = _scrollController.offset;
      final shouldShow = current == maxScroll;

      if (shouldShow) {
        setState(() {
          showRightArrow = false;
        });
      } else {
        setState(() {
          showRightArrow = true;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
        if (showRightArrow == true)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Container(
                width: 30,
                alignment: Alignment.centerRight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.white.withOpacity(0.0), // 왼쪽은 투명
                      Colors.white.withOpacity(0.8), // 오른쪽은 반투명 흰색
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  size: 50,
                  color: Colors.red,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
