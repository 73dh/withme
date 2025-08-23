import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:withme/core/data/fire_base/user_session.dart';
import 'package:withme/core/presentation/widget/show_overlay_snack_bar.dart';
import 'package:withme/core/utils/core_utils_import.dart';
import 'package:withme/domain/domain_import.dart';
import 'package:withme/domain/model/customer_model.dart';
import 'package:withme/domain/model/history_model.dart';
import 'package:withme/presentation/registration/screen/registration_form_controller.dart';

import '../../../core/di/setup.dart';
import '../../../core/domain/core_domain_import.dart';
import '../../../core/presentation/core_presentation_import.dart';
import '../../../core/presentation/todo/todo_view_model.dart';
import '../../../core/presentation/widget/customer_registration_app_bar.dart';
import '../../../core/utils/is_need_new_history.dart';
import '../part/confirm_box_part.dart';
import '../part/customer_info_part.dart';
import '../registration_event.dart';
import '../registration_view_model.dart';

class RegistrationScreen extends StatefulWidget {
  final CustomerModel? customer;
  final ScrollController? scrollController;
  final TodoViewModel todoViewModel;
  final void Function(bool)? onFabVisibilityChanged;

  const RegistrationScreen({
    super.key,
    this.customer,
    this.scrollController,
    required this.todoViewModel,
    this.onFabVisibilityChanged,
  });

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  late final RegistrationFormController _formCtrl;
  late final RegistrationViewModel _registrationViewModel;

  ScrollController? _internalController;
  bool _isReadOnly = false;
  bool _isRecommended = false;
  bool _isNeedNewHistory = false;
  bool _isRegistering = false;

  ScrollController get _effectiveController =>
      widget.scrollController ?? _internalController!;

  @override
  void initState() {
    super.initState();
    if (widget.scrollController == null) {
      _internalController = ScrollController();
    }
    _formCtrl = RegistrationFormController();
    _registrationViewModel = getIt<RegistrationViewModel>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeCustomer();
    _isNeedNewHistory = isNeedNewHistory(widget.customer?.histories ?? []);
    if (widget.customer?.todos != null) {
      widget.todoViewModel.loadTodos(widget.customer!.todos);
    }
  }

  void _initializeCustomer() {
    final customer = widget.customer;
    _formCtrl.initialize(customer);
    if (customer != null) {
      _isReadOnly = true;
      _isRecommended = customer.recommended.isNotEmpty;
    }
  }

