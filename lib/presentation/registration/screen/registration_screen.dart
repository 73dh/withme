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

  DateTime? _birth;
  String? _sex;

  ScrollController? _internalController;
  bool _isReadOnly = false;
  bool _isRecommended = false;
  bool _isNeedNewHistory = false;

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
      setState(() {
        _isReadOnly = true;
        _isRecommended = customer.recommended.isNotEmpty;
      });
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
                  sex: _formCtrl.sex,
                  birth: _formCtrl.birth,
                  birthController: _formCtrl.birthCtrl,
                  onSexChanged: _formCtrl.setSex,
                  onBirthInitPressed: _formCtrl.clearBirth,
                  onBirthSetPressed: _formCtrl.setBirth,
                  onRegisteredDatePressed: _formCtrl.setRegisteredDate,
                  isRecommended: _isRecommended,
                  recommendedController: _formCtrl.recommended,
                  onRecommendedChanged: (val) {
                    setState(() {
                      _isRecommended = val;
                      if (!val) _formCtrl.recommended.clear();
                    });
                  },
                  memoController: _formCtrl.memo,
                  titleTextStyle: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                  subtitleTextStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(180),
                  ),
                  backgroundColor: theme.colorScheme.surfaceVariant,
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
    if (!_formCtrl.validate(context, isRecommended: _isRecommended)) return;

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        showOverlaySnackBar(context, '로그인 정보가 없습니다.');
        return;
      }

      final customerMap = CustomerModel.toMapForCreateCustomer(
        userKey: currentUser.uid,
        customerKey: widget.customer?.customerKey ??
            generateCustomerKey('${currentUser.email}'),
        name: _formCtrl.name.text,
        sex: _formCtrl.sex!,
        recommender: _formCtrl.recommended.text,
        birth: _formCtrl.birth,
        registeredDate: DateFormat('yy/MM/dd')
            .parseStrict(_formCtrl.registeredDate.text),
        memo: _formCtrl.memo.text.trim(),
      );

      if (widget.customer == null) {
        // 신규 등록
        final historyMap = HistoryModel.toMapForHistory(
          registeredDate: DateFormat('yy/MM/dd')
              .parseStrict(_formCtrl.registeredDate.text),
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

      if (mounted) context.pop(true);
    } catch (e) {
      debugPrint('submitForm error: $e');
      if (mounted) {
        showOverlaySnackBar(context, '등록에 실패했습니다. 다시 시도해주세요.');
      }
    }
  }
}


