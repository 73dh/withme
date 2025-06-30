import 'dart:io';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:withme/core/presentation/core_presentation_import.dart';

Future<void> exportAndSendEmailWithExcel(BuildContext context) async {
  // Android: 권한 요청
  if (Platform.isAndroid) {
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("저장 권한이 필요합니다.")));
      return;
    }
  }

  // Excel 생성
  final excel = Excel.createExcel();
  final sheet = excel['Customers'];
  sheet.appendRow(['이름', '나이', '가입일']);
  sheet.appendRow(['홍길동', 30, '2023-01-01']);
  sheet.appendRow(['김영희', 25, '2024-05-10']);

  final List<int>? bytes = excel.encode();
  if (bytes == null) return;

  final Uint8List fileBytes = Uint8List.fromList(bytes);
  final dir = await getTemporaryDirectory();
  final path = '${dir.path}/customer_data.xlsx';
  final file = File(path);
  await file.writeAsBytes(fileBytes);

  // 이메일 작성
  final Email email = Email(
    body: '고객 데이터를 첨부합니다.',
    subject: '고객 데이터 엑셀 파일',
    recipients: ['kdaehee@gmail.com'],
    // <- 수신자 지정
    attachmentPaths: [file.path],
    isHTML: false,
  );

  await FlutterEmailSender.send(email);
}
