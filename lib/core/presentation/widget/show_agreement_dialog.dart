import '../core_presentation_import.dart';

void showAgreementDialog(BuildContext context,{required void Function() onPressed}) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('이용 약관'),
      content: const SizedBox(
        height: 200,
        child: SingleChildScrollView(
          child: Text(
            '여기에 약관 내용을 입력하세요.\n\n'
                '1. 본 앱은 고객 관리 목적으로 사용됩니다.\n'
                '2. 사용자는 이메일과 비밀번호를 입력하여 가입합니다.\n'
                '3. 수집된 데이터는 내부 목적 외에는 사용되지 않습니다.\n'
                '4. 기타 내용은 실제 약관을 참고하세요.',
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: onPressed,
          child: const Text('동의합니다'),
        ),
      ],
    ),
  );
}
