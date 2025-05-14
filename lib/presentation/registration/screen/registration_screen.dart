import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:withme/core/domain/enum/history_content.dart';
import 'package:withme/core/presentation/widget/confirm_box_text.dart';
import 'package:withme/core/presentation/widget/history_button.dart';
import 'package:withme/core/presentation/widget/select_history_menu.dart';
import 'package:withme/core/presentation/widget/show_confirm_dialog.dart';
import 'package:withme/core/presentation/widget/show_histories.dart';
import 'package:withme/core/router/router_path.dart';
import 'package:withme/core/ui/color/color_style.dart';
import 'package:withme/core/ui/icon/const.dart';
import 'package:withme/core/utils/calculate_age.dart';
import 'package:withme/core/utils/calculate_insurance_age.dart';
import 'package:withme/core/utils/days_until_insurance_age.dart';
import 'package:withme/core/utils/extension/date_time.dart';
import 'package:withme/core/utils/generate_customer_key.dart';
import 'package:withme/domain/model/customer_model.dart';
import 'package:withme/domain/model/history_model.dart';
import 'package:withme/domain/model/policy_model.dart';
import 'package:withme/core/presentation/widget/title_widget.dart';
import 'package:withme/presentation/registration/registration_event.dart';
import 'package:withme/presentation/registration/registration_view_model.dart';

import '../../../core/di/setup.dart';
import '../../../core/presentation/widget/custom_text_form_field.dart';
import '../../../core/presentation/widget/render_filled_button.dart';
import '../../../core/presentation/widget/render_snack_bar.dart';
import '../../../core/presentation/widget/select_date.dart';
import '../../../core/presentation/widget/width_height.dart';
import '../../../core/ui/text_style/text_styles.dart';

class RegistrationScreen extends StatefulWidget {
  final CustomerModel? customerModel;

  const RegistrationScreen({super.key, this.customerModel});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _recommendedController = TextEditingController();
  final TextEditingController _historyController = TextEditingController(
    text: '신규등록',
  );
  final TextEditingController _birthController = TextEditingController();

   AnimationController? _animationController;
  late Animation<Color?> _colorAnimation;

  bool _isReadOnly = false;
  bool _isRecommended = false;
  DateTime? _birth;
  String? _sex;

  final viewModel = getIt<RegistrationViewModel>();