  @override
  void dispose() {
    _internalController?.dispose();
    _formCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        controller: _effectiveController,
        child: Container(
          color: theme.colorScheme.surface,
          child: Column(
            children: [
              CustomerRegistrationAppBar(
                customer: widget.customer,
                todoViewModel: widget.todoViewModel,
                isReadOnly: _isReadOnly,
                onEditToggle: () {
                  setState(() => _isReadOnly = !_isReadOnly);
                  widget.onFabVisibilityChanged?.call(!_isReadOnly);
                },
                onHistoryTap: _onAddHistory,
                isNeedNewHistory: _isNeedNewHistory,
                registrationViewModel: _registrationViewModel,
                backgroundColor: theme.colorScheme.surface,
                foregroundColor: theme.colorScheme.onSurface,
              ),
              Form(
                key: _formCtrl.formKey,
                child: CustomerInfoPart(
                  isReadOnly: _isReadOnly,
                  nameController: _formCtrl.name,
                  registeredDateController: _formCtrl.registeredDate,
                  birthController: _formCtrl.birthCtrl,
                  memoController: _formCtrl.memo,
                  sex: _formCtrl.sex,
                  birth: _formCtrl.birth,
                  onSexChanged: (val) => setState(() => _formCtrl.setSex(val)),
                  onBirthInitPressed:
                      () => setState(() => _formCtrl.clearBirth()),
                  onBirthSetPressed: _formCtrl.setBirth,
                  onRegisteredDatePressed: _formCtrl.setRegisteredDate,
                  isRecommended: _isRecommended,
                  recommendedController: _formCtrl.recommended,
                  onRecommendedChanged: (val) {
                    setState(() {
                      _isRecommended = val;
                      _formCtrl.recommended.text =
                          val ? _formCtrl.recommended.text : '';
                    });
                  },
                  titleTextStyle: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                  subtitleTextStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(180),
                  ),
                  backgroundColor: theme.colorScheme.surface,
                ),
              ),
              if (!_isReadOnly) _buildSubmitButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _onSubmitPressed,
          child: Text(
            widget.customer == null ? '등록' : '수정',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onAddHistory() async {
    final newHistory = await popupAddHistory(
      context: context,
      histories: widget.customer?.histories ?? [],
      customer: widget.customer!,
      initContent: HistoryContent.title.toString(),
    );
    if (newHistory != null) {
      setState(() {
        widget.customer?.histories.add(newHistory);
        widget.customer?.histories.sort(
          (a, b) => b.contactDate.compareTo(a.contactDate),
        );
        _isNeedNewHistory = isNeedNewHistory(widget.customer?.histories ?? []);
      });
    }
  }

  Future<void> _onSubmitPressed() async {
    // 🔹 validate (formCtrl 기반)
    if (!_formCtrl.validate(context, isRecommended: _isRecommended)) return;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: ConfirmBoxPart(
                isRegistering: _isRegistering,
                customerModel: widget.customer,
                nameController: _formCtrl.name,
                recommendedController: _formCtrl.recommended,
                historyController: _formCtrl.history,
                // ✅ 되살림
                birthController: _formCtrl.birthCtrl,
                registeredDateController: _formCtrl.registeredDate,
                sex: _formCtrl.sex,
                birth: _formCtrl.birth,
                textColor: colorScheme.onSurface,
                backgroundColor: colorScheme.surfaceContainerLowest.withAlpha(
                  20,
                ),
                onPressed: () async {
                  setModalState(() => _isRegistering = true);

                  final success = await _submitForm();

                  setModalState(() => _isRegistering = false);

                  if (modalContext.mounted) Navigator.of(modalContext).pop();
                  if (success && mounted && context.mounted) {
                    context.pop(true);
                  }
                },
              ),
            );
          },
        );
      },
    );
  }

  Future<bool> _submitForm() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        showOverlaySnackBar(context, '로그인 정보가 없습니다.');
        return false;
      }

      final customerMap = CustomerModel.toMapForCreateCustomer(
        userKey: currentUser.uid,
        customerKey:
            widget.customer?.customerKey ??
            generateCustomerKey('${currentUser.email}'),
        name: _formCtrl.name.text,
        sex: _formCtrl.sex!,
        recommender: _formCtrl.recommended.text,
        birth: _formCtrl.birth,
        registeredDate: DateFormat(
          'yy/MM/dd',
        ).parseStrict(_formCtrl.registeredDate.text),
        memo: _formCtrl.memo.text.trim(),
      );

      if (widget.customer == null) {
        // 신규 등록
        final historyMap = HistoryModel.toMapForHistory(
          registeredDate: DateFormat(
            'yy/MM/dd',
          ).parseStrict(_formCtrl.registeredDate.text),
          content: _formCtrl.history.text,
        );

        final todoMap = <String, dynamic>{};

        await getIt<RegistrationViewModel>().onEvent(
          RegistrationEvent.registerCustomer(
            userKey: currentUser.uid,
            customerData: customerMap,
            historyData: historyMap,
            todoData: todoMap,
          ),
        );
      } else {
        // 수정
        await getIt<RegistrationViewModel>().onEvent(
          RegistrationEvent.updateCustomer(
            userKey: UserSession.userId,
            customerData: customerMap,
          ),
        );
      }

      return true;
    } catch (e) {
      debugPrint('submitForm error: $e');
      if (mounted) {
        showOverlaySnackBar(context, '등록에 실패했습니다. 다시 시도해주세요.');
      }
      return false;
    }
  }
}
