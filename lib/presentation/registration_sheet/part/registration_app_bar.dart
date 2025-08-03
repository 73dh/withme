import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/core/presentation/widget/history_part_widget.dart';
import 'package:withme/core/utils/core_utils_import.dart';
import 'package:withme/domain/model/todo_model.dart';
import 'package:withme/domain/use_case/history/add_history_use_case.dart';

import '../../../core/data/fire_base/user_session.dart';
import '../../../core/di/setup.dart';
import '../../../core/domain/core_domain_import.dart';
import '../../../core/presentation/components/orbiting_dots.dart';
import '../../../core/presentation/core_presentation_import.dart';
import '../../../core/presentation/widget/show_add_todo_dialog.dart';
import '../../../core/ui/core_ui_import.dart';
import '../../../core/utils/show_history_util.dart';
import '../../../domain/domain_import.dart';
import '../../../domain/model/history_model.dart';
import '../components/add_policy_button.dart';
import '../components/edit_toggle_icon.dart';
import '../registration_event.dart';
import '../registration_view_model.dart';

class RegistrationAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final bool isReadOnly;
  final VoidCallback onPressed;
  final VoidCallback onTap;
  final bool isNeedNewHistory;
  final RegistrationViewModel viewModel;
  final CustomerModel? customerModel;

  const RegistrationAppBar({
    super.key,
    required this.isReadOnly,
    required this.onPressed,
    required this.onTap,
    required this.isNeedNewHistory,
    required this.viewModel,
    required this.customerModel,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: Colors.white,
      title: _buildTitle(),
      actions: [_buildActions(context)],
    );
  }

  Widget _buildTitle() {
    if (customerModel == null) return const Text('New');
    final iconPath =
        customerModel!.sex == '남' ? IconsPath.manIcon : IconsPath.womanIcon;
    final color = getSexIconColor(customerModel!.sex).withOpacity(0.6);

    return Image.asset(iconPath, fit: BoxFit.cover, color: color);
  }

  Widget _buildActions(BuildContext context) {
    if (customerModel == null) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTodoList(context),
        _buildHistoryButton(),
        width(10),
        EditToggleIcon(isReadOnly: isReadOnly, onPressed: onPressed),
        width(5),
        _buildDeleteButton(context),
        width(10),
        _buildAddPolicyButton(),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildTodoList(BuildContext context) {
    final List<TodoModel> todoList = [
      TodoModel(dueDate: DateTime.now(), content: '집에 전화하기집에 전화하기집에 전화하기'), TodoModel(dueDate: DateTime.now(), content: '밥먹으러 가기')
    ];

    todoList.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    final TodoModel? nearestTodo = todoList.isNotEmpty ? todoList.first : null;

    return Row(
      mainAxisSize: MainAxisSize.min, // ✅ 핵심: Row가 필요한 만큼만 차지하게
      children: [
        if (nearestTodo != null)
          Row(
            mainAxisSize: MainAxisSize.min, // ✅ 내부 Row도 최소한의 너비로
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 120), // ✅ 폭 제한
                child: Text(
                  '${nearestTodo.content}',
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              PopupMenuButton<String>(
                tooltip: '할 일 목록',
                icon: const Icon(Icons.expand_more),
                itemBuilder: (context) => [
                  ...todoList.map((todo) => PopupMenuItem<String>(
                    enabled: false, // 기본 선택 비활성화 (버튼 제스처로만 처리)
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 할 일 텍스트
                        Text(
                          '${todo.dueDate.formattedDate} ${todo.content}',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 8),

                        // 버튼 Row
                        Row(
                          children: [
                            Material(
                              color: Colors.transparent, // 배경 없애기
                              child: InkWell(
                                onTap: () {
                                  print('tap');
                                  // 실행 로직
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0), // 터치 범위 넓히기
                                  child: Row(
                                    children: const [
                                      Icon(Icons.check_circle_outline, size: 18),
                                      SizedBox(width: 6),
                                      Text('완료, 관리이력 추가'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            GestureDetector(
                              onTap: () {
                                // 삭제 로직 연결 (viewModel 등에서 삭제)
                                // 예: viewModel.removeTodo(todo);
                                Navigator.pop(context);
                              },
                              child: Row(
                                children: const [
                                  Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                  SizedBox(width: 6),
                                  Text('할 일 삭제', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const PopupMenuDivider(),
                      ],
                    ),
                  )),


                  PopupMenuItem<String>(
                    value: 'add',
                    child: Row(
                      children: const [
                        Icon(Icons.add, size: 18),
                        SizedBox(width: 6),
                        Text('할 일 추가'),
                      ],
                    ),
                    onTap: () {
                      Future.delayed(const Duration(milliseconds: 200), () {
                        showAddTodoDialog(context);
                      });
                    },
                  ),
                ],
              )
,

              // PopupMenuButton<String>(
              //   tooltip: '할 일 목록',
              //   icon: const Icon(Icons.expand_more),
              //   itemBuilder:
              //       (context) => [
              //         ...todoList.map(
              //           (todo) => PopupMenuItem<String>(
              //             value: todo.content,
              //             child: GestureDetector(
              //               onTap: () {
              //                 popupAddHistory(
              //                   context: context,
              //                   histories: customerModel?.histories ?? [],
              //                   customer: customerModel!,
              //                   initContent: todo.content,
              //                 );
              //               },
              //               child: Text(
              //                 '${todo.dueDate.formattedDate} - ${todo.content}',
              //                 overflow: TextOverflow.ellipsis,
              //                 maxLines: 1,
              //               ),
              //             ),
              //           ),
              //         ),
              //         PopupMenuItem<String>(
              //           value: 'add',
              //           child: Row(
              //             children: const [
              //               Icon(Icons.add, size: 18),
              //               SizedBox(width: 6),
              //               Text('할 일 추가'),
              //             ],
              //           ),
              //           onTap: () {
              //             Future.delayed(const Duration(milliseconds: 200), () {
              //               showAddTodoDialog(context);
              //             });
              //           },
              //         ),
              //       ],
              // ),
            ],
          ),
        if (todoList.isEmpty)
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '할 일 추가',
            onPressed: () => showAddTodoDialog(context),
          ),
      ],
    );
  }

  Widget _buildHistoryButton() {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isNeedNewHistory)
            BlinkingCursorIcon(
              key: ValueKey(isNeedNewHistory),
              sex: customerModel?.sex ?? '',
              size: 30,
            )
          else
            const Icon(Icons.menu),
        ],
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final confirmed = await showConfirmDialog(
          context,
          text: '가망고객을 삭제하시겠습니까?',
          onConfirm: () async {
            await viewModel.onEvent(
              RegistrationEvent.deleteCustomer(
                userKey: UserSession.userId,
                customerKey: customerModel!.customerKey,
              ),
            );

            final prospectViewModel = getIt<ProspectListViewModel>();
            prospectViewModel.clearCache();
            await prospectViewModel.fetchData(force: true);
          },
        );

        if (context.mounted && confirmed == true) {
          context.pop();
        }
      },
      child: Image.asset(IconsPath.deleteIcon, width: 22),
    );
  }

  Widget _buildAddPolicyButton() {
    return AddPolicyButton(
      customerModel: customerModel!,
      onRegistered: (bool result) async {
        if (result) {
          await getIt<CustomerListViewModel>().refresh();
        } else {
          debugPrint('등록 취소 또는 실패');
        }
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
