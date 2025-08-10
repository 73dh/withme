import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:withme/core/data/fire_base/user_session.dart';
import 'package:withme/core/presentation/widget/show_overlay_snack_bar.dart';
import 'package:withme/core/utils/core_utils_import.dart';
import 'package:withme/domain/domain_import.dart';
import 'package:withme/domain/model/customer_model.dart';
import 'package:withme/domain/model/history_model.dart';

import '../../../core/di/setup.dart';
import '../../../core/domain/core_domain_import.dart';
import '../../../core/presentation/core_presentation_import.dart';
import '../../../core/presentation/fab/fab_overlay_manager_mixin.dart';
import '../../../core/presentation/todo/customerRegistrationAppBar.dart';
import '../../../core/ui/core_ui_import.dart';
import '../../../core/utils/is_need_new_history.dart';
import '../../../core/presentation/todo/todo_view_model.dart';
import '../part/confirm_box_part.dart';
import '../part/customer_info_part.dart';
import '../registration_event.dart';
import '../registration_view_model.dart';
import 'registration_app_bar.dart';

class RegistrationBottomSheet extends StatefulWidget {
  final CustomerModel? customer;
  final ScrollController? scrollController;
  final BuildContext? outerContext;
  final void Function(bool)? onFabVisibilityChanged; // FAB강제 숨김 기능 추가

  const RegistrationBottomSheet({
    super.key,
    this.customer,
    this.scrollController,
    this.outerContext,
    this.onFabVisibilityChanged, // 추가
  });

  @override
  State<RegistrationBottomSheet> createState() =>
      _RegistrationBottomSheetState();
}

