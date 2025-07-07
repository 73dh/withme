import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:withme/core/data/fire_base/firestore_keys.dart';
import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/core/utils/core_utils_import.dart';

import 'package:withme/domain/model/policy_model.dart';
import 'package:withme/presentation/policy/components/policy_confirm_box.dart';
import 'package:withme/presentation/policy/part/customer_part.dart';
import 'package:withme/presentation/policy/part/policy_part.dart';
import 'package:withme/presentation/policy/policy_view_model.dart';

import '../../../core/data/fire_base/user_session.dart';
import '../../../core/di/setup.dart';
import '../../../core/domain/core_domain_import.dart';
import '../../../core/presentation/core_presentation_import.dart';
import '../../../core/ui/core_ui_import.dart';
import '../../../domain/model/customer_model.dart';

class PolicyScreen extends StatefulWidget {
  final CustomerModel customer;

  const PolicyScreen({super.key, required this.customer});

  @override
  State<PolicyScreen> createState() => _PolicyScreenState();
}

class _PolicyScreenState extends State<PolicyScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _insuredNameController = TextEditingController();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _premiumController = TextEditingController();
  final NumberFormat _formatter = NumberFormat.decimalPattern();

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
    if (widget.customer.name.isNotEmpty) {
      _policyHolderName = widget.customer.name;
      _policyHolderSex = widget.customer.sex;
      _policyHolderBirth = widget.customer.birth;
    }
    _premiumController.addListener(() {
      final text = _premiumController.text.replaceAll(',', '');
      if (text.isEmpty) return;

      final newText = _formatter.format(int.parse(text));
      if (newText != _premiumController.text) {
        _premiumController.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length),
        );
      }
    });

    setState(() {});
    super.initState();
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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(),
        body: Form(
          key: _formKey,
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.only(
              bottom: 50, // filledButton 기본 높이
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(8),
              child: Column(
                children: [
                  const TitleWidget(title: '계약 정보 등록'),
                  height(40),
                  const PartTitle(text: '계약관계자 정보'),

                  CustomerPart(
                    policyHolderName: _policyHolderName,
                    policyHolderSex: _policyHolderSex,
                    policyHolderBirth: _policyHolderBirth,
                    onBirthPressed: (birth) async {
                      if (_policyHolderBirth == null) {
                        DateTime? selected = await selectDate(context);
                        if (selected != null) {
                          setState(() => _policyHolderBirth = selected);
                        }
                      }
                    },
                    insuredNameController: _insuredNameController,
                    insuredSex: _insuredSex,
                    insuredBirth: _insuredBirth,
                    onInsuredNameChanged: (_) {
                      // setState(() {
                        // _insuredNameController.text = value;
                      // });
                    },
                    onManChanged:
                        (value) => setState(() => _insuredSex = value),
                    onWomanChanged:
                        (value) => setState(() => _insuredSex = value),
                    onBirthChanged: (birth) async {
                      DateTime? birth = await selectDate(context);
                      if (birth != null) {
                        setState(() => _insuredBirth = birth);
                      }
                    },
                  ),
                  height(20),
                  const PartTitle(text: '보험계약 정보'),
                  PolicyPart(
                    productCategory: _productCategory,
                    insuranceCompany: _insuranceCompany,
                    onCategoryTap: (value) {
                      setState(() {
                        _productCategory = value.toString();
                        // context.pop();
                      });
                    },
                    onCompanyTap: (value) {
                      setState(() {
                        _insuranceCompany = value.toString();
                        // context.pop();
                      });
                    },
                    productNameController: _productNameController,
                    paymentMethod: _paymentMethod,
                    premiumController: _premiumController,
                    onPremiumMonthTap: (value) {
                      setState(() => _paymentMethod = value);
                    },
                    onPremiumSingleTap: (value) {
                      setState(() => _paymentMethod = value);
                    },
                    onProductNameTap: (_) {
                      // setState(() => _productNameController.text = value);
                    },
                    onInputPremiumTap: (value) {
                      setState(() => _premiumController.text = value);
                    },
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
        bottomSheet: _submitButton(context),
      ),
    );
  }

  Widget _submitButton(BuildContext context) {
    return RenderFilledButton(
      backgroundColor: ColorStyles.activeButtonColor,
      foregroundColor: Colors.black87,
      onPressed: () async {
        _tryValidation();
      },
      text: '확인',
    );
  }

  void _tryValidation() async {
    if (_formKey.currentState!.validate()) {
      final name = _insuredNameController.text.trim();
      final nameRegex = RegExp(r'^[a-zA-Z가-힣]+$');
      if (_policyHolderBirth == null) {
        renderSnackBar(context, text: '계약자 생일을 확인하세요');
        return;
      }
      if (name.isEmpty) {
        renderSnackBar(context, text: '피보험자 이름을 입력하세요');
        return;
      }
      if (!nameRegex.hasMatch(name)) {
        renderSnackBar(context, text: '이름은 한글 또는 영문만 입력 가능합니다');
        return;
      }
      if (_insuredSex == '') {
        renderSnackBar(context, text: '피보험자 성별을 확인하세요');
        return;
      }
      if (_insuredBirth == null) {
        renderSnackBar(context, text: '피보험자 생일을 확인하세요');
        return;
      }
      if (_productCategory == '상품종류') {
        renderSnackBar(context, text: '상품종류를 선택하세요.');
        return;
      }
      if (_insuranceCompany == '보험사') {
        renderSnackBar(context, text: '보험사를 선택하세요.');
        return;
      }
      if (_productNameController.text.trim().isEmpty) {
        renderSnackBar(context, text: '상품명을 입력하세요.');
        return;
      }
      if (_paymentMethod.isEmpty) {
        renderSnackBar(context, text: '납입방법을 선택하세요.');
        return;
      }
      if (_premiumController.text.trim().isEmpty) {
        renderSnackBar(context, text: '보험료를 입력하세요.');
        return;
      }

      if (_startDate == null) {
        renderSnackBar(context, text: '계약일을 확인하세요');
        return;
      }
      if (_endDate == null) {
        renderSnackBar(context, text: '보장 종료일을 확인하세요');

        return;
      }
      if (_startDate != null &&
          _endDate != null &&
          _startDate!.isAfter(_endDate!)) {
        renderSnackBar(context, text: '시작일이 종료일보다 늦습니다.');
        return;
      }
      setState(() => _isCompleted = true);
      _formKey.currentState!.save();
      final result = await showModalBottomSheet(
        context: context,
        builder: (context) {
          return SizedBox(
            height: 400,
            width: double.infinity,
            child: _confirmBox(context),
          );
        },
      );
      if (result == true && mounted) {
        context.pop(true);
      }
    }
  }

  _confirmBox(BuildContext context) {
    // 안전성 확인용 null 체크
    if (_policyHolderBirth == null ||
        _insuredBirth == null ||
        _startDate == null ||
        _endDate == null) {
      return const Center(child: Text('입력 누락 발생'));
    }
    final userId = UserSession.userId;
    final customerKey = widget.customer.customerKey;

    final policyDocRef =
        FirebaseFirestore.instance
            .collection(collectionUsers)
            .doc(userId)
            .collection(collectionCustomer)
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
      policyKey: policyDocRef.id,
    );

    return PolicyConfirmBox(
      policyMap: policyMap,
      onChecked: (bool result) async {
        if (result == true) {
          if (widget.customer.customerKey.isEmpty) {
            renderSnackBar(context, text: '고객 정보 오류');
            return;
          }

          await getIt<PolicyViewModel>().addPolicy(
            userKey: UserSession.userId,
            customerKey: widget.customer.customerKey,
            policyData: policyMap,
          );

          await getIt<CustomerListViewModel>().refresh();
          if (context.mounted) Navigator.pop(context, true);
        }
      },
    );
  }
}