//
// class RegistrationScreen extends StatefulWidget {
//   final CustomerModel? customer;
//   final ScrollController? scrollController;
//   final TodoViewModel todoViewModel; // 생성자에서 안전하게 주입
//   final void Function(bool)? onFabVisibilityChanged;
//
//   const RegistrationScreen({
//     super.key,
//     this.customer,
//     this.scrollController,
//     required this.todoViewModel,
//     this.onFabVisibilityChanged,
//   });
//
//   @override
//   State<RegistrationScreen> createState() => _RegistrationScreenState();
// }
//
// class _RegistrationScreenState extends State<RegistrationScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _recommendedController = TextEditingController();
//   final _historyController = TextEditingController(text: '신규등록');
//   final _birthController = TextEditingController();
//   final _memoController = TextEditingController();
//   final _registeredDateController = TextEditingController();
//
//   ScrollController? _internalController;
//   bool _isReadOnly = false;
//   bool _isRecommended = false;
//   bool _isNeedNewHistory = false;
//   DateTime? _birth;
//   String? _sex;
//   bool _isRegistering = false;
//
//   ScrollController get _effectiveController =>
//       widget.scrollController ?? _internalController!;
//
//   @override
//   void initState() {
//     super.initState();
//     if (widget.scrollController == null)
//       _internalController = ScrollController();
//   }
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     // context 기반 초기화 안전하게 수행
//     _initializeCustomer();
//     _isNeedNewHistory = isNeedNewHistory(widget.customer?.histories ?? []);
//     if (widget.customer?.todos != null) {
//       widget.todoViewModel.loadTodos(widget.customer!.todos);
//     }
//   }
//
//   void _initializeCustomer() {
//     final customer = widget.customer;
//     _registeredDateController.text =
//         customer?.registeredDate.formattedBirth ??
//         DateTime.now().formattedBirth;
//     if (customer != null) {
//       _isReadOnly = true;
//       _nameController.text = customer.name;
//       _sex = customer.sex;
//       _birth = customer.birth;
//       _birthController.text = customer.birth.toString();
//       _memoController.text = customer.memo;
//       if (customer.recommended.isNotEmpty) {
//         _isRecommended = true;
//         _recommendedController.text = customer.recommended;
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     _internalController?.dispose();
//     _nameController.dispose();
//     _recommendedController.dispose();
//     _historyController.dispose();
//     _birthController.dispose();
//     _memoController.dispose();
//     _registeredDateController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
//     final textTheme = theme.textTheme;
//
//     return SafeArea(
//       child: SingleChildScrollView(
//         controller: _effectiveController,
//         child: Container(
//           color: colorScheme.surface, // 전체 배경 테마 적용
//           child: Column(
//             children: [
//               CustomerRegistrationAppBar(
//                 customer: widget.customer,
//                 todoViewModel: widget.todoViewModel,
//                 isReadOnly: _isReadOnly,
//                 onEditToggle: () {
//                   setState(() => _isReadOnly = !_isReadOnly);
//                   widget.onFabVisibilityChanged?.call(!_isReadOnly);
//                 },
//                 onHistoryTap: _onAddHistory,
//                 isNeedNewHistory: _isNeedNewHistory,
//                 registrationViewModel: getIt<RegistrationViewModel>(),
//                 backgroundColor: colorScheme.surface,
//                 foregroundColor: colorScheme.onSurface,
//               ),
//               Form(
//                 key: _formKey,
//                 child: CustomerInfoPart(
//                   isReadOnly: _isReadOnly,
//                   nameController: _nameController,
//                   registeredDateController: _registeredDateController,
//                   sex: _sex,
//                   birth: _birth,
//                   birthController: _birthController,
//                   onSexChanged: (val) => setState(() => _sex = val),
//                   onBirthInitPressed: () {
//                     setState(() {
//                       _birth = null;
//                       _birthController.clear();
//                     });
//                   },
//                   onBirthSetPressed: (date) {
//                     setState(() {
//                       _birth = date;
//                       _birthController.text = date.toString();
//                     });
//                   },
//                   onRegisteredDatePressed: (date) {
//                     setState(
//                       () =>
//                           _registeredDateController.text = date.formattedBirth,
//                     );
//                   },
//                   isRecommended: _isRecommended,
//                   recommendedController: _recommendedController,
//                   onRecommendedChanged: (val) {
//                     setState(() {
//                       _isRecommended = val;
//                       if (!val) _recommendedController.clear();
//                     });
//                   },
//                   memoController: _memoController,
//                   titleTextStyle: textTheme.titleMedium?.copyWith(
//                     color: colorScheme.onSurface,
//                   ),
//                   subtitleTextStyle: textTheme.bodyMedium?.copyWith(
//                     color: colorScheme.onSurface.withAlpha(180),
//                   ),
//                   backgroundColor:
//                       colorScheme.surfaceVariant, // Card/Container 배경
//                 ),
//               ),
//               if (!_isReadOnly)
//                 Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: SizedBox(
//                     width: double.infinity, // 화면 폭만큼 확장
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: colorScheme.primary,
//                         foregroundColor: colorScheme.onPrimary,
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                         // 높이 여유
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12), // 모서리 둥글게
//                         ),
//                       ),
//                       onPressed: _onSubmitPressed,
//                       child: Text(
//                         widget.customer == null ? '등록' : '수정',
//                         style: textTheme.titleMedium?.copyWith(
//                           color: colorScheme.onPrimary,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Future<void> _onAddHistory() async {
//     final newHistory = await popupAddHistory(
//       context: context,
//       histories: widget.customer?.histories ?? [],
//       customer: widget.customer!,
//       initContent: HistoryContent.title.toString(),
//     );
//     if (newHistory != null) {
//       setState(() {
//         widget.customer?.histories.add(newHistory);
//         widget.customer?.histories.sort(
//           (a, b) => b.contactDate.compareTo(a.contactDate),
//         );
//         _isNeedNewHistory = isNeedNewHistory(widget.customer?.histories ?? []);
//       });
//     }
//   }
//
//   void _onSubmitPressed() async {
//     if (!_tryValidation()) return;
//
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
//
//     await showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: colorScheme.surface,
//       builder:
//           (modalContext) => StatefulBuilder(
//             builder:
//                 (context, setModalState) => Padding(
//                   padding: const EdgeInsets.symmetric(
//                     vertical: 16,
//                     horizontal: 20,
//                   ),
//                   child: ConfirmBoxPart(
//                     customerModel: widget.customer,
//                     nameController: _nameController,
//                     recommendedController: _recommendedController,
//                     historyController: _historyController,
//                     birthController: _birthController,
//                     registeredDateController: _registeredDateController,
//                     isRegistering: _isRegistering,
//                     onPressed: () async {
//                       setModalState(() => _isRegistering = true);
//                       final success = await _submitForm();
//                       setModalState(() => _isRegistering = false);
//                       if (modalContext.mounted)
//                         Navigator.of(modalContext).pop();
//                       if (success && mounted && context.mounted)
//                         context.pop(true);
//                     },
//                     sex: _sex,
//                     birth: _birth,
//                     textColor: colorScheme.onSurface,
//                     backgroundColor: colorScheme.surfaceContainerLowest
//                         .withAlpha(20),
//                   ),
//                 ),
//           ),
//     );
//   }
//
//   bool _tryValidation() {
//     final isValid = _formKey.currentState?.validate() ?? false;
//     final name = _nameController.text.trim();
//     final recommenderName = _recommendedController.text.trim();
//     final nameRegex = RegExp(r'^[a-zA-Z가-힣]+$');
//
//     if (name.isEmpty) {
//       showOverlaySnackBar(context, '고객 이름을 입력하세요');
//       return false;
//     }
//     if (!nameRegex.hasMatch(name)) {
//       showOverlaySnackBar(context, '이름은 한글 또는 영문만 입력 가능합니다');
//       return false;
//     }
//     if (_sex == null) {
//       showOverlaySnackBar(context, '성별을 선택 하세요');
//       return false;
//     }
//     if (_isRecommended && recommenderName.isEmpty) {
//       showOverlaySnackBar(context, '소개자 이름을 입력 하세요');
//       return false;
//     }
//     if (_isRecommended && !nameRegex.hasMatch(recommenderName)) {
//       showOverlaySnackBar(context, '이름은 한글 또는 영문만 입력 가능합니다');
//       return false;
//     }
//     if (isValid) _formKey.currentState!.save();
//     return isValid;
//   }
//
//   Future<bool> _submitForm() async {
//     try {
//       final currentUser = FirebaseAuth.instance.currentUser;
//       final customerMap = CustomerModel.toMapForCreateCustomer(
//         userKey: currentUser?.uid ?? '',
//         customerKey:
//             widget.customer?.customerKey ??
//             generateCustomerKey('${currentUser?.email}'),
//         name: _nameController.text,
//         sex: _sex!,
//         recommender: _recommendedController.text,
//         birth: _birth,
//         registeredDate: DateFormat(
//           'yy/MM/dd',
//         ).parseStrict(_registeredDateController.text),
//         memo: _memoController.text.trim(),
//       );
//
//       if (widget.customer == null) {
//         final historyMap = HistoryModel.toMapForHistory(
//           registeredDate: DateFormat(
//             'yy/MM/dd',
//           ).parseStrict(_registeredDateController.text),
//           content: _historyController.text,
//         );
//         Map<String, dynamic> todoMap = {};
//         await getIt<RegistrationViewModel>().onEvent(
//           RegistrationEvent.registerCustomer(
//             userKey: currentUser!.uid,
//             customerData: customerMap,
//             historyData: historyMap,
//             todoData: todoMap,
//           ),
//         );
//       } else {
//         await getIt<RegistrationViewModel>().onEvent(
//           RegistrationEvent.updateCustomer(
//             userKey: UserSession.userId,
//             customerData: customerMap,
//           ),
//         );
//       }
//       return true;
//     } catch (e) {
//       debugPrint('submitForm error: $e');
//       if (mounted) showOverlaySnackBar(context, '등록에 실패했습니다. 다시 시도해주세요.');
//       return false;
//     }
//   }
// }
