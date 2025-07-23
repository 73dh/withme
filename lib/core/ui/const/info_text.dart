import '../../presentation/core_presentation_import.dart';
import 'free_count.dart';

const String adminEmail='kdaehee@gmail.com';

final Widget styledInfoText = Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const Text(
      'App소개',
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
    height(20), // 제목과 본문 사이 간격
    const Text.rich(
      TextSpan(
        style: TextStyle(fontSize: 14, height: 1.5, color: Colors.black),
        children: [
          TextSpan(text: '이 앱은 가망고객을 발굴한 후,\n고객을 손쉽게 체계적으로 관리할수 있습니다.\n\n'),
          TextSpan(text: '관리주기를 설정하여 고객관리를 놓치는 일이 없도록 하였으며,\n\n'),
          TextSpan(
            text:
                '생일, 상령일, 미관리 고객등을 선별해 볼수도 있고, 계약자의 경우 계약내용까지 관리가 가능하도록 하였습니다.\n\n',
          ),
          TextSpan(text: '무료회원은 '),
          TextSpan(
            text: '$freeCount명',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
          ),
          TextSpan(
            text:
                '까지 사용이 가능하며, \n이상의 고객을 등록하여 관리하기 위해서는 유료회원 가입후 사용이 가능합니다.\n\n',
          ),
          TextSpan(
            text: 'Dashboard 화면에서는 현재 관리중인 가망고객이나 계약자의 통계를 확인할 수 있으며,\n\n',
          ),
          TextSpan(
            text: '유료회원의 경우에는 등록되어 있는 고객의 정보를 Excel로 받을수 있도록 하였습니다.\n\n\n',
          ),
          TextSpan(text: '문의: $adminEmail'),
        ],
      ),
    ),
  ],
);
