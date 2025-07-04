enum SignOutError {
  emailError,
  invalidPassword,
  unknownError;

  static SignOutError fromCode(String code) {
    switch (code) {
      case 'invalid-email':
        return SignOutError.emailError;
      case 'invalid-credential':
        return SignOutError.invalidPassword;
      default:
        return SignOutError.unknownError;
    }
  }

  @override
  String toString() {
    return switch (this) {
      SignOutError.emailError => '이메일을 확인하세요',
      SignOutError.invalidPassword => '비밀번호를 확인하세요',
      SignOutError.unknownError => '알수 없는 에러입니다.',
    };
  }
}
