import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:withme/core/data/fire_base/firestore_keys.dart';
import 'package:withme/core/presentation/widget/history_button.dart';
import 'package:withme/core/presentation/widget/select_history_menu.dart';
import 'package:withme/core/utils/calculate_age.dart';
import 'package:withme/core/utils/calculate_insurance_age.dart';
import 'package:withme/core/utils/days_until_insurance_age.dart';
import 'package:withme/core/utils/extension/date_time.dart';
import 'package:withme/domain/model/customer_model.dart';
import 'package:withme/domain/model/history_model.dart';
import 'package:withme/domain/use_case/customer/register_customer_use_case.dart';
import 'package:withme/domain/use_case/customer/update_customer_use_case.dart';
import 'package:withme/domain/use_case/customer_use_case.dart';
import 'package:withme/core/domain/enum/history_content.dart';

import '../../core/di/setup.dart';
import '../../core/presentation/widget/custom_text_form_field.dart';
import '../../core/presentation/widget/render_filled_button.dart';
import '../../core/presentation/widget/render_snack_bar.dart';
import '../../core/presentation/widget/select_birth.dart';
import '../../core/presentation/widget/width_height.dart';

class RegistrationScreen extends StatefulWidget {
  final CustomerModel? customerModel;

  const RegistrationScreen({super.key, this.customerModel});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _recommendedController = TextEditingController();
  TextEditingController _historyController = TextEditingController(
    text: HistoryContent.title.toString(),
  );
  final TextEditingController _birthController = TextEditingController();
  final MenuController _menuController = MenuController();

  bool isRecommended = false;
  DateTime? _birth;
  String? _sex;

