import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:withme/core/utils/core_utils_import.dart';

import 'package:withme/domain/model/policy_model.dart';
import 'package:withme/presentation/policy/components/policy_confirm_box.dart';
import 'package:withme/presentation/policy/part/customer_part.dart';
import 'package:withme/presentation/policy/part/policy_part.dart';
import 'package:withme/presentation/policy/policy_view_model.dart';

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
  String _productCategory = '상품 종류';
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
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const TitleWidget(title: 'Registration Policy Info'),
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
                    onInsuredNameChanged: (value) {
                      setState(() => _insuredNameController.text = value);
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
                        context.pop();
                      });
                    },
                    onCompanyTap: (value) {
                      setState(() {
                        _insuranceCompany = value.toString();
                        context.pop();
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
                    onProductNameTap: (value) {
                      setState(() => _productNameController.text = value);
                    },
                    onInputPremiumTap: (value) {
                      setState(() => _premiumController.text = value);
                    },
                  ),
                  height(20),
                  const PartTitle(text: '계약일, 만기일'),
                  PartBox(child: _periodPart(context)),
                ],
              ),
            ),
          ),
        ),
        bottomSheet: _submitButton(context),
      ),
    );
  }

  Padding _periodPart(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: RenderFilledButton(
              borderRadius: 10,
              backgroundColor:
                  _startDate != null
                      ? ColorStyles.unActiveButtonColor
                      : ColorStyles.activeButtonColor,
              foregroundColor:
                  _startDate != null ? Colors.black87 : Colors.white,
              onPressed: () async {
                DateTime? selectedDate = await selectDate(context);
                if (selectedDate != null) {
                  setState(() => _startDate = selectedDate);
                }
              },
              text:
                  _startDate == null
                      ? '계약일 선택'
                      : '개시일: ${_startDate!.toLocal().toString().split(' ')[0]}',
            ),
          ),
          width(10),
          Expanded(
            child: RenderFilledButton(
              borderRadius: 10,
              backgroundColor:
                  _endDate != null
                      ? ColorStyles.unActiveButtonColor
                      : ColorStyles.activeButtonColor,
              foregroundColor: _endDate != null ? Colors.black87 : Colors.white,
              onPressed: () async {
                DateTime? selectedDate = await selectDate(context);
                if (selectedDate != null) {
                  setState(() => _endDate = selectedDate);
                }
              },
              text:
                  _endDate == null
                      ? '만기일 선택'
                      : '만기일: ${_endDate!.toLocal().toString().split(' ')[0]}',
            ),
          ),
        ],
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

  void _tryValidation() {
    if (_formKey.currentState!.validate()) {
      if (_policyHolderBirth == null) {
        renderSnackBar(context, text: '계약자 생일을 확인하세요');
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
      if (_productCategory.isEmpty || _insuranceCompany.isEmpty) {
        renderSnackBar(context, text: '상품종류와 보험사를 선택하세요.');
        return;
      }
      if (_paymentMethod.isEmpty) {
        renderSnackBar(context, text: '납입방법을 선택하세요.');
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
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return SizedBox(
            height: 300,
            width: double.infinity,
            child: _confirmBox(context),
          );
        },
      );

      return;
    }
  }

  _confirmBox(context) {
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
    );

    // final policyMapSample = PolicyModel.toMapForCreatePolicy(
    //   policyHolder: '홍길동',
    //   policyHolderBirth: DateTime.now(),
    //   policyHolderSex: '여',
    //   insured: '김신한',
    //   insuredBirth: DateTime.now(),
    //   insuredSex: '남',
    //   productCategory: '저축보험',
    //   insuranceCompany: '삼성생명',
    //   productName: '(무)삼성저축보험',
    //   paymentMethod: '월납',
    //   premium: '100000',
    //   startDate: DateTime.now(),
    //   endDate: DateTime.now(),
    // );

    // original
    return PolicyConfirmBox(
      policyMap: policyMap,
      onChecked: (bool result) {
        if (result == true) {
          getIt<PolicyViewModel>().addPolicy(
            userKey: 'user1',
            customerKey: widget.customer.customerKey,
            policyData: policyMap,
          );
        }
      },
    );

    // sample
    // return PolicyConfirmBox(
    //   policyMap: policyMapSample,
    //   onChecked: (bool result) {
    //     if (result == true) {
    //       getIt<PolicyViewModel>().addPolicy(
    //         userKey: 'user1',
    //         customerKey: widget.customer.customerKey,
    //         policyData: policyMapSample,
    //       );
    //     }
    //   },
    // );
  }
}
