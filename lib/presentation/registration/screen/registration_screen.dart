import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:withme/core/data/fire_base/user_session.dart';
import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/core/utils/core_utils_import.dart';
import 'package:withme/domain/domain_import.dart';
import 'package:withme/domain/model/customer_model.dart';
import 'package:withme/domain/model/history_model.dart';
import 'package:withme/presentation/registration/components/add_policy_button.dart';
import 'package:withme/presentation/registration/part/confirm_box_part.dart';
import 'package:withme/presentation/registration/part/custom_app_bar.dart';
import 'package:withme/presentation/registration/part/customer_info_part.dart';
import 'package:withme/presentation/registration/part/recommender_part.dart';
import 'package:withme/presentation/registration/registration_event.dart';

import '../../../core/di/setup.dart';
import '../../../core/domain/core_domain_import.dart';
import '../../../core/presentation/core_presentation_import.dart';
import '../../../core/ui/core_ui_import.dart';

class RegistrationScreen extends StatefulWidget {
  final CustomerModel? customerModel;

  const RegistrationScreen({super.key, this.customerModel});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _recommendedController = TextEditingController();
  final _historyController = TextEditingController(text: '신규등록');
  final _birthController = TextEditingController();
  final _registeredDateController = TextEditingController();

  final viewModel = getIt<RegistrationViewModel>();

  bool _isReadOnly = false;
  bool _isRecommended = false;
  DateTime? _birth;
  String? _sex;
  bool _isRegistering = false;

  @override
  void initState() {
    super.initState();
    _initializeCustomer();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: CustomAppBar(
            isReadOnly: _isReadOnly,
            onPressed: () => setState(() => _isReadOnly = !_isReadOnly),
            viewModel: viewModel,
            customerModel: widget.customerModel,
          ),
        ),
        body: _buildForm(),
        bottomSheet: !_isReadOnly ? _buildSubmitButton() : null,
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.only(
          bottom: 40, // filledButton 기본 높이
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const TitleWidget(title: '고객 정보'),
              height(20),
              const PartTitle(text: '가망고객'),
              _buildCustomerInfoPart(),
              height(15),
              const PartTitle(text: '소개자'),
              _buildRecommenderPart(),
              height(20),
              if (_isReadOnly)
                AddPolicyButton(
                  customerModel: widget.customerModel!,
                  onRegistered: () async {
                    await getIt<CustomerListViewModel>()
                        .refresh(); // ✅ 등록 후 리스트 재갱신
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommenderPart() {
    return RecommenderPart(
      isReadOnly: _isReadOnly,
      isRecommended: _isRecommended,
      recommendedController: _recommendedController,
      onChanged: (val) {
        setState(() {
          _isRecommended = val;
          if (!val) _recommendedController.clear();
        });
      },
    );
  }

  Widget _buildCustomerInfoPart() {
    return CustomerInfoPart(
      isReadOnly: _isReadOnly,
      nameController: _nameController,
      registeredDateController: _registeredDateController,
      sex: _sex,
      birth: _birth,
      onSexChanged: (value) => setState(() => _sex = value),
      birthController: _birthController,
      onBirthInitPressed:
          () async => setState(() {
            _birth = null;
            _birthController.clear();
          }),
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
      renderSnackBar(context, text: '고객 이름을 입력 하세요');
      return false;
    }
    if (!nameRegex.hasMatch(name)) {
      renderSnackBar(context, text: '이름은 한글 또는 영문만 입력 가능합니다');
      return false;
    }
    if (_sex == null) {
      renderSnackBar(context, text: '성별을 선택 하세요');
      return false;
    }
    if (_isRecommended && recommenderName.isEmpty) {
      renderSnackBar(context, text: '소개자 이름을 입력 하세요');
      return false;
    }
    if (_isRecommended&& !nameRegex.hasMatch(recommenderName)) {
      renderSnackBar(context, text: '이름은 한글 또는 영문만 입력 가능합니다');
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
        renderSnackBar(context, text: '등록에 실패했습니다. 다시 시도해주세요.');
      }
      return false;
    }
  }
}
