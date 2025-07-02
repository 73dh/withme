import 'dart:io';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:withme/core/presentation/core_presentation_import.dart';
import 'dart:io';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:withme/core/presentation/core_presentation_import.dart';

import '../../../domain/domain_import.dart';

Future<void> exportAndSendEmailWithExcel(
  BuildContext context,
  List<CustomerModel> customers,
  String currentUserEmail,
) async {
  // Android: 저장 권한이 필요한지 확인 (API 29 이하에서만 요청)
  if (await _needsStoragePermission()) {
    final status =
        await Permission.storage
            .request(); // WRITE_EXTERNAL_STORAGE는 maxSdkVersion:28이므로 여기선 storage
    if (!status.isGranted && context.mounted) {
      renderSnackBar(context, text: '저장 권한이 필요합니다.');
      return;
    }
  }
  final excel = Excel.createExcel();
  final customerSheet = excel['Customers'];
  final policySheet = excel['Policies'];

  // 🔸 고객 시트 헤더
  customerSheet.appendRow([
    '고객 이름',
    '성별',
    '생년월일',
    '소개자',
    '등록일',
    '보험계약 건수',
    // '관리 개수',
  ]);

  for (final customer in customers) {
    customerSheet.appendRow([
      customer.name,
      customer.sex,
      _formatDate(customer.birth),
      customer.recommended,
      _formatDate(customer.registeredDate),
      customer.policies.length,
      // customer.histories.length,
    ]);

    // // 히스토리 추가
    // if (customer.histories.isNotEmpty) {
    //   customerSheet.appendRow(['[히스토리]']);
    //   customerSheet.appendRow(['날짜', '유형', '메모']);
    //   for (final history in customer.histories) {
    //     customerSheet.appendRow([
    //       _formatDate(history.contactDate),
    //       history.content,
    //     ]);
    //   }
    //   customerSheet.appendRow([]);
    // }
  }
  // 🔸 보험 시트 헤더
  policySheet.appendRow([
    // '고객 키',
    '계약자',
    '계약자 생일',
    '계약자 성별',
    '피보험자',
    '피보험자 생일',
    '피보험자 성별',
    '상품분류',
    '보험사',
    '상품명',
    '납입방법',
    '보험료',
    '계약일',
    '만기일',
    '계약상태',
    // '보험 키',
  ]);

  for (final customer in customers) {
    for (final policy in customer.policies) {
      policySheet.appendRow([
        // policy.customerKey,
        policy.policyHolder,
        _formatDate(policy.policyHolderBirth),
        policy.policyHolderSex,
        policy.insured,
        _formatDate(policy.insuredBirth),
        policy.insuredSex,
        policy.productCategory,
        policy.insuranceCompany,
        policy.productName,
        policy.paymentMethod,
        policy.premium,
        _formatDate(policy.startDate),
        _formatDate(policy.endDate),
        policy.policyState,
        // policy.policyKey,
      ]);
    }
  }

  // 🔸 저장
  final fileBytes = excel.encode();
  if (fileBytes == null) return;

  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/고객 데이터.xlsx');
  await file.writeAsBytes(Uint8List.fromList(fileBytes));

  // 🔸 이메일 보내기
  final email = Email(
    body: '고객 및 계약 데이터가 첨부되었습니다.',
    subject: '고객 데이터',
    recipients: [currentUserEmail],
    attachmentPaths: [file.path],
    isHTML: false,
  );

  await FlutterEmailSender.send(email);
}

String _formatDate(DateTime? date) {
  if (date == null) return '';
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

// Android API 29 이하일 경우에만 저장 권한 필요
Future<bool> _needsStoragePermission() async {
  if (!Platform.isAndroid) return false;

  final androidInfo = await DeviceInfoPlugin().androidInfo;
  return androidInfo.version.sdkInt <= 29; // API 29 (Android 10) 이하만 권한 요청
}
