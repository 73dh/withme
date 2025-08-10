import 'package:withme/core/presentation/widget/show_overlay_snack_bar.dart';

import '../core_presentation_import.dart';

Future<void> showCycleEditDialog(
  BuildContext context, {
  required String title,
  required int initNumber, // 현재 주기를 인자로 받도록 변경
  required ValueChanged<int> onUpdate, // 업데이트 콜백 추가
}) async {
  final controller = TextEditingController(
    text: initNumber.toString(), // 현재 주기를 초기값으로 설정
  );

  await showDialog(
    context: context,
    builder: (dialogContext) {
      // 다이얼로그 내부의 BuildContext를 명확히 구분
      return Dialog(
        backgroundColor: Colors.transparent, // CommonConfirmDialog와 동일한 투명 배경
        child: SizedBox(
          width: 180,
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100, // CommonConfirmDialog와 동일한 배경색
                  border: Border.all(color: Colors.grey.shade500, width: 1.2),
                  borderRadius: BorderRadius.circular(
                    10,
                  ), // CommonConfirmDialog와 동일한 둥근 모서리
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // 내용에 따라 높이 조절
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 20.0,
                        left: 12,
                        right: 12,
                      ),
                      child: Column(
                        // 제목과 내용을 세로로 배치하기 위한 Column
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          height(10), // 제목과 TextField 사이 간격
                          TextField(
                            controller: controller,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: '(예: 60)',
                              hintText: '1 이상의 숫자를 입력하세요',
                              // 힌트 텍스트 추가
                              border: OutlineInputBorder(),
                              isDense: true,
                              // 입력 필드 높이 조절
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 10,
                              ),
                            ),
                            autofocus: true,
                            // 다이얼로그 열릴 때 자동으로 키보드 올리기
                            textAlign: TextAlign.center, // 텍스트 중앙 정렬
                          ),
                        ],
                      ),
                    ),
                    height(20), // 내용과 버튼 사이 간격
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      // 버튼들을 중앙에 정렬
                      children: [
                        // 취소 버튼
                        FilledButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.grey, // 취소 버튼은 회색
                            minimumSize: const Size(80, 40), // 버튼 최소 크기 지정
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8), // 둥근 모서리
                            ),
                          ),
                          child: const Text('취소'),
                        ),
                        width(10), // 버튼 사이 간격
                        // 저장 버튼
                        FilledButton(
                          onPressed: () {
                            final input = int.tryParse(
                              controller.text.trim(),
                            ); // 공백 제거
                            if (input != null && input > 0) {
                              onUpdate(input); // 콜백을 통해 새로운 값을 전달

                              if (dialogContext.mounted) {
                                Navigator.of(dialogContext).pop(); // 다이얼로그 닫기
                                showOverlaySnackBar(context, '설정이 저장되었습니다.');
                              }
                            } else {
                              showOverlaySnackBar(
                                context,
                                '올바른 숫자를 입력해주세요 (1 이상).',
                              );
                            }
                          },
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(80, 40), // 버튼 최소 크기 지정
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8), // 둥근 모서리
                            ),
                          ),
                          child: const Text('저장'),
                        ),
                      ],
                    ),
                    height(10), // 하단 여백
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
