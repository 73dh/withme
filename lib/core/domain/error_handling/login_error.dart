import '../core_domain_import.dart';

enum LoginError  {
  userNotFound,
  invalidEmail,
  wrongPassword,
  invalidCredential,
  tooManyRequests,
  unknownError;

  static LoginError fromCode(String code) {
    switch (code) {
      case 'user-not-found':
        return LoginError.userNotFound;
      case 'invalid-email':
        return LoginError.invalidEmail;
      case 'wrong-password':
        return LoginError.wrongPassword;
      case 'invalid-credential':
        return LoginError.invalidCredential;
      case 'too-many-requests':
        return LoginError.tooManyRequests;
      default:
        return LoginError.unknownError;
    }
  }
  @override
  String toString() {
    return switch (this) {
      LoginError.userNotFound => '등록되지 않은 이메일입니다.',
      LoginError.invalidEmail => '이메일 형식이 잘못되었습니다.',
      LoginError.wrongPassword => '비밀번호가 일치하지 않습니다.',
      LoginError.invalidCredential => '사용자 정보가 없습니다.',
      LoginError.tooManyRequests => '잠시 후 다시 시도해 주세요.',
      LoginError.unknownError => '알수 없는 에러입니다.',
    };
  }
}
