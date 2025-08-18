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
import '../../../core/presentation/todo/todo_view_model.dart';
import '../../../core/presentation/widget/customer_registration_app_bar.dart';
import '../../../core/utils/is_need_new_history.dart';
import '../../home/customer_list/components/customer_list_app_bar.dart';
import '../part/confirm_box_part.dart';
import '../part/customer_info_part.dart';
import '../registration_event.dart';
import '../registration_view_model.dart';

class RegistrationScreen extends StatefulWidget {
  final CustomerModel? customer;
  final ScrollController? scrollController;
  final TodoViewModel todoViewModel; // 생성자에서 안전하게 주입
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
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _recommendedController = TextEditingController();
  final _historyController = TextEditingController(text: '신규등록');
  final _birthController = TextEditingController();
  final _memoController = TextEditingController();
  final _registeredDateController = TextEditingController();

  ScrollController? _internalController;
  bool _isReadOnly = false;
  bool _isRecommended = false;
  bool _isNeedNewHistory = false;
  DateTime? _birth;
  String? _sex;

  ScrollController get _effectiveController =>
      widget.scrollController ?? _internalController!;

  @override
  void initState() {
    super.initState();
    if (widget.scrollController == null)
      _internalController = ScrollController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // context 기반 초기화 안전하게 수행
    _initializeCustomer();
    _isNeedNewHistory = isNeedNewHistory(widget.customer?.histories ?? []);
    if (widget.customer?.todos != null) {
      widget.todoViewModel.loadTodos(widget.customer!.todos);
    }
  }

  void _initializeCustomer() {
    final customer = widget.customer;
    _registeredDateController.text =
        customer?.registeredDate.formattedBirth ??
        DateTime.now().formattedBirth;
    if (customer != null) {
      _isReadOnly = true;
      _nameController.text = customer.name;
      _sex = customer.sex;
      _birth = customer.birth;
      _birthController.text = customer.birth.toString();
      _memoController.text = customer.memo;
      if (customer.recommended.isNotEmpty) {
        _isRecommended = true;
        _recommendedController.text = customer.recommended;
      }
    }
  }

  @override
  void dispose() {
    _internalController?.dispose();
    _nameController.dispose();
    _recommendedController.dispose();
    _historyController.dispose();
    _birthController.dispose();
    _memoController.dispose();
    _registeredDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SafeArea(
      child: SingleChildScrollView(
        controller: _effectiveController,
        child: Container(
          color: colorScheme.surface, // 전체 배경 테마 적용
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
                registrationViewModel: getIt<RegistrationViewModel>(),
                backgroundColor: colorScheme.surface,
                foregroundColor: colorScheme.onSurface,
              ),
              Form(
                key: _formKey,
                child: CustomerInfoPart(
                  isReadOnly: _isReadOnly,
                  nameController: _nameController,
                  registeredDateController: _registeredDateController,
                  sex: _sex,
                  birth: _birth,
                  birthController: _birthController,
                  onSexChanged: (val) => setState(() => _sex = val),
                  onBirthInitPressed: () {
                    setState(() {
                      _birth = null;
                      _birthController.clear();
                    });
                  },
                  onBirthSetPressed: (date) {
                    setState(() {
                      _birth = date;
                      _birthController.text = date.toString();
                    });
                  },
                  onRegisteredDatePressed: (date) {
                    setState(
                      () =>
                          _registeredDateController.text = date.formattedBirth,
                    );
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
                  titleTextStyle: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  subtitleTextStyle: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withAlpha(180),
                  ),
                  backgroundColor:
                      colorScheme.surfaceVariant, // Card/Container 배경
                ),
              ),
              if (!_isReadOnly)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity, // 화면 폭만큼 확장
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        // 높이 여유
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // 모서리 둥글게
                        ),
                      ),
                      onPressed: _onSubmitPressed,
                      child: Text(
                        widget.customer == null ? '등록' : '수정',
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
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

  void _onSubmitPressed() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final success = await _submitForm();
    if (success && mounted) Navigator.of(context).pop(true);
  }

  Future<bool> _submitForm() async {
    try {
      // ✅ 필수값 검증
      if (_nameController.text.trim().isEmpty) {
        if (mounted) showOverlaySnackBar(context, '이름을 입력하세요.');
        return false;
      }
      if (_sex == null || _sex!.isEmpty) {
        if (mounted) showOverlaySnackBar(context, '성별을 입력하세요.');
        return false;
      }

      final userKey = UserSession.userId;
      final customerMap = CustomerModel.toMapForCreateCustomer(
        userKey: userKey,
        customerKey: widget.customer?.customerKey ??
            'new_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text.trim(),
        sex: _sex!,
        recommender: _recommendedController.text.trim(),
        birth: _birth,
        registeredDate: DateFormat('yy/MM/dd')
            .parseStrict(_registeredDateController.text),
        memo: _memoController.text.trim(),
      );

      if (widget.customer == null) {
        final historyMap = HistoryModel.toMapForHistory(
          registeredDate: DateFormat('yy/MM/dd')
              .parseStrict(_registeredDateController.text),
          content: _historyController.text,
        );
        await getIt<RegistrationViewModel>().onEvent(
          RegistrationEvent.registerCustomer(
            userKey: userKey,
            customerData: customerMap,
            historyData: historyMap,
            todoData: {},
          ),
        );
      } else {
        await getIt<RegistrationViewModel>().onEvent(
          RegistrationEvent.updateCustomer(
            userKey: userKey,
            customerData: customerMap,
          ),
        );
      }
      return true;
    } catch (e) {
      debugPrint('submitForm error: $e');
      if (mounted) showOverlaySnackBar(context, '등록에 실패했습니다.');
      return false;
    }
  }
}
