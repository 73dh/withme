import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:withme/core/ui/const/duration.dart';
import 'package:withme/core/ui/const/free_count.dart';
import 'package:withme/core/ui/const/size.dart';
import 'package:withme/core/utils/core_utils_import.dart';
import 'package:withme/presentation/home/dash_board/dash_board_view_model.dart';

import '../../../../core/domain/core_domain_import.dart';
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
                        const Icon(Icons.date_range),
                        width(5),
                        Text('가입일시: ${currentUser?.agreedDate.formattedDate}'),
                      ],
                    ),
                    const DashedDivider(height: 30),
                    Row(
                      children: [
                        const Icon(Icons.monetization_on),
                        width(5),
                        Text(currentUser?.membershipStatus.toString() ?? ''),
                        if (currentUser != null &&
                            currentUser!.membershipStatus !=
                                MembershipStatus.free) ...[
                          width(8),
                          currentUser!.isMembershipValid
                              ? Text(
                                '(만료일: ${currentUser!.membershipExpiresAt?.formattedDate})',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              )
                              : const Text(
                                '(만료됨)',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                        ],
                      ],
                    ),

                    (currentUser?.membershipStatus.isPaid == true)
                        ? Column(
                          children: [
                            height(15),
                            Row(
                              children: [
                                const Icon(Icons.date_range),
                                width(5),
                                Text(
                                  '직전결제일: ${currentUser?.paidAt?.formattedDate == DateTime(2020).formattedDate ? '이력 없음' : currentUser?.paidAt?.formattedDate}',
                                ),
                              ],
                            ),
                          ],
                        )
                        : const SizedBox.shrink(),

                    const DashedDivider(height: 30),
                    GestureDetector(
                      onTap: onInquiryTap,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.email_outlined,
                                color: Colors.black87,
                              ),
                              width(5),
                              const Text('유료회원 문의'),
                            ],
                          ),
                          height(5),
                          const Text('$freeCount건 까지 결재 무관 사용 가능'),
                        ],
                      ),
                    ),

                    height(10),
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
