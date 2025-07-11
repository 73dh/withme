import 'package:withme/core/ui/const/duration.dart';
import 'package:withme/core/ui/const/free_count.dart';
import 'package:withme/core/ui/const/size.dart';
import 'package:withme/core/utils/core_utils_import.dart';
import 'package:withme/presentation/home/dash_board/dash_board_view_model.dart';

import '../../../../core/data/fire_base/user_session.dart';
import '../../../../core/di/setup.dart';
import '../../../../core/domain/core_domain_import.dart';
import '../../../../core/presentation/core_presentation_import.dart';
import '../../../../core/presentation/widget/show_cycle_edit_dialog.dart';
import '../../../../core/ui/core_ui_import.dart';
import '../../../../domain/model/user_model.dart';

class DashBoardSideMenu extends StatelessWidget {
  final DashBoardViewModel viewModel;
  final void Function() onLogOutTap;
  final void Function() onSignOutTap;
  final UserModel? currentUser;
  final void Function() onInquiryTap;

  DashBoardSideMenu({
    super.key,
    required this.viewModel,
    required this.onLogOutTap,
    required this.onSignOutTap,
    required this.currentUser,
    required this.onInquiryTap,
  });

  final iconColor = ColorStyles.dashBoardIconColor;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedContainer(
        color: Colors.white,
        duration: AppDurations.duration300,
        curve: Curves.easeInOut,
        transform: Matrix4.translationValues(
          viewModel.state.menuXPosition,
          0,
          0,
        ),
        child: SizedBox(
          width: AppSizes.myMenuWidth,
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: PartBox(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildIconRow(
                          Icons.person,
                          currentUser?.email ?? '로그인 정보 없음',
                        ),
                        height(15),
                        buildIconRow(
                          Icons.date_range,
                          '가입일시: ${currentUser?.agreedDate.formattedDate ?? '-'}',
                        ),
                        const DashedDivider(height: 30),
                        if (currentUser?.membershipStatus ==
                            MembershipStatus.free)
                          buildFreeUserInfo(),

                        if (currentUser?.membershipStatus.isPaid == true &&
                            currentUser?.isMembershipValid == false)
                          buildMembershipExpiredBox(),

                        buildMembershipStatusInfo(),
                        buildPaymentHistory(),
                        const DashedDivider(height: 30),
                        buildMenuItem(
                          icon: Icons.email_outlined,
                          text: '유료회원 문의',
                          onTap: onInquiryTap,
                        ),
                        height(15),
                        if (currentUser?.membershipStatus.isPaid == true &&
                            currentUser?.isMembershipValid == true)
                          buildMenuItem(
                            icon: Icons.save_alt_outlined,
                            text: '데이터 내보내기 (Excel)',
                            onTap:
                                currentUser?.isMembershipValid == true
                                    ? () => exportAndSendEmailWithExcel(
                                      context,
                                      viewModel.state.customers,
                                      currentUser!.email,
                                    )
                                    : null,
                          ),

                        AnimatedBuilder(
                          animation: getIt<UserSession>(),
                          builder:
                              (context, _) => buildMenuItem(
                                icon: Icons.handyman,
                                text:
                                    '가망고객 관리주기: ${getIt<UserSession>().managePeriodDays}일',
                                onTap: () => showCycleEditDialog(context),
                              ),
                        ),
                        height(15),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildMenuItem(
                          icon: Icons.exit_to_app,
                          text: 'Logout',
                          onTap: onLogOutTap,
                        ),
                        buildMenuItem(
                          icon: Icons.layers_clear_outlined,
                          text: '회원탈퇴',
                          onTap: onSignOutTap,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildIconRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: iconColor),
        width(5),
        Expanded(child: Text(text)),
      ],
    );
  }

  Widget buildMenuItem({
    required IconData icon,
    required String text,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [Icon(icon, color: iconColor), width(5), Text(text)],
      ),
    );
  }

  Widget buildFreeUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '사용가능 고객정보: ${freeCount - viewModel.state.customers.length} 건',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        height(10),
      ],
    );
  }

  Widget buildMembershipExpiredBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning, color: Colors.red),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              '유료회원 서비스가 만료되어 고객 추가 등록이 불가합니다.\n멤버십을 갱신해주세요.',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMembershipStatusInfo() {
    final status = currentUser?.membershipStatus;
    if (status == null) return const SizedBox.shrink();

    return Row(
      children: [
        Icon(Icons.monetization_on, color: iconColor),
        width(5),
        Text(status.toString()),
        if (status != MembershipStatus.free) ...[
          width(8),
          currentUser!.isMembershipValid
              ? Text(
                '(만료일: ${currentUser!.membershipExpiresAt?.formattedDate ?? '-'})',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              )
              : const Text(
                '(만료됨)',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
        ],
      ],
    );
  }

  Widget buildPaymentHistory() {
    if (currentUser?.membershipStatus.isPaid != true) {
      return const SizedBox.shrink();
    }

    final paidAt = currentUser?.paidAt;
    final hasPaid = paidAt != null && paidAt != DateTime(2020);

    return Column(
      children: [
        height(15),
        buildIconRow(
          Icons.date_range,
          '직전결제일: ${hasPaid ? paidAt!.formattedDate : '이력 없음'}',
        ),
      ],
    );
  }
}
