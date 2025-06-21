import 'package:go_router/go_router.dart';
import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/core/presentation/core_presentation_import.dart';
import 'package:withme/core/ui/const/duration.dart';
import 'package:withme/domain/model/user_model.dart';

import '../../di/setup.dart';
import '../../domain/core_domain_import.dart';

class FreeLimitDialog {
  static Future<bool> checkAndShow({
    required BuildContext context,
    required ProspectListViewModel viewModel,
  }) async {
    final limitCount = 5;
    try {
      // ① Firestore에서 유저 상태 확인
      final userInfo = UserModel.fromSnapshot(
        await getIt<FBase>().getUserInfo(),
      );

      final membershipStatusString = userInfo.membershipStatus.name as String?;
      final membershipStatus = MembershipStatusExtension.fromString(
        membershipStatusString ?? 'free',
      );

      // ② Prospect 개수 확인
      final itemList = await viewModel.cachedProspects
          .firstWhere((list) => list.isNotEmpty, orElse: () => [])
          .timeout(AppDurations.duration50, onTimeout: () => []);
      final itemCount = itemList.length;

      // ③ 제한 조건 충족 시 다이얼로그 표시
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
    } catch (e) {
      debugPrint("FreeLimitDialog error: $e");
    }

    return false; // 제한 없음
  }
}
