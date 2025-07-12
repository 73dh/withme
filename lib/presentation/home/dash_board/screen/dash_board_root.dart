import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/core/domain/error_handling/signout_error.dart';
import 'package:withme/core/presentation/components/animated_text.dart';
import 'package:withme/core/presentation/components/my_circular_indicator.dart';
import 'package:withme/core/presentation/components/width_height.dart';
import 'package:withme/core/presentation/widget/show_inquiry_confirm_dialog.dart';
import 'package:withme/core/ui/const/duration.dart';
import 'package:withme/core/ui/const/size.dart';
import 'package:withme/domain/model/user_model.dart';
import 'package:withme/presentation/home/dash_board/enum/menu_status.dart';
import 'package:withme/presentation/home/dash_board/screen/dash_board_page.dart';
import 'package:withme/presentation/home/dash_board/screen/dash_board_side_menu.dart';

import '../../../../core/data/fire_base/user_session.dart';
import '../../../../core/di/setup.dart';
import '../../../../core/presentation/core_presentation_import.dart';
import '../../../../core/presentation/widget/show_reauth_dialog.dart';
import '../../../../core/ui/core_ui_import.dart';
import '../dash_board_view_model.dart';

class DashBoardRoot extends StatefulWidget {
  const DashBoardRoot({super.key});

  @override
  State<DashBoardRoot> createState() => _DashBoardRootState();
}

class _DashBoardRootState extends State<DashBoardRoot>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final viewModel = getIt<DashBoardViewModel>();

  @override
  void initState() {
    super.initState();
    viewModel.loadData();
    _animationController = AnimationController(
      vsync: this,
      duration: AppDurations.duration300,
    );
  }

  @override
  void dispose() {
    if (viewModel.state.menuStatus == MenuStatus.isOpened) {
      viewModel.forceCloseMenu();
    }
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListenableBuilder(
        listenable: viewModel,
        builder: (context, widget) {
          return switch (viewModel.state.isLoading) {
            true => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AnimatedText(text: '통계 작성중'),
                height(20),
                const MyCircularIndicator(),
              ],
            ),
            false => Stack(
              children: [
                DashBoardPage(
                  viewModel: viewModel,
                  animationController: _animationController,
                  onMenuTap: () => viewModel.toggleMenu(_animationController),
                ),
                DashBoardSideMenu(
                  viewModel: viewModel,
                  onLogOutTap: _onLogOutTap,
                  onSignOutTap: _onSignOutTap,
                  // currentUser: viewModel.state.userInfo,
                  onInquiryTap: _onInquiryTap,
                  onExcelMessageTap: _onExcelMessageTap,
                ),
              ],
            ),
          };
        },
      ),
    );
  }

  void _onLogOutTap() async {
    bool? result = await showInquiryConfirmDialog(
      context,
      title: 'Logout',
      content: 'Logout 하겠습니까?',
    );
    if (result == true && mounted) {
      viewModel.logout(context);
    }
  }

  void _onSignOutTap() async {
    await showConfirmDialog(
      context,
      text: '계정 및 데이터가 모두 삭제됩니다.\n탈퇴 후에는 복구할 수 없습니다.',
      buttonText: '회원탈퇴',
      onConfirm: () async {
        final credentials = await showReauthDialog(
          context,
          email: viewModel.state.userInfo?.email ?? '',
        );
        if (credentials == null) return; // 취소 시 종료

        try {
          if (mounted) {
            await viewModel.signOut(context, credentials);
          }
          if (mounted) {
            renderSnackBar(context, text: '계정이 삭제되었습니다.');
          }
        } on FirebaseAuthException catch (e) {
          final error = SignOutError.fromCode(e.code);
          if (mounted) {
            renderSnackBar(context, text: error.toString());
          }
        }
      },
    );
  }

  void _onInquiryTap() async {
    bool? result = await showInquiryConfirmDialog(
      context,
      title: '유료회원 문의',
      content: '문의 메일을 보내시겠습니까?',
    );
    if (result == true && mounted) {
      viewModel.sendInquiryEmail(context);
    }
  }

  void _onExcelMessageTap() {
    showInquiryConfirmDialog(title: '유료회원용', content: '유료회원 문의 바랍니다.', context);
  }
}
