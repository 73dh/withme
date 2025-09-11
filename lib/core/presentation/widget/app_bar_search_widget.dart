import 'package:flutter/material.dart';

import '../../const/duration.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        if (_isSearching)
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 60),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: '이름',
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                hintStyle: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              style: TextStyle(color: colorScheme.onSurface),
              onSubmitted: (value) => widget.onSubmitted(value),
              textAlign: TextAlign.right,
            ),
          ),

        AnimatedSwitcher(
          duration: AppDurations.duration500,
          transitionBuilder: (child, animation) {
            return RotationTransition(turns: animation, child: child);
          },
          child: IconButton(
            key: ValueKey<bool>(_isSearching),
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: colorScheme.onSurface,
            ),
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
