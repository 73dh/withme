import 'package:flutter/material.dart';
import 'package:withme/core/presentation/widget/custom_text_form_field.dart';
import 'package:withme/core/presentation/widget/render_filled_button.dart';
import 'package:withme/core/presentation/widget/render_snack_bar.dart';
import 'package:withme/core/presentation/widget/select_date.dart';
import 'package:withme/core/presentation/widget/title_widget.dart';
import 'package:withme/core/presentation/widget/width_height.dart';
import 'package:withme/core/ui/color/color_style.dart';
import 'package:withme/core/utils/extension/date_time.dart';
import 'package:withme/domain/model/policy_model.dart';

import '../../domain/model/customer_model.dart';

class PolicyScreen extends StatefulWidget {
  final CustomerModel customer;

  const PolicyScreen({super.key, required this.customer});

  @override
  State<PolicyScreen> createState() => _PolicyScreenState();
}

class _PolicyScreenState extends State<PolicyScreen> {
  final _formKey = GlobalKey<FormState>();

  String _policyHolderName = '';
  String _policyHolderSex = '';
  DateTime? _policyHolderBirth;
  String _insuredName = '';
  String _insuredSex = '';
  DateTime? _insuredBirth;
  String _productName = '';
  double _premium = 0;
  DateTime? _startDate;
  DateTime? _endDate;

  bool _isCompleted = false;

  @override
  void initState() {
    if (widget.customer.name.isNotEmpty) {
      _policyHolderName = widget.customer.name;
      // _policyHolderNameController.text = widget.customer.name;
      _policyHolderSex = widget.customer.sex;
      _policyHolderBirth = widget.customer.birth;
    }
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TitleWidget(title: 'Policy Info'),
                height(20),
                _policyHolderPart(),
                height(5),
                _insuredPart(),

                TextFormField(
                  decoration: const InputDecoration(labelText: '보험 상품명'),
                  validator: (value) => value!.isEmpty ? '상품명을 확인하세요' : null,
                  onSaved: (value) => _productName = value!,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: '보험료 (₩)'),
                  keyboardType: TextInputType.number,
                  validator:
                      (value) =>
                          value == null || double.tryParse(value) == null
                              ? '숫자를 입력하세요'
                              : null,
                  onSaved: (value) => _premium = double.parse(value!),
                ),
                const SizedBox(height: 16),
                _periodPart(context),
              ],
            ),
          ),
        ),
        bottomSheet: RenderFilledButton(
          onPressed: _submitForm,
          text: '등록',
          backgroundColor:
              _isCompleted ? ColorStyles.bottomNavColor : Colors.grey,
        ),
      ),
    );
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
                borderRadius: 30,
                backgroundColor:
                    _policyHolderBirth == null
                        ? ColorStyles.activeButtonColor
                        : ColorStyles.unActiveButtonColor,
                foregroundColor: Colors.black87,
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
                hintText: '피보험자',
                validator: (value) => value.isEmpty ? '이름 입력' : null,
                onSaved: (value) => _insuredName = value,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioMenuButton<String>(
                  value: '남',
                  groupValue: _insuredSex,
                  onChanged:
                      (value) => setState(() {
                        _insuredSex = value!;
                      }),

                  child: const Text('남'),
                ),
                RadioMenuButton<String>(
                  value: '여',
                  groupValue: _insuredSex,
                  onChanged:
                      (value) => setState(() {
                        _insuredSex = value!;
                      }),

                  child: const Text('여'),
                ),
              ],
            ),
            SizedBox(
              width: 130,
              child: RenderFilledButton(
                borderRadius: 30,
                backgroundColor: ColorStyles.activeButtonColor,
                foregroundColor: Colors.black87,
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

  Row _periodPart(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: RenderFilledButton(
            borderRadius: 30,
            backgroundColor: ColorStyles.activeButtonColor,
            foregroundColor: Colors.black87,
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
            borderRadius: 30,
            backgroundColor: ColorStyles.activeButtonColor,
            foregroundColor: Colors.black87,
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
    );
  }

  void _submitForm() {
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
      if (_startDate == null) {
        renderSnackBar(context, text: '계약일을 확인하세요');
        return;
      }
      if (_endDate == null) {
        renderSnackBar(context, text: '보장 종료일을 확인하세요');
        setState(() => _isCompleted = true);
        return;
      }

      _formKey.currentState!.save();
      final policyMap = PolicyModel.toMapForCreatePolicy(
        policyHolder: _policyHolderName,
        policyHolderBirth: _policyHolderBirth!,
        policyHolderSex: _policyHolderSex,
        insured: _insuredName,
        insuredBirth: _insuredBirth!,
        insuredSex: _insuredSex,
        startDate: _startDate!,
        endDate: _endDate!,
      );

      print('--- 보험 계약 정보 --- $policyMap');
      // 여기에서 Firebase 등에 저장 가능
    }
  }
}
