import 'package:flutter/material.dart';
import 'package:withme/core/presentation/components/my_circular_indicator.dart';
import 'package:withme/core/presentation/components/width_height.dart';
import 'package:withme/core/ui/const/duration.dart';
import 'package:withme/core/ui/const/size.dart';
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
  MenuStatus _menuStatus = MenuStatus.isClosed;
  double _bodyXPosition = 0;
  double _menuXPosition = AppSizes.deviceSize.width;

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

  void _toggleMenu() {
    setState(() {
      final isOpening = _menuStatus == MenuStatus.isClosed;
      _menuStatus = isOpening ? MenuStatus.isOpened : MenuStatus.isClosed;

      if (isOpening) {
        _animationController.forward();
        _bodyXPosition = -AppSizes.myMenuWidth;
        _menuXPosition = AppSizes.deviceSize.width - AppSizes.myMenuWidth;
      } else {
        _animationController.reverse();
        _bodyXPosition = 0;
        _menuXPosition = AppSizes.deviceSize.width;
      }
    });
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
                const Text('통계 작성중',style: TextStyles.bold16,),
                height(20),
                const MyCircularIndicator(),
              ],
            ),
            false => Stack(
              children: [
                DashBoardPage(
                  viewModel: viewModel,
                  bodyXPosition: _bodyXPosition,
                  animationController: _animationController,
                  onMenuTap: _toggleMenu,
                ),
                DashBoardSideMenu(
                  menuXPosition: _menuXPosition,
                  menuWidth: AppSizes.myMenuWidth,
                  onTap: () {
                    viewModel.logout();
                    _toggleMenu();
                  },
                ),
              ],
            ),
          };
        },
      ),
    );
  }
}
