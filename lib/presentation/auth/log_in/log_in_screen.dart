import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:withme/core/presentation/components/custom_text_form_field.dart';
import 'package:withme/core/presentation/components/render_filled_button.dart';
import 'package:withme/core/presentation/components/width_height.dart';
import 'package:withme/core/ui/color/color_style.dart';
import 'package:withme/core/ui/text_style/text_styles.dart';

import '../../../core/di/setup.dart';
import '../../../core/presentation/core_presentation_import.dart';
import '../../../core/router/router_import.dart';
import '../../home/customer_list/customer_list_view_model.dart';
import '../../home/prospect_list/prospect_list_view_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:withme/core/presentation/components/custom_text_form_field.dart';
import 'package:withme/core/presentation/components/render_filled_button.dart';
import 'package:withme/core/presentation/components/width_height.dart';
import 'package:withme/core/ui/color/color_style.dart';
import 'package:withme/core/ui/text_style/text_styles.dart';

import '../../../core/presentation/core_presentation_import.dart';
import '../../../core/router/router_import.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:withme/core/presentation/components/custom_text_form_field.dart';
import 'package:withme/core/presentation/components/render_filled_button.dart';
import 'package:withme/core/presentation/components/width_height.dart';
import 'package:withme/core/ui/color/color_style.dart';
import 'package:withme/core/ui/text_style/text_styles.dart';

import '../../../core/presentation/core_presentation_import.dart';
import '../../../core/router/router_import.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:withme/core/presentation/components/custom_text_form_field.dart';
import 'package:withme/core/presentation/components/render_filled_button.dart';
import 'package:withme/core/presentation/components/width_height.dart';
import 'package:withme/core/ui/color/color_style.dart';
import 'package:withme/core/ui/text_style/text_styles.dart';

import '../../../core/presentation/core_presentation_import.dart';
import '../../../core/router/router_import.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isFormValid = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
  }

  void _validateForm() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final isEmailValid = email.isNotEmpty && email.contains('@');
    final isPasswordValid = password.length >= 6;

    final isValid = isEmailValid && isPasswordValid;

    if (_isFormValid != isValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;
      context.go(RoutePath.splash);
    } on FirebaseAuthException catch (e) {
      _showErrorMessage(_firebaseErrorMessage(e));
    } catch (e) {
      _showErrorMessage('오류가 발생했습니다: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) renderSnackBar(context, text: message);
  }

  String _firebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return '등록되지 않은 이메일입니다.';
      case 'invalid-email':
        return '이메일 형식이 잘못되었습니다.';
      case 'wrong-password':
        return '비밀번호가 일치하지 않습니다.';
      case 'invalid-credential':
        return '인증 정보가 유효하지 않거나 만료되었습니다.';
      case 'too-many-requests':
        return '잠시 후 다시 시도해 주세요.';
      default:
        return '로그인 실패: ${e.message ?? e.code}';
    }
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
                    'Welcome back!\nLog in to manage your customers.',
                    style: TextStyles.bold20,
                  ),
                ),
                height(60),
                CustomTextFormField(
                  controller: _emailController,
                  labelText: 'Email',
                  hintText: 'email@gmail.com',
                  inputType: TextInputType.emailAddress,
                  onChanged: (_) => _validateForm(),
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
                  onChanged: (_) => _validateForm(),
                  validator: (value) {
                    if (value.length < 6) return '최소 6자 이상 입력하세요.';
                    return null;
                  },
                ),
                height(30),
                RenderFilledButton(
                  text: _isLoading ? '로그인 중...' : '로그인',
                  foregroundColor: Colors.white,
                  backgroundColor:
                  _isFormValid ? ColorStyles.menuButtonColor : Colors.grey[300],
                  onPressed: _isFormValid && !_isLoading ? _login : null,
                ),
                height(20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?", style: TextStyles.bold16),
                    GestureDetector(
                      onTap: () => context.go(RoutePath.signUp),
                      child: Text(
                        ' 회원가입',
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
