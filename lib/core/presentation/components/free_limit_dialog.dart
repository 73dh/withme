import 'package:go_router/go_router.dart';
import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/core/presentation/core_presentation_import.dart';
import 'package:withme/core/ui/const/duration.dart';
import 'package:withme/core/ui/const/free_count.dart';
import 'package:withme/domain/model/user_model.dart';

import '../../di/setup.dart';
import '../../domain/core_domain_import.dart';

class FreeLimitDialog {
  static Future<bool> checkAndShow({
    required BuildContext context,
    required ProspectListViewModel viewModel,
  }) async {
    final limitCount = freeCount;

    try {
      // ① Firestore에서 유저 상태 확인
      final userInfo = UserModel.fromSnapshot(
        await getIt<FBase>().getUserInfo(),
      );
      final DateTime? paidAt = userInfo.paidAt;
      final membershipStatusString = userInfo.membershipStatus.name;
      final membershipStatus = MembershipStatusExtension.fromString(
        membershipStatusString,
      );

      // ② 현재 등록된 고객 수 확인
      final itemCount = viewModel.allCustomers.length;
      debugPrint('{itemCount: $itemCount}');
      // ③ 무료회원: 등록 제한 조건
      if (membershipStatus == MembershipStatus.free) {
        if (itemCount >= limitCount) {
          if (context.mounted) {
            await showConfirmDialog(
              context,
              text:
                  '무료 회원은 최대 $limitCount건까지만 등록할 수 있습니다.\n'
                  '이메일 문의 후 제한을 해제하세요.',
              onConfirm: () async => context.pop(),
            );
          }
          return true;
        }
        return false; // 무료회원이지만 제한 미만 → 등록 허용
      }

      // ④ 유료회원: 유효기간 만료 시 제한 조건
      if (membershipStatus.isPaid) {
        final validity = membershipStatus.validityDuration;

        // 유효기간이 존재하고, 결제일 기준 만료되었는지 확인
        if (validity != null && paidAt != null) {
          final expiryDate = paidAt.add(validity);
          final isExpired = DateTime.now().isAfter(expiryDate);

          if (isExpired && itemCount >= limitCount) {
            if (context.mounted) {
              await showConfirmDialog(
                context,
                text:
                    '${membershipStatus.toString()}의 사용 기간이 만료되었습니다.\n'
                    '계속 이용하려면 결제를 갱신하세요.',
                onConfirm: () async => context.pop(),
              );
            }
            return true;
          }
        }
      }
    } catch (e) {
      debugPrint("FreeLimitDialog error: $e");
    }

    return false; // 제한 없음
  }
}
