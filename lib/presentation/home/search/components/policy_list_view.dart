import 'package:flutter/material.dart';

import '../../../../core/domain/enum/policy_state.dart';
import '../../../../core/presentation/components/policy_item.dart';
import '../../../../core/presentation/components/policy_simple_item.dart';
import '../../../../core/presentation/core_presentation_import.dart';
import '../../../../domain/model/policy_model.dart';

class PolicyListView extends StatefulWidget {
  final List<PolicyModel> policies;

  const PolicyListView({super.key, required this.policies});

  @override
  State<PolicyListView> createState() => _PolicyListViewState();
}

class _PolicyListViewState extends State<PolicyListView> {
  int? expandedIndex;
  PolicyState? selectedState;

  void toggleExpansion(int index) {
    setState(() {
      expandedIndex = expandedIndex == index ? null : index;
    });
  }

  List<PolicyModel> get filteredPolicies {
    if (selectedState == null) return widget.policies;
    return widget.policies
        .where((p) => p.policyState == selectedState!.label)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final filtered = filteredPolicies;

    if (widget.policies.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 100),
          child: Text(
            '조건에 맞는 계약이 없습니다.',
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        // 필터 버튼
        _buildStateFilterButtons(colorScheme, textTheme),
        // 리스트
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 90.0),
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final policy = filtered[index];
                final isExpanded = expandedIndex == index;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: GestureDetector(
                    onTap: () => toggleExpansion(index),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child:
                          isExpanded
                              ? PolicyItem(
                                key: ValueKey('expanded_$index'),
                                policy: policy,
                              )
                              : PolicySimpleItem(
                                key: ValueKey('simple_$index'),
                                policy: policy,
                              ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStateFilterButtons(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip(null, '전체', colorScheme, textTheme),
          ...PolicyState.values.map(
            (state) =>
                _buildFilterChip(state, state.label, colorScheme, textTheme),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    PolicyState? state,
    String label,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final isSelected = selectedState == state;

    // 각 상태에 해당하는 계약 수 계산
    final count =
        state == null
            ? widget.policies.length
            : widget.policies.where((p) => p.policyState == state.label).length;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        key: ValueKey(state ?? 'all'),
        label: Text('$label ($count)'),
        labelStyle: textTheme.labelLarge?.copyWith(
          color:
              isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
        ),
        selected: isSelected,
        showCheckmark: false,
        // 체크 표시 제거
        selectedColor: colorScheme.primary,
        backgroundColor: colorScheme.surfaceContainerHighest,
        onSelected: (_) {
          setState(() {
            selectedState = isSelected ? null : state;
            expandedIndex = null; // 필터 변경 시 펼쳐진 아이템 초기화
          });
        },
      ),
    );
  }
}
