import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/core/presentation/components/my_circular_indicator.dart';
import 'package:withme/core/presentation/components/width_height.dart';
import 'package:withme/core/ui/const/duration.dart';
import 'package:withme/core/ui/const/size.dart';
import 'package:withme/domain/model/user_model.dart';
import 'package:withme/presentation/home/dash_board/enum/menu_status.dart';
import 'package:withme/presentation/home/dash_board/screen/dash_board_page.dart';
import 'package:withme/presentation/home/dash_board/screen/dash_board_side_menu.dart';

import '../../../../core/di/setup.dart';
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
                const Text('통계 작성중', style: TextStyles.bold16),
                height(20),
                const MyCircularIndicator(),
              ],
            ),
            false => Stack(
              children: [
                DashBoardSideMenu(
                  viewModel: viewModel,
                  onTap: () {
                    viewModel.logout(context);
                  },
                  currentUser: viewModel.state.userInfo,
                  onInquiryTap: () {
                    showDialog(
                      context: context,
                      builder:
                          (_) => AlertDialog(
                        title: const Text('유료회원 문의'),
                        content: const Text('문의 메일을 보내시겠습니까?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('취소'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                             viewModel.sendInquiryEmail(context);
                            },
                            child: const Text('확인'),
                          ),
                        ],
                      ),
                    );
                  }
                  ,
                ),
                DashBoardPage(
                  viewModel: viewModel,
                  animationController: _animationController,
                  onMenuTap: () => viewModel.toggleMenu(_animationController),
                ),
              ],
            ),
          };
        },
      ),
    );
  }
}
