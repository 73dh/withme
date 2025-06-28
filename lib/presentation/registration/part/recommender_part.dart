import '../../../core/presentation/core_presentation_import.dart';
import '../../../core/ui/core_ui_import.dart';

class RecommenderPart extends StatelessWidget {
  final bool isReadOnly;
  final bool isRecommended;
  final TextEditingController recommendedController;
  final void Function(bool) onChanged;

  const RecommenderPart({
    super.key,
    required this.isReadOnly,
    required this.isRecommended,
    required this.onChanged,
    required this.recommendedController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: Column(
        children: [
          _buildRecommenderSwitch(),
          if (isRecommended) _buildRecommenderField(),
        ],
      ),
    );
  }

  Widget _buildRecommenderSwitch() => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text('소개자 ${isReadOnly ? '' : '(선택)'}', style: TextStyles.normal14),
    trailing: Switch.adaptive(
      value: isRecommended,
      activeColor: ColorStyles.activeSwitchColor,
      onChanged: isReadOnly ? null : (val) => onChanged(val),
    ),
  );

  Widget _buildRecommenderField() =>
      isReadOnly
          ? Align(
            alignment: Alignment.centerLeft,
            child: Text(recommendedController.text),
          )
          : CustomTextFormField(
            controller: recommendedController,
            hintText: '소개자 이름',
            validator: (text) => text.isEmpty ? '소개자 이름을 입력하세요' : null,
            onSaved: (text) => recommendedController.text = text.trim(),
          );
}
