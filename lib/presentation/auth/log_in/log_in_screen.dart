import 'package:firebase_auth/firebase_auth.dart';
import 'package:withme/core/presentation/widget/reset_password.dart';
import 'package:withme/core/presentation/widget/show_overlay_snack_bar.dart';

import '../../../core/presentation/core_presentation_import.dart';
import '../../../core/router/router_import.dart';
import '../../../core/ui/core_ui_import.dart';
import '../../../domain/domain_import.dart';

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
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      final user = credential.user;

      if (user != null && user.emailVerified) {
        debugPrint('로그인 성공, uid: ${user.uid}');
        authChangeNotifier.setLoggedIn(true); // 로그인 상태 갱신
        if (!mounted) return;

        context.go(RoutePath.splash);
      } else {
        _showErrorMessage('이메일 인증을 완료해주세요.');
      }
    } on FirebaseAuthException catch (e) {
      final error = LoginError.fromCode(e.code);
      if (error == LoginError.userDisabled && mounted) {
        _showDisabledAccountDialog(context);
        return;
      }
      _showErrorMessage(error.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showDisabledAccountDialog(BuildContext context) {
    showConfirmDialog(
      context,
      text:
          '이 계정은 사용 중지되었습니다.'
          '\n관리자에게 문의해 주세요.\n\n[문의] $adminEmail',
      cancelButtonText: '',
      onConfirm: null,
    );
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
                Row(
                  children: [
                    const Spacer(),
                    GestureDetector(
                      onTap: () async {
                        await resetPassword(
                          email: _emailController.text,
                          onResult: (message) {
                            if (!mounted) return;
                            showOverlaySnackBar(context, message);
                          },
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.lock_reset,
                            color: ColorStyles.menuButtonColor,
                            size: 20,
                          ),
                          width(3),
                          Text(
                            '비밀번호 재설정',
                            style: TextStyles.bold12.copyWith(
                              color: ColorStyles.menuButtonColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                RenderFilledButton(
                  text: _isLoading ? '로그인 중...' : '로그인',
                  foregroundColor: Colors.white,
                  backgroundColor:
                      _isFormValid
                          ? ColorStyles.menuButtonColor
                          : Colors.grey[300],
                  onPressed: _isFormValid && !_isLoading ? _login : null,
                ),
                height(20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyles.bold16,
                    ),
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
