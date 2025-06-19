import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:withme/core/ui/const/duration.dart';
import 'package:withme/core/ui/const/size.dart';
import 'package:withme/presentation/home/dash_board/dash_board_view_model.dart';

import '../../../../core/presentation/core_presentation_import.dart';
import '../../../../core/ui/core_ui_import.dart';
import '../../../../domain/model/user_model.dart';

class DashBoardSideMenu extends StatelessWidget {
  final DashBoardViewModel viewModel;
  final void Function() onTap;
  final UserModel? currentUser;
  final void Function() onInquiryTap;

  const DashBoardSideMenu({
    super.key,
    required this.viewModel,
    required this.onTap,
    required this.currentUser,
    required this.onInquiryTap,
  });

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person, color: Colors.black87),
                        width(5),
                        Text('${currentUser?.email}'),
                      ],
                    ),
                    height(15),
                    Row(
                      children: [
                        const Icon(Icons.person, color: Colors.black87),
                        width(5),
                        Text('${currentUser?.membershipStatus.toString()}'),
                       Spacer(),
                        SizedBox(
                          width: 130,
                          child: RenderFilledButton(
                            foregroundColor: Colors.white,
                            borderRadius: 5,
                            onPressed: onInquiryTap,
                            text: '유료회원 문의',
                          ),
                        ),
                      ],
                    ),

                    height(15),
                    GestureDetector(
                      onTap: onTap,
                      child: Row(
                        children: [
                          const Icon(Icons.exit_to_app, color: Colors.black87),
                          width(5),
                          const Text('Logout'),
                        ],
                      ),
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
}
