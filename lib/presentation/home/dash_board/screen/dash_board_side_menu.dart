import 'package:withme/core/ui/const/free_count.dart';
import 'package:withme/core/ui/const/size.dart';
import 'package:withme/core/utils/core_utils_import.dart';
import 'package:withme/presentation/home/dash_board/components/build_icon_row.dart';
import 'package:withme/presentation/home/dash_board/components/membership_expired_box.dart';
import 'package:withme/presentation/home/dash_board/dash_board_view_model.dart';

import '../../../../core/data/fire_base/user_session.dart';
import '../../../../core/di/setup.dart';
import '../../../../core/domain/core_domain_import.dart';
import '../../../../core/presentation/core_presentation_import.dart';
import '../../../../core/presentation/widget/show_cycle_edit_dialog.dart';
import '../../../../core/ui/core_ui_import.dart';
import '../../../../core/ui/theme/theme_controller.dart';
import '../../../../domain/model/user_model.dart';
import '../../../../main.dart' show themeController;
import '../components/build_menu_item.dart';

class DashBoardSideMenu extends StatelessWidget {
  final DashBoardViewModel viewModel;
  final void Function() onLogOutTap;
  final void Function() onSignOutTap;
  final void Function() onInquiryTap;
  final void Function() onExcelMessageTap;
  final void Function() onInfoTap;

  DashBoardSideMenu({
    super.key,
    required this.viewModel,
    required this.onLogOutTap,
    required this.onSignOutTap,
    required this.onInquiryTap,
    required this.onExcelMessageTap,
    required this.onInfoTap,
  });

  final Color iconColor = ColorStyles.dashBoardIconColor; // final로 변경

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
                        // UserSession의 변경을 감지하여 사용자 정보 영역을 업데이트
                        ListenableBuilder(
                          listenable: getIt<UserSession>(),
                          // UserSession의 모든 변경을 수신
                          builder: (context, _) {
                            final currentUser =
                                getIt<UserSession>().currentUser;
                            final managePeriodDays =
                                getIt<UserSession>().managePeriodDays;
                            final urgentThresholdDays =
                                getIt<UserSession>().urgentThresholdDays;
                            final targetProspectCount =
                                getIt<UserSession>().targetProspectCount;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: onLogOutTap,
                                      child: const Icon(
                                        Icons.power_settings_new,
                                        color: Colors.redAccent,
                                        weight: 60,
                                      ),
                                    ),
                                    width(5),
                                    Expanded(
                                      child: Text(
                                        currentUser?.email ?? '로그인 정보 없음',
                                      ),
                                    ),
                                  ],
                                ),

                                height(15),
                                BuildIconRow(
                                  icon: Icons.date_range,
                                  text:
                                      '가입일시: ${currentUser?.agreedDate.formattedBirth ?? '-'}',
                                ),
                                const DashedDivider(height: 30),

                                if (currentUser?.membershipStatus ==
                                    MembershipStatus.free)
                                  _buildFreeUserInfo(currentUser),

                                // currentUser 전달
                                if (currentUser?.membershipStatus.isPaid ==
                                        true &&
                                    currentUser?.isMembershipValid == false)
                                  const MembershipExpiredBox(),

                                // currentUser 전달
                                _buildMembershipStatusInfo(currentUser),
                                // currentUser 전달
                                _buildPaymentHistory(currentUser),
                                // currentUser 전달
                                const DashedDivider(height: 30),

                                BuildMenuItem(
                                  icon: Icons.email_outlined,
                                  text: '유료회원 문의',
                                  onTap: onInquiryTap,
                                ),
                                height(15),
                                BuildMenuItem(
                                  icon: Icons.save_alt_outlined,
                                  text: 'Excel 내보내기 (유료회원)',
                                  isActivated: currentUser?.isMembershipValid,
                                  onTap:
                                      (currentUser?.membershipStatus.isPaid ==
                                                  true &&
                                              currentUser?.isMembershipValid ==
                                                  true)
                                          ? () => exportAndSendEmailWithExcel(
                                            context,
                                            viewModel.state.customers,
                                            currentUser!.email,
                                          )
                                          : onExcelMessageTap,
                                ),
                                height(15),
                                BuildMenuItem(
                                  icon: Icons.add_call,
                                  text: '고객 관리 주기: $managePeriodDays일',
                                  onTap:
                                      () => showCycleEditDialog(
                                        context,
                                        title: '고객 관리 주기',
                                        initNumber: managePeriodDays,
                                        onUpdate: (newDays) {
                                          getIt<UserSession>()
                                              .updateManagePeriod(newDays);
                                        },
                                      ),
                                ),
                                height(15),
                                BuildMenuItem(
                                  icon: Icons.alarm_add_outlined,
                                  text: '상령일 도래 알림: $urgentThresholdDays일',
                                  onTap:
                                      () => showCycleEditDialog(
                                        context,
                                        title: '상령일 알림 기준일',
                                        initNumber: urgentThresholdDays,
                                        onUpdate: (newDays) {
                                          getIt<UserSession>()
                                              .updateUrgentThresholdDays(
                                                newDays,
                                              );
                                        },
                                      ),
                                ),
                                height(15),
                                BuildMenuItem(
                                  icon: Icons.person,
                                  text: '가망고객 목표: $targetProspectCount명',
                                  onTap:
                                      () => showCycleEditDialog(
                                        context,
                                        title: '가망고객 목표',
                                        initNumber: targetProspectCount,
                                        onUpdate: (newCount) {
                                          getIt<UserSession>()
                                              .updateTargetProspectCount(
                                                newCount,
                                              );
                                        },
                                      ),
                                ),
                                height(15),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                    const Spacer(),


                    BuildMenuItem(
                      icon: Icons.info_outline,
                      text: 'App소개',
                      onTap: onInfoTap,
                    ),
                    height(15),
                    BuildMenuItem(
                      icon: Icons.layers_clear_outlined,
                      text: '회원탈퇴',
                      onTap: onSignOutTap,
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

  // 이제 currentUser를 인자로 받도록 변경
  Widget _buildFreeUserInfo(UserModel? currentUser) {
    if (currentUser == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '추가등록 가능 고객수: ${freeCount - viewModel.state.customers.length} 명',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        height(10),
      ],
    );
  }

  // 이제 currentUser를 인자로 받도록 변경
  Widget _buildMembershipStatusInfo(UserModel? currentUser) {
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
                '(만료일: ${currentUser.membershipExpiresAt?.formattedBirth ?? '-'})',
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

  // 이제 currentUser를 인자로 받도록 변경
  Widget _buildPaymentHistory(UserModel? currentUser) {
    if (currentUser?.membershipStatus.isPaid != true) {
      return const SizedBox.shrink();
    }

    final paidAt = currentUser?.paidAt;
    final hasPaid = paidAt != null && paidAt != DateTime(2020);

    return Column(
      children: [
        height(15),
        BuildIconRow(
          icon: Icons.date_range,
          text: '직전결제일: ${hasPaid ? paidAt.formattedBirth : '이력 없음'}',
        ),
      ],
    );
  }
}