  @override
  void initState() {
    if (widget.customerModel != null) {
      _isReadOnly = true;
      final customer = widget.customerModel!;
      _nameController.text = customer.name;
      _sex = customer.sex;
      _birth = customer.birth;
      if (customer.birth.toString() != '') {
        _birthController.text = customer.birth.toString();
      }
      if (customer.recommended.isNotEmpty) {
        _isRecommended = true;
        _recommendedController.text = customer.recommended;
      }

      _animationController = AnimationController(
        vsync: this,
        duration: Duration(seconds: 3),
      )..repeat(reverse: true);
      _colorAnimation = ColorTween(
        begin: Colors.red,
        end: Colors.blue,
      ).animate(_animationController!);
    }
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _recommendedController.dispose();
    _historyController.dispose();
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: _appBar(),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                height(20),
                const TitleWidget(title: 'Registration in Prospect'),
                height(39),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _inputName(),
                      height(10),
                      _inputSex(),
                      height(10),
                      _inputBirth(),
                      height(5),
                      _recommendedSwitch(),
                      if (_isRecommended) _recommendedInputName(),
                      height(30),
                      if(_isReadOnly)
                      _addPolicy(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomSheet: _registrationButton(context),
      ),
    );
  }

  Row _addPolicy(BuildContext context) {
    return Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            context.push(
                              RoutePath.policy,
                              extra: widget.customerModel,
                            );
                          },
                          child: AnimatedBuilder(
                            animation: _colorAnimation,
                            builder: (context, child) {
                              return Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: _colorAnimation.value,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    '계약',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
  }

  AppBar _appBar() {
    return AppBar( actions: [_editIcon(), if (_isReadOnly) _deleteIcon()]);
  }

  IconButton _deleteIcon() {
    return IconButton(
      onPressed: () async {
        bool? result = await showConfirmDialog(
          context,
          text: '가망고객을 삭제하시겠습니까?',
        );
        if (result != null && mounted) {
          viewModel.onEvent(
            RegistrationEvent.deleteCustomer(
              customerKey: widget.customerModel!.customerKey,
            ),
          );

          context.pop();
        }
      },
      icon: Image.asset(IconsPath.deleteIcon, width: 25),
    );
  }

  IconButton _editIcon() {
    return IconButton(
      onPressed: () {
        setState(() {
          _isReadOnly = !_isReadOnly;
        });
      },
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder:
            (child, animation) =>
                RotationTransition(turns: animation, child: child),
        child: Icon(
          _isReadOnly ? Icons.edit : Icons.check,
          key: ValueKey<bool>(_isReadOnly),
        ),
      ),
    );
  }

  Widget _inputName() {
    return _isReadOnly
        ? Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Text('고객명: ${_nameController.text}'),
        )
        : CustomTextFormField(
          controller: _nameController,
          hintText: '신규 고객 이름 (필수)',
          autoFocus: true,
          readOnly: _isReadOnly,
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
          Text('성별 ' + (!_isReadOnly ? ' (필수)' : '')),
          const Spacer(),
          RadioMenuButton<String>(
            value: '남',
            groupValue: _sex,
            onChanged:
                _isReadOnly
                    ? null
                    : (value) => setState(() {
                      _sex = value;
                    }),

            child: const Text('남성'),
          ),
          RadioMenuButton<String>(
            value: '여',
            groupValue: _sex,
            onChanged:
                _isReadOnly
                    ? null
                    : (value) => setState(() {
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
              Text('생년월일 ${!_isReadOnly ? '(선택)' : ''}'),
              const Spacer(),
              if (_birth != null)
                FilledButton.tonal(
                  onPressed:
                      _isReadOnly
                          ? null
                          : () async {
                            setState(() {
                              _birth = null;
                              _birthController.clear();
                            });
                          },
                  child: const Text('초기화'),
                ),
              FilledButton.tonal(
                onPressed:
                    _isReadOnly
                        ? null
                        : () async {
                          DateTime? selectedBirth = await selectDate(context);
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

  ListTile _recommendedSwitch() {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 20),
      title: Text(
        '소개자 여부 ${!_isReadOnly ? '(선택)' : ''}',
        style: TextStyles.normal13,
      ),
      trailing: Switch.adaptive(
        value: _isRecommended,
        onChanged:
            _isReadOnly
                ? null
                : (value) {
                  setState(() {
                    _isRecommended = value;
                    if (!_isRecommended) {
                      _recommendedController.text = '';
                    }
                  });
                },
      ),
    );
  }

  Widget _recommendedInputName() {
    return _isReadOnly
        ? Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Text('(소개자명: ${_nameController.text})'),
        )
        : CustomTextFormField(
          controller: _recommendedController,
          hintText: '소개자 이름',
          readOnly: _isReadOnly,
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

  Widget _registrationButton(BuildContext context) {
    return RenderFilledButton(
      backgroundColor: _isReadOnly ? Colors.grey : null,
      onPressed:
          _isReadOnly
              ? () {}
              : () async {
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
        ConfirmBoxText(
          text: widget.customerModel == null ? '신규등록 확인' : '수정내용 확인',
          size: 20,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ConfirmBoxText(
                text: '등록자: ',
                text2: ' ${_nameController.text} ($_sex)',
              ),
              ConfirmBoxText(
                text: '생년월일: ',
                text2:
                    ' ${_birthController.text.isEmpty ? "추후입력" : _birth?.formattedDate}',
              ),
              ConfirmBoxText(
                text: '소개자: ',
                text2:
                    _recommendedController.text.isEmpty
                        ? "없음"
                        : _recommendedController.text,
              ),
              if (widget.customerModel == null)
                ConfirmBoxText(text2: _historyController.text),
            ],
          ),
        ),
        height(5),
        RenderFilledButton(
          onPressed: () {
            final customerMap = CustomerModel.toMapForCreateCustomer(
              customerKey:
                  widget.customerModel == null
                      ? generateCustomerKey('user1')
                      : widget.customerModel!.customerKey,
              name: _nameController.text,
              sex: _sex!,
              recommender: _recommendedController.text,
              birth: _birth,
            );
            final historyMap = HistoryModel.toMapForHistory(
              content: _historyController.text,
            );
            widget.customerModel == null
                ? viewModel.onEvent(
                  RegistrationEvent.registerCustomer(
                    customerData: customerMap,
                    historyData: historyMap,
                  ),
                )
                : viewModel.onEvent(
                  RegistrationEvent.updateCustomer(customerData: customerMap),
                );

            context.pop(true);
            context.pop();
          },
          text: widget.customerModel == null ? '등록' : '수정',
        ),
      ],
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
