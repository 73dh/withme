import 'package:shared_preferences/shared_preferences.dart';
import 'package:withme/core/data/fire_base/firestore_keys.dart';
import 'package:withme/core/di/di_setup_import.dart';

import '../../../domain/model/user_model.dart';
import '../../data/fire_base/user_session.dart';
import '../../di/setup.dart';
import '../core_presentation_import.dart';
Future<void> showCycleEditDialog(BuildContext context) async {
  final userSession = getIt<UserSession>();
  final controller = TextEditingController(
    text: userSession.managePeriodDays.toString(),
  );

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('가망고객 관리주기 설정'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '일 수 (예: 60)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              final input = int.tryParse(controller.text);
              if (input != null && input > 0) {
                final currentUser = userSession.currentUser;

                // if (currentUser?.documentReference != null) {
                //   // ✅ Firestore 업데이트
                //   await currentUser!.documentReference!.update({
                //     'prospectCycleDays': input,
                //   });

                  // ✅ UserSession + SharedPreferences 업데이트
                  userSession.updateManagePeriod(input);

                  if (context.mounted) {
                    Navigator.of(context).pop();
                    renderSnackBar(context, text: '관리주기가 저장되었습니다');
                  // }
                }
              } else {
                renderSnackBar(context, text: '올바른 숫자를 입력해주세요');
              }
            },
            child: const Text('저장'),
          ),
        ],
      );
    },
  );
}
