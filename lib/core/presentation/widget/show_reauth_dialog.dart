import '../../ui/core_ui_import.dart';
import '../core_presentation_import.dart';
Future<Map<String, String>?> showReauthDialog(BuildContext context) async {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  return showDialog<Map<String, String>>(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border.all(color: Colors.grey.shade500, width: 1.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                 const Text(
                  '이메일과 비밀번호를 인증합니다.',
                  textAlign: TextAlign.center,style: TextStyles.bold16,
                ),
                height(20),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: '이메일',
                    border: OutlineInputBorder(),
                  ),
                ),
                height(10),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: '비밀번호',
                    border: OutlineInputBorder(),
                  ),
                ),
                height(20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilledButton(
                      onPressed: () {
                        Navigator.of(context).pop({
                          'email': emailController.text.trim(),
                          'password': passwordController.text.trim(),
                        });
                      },
                      child: const Text('확인'),
                    ),
                    width(10),
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(null),
                      child: const Text('취소'),
                    ),
                  ],
                ),
                height(10),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
