import 'package:withme/core/utils/core_utils_import.dart';

import '../../../core/presentation/core_presentation_import.dart';
import '../../../domain/domain_import.dart';

class ConfirmBoxPart extends StatelessWidget {
  final bool isRegistering;
  final CustomerModel? customerModel;
  final TextEditingController nameController;

  final TextEditingController recommendedController;

  final TextEditingController historyController;

  final TextEditingController birthController;

  final TextEditingController registeredDateController;

  final String? sex;
  final DateTime? birth;
  final void Function() onPressed;

  const ConfirmBoxPart({
    super.key,
    required this.isRegistering,
    required this.customerModel,
    required this.nameController,
    required this.recommendedController,
    required this.historyController,
    required this.birthController,
    required this.registeredDateController,
    required this.onPressed,
    required this.sex,
    required this.birth,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            height(15),
            ConfirmBoxText(
              text: customerModel == null ? '신규등록 확인' : '수정내용 확인',
              size: 18,
            ),
            height(10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ConfirmBoxText(
                  text: '등록자: ',
                  text2: ' ${nameController.text} ($sex)',
                ),
                ConfirmBoxText(
                  text: '생년월일: ',
                  text2:
                      birthController.text.isEmpty
                          ? '추후입력'
                          : birth?.formattedDate,
                ),
                ConfirmBoxText(
                  text: '소개자: ',
                  text2:
                      recommendedController.text.isEmpty
                          ? '없음'
                          : recommendedController.text,
                ),
                ConfirmBoxText(
                  text: '등록일: ',
                  text2: registeredDateController.text,
                ),
                if (customerModel == null)
                  ConfirmBoxText(text2: historyController.text),
              ],
            ),
            height(20),
            RenderFilledButton(
              text: customerModel == null ? '등록' : '수정',
              onPressed: onPressed,
              foregroundColor: Colors.white,
            ),
          ],
        ),
        if (isRegistering)
           Positioned(
            left: 10,
            top: 10,
            child: Row(
              children: [
                Text('저장중'),
                width(5),
                MyCircularIndicator(size: 10),
              ],
            ),
          ),
      ],
    );
  }
}
