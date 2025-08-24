import '../../../domain/model/policy_model.dart';
import '../../domain/enum/policy_state.dart';
import '../core_presentation_import.dart';

class CommonPolicyStateDialog extends StatefulWidget {
  final PolicyModel policy;
  final Future<void> Function(String newState) onConfirm;

  const CommonPolicyStateDialog({
    super.key,
    required this.policy,
    required this.onConfirm,
  });

  @override
  State<CommonPolicyStateDialog> createState() =>
      _CommonPolicyStateDialogState();
}

class _CommonPolicyStateDialogState extends State<CommonPolicyStateDialog> {
  late String selectedState;

  @override
  void initState() {
    super.initState();
    selectedState = widget.policy.policyState;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border.all(color: Colors.grey.shade500, width: 1.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 20.0),
                  child: Text(
                    '계약 상태를 선택하세요',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                height(10),
                Column(
                  children:
                      PolicyStatus.values.map((state) {
                        return RadioListTile<String>(
                          title: Text(state.label),
                          value: state.label,
                          groupValue: selectedState,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedState = value;
                              });
                            }
                          },
                        );
                      }).toList(),
                ),
                height(10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilledButton(
                      onPressed: () async {
                        await widget.onConfirm(selectedState);
                        if (context.mounted && Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text('확인'),
                    ),
                  ],
                ),
                height(10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
