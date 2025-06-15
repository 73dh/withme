String generateUserKey(String email) =>
    '${email}_${DateTime.now().millisecondsSinceEpoch}';