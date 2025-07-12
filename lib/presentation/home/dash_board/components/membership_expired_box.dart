import '../../../../core/presentation/core_presentation_import.dart';

class MembershipExpiredBox extends StatelessWidget {
  const MembershipExpiredBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning, color: Colors.red),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              '유료회원 서비스가 만료되어 고객 추가 등록이 불가합니다.\n멤버십을 갱신해주세요.',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
