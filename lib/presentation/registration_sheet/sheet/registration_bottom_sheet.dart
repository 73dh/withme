import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:withme/core/data/fire_base/user_session.dart';
import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/core/presentation/widget/show_overlay_snack_bar.dart';
import 'package:withme/core/utils/core_utils_import.dart';
import 'package:withme/domain/domain_import.dart';
import 'package:withme/domain/model/customer_model.dart';
import 'package:withme/domain/model/history_model.dart';

import '../../../core/di/setup.dart';
import '../../../core/domain/core_domain_import.dart';
import '../../../core/presentation/core_presentation_import.dart';
import '../../../core/ui/core_ui_import.dart';
import '../../../core/utils/is_need_new_history.dart';
import '../components/add_policy_button.dart';
import '../part/confirm_box_part.dart';
import '../part/customer_info_part.dart';
import '../part/recommender_part.dart';
import '../part/registration_app_bar.dart';
import '../registration_event.dart';
import '../registration_view_model.dart';

class RegistrationBottomSheet extends StatefulWidget {
  final CustomerModel? customerModel;
  final ScrollController? scrollController; // 추가
  final BuildContext? outerContext; // 추가

  const RegistrationBottomSheet({
    super.key,
    this.customerModel,
    this.scrollController,
    this.outerContext, // 추가
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
    _isNeedNewHistory = isNeedNewHistory(widget.customerModel?.histories ?? []);
    if (widget.scrollController == null) {
      _internalController = ScrollController();
    }
  }

  void _initializeCustomer() {
    final customer = widget.customerModel;
    _registeredDateController.text = DateTime.now().formattedDate;
    if (customer != null) {
      _isReadOnly = true;
      _nameController.text = customer.name;
      _sex = customer.sex;
      _birth = customer.birth;
      _birthController.text = customer.birth.toString();
      _registeredDateController.text = customer.registeredDate.formattedDate;
      _memoController.text = customer.memo;
      if (customer.recommended.isNotEmpty) {
        _isRecommended = true;
        _recommendedController.text = customer.recommended;
      }
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
      child: Column(
        children: [
          RegistrationAppBar(
            isReadOnly: _isReadOnly,
            onPressed: () => setState(() => _isReadOnly = !_isReadOnly),
            onTap: () async {
              await onAddHistory();
              if (isNeedNewHistory(widget.customerModel?.histories ?? [])) {
                setState(() {
                  _isNeedNewHistory = !_isNeedNewHistory;
                });
              }
            },
            isNeedNewHistory: _isNeedNewHistory,
            viewModel: viewModel,
            customerModel: widget.customerModel,
          ),
          _buildForm(),

          if (!_isReadOnly) _buildSubmitButton(), // bottomSheet 대체
        ],
      ),
    );
  }

  Future<void> onAddHistory() async {
    final newHistory = await popupAddHistory(
      context,
      widget.customerModel?.histories ?? [],
      widget.customerModel!,
      HistoryContent.title.toString(),
    );
    if (newHistory != null) {
      setState(() {
        final histories = widget.customerModel!.histories;
        histories.add(newHistory);

        // 🔽 연락일 기준으로 최신 순 정렬
        histories.sort((a, b) {
          final aDate = a.contactDate ?? DateTime(1970);
          final bDate = b.contactDate ?? DateTime(1970);
          return bDate.compareTo(aDate); // 최신 날짜가 앞에 오도록
        });

        _isNeedNewHistory = isNeedNewHistory(histories);
      });
    }
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.only(
          bottom: 10, // filledButton 기본 높이
        ),
        child: SingleChildScrollView(
          controller: _effectiveController,
          padding: const EdgeInsets.all(8.0),
          child: _buildCustomerInfoPart(),
        ),
      ),
    );
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
          _registeredDateController.text = date.formattedDate;
        });
      },

      // 🔽 Recommender 관련 추가
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
      text: widget.customerModel == null ? '등록' : '수정',
      foregroundColor: ColorStyles.activeButtonColor,
      onPressed: () {
        if (_tryValidation()) {
          showModalBottomSheet(
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
                          customerModel: widget.customerModel,
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
            widget.customerModel?.customerKey ??
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

      if (widget.customerModel == null) {
        final historyMap = HistoryModel.toMapForHistory(
          registeredDate: DateFormat(
            'yy/MM/dd',
          ).parseStrict(_registeredDateController.text),
          content: _historyController.text,
        );

        await viewModel.onEvent(
          RegistrationEvent.registerCustomer(
            userKey: currentUser!.uid,
            customerData: customerMap,
            historyData: historyMap,
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
    } catch (e, st) {
      debugPrint('submitForm error: $e');
      if (mounted) {
        showOverlaySnackBar(context, '등록에 실패했습니다. 다시 시도해주세요.');
      }
      return false;
    }
  }
}