  @override
  void initState() {
    if (widget.customerModel != null) {
      print('전달받은 customerKey: ${widget.customerModel?.customerKey}');
      final customer = widget.customerModel!;
      _nameController.text = customer.name;
      _sex = customer.sex;
      _birth = customer.birth;
      if(customer.birth.toString()!=''){

      _birthController.text = customer.birth.toString();
      }
      if (customer.recommended.isNotEmpty) {
        isRecommended = true;
        _recommendedController.text = customer.recommended;
      }
    }
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _recommendedController.dispose();
    _historyController.dispose();
    _menuController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  height(50),
                  _title(),
                  height(39),
                  _inputName(),
                  height(10),
                  _inputSex(),
                  height(10),
                  _inputBirth(),
                  height(5),
                  _recommendedSwitch(),
                  if (isRecommended) _recommendedInputName(),
                  height(20),
                  // _historyMenu(),
                  SelectHistoryMenu(
                    menuController: _menuController,
                    textController: _historyController,
                    onTap: (textController) {
                      setState(() {
                        _historyController = textController;
                      });
                    },
                  ),
                  if (_historyController.text.isNotEmpty &&
                      widget.customerModel == null)
                    SizedBox(
                      width: double.infinity,
                      child: HistoryButton(
                        menuController: _menuController,
                        textController: _historyController,
                    onPressed:  () {
                      print('test');
                      setState(() {
                      Focus.of(context).requestFocus();
                    });
                    },
                      ),
                    ),
                  // _historyButton(context),
                  height(10),
                  if (_historyController.text.isEmpty) _etcHistoryInput(),
                ],
              ),
            ),
          ),
        ),
        bottomSheet: _registrationButton(context),
      ),
    );
  }

  Text _title() {
    return const Text(
      'Registration in Pool',
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  CustomTextFormField _inputName() {
    return CustomTextFormField(
      controller: _nameController,
      hintText: '신규 고객 이름 (필수)',
      autoFocus: true,
      onChanged: (text) async {
        setState(() {
          _nameController.text = text;
        });
      },
      validator: (String text) {
        if (text.isEmpty) {
          return '이름을 입력하세요';
        }
        return null;
      },
      onSaved: (String text) {
        _nameController.text = text.trim();
      },
    );
  }

  Widget _inputSex() {
    return Container(
      padding: const EdgeInsets.only(left: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text('성별 (필수)'),
          const Spacer(),
          RadioMenuButton<String>(
            value: '남',
            groupValue: _sex,
            onChanged:
                (value) => setState(() {
                  _sex = value;
                }),

            child: const Text('남성'),
          ),
          RadioMenuButton<String>(
            value: '여',
            groupValue: _sex,
            onChanged:
                (value) => setState(() {
                  _sex = value;
                }),

            child: const Text('여성'),
          ),
        ],
      ),
    );
  }

  _inputBirth() {
    return Container(
      padding: const EdgeInsets.only(left: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('생년월일 (선택)'),
              const Spacer(),
              if (_birth != null)
                FilledButton.tonal(
                  onPressed: () async {
                    setState(() {
                      _birth = null;
                      _birthController.clear();
                    });
                  },
                  child: const Text('초기화'),
                ),
              FilledButton.tonal(
                onPressed: () async {
                  DateTime? selectedBirth = await selectBirth(context);
                  if (selectedBirth != null) {
                    setState(() {
                      _birth = selectedBirth;
                      _birthController.text = selectedBirth.toString();
                    });
                  }
                },
                child: Text(_birth != null ? _birth!.formattedDate : 'Birth'),
              ),
            ],
          ),

          if (_birth != null)
            Column(
              children: [
                height(5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${calculateAge(_birth!)}세 (보험나이 : ${calculateInsuranceAge(_birth!)}세), 상령일까지 ${daysUntilInsuranceAgeChange(_birth!)}일',
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  SwitchListTile _recommendedSwitch() {
    return SwitchListTile.adaptive(
      value: isRecommended,
      onChanged: (value) {
        setState(() {
          isRecommended = value;
        });
      },
      title: const Text('소개자 여부 (선택)'),
      contentPadding: const EdgeInsets.only(left: 20),
    );
  }

  CustomTextFormField _recommendedInputName() {
    return CustomTextFormField(
      controller: _recommendedController,
      hintText: '소개자 이름',
      onChanged: (text) {
        setState(() {
          _recommendedController.text = text.trim();
        });
      },
      validator: (String text) {
        if (text.isEmpty) {
          return '소개자 이름을 입력하세요';
        }
        return null;
      },
      onSaved: (String text) {
        _recommendedController.text = text.trim();
      },
    );
  }

  CustomTextFormField _etcHistoryInput() {
    return CustomTextFormField(
      controller: _historyController,
      hintText: '내용을 입력 하세요.',
      autoFocus: true,
      onCompleted: () {
        setState(() {
          _historyController.text.trim();
        });
      },

      validator: (String text) {
        if (text.isEmpty) {
          return '내용을 입력하세요';
        }
        return null;
      },
      onSaved: (String text) {
        _historyController.text = text.trim();
      },
    );
  }

  Widget _registrationButton(BuildContext context) {
    return RenderFilledButton(
      onPressed: () async {
        final result = _tryValidation();
        if (result) {
         await showModalBottomSheet(
            context: context,
            builder: (context) {
              return SizedBox(
                height: 250,
                width: double.infinity,
                child: _confirmBox(context),
              );
            },
          );

        }
      },
      text: widget.customerModel == null ? '등록' : '수정',
    );
  }

  Column _confirmBox(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        height(15),
        _renderText(
          text: widget.customerModel == null ? '신규등록 확인' : '수정내용 확인',
          size: 20,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _renderText(
                text: '등록자: ',
                text2: ' ${_nameController.text} ($_sex)',
              ),
              _renderText(
                text: '생년월일: ',
                text2:
                    ' ${_birthController.text.isEmpty ? "추후입력" : _birth?.formattedDate}',
              ),
              _renderText(
                text: '소개자: ',
                text2:
                    _recommendedController.text.isEmpty
                        ? "없음"
                        : _recommendedController.text,
              ),
              if (widget.customerModel == null)
                _renderText(text2: _historyController.text),
            ],
          ),
        ),
        height(5),
        RenderFilledButton(
          onPressed: () {
            final customerMap = CustomerModel.toMapForCreateCustomer(
              name: _nameController.text,
              sex: _sex!,
              recommender: _recommendedController.text,
              birth: _birth,
            );
            final historyMap = HistoryModel.toMapForHistory(
              content: _historyController.text,
            );
            widget.customerModel == null
                ? _onRegistrationPressed(
                  customerMap: customerMap,
                  historyMap: historyMap,
                )
                : _onUpdatePressed(
                  customerMap: customerMap,
                );
            // getIt<CustomerUseCase>().execute(
            //   usecase: RegisterCustomerUseCase(
            //     userKey: 'user1',
            //     customerData: customerMap,
            //     historyData: historyMap,
            //   ),
            // );
            context.pop(true);
          },
          text: widget.customerModel == null ? '등록' : '수정',
        ),
      ],
    );
  }

  void _onRegistrationPressed({
    required Map<String, dynamic> customerMap,
    required Map<String, dynamic> historyMap,
  }) {
    getIt<CustomerUseCase>().execute(
      usecase: RegisterCustomerUseCase(
        userKey: 'user1',
        customerData: customerMap,
        historyData: historyMap,
      ),
    );
    context.pop(true);
  }

  void _onUpdatePressed({
    required Map<String, dynamic> customerMap,
  }) {
    getIt<CustomerUseCase>().execute(
      usecase: UpdateCustomerUseCase(
        userKey: 'user1',
        customerData: customerMap,
      ),
    );
    print(customerMap[keyCustomerKey]);
    context.pop(true);
  }

  Widget _renderText({String? text, String? text2, double size = 16}) {
    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: size), // 기본 스타일
        children: [
          TextSpan(text: text, style: const TextStyle(color: Colors.black87)),
          TextSpan(
            text: text2,
            style: const TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  bool _tryValidation() {
    final isValid = _formKey.currentState?.validate();

    if (_nameController.text.isNotEmpty && _sex == null) {
      renderSnackBar(context, text: '성별을 선택 하세요');
      return false;
    }
    if (_nameController.text.isNotEmpty &&
        _historyController.text == HistoryContent.title.toString() &&
        widget.customerModel == null) {
      renderSnackBar(context, text: '상담 이력을 선택 하세요');
      return false;
    }
    if (isValid == true) {
      _formKey.currentState!.save();
      return true;
    }
    return false;
  }
}
