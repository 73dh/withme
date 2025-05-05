import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:withme/core/utils/generate_customer_key.dart';
import 'package:withme/core/widget/custom_text_form_field.dart';
import 'package:withme/core/widget/width_height.dart';
import 'package:withme/data/data_source/remote/fbase.dart';
import 'package:withme/data/repository/customer_repository_impl.dart';
import 'package:withme/domain/model/customer.dart';
import 'package:withme/domain/repository/customer_repository.dart';
import 'package:withme/presentation/registration/enum/history_content.dart';

import '../../core/di/setup.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  TextEditingController _nameController = TextEditingController();
  TextEditingController _recommendedController = TextEditingController();
  TextEditingController _historyController = TextEditingController(
    text: HistoryContent.title.toString(),
  );

  final MenuController _menuController = MenuController();

  bool isPolicy = false;

  @override
  void dispose() {
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                height(20),
                const Text(
                  'Registration Customer in Pool',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                CustomTextFormField(
                  controller: _nameController,
                  hintText: '신규등록 이름',
                  onChanged: (text) {
                    setState(() {
                      _nameController.text = text.trim();
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
                ),
                height(5),
                SwitchListTile.adaptive(
                  value: isPolicy,
                  onChanged: (value) {
                    setState(() {
                      isPolicy = value;
                    });
                  },
                  title: const Text('소개자 여부'),
                  contentPadding: const EdgeInsets.only(left: 20),
                ),
                if (isPolicy)
                  CustomTextFormField(
                    controller: _nameController,
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
                  ),
                height(20),
                MenuAnchor(
                  controller: _menuController,
                  menuChildren:
                      HistoryContent.values.map((content) {

                        return MenuItemButton(
                          child: Text(content.toString()),
                          onPressed: () {
                            setState(() {

                              _historyController.text =
                                  content.toString().trim();
                              _menuController.close();
                            });
                          },
                        );
                      }).toList(),
                ),

                FilledButton(
                  onPressed: () {
                    if (_menuController.isOpen) {
                      _menuController.close();
                    } else {
                      _menuController.open();
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.grey,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(2)),
                    ),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 21.5),
                      child: Text(_historyController.text),
                    ),
                  ),
                ),
                height(10),
                if (_historyController.text == HistoryContent.etc.toString())
                  CustomTextFormField(
                    controller: _historyController,
                    hintText: '내용을 입력 하세요.',
                    autoFocus: true,
                    onChanged: (text) {
                      // setState(() {
                      //   _historyController.text = text.trim();
                      //   print(_historyController.text);
                      // });
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
                  ),
              ],
            ),
          ),
        ),
        bottomSheet: FilledButton(
          onPressed: () {
            final result = _tryValidation();
            if (result) {
              getIt<CustomerRepository>().registerCustomer(
                userKey: 'user1',
                customerData: Customer.toMapForCreateCustomer(
                  name: _nameController.text,
                ),
              );
              context.pop();
            }
          },
          style: FilledButton.styleFrom(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(2)),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: Text('등록', textAlign: TextAlign.center),
            ),
          ),
        ),
      ),
    );
  }

  bool _tryValidation() {
    final isValid = _formKey.currentState?.validate();
    if (isValid == true) {
      _formKey.currentState!.save();
      return true;
    }
    return false;
  }
}
