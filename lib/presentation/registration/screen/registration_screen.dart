import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/core/utils/core_utils_import.dart';
import 'package:withme/domain/model/customer_model.dart';
import 'package:withme/domain/model/history_model.dart';
import 'package:withme/presentation/registration/components/add_policy_button.dart';
import 'package:withme/presentation/registration/components/birth_selector.dart';
import 'package:withme/presentation/registration/components/delete_icon.dart';
import 'package:withme/presentation/registration/components/edit_toggle_icon.dart';
import 'package:withme/presentation/registration/components/name_field.dart';
import 'package:withme/presentation/registration/components/registered_date_selector.dart';
import 'package:withme/presentation/registration/components/sex_selector.dart';
import 'package:withme/presentation/registration/registration_event.dart';
import 'package:withme/presentation/registration/registration_view_model.dart';

import '../../../core/di/setup.dart';
import '../../../core/domain/core_domain_import.dart';
import '../../../core/presentation/core_presentation_import.dart';
import '../../../core/router/router_path.dart';
import '../../../core/ui/core_ui_import.dart';

class RegistrationScreen extends StatefulWidget {
  final CustomerModel? customerModel;

  const RegistrationScreen({super.key, this.customerModel});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _recommendedController = TextEditingController();
  final _historyController = TextEditingController(text: '신규등록');
  final _birthController = TextEditingController();
  final _registeredDateController = TextEditingController();

  bool _isReadOnly = false;
  bool _isRecommended = false;
  DateTime? _birth;
  String? _sex;

  final viewModel = getIt<RegistrationViewModel>();

  @override
  void initState() {
    super.initState();
    _initializeCustomer();
  }

