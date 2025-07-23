import '../core_presentation_import.dart';

void showAgreementDialog(
  BuildContext context, {
  required void Function()? onPressed,
}) {
  showDialog(
    context: context,
    builder:
        (_) => AlertDialog(
          title: const Text('이용 약관'),
          content: const SizedBox(
            // height: 200,
            child: SingleChildScrollView(
              child: Text(
                '내용을 반드시 확인하시기 바랍니다.\n\n'
                '1. 본 앱은 고객 관리 목적으로 사용됩니다.\n'
                '2. 사용자는 이메일과 비밀번호를 입력하여 가입합니다.\n'
                '3. 수집된 데이터는 내부 목적 외에는 사용되지 않습니다.\n'
                '4. 회원 탈퇴시에는 데이터를 모두 삭제합니다.',
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: onPressed, child: const Text('동의합니다')),
          ],
        ),
  );
}
