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
      final DateTime? paidAt = userInfo.paidAt; // ✅ 여기에서 paidAt 선언

      final membershipStatusString = userInfo.membershipStatus.name as String?;
      final membershipStatus = MembershipStatusExtension.fromString(
        membershipStatusString ?? 'free',
      );

      // ② customers 개수 확인
      // final itemList = await viewModel.cachedProspects
      final itemList =  viewModel.allCustomers;
          // .firstWhere((list) => list.isNotEmpty, orElse: () => [])
          // .timeout(AppDurations.duration50, onTimeout: () => []);
      final itemCount = itemList.length;

      // ③ 무료회원 갯수 제한
      if (membershipStatus == MembershipStatus.free &&
          itemCount >= limitCount) {
        if (context.mounted) {
          await showConfirmDialog(
            context,
            text:
                '무료 회원은 최대 $limitCount건 까지만 등록할 수 있습니다.'
                '\n이메일 문의 후 제한을 해제 하세요.',
            onConfirm: () async => context.pop(),
          );
          return true; // 제한 걸림
        }
      }
      // ④ 유료 회원의 유효기간 만료 여부 체크
      if (membershipStatus.isPaid) {
        final validity = membershipStatus.validityDuration;
        if (validity != null && paidAt != null) {
          final expired = DateTime.now().isAfter(paidAt.add(validity));
          if (expired) {
            // 단, itemCount가 limitCount 이내면 제한하지 않음
            if (itemCount > limitCount) {
              if (context.mounted) {
                await showConfirmDialog(
                  context,
                  text:
                  '${membershipStatus.toString()}의 사용 기간이 만료되었습니다.\n'
                      '계속 이용하려면 결제를 갱신하세요.',
                  onConfirm: () async => context.pop(),
                );
              }
              return true; // 제한 걸림
            }
            // itemCount <= limitCount 이면 제한 안 함 (사용 가능)
          }
        }
      }
    } catch (e) {
      debugPrint("FreeLimitDialog error: $e");
    }

    return false; // 제한 없음
  }
}
