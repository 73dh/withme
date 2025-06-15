import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userKey;
  final String email;
  final DateTime agreedDate;
  final DocumentReference? documentReference;

  UserModel({
    required this.userKey,
    required this.email,
    required this.agreedDate,
    this.documentReference,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userKey: json['userKey'] as String,
      email: json['email'] as String,
      agreedDate: (json['createdAt'] as Timestamp).toDate(),
      documentReference: json['documentReference'] as DocumentReference?,
    );
  }

  factory UserModel.fromMap(
      Map<String, dynamic> map,
      String userKey, {
        DocumentReference? documentReference,
      }) {
    return UserModel(
      userKey: userKey,
      email: map['email'] ?? '',
      agreedDate: (map['createdAt'] as Timestamp).toDate(),
      documentReference: documentReference,
    );
  }

  factory UserModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return UserModel.fromMap(data, snapshot.id, documentReference: snapshot.reference);
  }

  Map<String, dynamic> toMap() {
    return {
      'userKey': userKey,
      'email': email,
      'agreedDate': Timestamp.fromDate(agreedDate),
    };
  }

  @override
  String toString() {
    return 'UserModel{userKey: $userKey, email: $email, agreedDate: $agreedDate}';
  }
}
