import 'package:flutter/material.dart';

class AppBarSearchWidget extends StatefulWidget {
  final void Function(String) onSubmitted;

  const AppBarSearchWidget({super.key, required this.onSubmitted});

  @override
  State<AppBarSearchWidget> createState() => _AppBarSearchWidgetState();
}

class _AppBarSearchWidgetState extends State<AppBarSearchWidget> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (_isSearching)
          SizedBox(
            width: 120,
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: '이름입력',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
              style: const TextStyle(color: Colors.black87),
              onSubmitted: (value) {
                widget.onSubmitted(value);
              },
              textAlign: TextAlign.right,
            ),
          ),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 800),
          transitionBuilder: (child, animation) {
            return RotationTransition(turns: animation, child: child);
          },
          child: IconButton(
            key: ValueKey<bool>(_isSearching),
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchController.clear();
                  widget.onSubmitted('');
                }
                _isSearching = !_isSearching;
              });
            },
          ),
        ),
      ],
    );
  }
}
