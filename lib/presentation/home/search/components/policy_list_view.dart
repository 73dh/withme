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
    return widget.policies.where((p) => p.policyState == selectedState.toString()).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = filteredPolicies;

    if (widget.policies.isEmpty) {
      return Column(
        children: [height(200), const AnimatedText(text: '조건에 맞는 계약이 없습니다.')],
      );
    }

    return Column(
      children: [
        _buildStateFilterButtons(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 90.0),
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final policy = filtered[index];
                final isExpanded = expandedIndex == index;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: GestureDetector(
                    onTap: () => toggleExpansion(index),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: isExpanded
                          ? PolicyItem(key: ValueKey('expanded_$index'), policy: policy)
                          : PolicySimpleItem(key: ValueKey('simple_$index'), policy: policy),
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

  Widget _buildStateFilterButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip(null, '전체'),
          ...PolicyState.values.map(
                (state) => _buildFilterChip(state, state.label),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(PolicyState? state, String label) {
    final isSelected = selectedState == state;

    // 각 상태에 해당하는 계약 수 계산
    int count;
    if (state == null) {
      count = widget.policies.length;
    } else {
      count = widget.policies
          .where((p) => p.policyState == state.toString())
          .length;
    }

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text('$label ($count)'),
        selected: isSelected,
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

