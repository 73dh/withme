enum ResetPasswordError {
  userNotFound,
  invalidEmail,
  unKnownError;

  static ResetPasswordError fromCode(String code) {
    switch (code) {
      case 'user-not-found':
        return ResetPasswordError.userNotFound;
      case 'invalid-email':
        return ResetPasswordError.invalidEmail;

      default:
        return ResetPasswordError.unKnownError;
    }
  }

  @override
  String toString() {
    return switch (this) {
      ResetPasswordError.userNotFound => '사용자를 찾을수 없습니다.',
      ResetPasswordError.invalidEmail => '등록되지 않은 이메일입니다.',
      ResetPasswordError.unKnownError => '알수 없는 에러입니다.',
    };
  }
}
