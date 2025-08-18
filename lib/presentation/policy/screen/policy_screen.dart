import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:withme/core/data/fire_base/firestore_keys.dart';
import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/core/presentation/widget/show_overlay_snack_bar.dart';
import 'package:withme/domain/model/policy_model.dart';
import 'package:withme/presentation/policy/components/policy_confirm_box.dart';
import 'package:withme/presentation/policy/part/customer_part.dart';
import 'package:withme/presentation/policy/part/policy_part.dart';

import '../../../core/data/fire_base/user_session.dart';
import '../../../core/di/setup.dart';
import '../../../core/presentation/core_presentation_import.dart';
import '../../../domain/model/customer_model.dart';

class PolicyScreen extends StatefulWidget {
  final CustomerModel customer;

  const PolicyScreen({super.key, required this.customer});

  @override
  State<PolicyScreen> createState() => _PolicyScreenState();
}

class _PolicyScreenState extends State<PolicyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _insuredNameController = TextEditingController();
  final _productNameController = TextEditingController();
  final _premiumController = TextEditingController();
  final _formatter = NumberFormat.decimalPattern();

  String _policyHolderName = '';
  String _policyHolderSex = '';
  DateTime? _policyHolderBirth;

  String _insuredSex = '';
  DateTime? _insuredBirth;
  String _productCategory = '상품종류';
  String _insuranceCompany = '보험사';

  String _paymentMethod = '';
  DateTime? _startDate;
  DateTime? _endDate;

  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _initializeFields();
    _premiumController.addListener(_onPremiumChanged);
  }

  void _initializeFields() {
    final customer = widget.customer;
    if (customer.name.isNotEmpty) {
      _policyHolderName = customer.name;
      _policyHolderSex = customer.sex;
      _policyHolderBirth = customer.birth;
    }
  }

  void _onPremiumChanged() {
    final text = _premiumController.text.replaceAll(',', '');
    if (text.isEmpty) return;
    final formatted = _formatter.format(int.parse(text));
    if (formatted != _premiumController.text) {
      _premiumController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  @override
  void dispose() {
    _insuredNameController.dispose();
    _productNameController.dispose();
    _premiumController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, false),
          ),
        ),
        body: Form(
          key: _formKey,
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.only(bottom: 50),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  TitleWidget(
                    title: '계약 정보 등록',
                    textStyle: theme.textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  height(40),
                  PartTitle(
                    text: '계약관계자 정보',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  CustomerPart(
                    policyHolderName: _policyHolderName,
                    policyHolderSex: _policyHolderSex,
                    policyHolderBirth: _policyHolderBirth,
                    onBirthPressed: (_) async {
                      if (_policyHolderBirth == null) {
                        final selected = await selectDate(context);
                        if (selected != null) {
                          setState(() => _policyHolderBirth = selected);
                        }
                      }
                    },
                    insuredNameController: _insuredNameController,
                    insuredSex: _insuredSex,
                    insuredBirth: _insuredBirth,
                    onManChanged:
                        (value) => setState(() => _insuredSex = value),
                    onWomanChanged:
                        (value) => setState(() => _insuredSex = value),
                    onBirthChanged: (_) async {
                      final birth = await selectDate(context);
                      if (birth != null) setState(() => _insuredBirth = birth);
                    },
                  ),
                  height(20),
                  PartTitle(
                    text: '보험계약 정보',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  PolicyPart(
                    productCategory: _productCategory,
                    insuranceCompany: _insuranceCompany,
                    onCategoryTap:
                        (value) =>
                            setState(() => _productCategory = value.toString()),
                    onCompanyTap:
                        (value) => setState(
                          () => _insuranceCompany = value.toString(),
                        ),
                    productNameController: _productNameController,
                    paymentMethod: _paymentMethod,
                    premiumController: _premiumController,
                    onPremiumMonthTap:
                        (value) => setState(() => _paymentMethod = value),
                    onPremiumSingleTap:
                        (value) => setState(() => _paymentMethod = value),
                    onProductNameTap: (_) {},
                    onInputPremiumTap:
                        (value) =>
                            setState(() => _premiumController.text = value),
                    startDate: _startDate,
                    endDate: _endDate,
                    onStartDateChanged:
                        (date) => setState(() => _startDate = date),
                    onEndDateChanged: (date) => setState(() => _endDate = date),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomSheet: _submitButton(colorScheme),
      ),
    );
  }

  Widget _submitButton(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: RenderFilledButton(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        onPressed: _tryValidation,
        text: '확인',
      ),
    );
  }

  void _tryValidation() async {
    if (!_formKey.currentState!.validate()) return;

    final error = _validateForm();
    if (error != null) {
      showOverlaySnackBar(context, error);
      return;
    }

    setState(() => _isCompleted = true);
    _formKey.currentState!.save();

    final result = await showModalBottomSheet<bool>(
      context: context,
      builder:
          (_) => SizedBox(
            height: 360,
            width: double.infinity,
            child: _buildConfirmBox(),
          ),
    );

    if (result == true && mounted) context.pop(true);
  }

  String? _validateForm() {
    final name = _insuredNameController.text.trim();
    final nameRegex = RegExp(r'^[a-zA-Z가-힣]+$');

    if (_policyHolderBirth == null) return '계약자 생일을 확인하세요';
    if (name.isEmpty) return '피보험자 이름을 입력하세요';
    if (!nameRegex.hasMatch(name)) return '이름은 한글 또는 영문만 입력 가능합니다';
    if (_insuredSex.isEmpty) return '피보험자 성별을 확인하세요';
    if (_insuredBirth == null) return '피보험자 생일을 확인하세요';
    if (_productCategory == '상품종류') return '상품종류를 선택하세요.';
    if (_insuranceCompany == '보험사') return '보험사를 선택하세요.';
    if (_productNameController.text.trim().isEmpty) return '상품명을 입력하세요.';
    if (_paymentMethod.isEmpty) return '납입방법을 선택하세요.';
    if (_premiumController.text.trim().isEmpty) return '보험료를 입력하세요.';
    if (_startDate == null) return '계약일을 확인하세요';
    if (_endDate == null) return '보장 종료일을 확인하세요.';
    if (_startDate!.isAfter(_endDate!)) return '시작일이 종료일보다 늦습니다.';

    return null;
  }

  Widget _buildConfirmBox() {
    if (_policyHolderBirth == null ||
        _insuredBirth == null ||
        _startDate == null ||
        _endDate == null) {
      return const Center(child: Text('입력 누락 발생'));
    }

    final customerKey = widget.customer.customerKey;
    final userId = UserSession.userId;
    final policyRef =
        FirebaseFirestore.instance
            .collection(collectionUsers)
            .doc(userId)
            .collection(collectionCustomers)
            .doc(customerKey)
            .collection(collectionPolicies)
            .doc();

    final policyMap = PolicyModel.toMapForCreatePolicy(
      policyHolder: _policyHolderName,
      policyHolderBirth: _policyHolderBirth!,
      policyHolderSex: _policyHolderSex,
      insured: _insuredNameController.text,
      insuredBirth: _insuredBirth!,
      insuredSex: _insuredSex,
      productCategory: _productCategory,
      insuranceCompany: _insuranceCompany,
      productName: _productNameController.text,
      paymentMethod: _paymentMethod,
      premium: _premiumController.text,
      startDate: _startDate!,
      endDate: _endDate!,
      customerKey: customerKey,
      policyKey: policyRef.id,
    );

    return PolicyConfirmBox(
      policyMap: policyMap,
      onChecked: () async {
        if (customerKey.isEmpty) {
          showOverlaySnackBar(context, '고객 정보 오류');
          return;
        }

        await getIt<PolicyViewModel>().addPolicy(
          userKey: userId,
          customerKey: customerKey,
          policyData: policyMap,
        );
        await getIt<CustomerListViewModel>().refresh();

        if (mounted) Navigator.pop(context, true);
      },
    );
  }
}
