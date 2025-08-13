import '../core_presentation_import.dart';
import '../core_presentation_import.dart';

void showAgreementDialog(
  BuildContext context, {
  required void Function()? onPressed,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  showDialog(
    context: context,
    builder:
        (_) => AlertDialog(
          backgroundColor: colorScheme.surface,
          title: Text(
            '이용 약관',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            child: SingleChildScrollView(
              child: Text(
                '내용을 반드시 확인하시기 바랍니다.\n\n'
                '1. 앱은 고객 관리 목적으로만 사용됩니다.\n'
                '2. 사용자는 이메일과 비밀번호 만으로 가입할수 있습니다.\n'
                '3. 고객의 주민등록번호 및 전화번호는 수집하지 않습니다.\n'
                '4. 관리자는 고객정보를 내부 관리목적으로만 사용합니다.\n'
                '5. 회원 탈퇴시에는 데이터를 모두 삭제하며, 복구는 불가능합니다.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: onPressed,
              style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
              child: Text(
                '동의합니다',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
  );
}
