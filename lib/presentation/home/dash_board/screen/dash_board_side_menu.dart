import 'package:withme/core/utils/core_utils_import.dart';
import 'package:withme/presentation/home/dash_board/components/build_icon_row.dart';
import 'package:withme/presentation/home/dash_board/components/membership_expired_box.dart';
import 'package:withme/presentation/home/dash_board/dash_board_view_model.dart';

import '../../../../core/const/duration.dart';
import '../../../../core/const/free_count.dart';
import '../../../../core/const/size.dart';
import '../../../../core/data/fire_base/user_session.dart';
import '../../../../core/di/setup.dart';
import '../../../../core/domain/core_domain_import.dart';
import '../../../../core/presentation/core_presentation_import.dart';
import '../../../../core/presentation/widget/show_cycle_edit_dialog.dart';
import '../../../../core/ui/core_ui_import.dart';
import '../../../../domain/model/user_model.dart';
import '../components/build_menu_item.dart';

class DashBoardSideMenu extends StatelessWidget {
  final DashBoardViewModel viewModel;
  final void Function() onLogOutTap;
  final void Function() onSignOutTap;
  final void Function() onInquiryTap;
  final void Function() onExcelMessageTap;
  final void Function() onInfoTap;

  const DashBoardSideMenu({
    super.key,
    required this.viewModel,
    required this.onLogOutTap,
    required this.onSignOutTap,
    required this.onInquiryTap,
    required this.onExcelMessageTap,
    required this.onInfoTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SafeArea(
      child: AnimatedContainer(
        color: colorScheme.surface,
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
                  children: [
                    // 상단 스크롤 영역
                    Expanded(
                      child: SingleChildScrollView(
                        child: _buildTopSection(textTheme, colorScheme),
                      ),
                    ),
                    height(10),
                    // 하단 고정 메뉴
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopSection(TextTheme textTheme, ColorScheme colorScheme) {
    return ListenableBuilder(
      listenable: getIt<UserSession>(),
      builder: (context, _) {
        final currentUser = getIt<UserSession>().currentUser;
        final managePeriodDays = getIt<UserSession>().managePeriodDays;
        final urgentThresholdDays = getIt<UserSession>().urgentThresholdDays;
        final targetProspectCount = getIt<UserSession>().targetProspectCount;
        final remainPaymentMonth=getIt<UserSession>().remainPaymentMonth;

        if (currentUser == null) {
          return Text('로그인 정보 없음', style: textTheme.bodyMedium);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 사용자 이메일 + 로그아웃 버튼
            Row(
              children: [
                GestureDetector(
                  onTap: onLogOutTap,
                  child: Icon(
                    Icons.power_settings_new,
                    color: colorScheme.error,
                    size: 24,
                  ),
                ),
                width(5),
                Expanded(
                  child: Text(
                    currentUser.email,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            height(15),

            // 가입일
            BuildIconRow(
              icon: Icons.date_range,
              iconColor: colorScheme.primary,
              text: '가입일시: ${currentUser.agreedDate.formattedBirth}',
              textStyle: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const DashedDivider(height: 10),

            // Free User Info
            if (currentUser.membershipStatus == MembershipStatus.free)
              _buildFreeUserInfo(currentUser, colorScheme, textTheme),

            // Membership Expired Box
            if (currentUser.membershipStatus.isPaid &&
                !currentUser.isMembershipValid)
              const MembershipExpiredBox(),

            // Membership Status
            _buildMembershipStatusInfo(currentUser, colorScheme, textTheme),

            // Payment History
            _buildPaymentHistory(currentUser, textTheme, colorScheme),

            const DashedDivider(height: 20),
            Center(
              child: Text(
                '------------ 문의 및 설정 ------------',
                style: textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const DashedDivider(height: 10),
            // 메뉴 항목
            BuildMenuItem(
              icon: Icons.email_outlined,
              text: '유료회원 문의',
              onTap: onInquiryTap,
            ),
            height(15),
            BuildMenuItem(
              icon: Icons.save_alt_outlined,
              text: 'Excel 내보내기 (유료회원)',
              isActivated: currentUser.isMembershipValid,
              onTap:
                  (currentUser.membershipStatus.isPaid &&
                          currentUser.isMembershipValid)
                      ? () => exportAndSendEmailWithExcel(
                        context,
                        viewModel.state.customers,
                        currentUser.email,
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
                    onUpdate:
                        (newDays) =>
                            getIt<UserSession>().updateManagePeriod(newDays),
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
                    onUpdate:
                        (newDays) => getIt<UserSession>()
                            .updateUrgentThresholdDays(newDays),
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
                    onUpdate:
                        (newCount) => getIt<UserSession>()
                            .updateTargetProspectCount(newCount),
                  ),
            ),
            height(15),
            BuildMenuItem(
              icon: Icons.payment_outlined,
              text: '납입기간 종료 관리: $remainPaymentMonth개월',
              onTap:
                  () => showCycleEditDialog(
                context,
                title: '납입기간 종료 관리',
                initNumber: remainPaymentMonth,
                onUpdate:
                    (newMonth) => getIt<UserSession>()
                    .updateRemainPaymentMonth(newMonth),
              ),
            ),
            height(15),
          ],
        );
      },
    );
  }

  Widget _buildFreeUserInfo(
    UserModel currentUser,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '추가등록 가능 고객수: ${freeCount - viewModel.state.customers.length} 명',
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        height(10),
      ],
    );
  }

  Widget _buildMembershipStatusInfo(
    UserModel currentUser,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final status = currentUser.membershipStatus;

    return Row(
      children: [
        Icon(Icons.monetization_on, color: colorScheme.primary),
        width(5),
        Text(
          status.toString(),
          style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
        ),
        if (status != MembershipStatus.free) ...[
          width(8),
          currentUser.isMembershipValid
              ? Text(
                '(만료일: ${currentUser.membershipExpiresAt?.formattedBirth ?? '-'})',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              )
              : Text(
                '(만료됨)',
                style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
              ),
        ],
      ],
    );
  }

  Widget _buildPaymentHistory(
    UserModel currentUser,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    if (!currentUser.membershipStatus.isPaid) return const SizedBox.shrink();

    final paidAt = currentUser.paidAt;
    final hasPaid = paidAt != null && paidAt != DateTime(2020);

    return Column(
      children: [
        height(15),
        BuildIconRow(
          icon: Icons.date_range,
          text: '직전결제일: ${hasPaid ? paidAt.formattedBirth : '이력 없음'}',
          textStyle: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
