import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:withme/core/presentation/components/width_height.dart';
import 'package:withme/core/router/router_path.dart';
import 'package:withme/core/ui/theme/theme.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  bool _isVerifying = false;
  bool _isResending = false;

  Future<void> _checkVerification() async {
    setState(() => _isVerifying = true);
    try {
      await user?.reload();
      final refreshedUser = FirebaseAuth.instance.currentUser;

      if (refreshedUser?.emailVerified == true && mounted) {
        context.go(RoutePath.splash);
      } else {
        _showSnackBar('이메일 인증이 완료되지 않았습니다.');
      }
    } catch (e) {
      _showSnackBar('인증 확인 중 오류 발생: $e');
    } finally {
      setState(() => _isVerifying = false);
    }
  }

  Future<void> _resendEmail() async {
    setState(() => _isResending = true);
    try {
      await user?.sendEmailVerification();
      _showSnackBar('인증 메일을 다시 보냈습니다.');
    } catch (e) {
      _showSnackBar('메일 재전송 실패: $e');
    } finally {
      setState(() => _isResending = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final email = user?.email ?? '이메일 없음';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          '이메일 인증',
          style: textTheme.titleLarge?.copyWith(color: colorScheme.onSurface),
        ),
        backgroundColor: colorScheme.surface,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '이메일 인증을 완료해주세요',
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            height(12),
            Text(
              '회원가입 시 입력한 이메일 주소로 인증 메일을 보냈습니다.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface80,
              ),
            ),
            height(4),
            Text(
              '📬 $email',
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            height(24),
            Text(
              '이메일의 링크를 클릭한 후 아래 버튼을 눌러주세요.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface80,
              ),
            ),
            height(32),

            // 이메일 인증 완료 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  textStyle: textTheme.labelLarge,
                ),
                onPressed: _isVerifying ? null : _checkVerification,
                child:
                    _isVerifying
                        ? CircularProgressIndicator(
                          color: colorScheme.onPrimary,
                        )
                        : const Text('이메일 인증 완료'),
              ),
            ),
            height(16),

            // 인증 메일 재전송
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                  textStyle: textTheme.labelLarge,
                  side: BorderSide(color: colorScheme.primary),
                ),
                onPressed: _isResending ? null : _resendEmail,
                child:
                    _isResending
                        ? CircularProgressIndicator(color: colorScheme.primary)
                        : const Text('인증 메일 다시 보내기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
