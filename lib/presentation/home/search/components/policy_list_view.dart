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

  void toggleExpansion(int index) {
    setState(() {
      if(expandedIndex == index) {
        expandedIndex = null;
      } else {
        expandedIndex = index;
      }
      });

  }
  @override
  Widget build(BuildContext context) {
    if (widget.policies.isEmpty) {
      return Column(
        children: [height(200), const AnimatedText(text: '조건에 맞는 계약이 없습니다.')],
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 90.0),
      child: ListView.builder(
        itemCount: widget.policies.length,
        itemBuilder: (context, index) {
          final policy = widget.policies[index];
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
    );
  }
}
