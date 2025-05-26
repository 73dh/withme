import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:withme/core/domain/enum/product_category.dart';
import 'package:withme/core/domain/enum/insurance_company.dart';
import 'package:withme/core/presentation/components/custom_text_form_field.dart';
import 'package:withme/core/presentation/components/part_box.dart';
import 'package:withme/core/presentation/components/render_filled_button.dart';
import 'package:withme/core/presentation/widget/render_snack_bar.dart';
import 'package:withme/core/presentation/widget/select_date.dart';
import 'package:withme/core/presentation/components/title_widget.dart';
import 'package:withme/core/presentation/components/width_height.dart';
import 'package:withme/core/ui/color/color_style.dart';
import 'package:withme/core/utils/extension/date_time.dart';
import 'package:withme/domain/model/policy_model.dart';
import 'package:withme/presentation/policy/components/policy_confirm_box.dart';
import 'package:withme/presentation/policy/policy_view_model.dart';

import '../../core/di/setup.dart';
import '../../core/presentation/components/part_title.dart';
import '../../domain/model/customer_model.dart';

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
                  _customerPart(),
                  height(20),
                  const PartTitle(text: '보험계약 정보'),
                  _policyPart(),
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

  PartBox _customerPart() {
    return PartBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_policyHolderPart(), height(5), _insuredPart()],
      ),
    );
  }

  PartBox _policyPart() {
    return PartBox(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  _renderFittedBox(_productCategory),
                  _selectProductCategory(),
                ],
              ),
              Row(
                children: [
                  _renderFittedBox(_insuranceCompany),
                  _selectInsuranceCompany(),
                ],
              ),
            ],
          ),
          _inputProductName(),
          height(5),
          Row(
            children: [
              _selectPaymentMethod(),
              const Icon(Icons.more_vert),
              _inputPremium(),
            ],
          ),
        ],
      ),
    );
  }

  FittedBox _renderFittedBox(String text) {
    return FittedBox(child: Text(text, textAlign: TextAlign.center));
  }

  LayoutBuilder _policyHolderPart() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: constraints.maxWidth * 0.25,
              child: Text(_policyHolderName, textAlign: TextAlign.center),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioMenuButton<String>(
                  value: '남',
                  groupValue: _policyHolderSex,
                  onChanged: null,
                  child: const Text('남'),
                ),
                RadioMenuButton<String>(
                  value: '여',
                  groupValue: _policyHolderSex,
                  onChanged: null,
                  child: const Text('여'),
                ),
              ],
            ),
            SizedBox(
              width: 130,
              child: RenderFilledButton(
                borderRadius: 10,
                backgroundColor:
                    _policyHolderBirth == null
                        ? ColorStyles.activeButtonColor
                        : ColorStyles.unActiveButtonColor,
                foregroundColor:
                    _policyHolderBirth != null ? Colors.black87 : Colors.white,
                onPressed:
                    _policyHolderBirth == null
                        ? () async {
                          DateTime? birth = await selectDate(context);
                          if (birth != null) {
                            setState(() => _policyHolderBirth = birth);
                          }
                        }
                        : () {},
                text: _policyHolderBirth?.formattedDate ?? '생년월일',
              ),
            ),
          ],
        );
      },
    );
  }

  LayoutBuilder _insuredPart() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: constraints.maxWidth * 0.25,
              child: CustomTextFormField(
                controller: _insuredNameController,
                hintText: '피보험자',
                autoFocus: true,
                textAlign: TextAlign.center,
                validator: (value) => value.isEmpty ? '이름 입력' : null,
                onChanged: (value) {
                  setState(() => _insuredNameController.text = value);
                },
                onSaved: (value) => _insuredNameController.text = value,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioMenuButton<String>(
                  value: '남',
                  groupValue: _insuredSex,
                  onChanged: (value) => setState(() => _insuredSex = value!),
                  child: const Text('남'),
                ),
                RadioMenuButton<String>(
                  value: '여',
                  groupValue: _insuredSex,
                  onChanged: (value) => setState(() => _insuredSex = value!),
                  child: const Text('여'),
                ),
              ],
            ),
            SizedBox(
              width: 130,
              child: RenderFilledButton(
                borderRadius: 10,
                backgroundColor:
                    _insuredBirth != null
                        ? ColorStyles.unActiveButtonColor
                        : ColorStyles.activeButtonColor,
                foregroundColor:
                    _insuredBirth != null ? Colors.black87 : Colors.white,
                onPressed: () async {
                  DateTime? birth = await selectDate(context);
                  if (birth != null) {
                    setState(() => _insuredBirth = birth);
                  }
                },
                text: _insuredBirth?.formattedDate ?? '생년월일',
              ),
            ),
          ],
        );
      },
    );
  }

  PopupMenuButton<dynamic> _selectProductCategory() {
    return PopupMenuButton(
      icon: const Icon(Icons.drag_indicator),
      itemBuilder: (context) {
        return ProductCategory.values
            .map(
              (e) => PopupMenuItem(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _productCategory = e.toString();
                      context.pop();
                    });
                  },
                  child: Row(
                    children: [
                      Icon(e.getCategoryIcon()),
                      width(10),
                      Text(e.toString()),
                    ],
                  ),
                ),
              ),
            )
            .toList();
      },
    );
  }

  PopupMenuButton<dynamic> _selectInsuranceCompany() {
    return PopupMenuButton(
      icon: const Icon(Icons.drag_indicator),
      itemBuilder: (context) {
        return InsuranceCompany.values
            .map(
              (e) => PopupMenuItem(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _insuranceCompany = e.toString();
                      context.pop();
                    });
                  },
                  child: Text(e.toString()),
                ),
              ),
            )
            .toList();
      },
    );
  }

  CustomTextFormField _inputProductName() {
    return CustomTextFormField(
      controller: _productNameController,
      hintText: '보험 상품명',
      textAlign: TextAlign.center,
      onChanged: (value) {
        setState(() => _productNameController.text = value);
      },
      validator: (value) => value.isEmpty ? '상품명을 입력하세요' : null,
      onSaved: (value) => _productNameController.text = value,
    );
  }

  Row _selectPaymentMethod() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        RadioMenuButton<String>(
          value: '월납',
          groupValue: _paymentMethod,
          onChanged: (value) {
            setState(() => _paymentMethod = value!);
          },
          child: const Text('월납'),
        ),
        RadioMenuButton<String>(
          value: '일시납',
          groupValue: _paymentMethod,

          onChanged: (value) {
            setState(() => _paymentMethod = value!);
          },
          child: const Text('일시납'),
        ),
      ],
    );
  }

  Expanded _inputPremium() {
    return Expanded(
      child: CustomTextFormField(
        controller: _premiumController,
        hintText: '보험료 (예) 100,000',
        inputType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) {
          setState(() => _premiumController.text = value);
        },
        validator: (value) => value.isEmpty ? '보험료를 입력하세요' : null,
        onSaved: (value) => _premiumController.text = value,
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
                      : '보장개시일: ${_startDate!.toLocal().toString().split(' ')[0]}',
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
                      : '보장종료일: ${_endDate!.toLocal().toString().split(' ')[0]}',
            ),
          ),
        ],
      ),
    );
  }

  Widget _submitButton(BuildContext context) {
    return RenderFilledButton(
      backgroundColor: ColorStyles.activeButtonColor,
      foregroundColor: Colors.white,
      onPressed: () async {
        _tryValidation();
      },
      text: '확인',
    );
  }

  void _tryValidation() {
    // if (_formKey.currentState!.validate()) {
    //   if (_policyHolderBirth == null) {
    //     renderSnackBar(context, text: '계약자 생일을 확인하세요');
    //     return;
    //   }
    //   if (_insuredSex == '') {
    //     renderSnackBar(context, text: '피보험자 성별을 확인하세요');
    //     return;
    //   }
    //   if (_insuredBirth == null) {
    //     renderSnackBar(context, text: '피보험자 생일을 확인하세요');
    //     return;
    //   }
    //   if (_productCategory.isEmpty || _insuranceCompany.isEmpty) {
    //     renderSnackBar(context, text: '상품종류와 보험사를 선택하세요.');
    //     return;
    //   }
    //   if (_paymentMethod.isEmpty) {
    //     renderSnackBar(context, text: '납입방법을 선택하세요.');
    //     return;
    //   }
    //
    //   if (_startDate == null) {
    //     renderSnackBar(context, text: '계약일을 확인하세요');
    //     return;
    //   }
    //   if (_endDate == null) {
    //     renderSnackBar(context, text: '보장 종료일을 확인하세요');
    //
    //     return;
    //   }
    //   if (_startDate != null &&
    //       _endDate != null &&
    //       _startDate!.isAfter(_endDate!)) {
    //     renderSnackBar(context, text: '시작일이 종료일보다 늦습니다.');
    //     return;
    //   }
    //   setState(() => _isCompleted = true);
    //   _formKey.currentState!.save();
    //   showModalBottomSheet(
    //     context: context,
    //     builder: (context) {
    //       return SizedBox(
    //         height: 300,
    //         width: double.infinity,
    //         child: _confirmBox(context),
    //       );
    //     },
    //   );
    //
    //   return;
    // }
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
  }

  _confirmBox(context) {
    // final policyMap = PolicyModel.toMapForCreatePolicy(
    //   policyHolder: _policyHolderName,
    //   policyHolderBirth: _policyHolderBirth!,
    //   policyHolderSex: _policyHolderSex,
    //   insured: _insuredNameController.text,
    //   insuredBirth: _insuredBirth!,
    //   insuredSex: _insuredSex,
    //   productCategory: _productCategory,
    //   insuranceCompany: _insuranceCompany,
    //   productName: _productNameController.text,
    //   paymentMethod: _paymentMethod,
    //   premium: _premiumController.text,
    //   startDate: _startDate!,
    //   endDate: _endDate!,
    // );

    final policyMapSample = PolicyModel.toMapForCreatePolicy(
      policyHolder: '홍길동',
      policyHolderBirth: DateTime.now(),
      policyHolderSex: '여',
      insured: '김신한',
      insuredBirth: DateTime.now(),
      insuredSex: '남',
      productCategory: '저축보험',
      insuranceCompany: '삼성생명',
      productName: '(무)삼성저축보험',
      paymentMethod: '월납',
      premium: '100000',
      startDate: DateTime.now(),
      endDate: DateTime.now(),
    );

    // original
    // return PolicyConfirmBox(
    //   policyMap: policyMap,
    //   onChecked: (bool result) {
    //     if (result == true) {
    //       getIt<PolicyViewModel>().addPolicy(
    //         userKey: 'user1',
    //         customerKey: widget.customer.customerKey,
    //         policyData: policyMap,
    //       );
    //     }
    //   },
    // );

    // sample
    return PolicyConfirmBox(
      policyMap: policyMapSample,
      onChecked: (bool result) {
        if (result == true) {
          getIt<PolicyViewModel>().addPolicy(
            userKey: 'user1',
            customerKey: widget.customer.customerKey,
            policyData: policyMapSample,
          );
        }
      },
    );
  }
}
