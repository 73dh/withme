import 'package:firebase_auth/firebase_auth.dart';
import 'package:withme/core/domain/error_handling/reset_password_error.dart';

Future<void> resetPassword({
  required String email,
  required void Function(String message) onResult,
}) async {
  if (email.isEmpty || !email.contains('@')) {
    onResult('유효한 이메일을 입력하세요.');
    return;
  }

  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    onResult('비밀번호 재설정 이메일을 전송했습니다.\n메일함을 확인하세요.');
  } on FirebaseAuthException catch (e) {
    final message = ResetPasswordError.fromCode(e.code).toString();
    onResult(message);
  } catch (_) {
    onResult(ResetPasswordError.unKnownError.toString());
  }
}
