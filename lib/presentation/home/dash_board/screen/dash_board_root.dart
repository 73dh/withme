import 'package:firebase_auth/firebase_auth.dart';
import 'package:withme/core/domain/error_handling/signout_error.dart';
import 'package:withme/core/presentation/widget/show_inquiry_confirm_dialog.dart';
import 'package:withme/core/presentation/widget/show_overlay_snack_bar.dart';
import 'package:withme/presentation/home/dash_board/enum/menu_status.dart';
import 'package:withme/presentation/home/dash_board/screen/dash_board_page.dart';
import 'package:withme/presentation/home/dash_board/screen/dash_board_side_menu.dart';

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
  late final AnimationController _animationController;
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SafeArea(
      child: ListenableBuilder(
        listenable: viewModel,
        builder: (_, __) {
          if (viewModel.state.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedText(
                    text: '통계 작성중',
                    style: textTheme.titleSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  height(20),
                  const MyCircularIndicator(),
                ],
              ),
            );
          }

          return Stack(
            children: [
              Container(
                color: colorScheme.surface,
                child: DashBoardPage(
                  viewModel: viewModel,
                  animationController: _animationController,
                  onMenuTap: () => viewModel.toggleMenu(_animationController),
                ),
              ),
              DashBoardSideMenu(
                viewModel: viewModel,
                onLogOutTap: () => _handleLogout(context),
                onSignOutTap: () => _handleSignOut(context),
                onInquiryTap: () => _handleInquiry(context),
                onExcelMessageTap: () => _handleExcelMessage(context),
                onInfoTap: () => _showInfoDialog(context),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Logout
  Future<void> _handleLogout(BuildContext context) async {
    final result = await showInquiryConfirmDialog(
      context,
      title: 'Logout',
      content: 'Logout 하시겠습니까?',
    );
    if (result == true && context.mounted) {
      viewModel.logout(context);
    }
  }

  /// 회원탈퇴
  Future<void> _handleSignOut(BuildContext context) async {
    await showConfirmDialog(
      context,
      textSpans: [
        TextSpan(
          text: '계정 및 데이터가 모두 삭제됩니다.\n',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        TextSpan(
          text: '탈퇴 후에는 복구할 수 없습니다.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.error,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
      confirmButtonText: '회원탈퇴',
      onConfirm: () async {
        final credentials = await showReAuthDialog(
          context,
          email: viewModel.state.userInfo?.email ?? '',
        );
        if (credentials == null) return;

        try {
          if (context.mounted) {
            await viewModel.signOut(context, credentials);
          }
          if (context.mounted) {
            showOverlaySnackBar(
              context,
              '계정이 삭제되었습니다.',
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              textColor: Theme.of(context).colorScheme.onPrimaryContainer,
            );
          }
        } on FirebaseAuthException catch (e) {
          final error = SignOutError.fromCode(e.code);
          if (context.mounted) {
            showOverlaySnackBar(
              context,
              error.toString(),
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              textColor: Theme.of(context).colorScheme.onErrorContainer,
            );
          }
        }
      },
    );
  }

  /// 문의
  Future<void> _handleInquiry(BuildContext context) async {
    final result = await showInquiryConfirmDialog(
      context,
      title: '유료회원 문의',
      content: '문의 메일을 보내시겠습니까?',
    );
    if (result == true && context.mounted) {
      viewModel.sendInquiryEmail(context);
    }
  }

  /// Excel 문의
  void _handleExcelMessage(BuildContext context) {
    showInquiryConfirmDialog(context, title: '유료회원용', content: '유료회원 문의 바랍니다.');
  }

  /// 정보 다이얼로그
  void _showInfoDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border.all(color: colorScheme.outline, width: 1.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 20,
                    ),
                    child: styledInfoText(context), // RichText 지원
                  ),
                  height(10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