class _RegistrationBottomSheetState extends State<RegistrationBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _recommendedController = TextEditingController();
  final _historyController = TextEditingController(text: '신규등록');
  final _birthController = TextEditingController();
  final _memoController = TextEditingController();
  final _registeredDateController = TextEditingController();

  final viewModel = getIt<RegistrationViewModel>();
  final todoViewModel = getIt<TodoViewModel>();
  ScrollController? _internalController;

  ScrollController get _effectiveController =>
      widget.scrollController ?? _internalController!;

  bool _isReadOnly = false;
  bool _isRecommended = false;
  DateTime? _birth;
  String? _sex;
  bool _isRegistering = false;
  bool _isNeedNewHistory = false;

  @override
  void initState() {
    super.initState();
    _initializeCustomer();
    _isNeedNewHistory = isNeedNewHistory(widget.customer?.histories ?? []);

    if (widget.scrollController == null) {
      _internalController = ScrollController();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final customerKey = widget.customer?.customerKey;
      if (customerKey != null && customerKey.isNotEmpty) {
        todoViewModel.initializeTodos(
          userKey: UserSession.userId,
          customerKey: customerKey,
        );
      } else {
        // 디버깅 로그나 처리
        debugPrint("customerKey가 비어 있습니다. Todos를 초기화하지 않습니다.");
      }
    });
  }

  void _initializeCustomer() async {
    final customer = widget.customer;
    _registeredDateController.text = DateTime.now().formattedBirth;
    if (customer != null) {
      _isReadOnly = true;
      _nameController.text = customer.name;
      _sex = customer.sex;
      _birth = customer.birth;
      _birthController.text = customer.birth.toString();
      _registeredDateController.text = customer.registeredDate.formattedBirth;
      _memoController.text = customer.memo;
      if (customer.recommended.isNotEmpty) {
        _isRecommended = true;
        _recommendedController.text = customer.recommended;
      }
      todoViewModel.initializeTodos(
        userKey: UserSession.userId,
        customerKey: widget.customer!.customerKey,
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _recommendedController.dispose();
    _historyController.dispose();
    _birthController.dispose();
    _internalController?.dispose();
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        controller: _effectiveController,
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            AnimatedBuilder(
              animation: todoViewModel,
              builder: (BuildContext context, Widget? child) {
                return
                  CustomerRegistrationAppBar(
                    customer: widget.customer,
                    todoViewModel: getIt<TodoViewModel>(),
                    isReadOnly: _isReadOnly,
                    onEditToggle: () {
                      setState(() => _isReadOnly = !_isReadOnly);

                      final fabMixin =
                      context
                          .findAncestorStateOfType<FabOverlayManagerMixin>();
                      fabMixin?.setFabCanBeShown(false);
                    },
                    onHistoryTap: () async {
                      await onAddHistory();
                      if (isNeedNewHistory(widget.customer?.histories ?? [])) {
                        setState(() {
                          _isNeedNewHistory = !_isNeedNewHistory;
                        });
                      }
                    },
                    isNeedNewHistory: _isNeedNewHistory,
                    registrationViewModel: viewModel,
                  );


                // RegistrationAppBar(
                //   isReadOnly: _isReadOnly,
                //   onPressed: () {
                //     setState(() => _isReadOnly = !_isReadOnly);
                //
                //     final fabMixin =
                //         context
                //             .findAncestorStateOfType<FabOverlayManagerMixin>();
                //     fabMixin?.setFabCanBeShown(false);
                //   },
                //   onTap: () async {
                //     await onAddHistory();
                //     if (isNeedNewHistory(widget.customer?.histories ?? [])) {
                //       setState(() {
                //         _isNeedNewHistory = !_isNeedNewHistory;
                //       });
                //     }
                //   },
                //   isNeedNewHistory: _isNeedNewHistory,
                //   viewModel: viewModel,
                //   customer: widget.customer,
                // );
              },
            ),
            _buildForm(),
            if (!_isReadOnly) _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Future<void> onAddHistory() async {
    final newHistory = await popupAddHistory(
      context: context,
      histories: widget.customer?.histories ?? [],
      customer: widget.customer!,
      initContent: HistoryContent.title.toString(),
    );
    if (newHistory != null) {
      setState(() {
        final histories = widget.customer!.histories;
        histories.add(newHistory);
        histories.sort((a, b) {
          final aDate = a.contactDate;
          final bDate = b.contactDate;
          return bDate.compareTo(aDate);
        });
        _isNeedNewHistory = isNeedNewHistory(histories);
      });
    }
  }

  Widget _buildForm() {
    return Form(key: _formKey, child: _buildCustomerInfoPart());
  }

  Widget _buildCustomerInfoPart() {
    return CustomerInfoPart(
      isReadOnly: _isReadOnly,
      nameController: _nameController,
      registeredDateController: _registeredDateController,
      sex: _sex,
      birth: _birth,
      birthController: _birthController,
      onSexChanged: (value) => setState(() => _sex = value),
      onBirthInitPressed: () async {
        setState(() {
          _birth = null;
          _birthController.clear();
        });
      },
      onBirthSetPressed: (date) async {
        setState(() {
          _birth = date;
          _birthController.text = date.toString();
        });
      },
      onRegisteredDatePressed: (date) async {
        setState(() {
          _registeredDateController.text = date.formattedBirth;
        });
      },
      isRecommended: _isRecommended,
      recommendedController: _recommendedController,
      onRecommendedChanged: (val) {
        setState(() {
          _isRecommended = val;
          if (!val) _recommendedController.clear();
        });
      },
      memoController: _memoController,
    );
  }

  Widget _buildSubmitButton() {
    return RenderFilledButton(
      text: widget.customer == null ? '등록' : '수정',
      foregroundColor: ColorStyles.activeButtonColor,
      onPressed: () async {
        if (_tryValidation()) {
          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder:
                (modalContext) => StatefulBuilder(
                  builder:
                      (context, setModalState) => Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                        child: ConfirmBoxPart(
                          customerModel: widget.customer,
                          nameController: _nameController,
                          recommendedController: _recommendedController,
                          historyController: _historyController,
                          birthController: _birthController,
                          registeredDateController: _registeredDateController,
                          isRegistering: _isRegistering,
                          onPressed: () async {
                            setModalState(() => _isRegistering = true);
                            final success = await _submitForm();
                            setModalState(() => _isRegistering = false);
                            if (modalContext.mounted) {
                              Navigator.of(modalContext).pop();
                            }
                            if (success && mounted) {
                              if (context.mounted) {
                                context.pop(true);
                              }
                            }
                          },
                          sex: _sex,
                          birth: _birth,
                        ),
                      ),
                ),
          );
        }
      },
    );
  }

  bool _tryValidation() {
    final isValid = _formKey.currentState?.validate() ?? false;
    final name = _nameController.text.trim();
    final recommenderName = _recommendedController.text.trim();
    final nameRegex = RegExp(r'^[a-zA-Z가-힣]+$');
    if (name.isEmpty) {
      showOverlaySnackBar(context, '고객 이름을 입력하세요');
      return false;
    }
    if (!nameRegex.hasMatch(name)) {
      showOverlaySnackBar(context, '이름은 한글 또는 영문만 입력 가능합니다');
      return false;
    }
    if (_sex == null) {
      showOverlaySnackBar(context, '성별을 선택 하세요');
      return false;
    }
    if (_isRecommended && recommenderName.isEmpty) {
      showOverlaySnackBar(context, '소개자 이름을 입력 하세요');
      return false;
    }
    if (_isRecommended && !nameRegex.hasMatch(recommenderName)) {
      showOverlaySnackBar(context, '이름은 한글 또는 영문만 입력 가능합니다');
      return false;
    }
    if (isValid) {
      _formKey.currentState!.save();
      return true;
    }
    return false;
  }

  Future _submitForm() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      final customerMap = CustomerModel.toMapForCreateCustomer(
        userKey: currentUser?.uid ?? '',
        customerKey:
            widget.customer?.customerKey ??
            generateCustomerKey('${currentUser?.email}'),
        name: _nameController.text,
        sex: _sex!,
        recommender: _recommendedController.text,
        birth: _birth,
        registeredDate: DateFormat(
          'yy/MM/dd',
        ).parseStrict(_registeredDateController.text),
        memo: _memoController.text.trim(),
      );

      if (widget.customer == null) {
        final historyMap = HistoryModel.toMapForHistory(
          registeredDate: DateFormat(
            'yy/MM/dd',
          ).parseStrict(_registeredDateController.text),
          content: _historyController.text,
        );
        Map<String, dynamic> todoMap = {};

        await viewModel.onEvent(
          RegistrationEvent.registerCustomer(
            userKey: currentUser!.uid,
            customerData: customerMap,
            historyData: historyMap,
            todoData: todoMap,
          ),
        );
      } else {
        await viewModel.onEvent(
          RegistrationEvent.updateCustomer(
            userKey: UserSession.userId,
            customerData: customerMap,
          ),
        );
      }
      return true;
    } catch (e, _) {
      debugPrint('submitForm error: $e');
      if (mounted) {
        showOverlaySnackBar(context, '등록에 실패했습니다. 다시 시도해주세요.');
      }
      return false;
    }
  }
}
