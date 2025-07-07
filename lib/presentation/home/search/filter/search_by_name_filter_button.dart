import 'package:flutter/material.dart';
import 'package:withme/core/presentation/components/render_filled_button.dart';
import 'package:withme/core/ui/color/color_style.dart';
import 'package:withme/presentation/home/search/search_page_view_model.dart';

import 'package:flutter/material.dart';
import 'package:withme/core/presentation/components/render_filled_button.dart';
import 'package:withme/core/ui/color/color_style.dart';
import 'package:withme/presentation/home/search/search_page_view_model.dart';


import 'package:flutter/material.dart';
import 'package:withme/core/presentation/components/render_filled_button.dart';
import 'package:withme/core/ui/color/color_style.dart';
import 'package:withme/presentation/home/search/search_page_view_model.dart';
class SearchByNameFilterButton extends StatefulWidget {
  final SearchPageViewModel viewModel;
  final FocusNode? focusNode;

  const SearchByNameFilterButton({
    super.key,
    required this.viewModel,
    this.focusNode,
  });

  @override
  State<SearchByNameFilterButton> createState() =>
      _SearchByNameFilterButtonState();
}

class _SearchByNameFilterButtonState extends State<SearchByNameFilterButton> {
  late final FocusNode _focusNode;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 85,
      child: TextField(
        focusNode: _focusNode,
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: '이름',
          isDense: true,
          contentPadding: EdgeInsets.zero,
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
        ),
        onChanged: widget.viewModel.filterPolicyByName,
      ),
    );
  }
}
