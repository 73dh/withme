import 'package:go_router/go_router.dart';
import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/core/presentation/core_presentation_import.dart';
import 'package:withme/core/ui/const/free_count.dart';
import 'package:withme/domain/model/user_model.dart';

import '../../di/setup.dart';
import '../../domain/core_domain_import.dart';


import 'package:flutter/material.dart';
import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/core/ui/const/free_count.dart';
import 'package:withme/domain/model/user_model.dart';

import '../../di/setup.dart';
import '../../domain/core_domain_import.dart';
import '../core_presentation_import.dart'; // showConfirmDialog import 필요

class FreeLimitDialog {
  static Future<bool> checkAndShow({
    required BuildContext context,
    required ProspectListViewModel viewModel,
  }) async {
    final limitCount = freeCount;

    try {
      final userInfo = UserModel.fromSnapshot(
        await getIt<FBase>().getUserInfo(),
      );
      final DateTime? paidAt = userInfo.paidAt;
      final membershipStatusString = userInfo.membershipStatus.name;
      final membershipStatus = MembershipStatusExtension.fromString(
        membershipStatusString,
      );

      final itemCount = viewModel.allCustomers.length;
      debugPrint('{itemCount: $itemCount}');

      // 무료회원 제한
      if (membershipStatus == MembershipStatus.free) {
        if (itemCount >= limitCount) {
          if (context.mounted) {
            await showConfirmDialog(
              context,
              text:
              '무료 회원은 최대 $limitCount건까지만 등록할 수 있습니다.\n'
                  '이메일 문의 후 제한을 해제하세요.',
              confirmButtonText: "확인",
              cancelButtonText: "",
              // onConfirm 전달 안 하면 기본 동작: 다이얼로그 닫기
            );
          }
          return true;
        }
        return false;
      }

      // 유료회원 제한
      if (membershipStatus.isPaid) {
        final validity = membershipStatus.validityDuration;

        if (validity != null && paidAt != null) {
          final expiryDate = paidAt.add(validity);
          final isExpired = DateTime.now().isAfter(expiryDate);

          if (isExpired && itemCount >= limitCount) {
            if (context.mounted) {
              await showConfirmDialog(
                context,
                text:
                '${membershipStatus.toString()} 사용 기간 만료.\n'
                    '계속 이용하려면 결제를 갱신하세요.',
                confirmButtonText: "확인",
                cancelButtonText: "",
              );
            }
            return true;
          }
        }
      }
    } catch (e) {
      debugPrint("FreeLimitDialog error: $e");
    }

    return false;
  }
}

// class FreeLimitDialog {
//   static Future<bool> checkAndShow({
//     required BuildContext context,
//     required ProspectListViewModel viewModel,
//   }) async {
//     final limitCount = freeCount;
//
//     try {
//       final userInfo = UserModel.fromSnapshot(
//         await getIt<FBase>().getUserInfo(),
//       );
//       final DateTime? paidAt = userInfo.paidAt;
//       final membershipStatusString = userInfo.membershipStatus.name;
//       final membershipStatus = MembershipStatusExtension.fromString(
//         membershipStatusString,
//       );
//
//       final itemCount = viewModel.allCustomers.length;
//       debugPrint('{itemCount: $itemCount}');
//
//       // 무료회원
//       if (membershipStatus == MembershipStatus.free) {
//         if (itemCount >= limitCount) {
//           if (context.mounted) {
//             await showConfirmDialog(
//               context,
//               text:
//               '무료 회원은 최대 $limitCount건까지만 등록할 수 있습니다.\n'
//                   '이메일 문의 후 제한을 해제하세요.',
//               confirmButtonText: "확인",
//               cancelButtonText: "",
//               onConfirm: () async => Navigator.of(context).pop(), // ✅ Dialog만 닫음
//             );
//           }
//           return true;
//         }
//         return false;
//       }
//
//       // 유료회원
//       if (membershipStatus.isPaid) {
//         final validity = membershipStatus.validityDuration;
//
//         if (validity != null && paidAt != null) {
//           final expiryDate = paidAt.add(validity);
//           final isExpired = DateTime.now().isAfter(expiryDate);
//
//           if (isExpired && itemCount >= limitCount) {
//             if (context.mounted) {
//               await showConfirmDialog(
//                 context,
//                 text:
//                 '${membershipStatus.toString()}의 사용 기간이 만료되었습니다.\n'
//                     '계속 이용하려면 결제를 갱신하세요.',
//                 confirmButtonText: "확인",
//                 cancelButtonText: "",
//                 onConfirm: () async => Navigator.of(context).pop(), // ✅ Dialog만 닫음
//               );
//             }
//             return true;
//           }
//         }
//       }
//     } catch (e) {
//       debugPrint("FreeLimitDialog error: $e");
//     }
//
//     return false;
//   }
// }