  void _initializeCustomer() {
    final customer = widget.customerModel;
    _registeredDateController.text = DateTime.now().formattedDate;
    if (customer != null) {
      _isReadOnly = true;
      _nameController.text = customer.name;
      _sex = customer.sex;
      _birth = customer.birth;
      _birthController.text = customer.birth.toString();
      _registeredDateController.text = customer.registeredDate.toString();
      if (customer.recommended.isNotEmpty) {
        _isRecommended = true;
        _recommendedController.text = customer.recommended;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _recommendedController.dispose();
    _historyController.dispose();
    _birthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildForm(),
        bottomSheet: !_isReadOnly ? _buildSubmitButton() : null,
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      actions: [
        EditToggleIcon(
          isReadOnly: _isReadOnly,
          onPressed: () => setState(() => _isReadOnly = !_isReadOnly),
        ),
        if (_isReadOnly)
          DeleteIcon(
            viewModel: viewModel,
            customerModel: widget.customerModel!,
          ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const TitleWidget(title: 'Registered Prospect'),
            height(20),
            const PartTitle(text: '가망고객'),
            _buildCustomerInfoPart(),
            height(15),
            const PartTitle(text: '소개자'),
            _buildRecommenderPart(),
            height(20),
            if (_isReadOnly)
              AddPolicyButton(customerModel: widget.customerModel!),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfoPart() {
    return PartBox(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildNameField(),
                const Spacer(),
                _buildSexSelector(),
              ],
            ),
            height(10),
            _buildBirthSelector(),
            height(10),
            _buildRegisteredDateSelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommenderPart() {
    return PartBox(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        child: Column(
          children: [
            _buildRecommenderSwitch(),
            if (_isRecommended) _buildRecommenderField(),
          ],
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return NameField(isReadOnly: _isReadOnly, nameController: _nameController);
  }

  Widget _buildSexSelector() {
    return SexSelector(
      sex: _sex,
      isReadOnly: _isReadOnly,
      onChanged: _isReadOnly ? null : (value) => setState(() => _sex = value),
    );
  }

  Widget _buildBirthSelector() {
    return BirthSelector(
      isReadOnly: _isReadOnly,
      birth: _birth,
      onInitPressed:
          _isReadOnly
              ? null
              : () => setState(() {
                _birth = null;
                _birthController.clear();
              }),
      onSetPressed:
          _isReadOnly
              ? null
              : () async {
                final date = await selectDate(context);
                if (date != null) {
                  setState(() {
                    _birth = date;
                    _birthController.text = date.toString();
                  });
                }
              },
    );
  }

  Widget _buildRegisteredDateSelector() {
    return RegisteredDateSelector(
      isReadOnly: _isReadOnly,
      registeredDate: DateTime.parse(_registeredDateController.text),
      onPressed:
          _isReadOnly
              ? null
              : () async {
                final date = await selectDate(context);
                if (date != null) {
                  setState(() {
                    _registeredDateController.text = date.formattedDate;
                  });
                }
              },
    );
  }

  Widget _buildRecommenderSwitch() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        '소개자 ${_isReadOnly ? '' : '(선택)'}',
        style: TextStyles.normal14,
      ),
      trailing: Switch.adaptive(
        value: _isRecommended,
        onChanged:
            _isReadOnly
                ? null
                : (val) => setState(() {
                  _isRecommended = val;
                  if (!val) _recommendedController.clear();
                }),
      ),
    );
  }

  Widget _buildRecommenderField() {
    return _isReadOnly
        ? Align(
          alignment: Alignment.centerLeft,
          child: Text(_recommendedController.text),
        )
        : CustomTextFormField(
          controller: _recommendedController,
          hintText: '소개자 이름',
          validator: (text) => text.isEmpty ? '소개자 이름을 입력하세요' : null,
          onSaved: (text) => _recommendedController.text = text.trim(),
        );
  }

  Widget _buildSubmitButton() {
    return RenderFilledButton(
      text: widget.customerModel == null ? '등록' : '수정',
      foregroundColor: ColorStyles.activeButtonColor,
      onPressed: () {
        if (_tryValidation()) {
          showModalBottomSheet(
            context: context,
            builder: (_) => _buildConfirmationBox(),
          );
        }
      },
    );
  }

  Widget _buildConfirmationBox() {
    return SizedBox(
      height: 280,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          height(5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MyCircularIndicator(),
              ConfirmBoxText(
                text: widget.customerModel == null ? '신규등록 확인' : '수정내용 확인',
                size: 18,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
                      _birthController.text.isEmpty
                          ? "추후입력"
                          : _birth?.formattedDate,
                ),
                ConfirmBoxText(
                  text: '소개자: ',
                  text2:
                      _recommendedController.text.isEmpty
                          ? "없음"
                          : _recommendedController.text,
                ),
                ConfirmBoxText(
                  text: '등록일: ',
                  text2:
                      DateTime.parse(
                        _registeredDateController.text,
                      ).formattedDate,
                ),
                if (widget.customerModel == null)
                  ConfirmBoxText(text2: _historyController.text),
              ],
            ),
          ),
          RenderFilledButton(
            text: widget.customerModel == null ? '등록' : '수정',
            onPressed: _submitForm,
            foregroundColor: Colors.white,
          ),
        ],
      ),
    );
  }

  bool _tryValidation() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (_nameController.text.isNotEmpty && _sex == null) {
      renderSnackBar(context, text: '성별을 선택 하세요');
      return false;
    }
    if (widget.customerModel == null &&
        _historyController.text == HistoryContent.title.toString()) {
      renderSnackBar(context, text: '상담 이력을 선택 하세요');
      return false;
    }
    if (isValid) {
      _formKey.currentState!.save();
      return true;
    }
    return false;
  }

  void _submitForm() async {
    final customerMap = CustomerModel.toMapForCreateCustomer(
      customerKey:
          widget.customerModel?.customerKey ?? generateCustomerKey('user1'),
      name: _nameController.text,
      sex: _sex!,
      recommender: _recommendedController.text,
      birth: _birth,
      registeredDate: DateTime.parse(_registeredDateController.text),
    );

    if (widget.customerModel == null) {
      final historyMap = HistoryModel.toMapForHistory(
        content: _historyController.text,
      );
      viewModel.onEvent(
        RegistrationEvent.registerCustomer(
          customerData: customerMap,
          historyData: historyMap,
        ),
      );
    } else {
      viewModel.onEvent(
        RegistrationEvent.updateCustomer(customerData: customerMap),
      );
    }
    await getIt<ProspectListViewModel>().refresh();
    if (mounted && context.canPop()) {
      context.pop(true);
      context.pop('true');
    }
  }
}
