import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:withme/core/domain/error_handling/signup_error.dart';
import 'package:withme/core/presentation/components/custom_text_form_field.dart';
import 'package:withme/core/presentation/components/render_filled_button.dart';
import 'package:withme/core/presentation/components/width_height.dart';
import 'package:withme/core/presentation/core_presentation_import.dart';
import 'package:withme/core/presentation/widget/show_agreement_dialog.dart';
import 'package:withme/core/presentation/widget/show_overlay_snack_bar.dart';

import '../../../core/di/setup.dart';
import '../../../core/router/router_import.dart';
import '../../../core/ui/color/color_style.dart';
import '../../../core/ui/core_ui_import.dart';
import '../../../core/ui/text_style/text_styles.dart';
import '../../home/customer_list/customer_list_view_model.dart';
import '../../home/prospect_list/prospect_list_view_model.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isChecked = false;
  bool _isLoading = false;
  String? _agreedDateTime;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_isChecked) {
      showOverlaySnackBar(context, '회원가입 동의를 선택해주세요.');
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      final user = userCredential.user;

      // ✅ 온보딩 상태 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboardingComplete', false);

      // 이메일 인증 요청
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }

      // 이메일 인증 화면으로 이동
      if (mounted) {
        context.go(RoutePath.verifyEmail);
      }
    } on FirebaseAuthException catch (e) {
      final error = SignUpError.fromCode(e.code);

      _showErrorMessage(error.toString());
    } catch (e) {
      _showErrorMessage(SignUpError.unknownError.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) showOverlaySnackBar(context, message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                height(50),
                const SizedBox(
                  width: 200,
                  child: Text(
                    'Welcome to withMe,\nthe app for managing your customers!',
                    style: TextStyles.bold20,
                  ),
                ),
                height(60),
                CustomTextFormField(
                  controller: _emailController,
                  labelText: 'Email',
                  hintText: 'email@gmail.com',
                  inputType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value.isEmpty) return '이메일을 입력하세요.';
                    if (!value.contains('@')) return '이메일 형식을 확인하세요.';
                    return null;
                  },
                ),
                CustomTextFormField(
                  controller: _passwordController,
                  labelText: 'Password',
                  hintText: 'Enter Password',
                  obscureText: true,
                  validator: (value) {
                    if (value.length < 6) return '최소 6자 이상 입력하세요.';
                    return null;
                  },
                ),
                CustomTextFormField(
                  controller: _confirmPasswordController,
                  labelText: 'Confirm Password',
                  hintText: 'Retype Password',
                  obscureText: true,
                  validator: (value) {
                    if (value.isEmpty) return '비밀번호를 입력하세요.';
                    if (value != _passwordController.text) {
                      return '비밀번호가 일치하지 않습니다.';
                    }
                    return null;
                  },
                ),
                height(30),
                Row(
                  children: [
                    GestureDetector(
                      onTap:
                          () => showAgreementDialog(
                            context,
                            onPressed: () {
                              setState(() {
                                _isChecked = true;
                                _agreedDateTime = DateFormat(
                                  'yyyy-MM-dd HH:mm',
                                ).format(DateTime.now());
                              });
                              Navigator.of(context).pop();
                            },
                          ),
                      child: Text(
                        '약관확인',
                        style: TextStyles.bold14.copyWith(
                          color: ColorStyles.menuButtonColor,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    width(10),
                    _isChecked
                        ? Text(
                          '동의일시: $_agreedDateTime',
                          style: TextStyles.normal14.copyWith(
                            color: Colors.grey[700],
                          ),
                        )
                        : const Text('미동의'),
                  ],
                ),
                height(20),
                RenderFilledButton(
                  text: '회원가입',
                  foregroundColor: _isChecked ? Colors.white : Colors.grey,
                  backgroundColor:
                      _isChecked
                          ? ColorStyles.menuButtonColor
                          : Colors.grey[300],
                  onPressed: _isChecked ? _signUp : null,
                ),
                height(20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already a member?", style: TextStyles.bold16),
                    GestureDetector(
                      onTap: () => context.go(RoutePath.login),
                      child: Text(
                        ' 로그인',
                        style: TextStyles.bold16.copyWith(
                          color: ColorStyles.menuButtonColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
