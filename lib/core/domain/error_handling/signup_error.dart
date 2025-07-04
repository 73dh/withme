enum SignUpError {
  emailAlreadyInUse,
  inValidEmail,
  weakPassword,
  unknownError;

  static SignUpError fromCode(String code) {
    switch (code) {
      case 'email-already-in-use':
        return SignUpError.emailAlreadyInUse;
      case 'invalid-email':
        return SignUpError.inValidEmail;
      case 'weak-password':
        return SignUpError.weakPassword;
      default:
        return SignUpError.unknownError;
    }
  }

  @override
  String toString() {
    return switch (this) {
      SignUpError.emailAlreadyInUse => '이미 사용 중인 이메일입니다.',
      SignUpError.inValidEmail => '이메일 형식을 확인하세요.',
      SignUpError.weakPassword => '비밀번호를 강화하세요.',
      SignUpError.unknownError => '회원가입에 실패하였습니다.',
    };
  }
}
