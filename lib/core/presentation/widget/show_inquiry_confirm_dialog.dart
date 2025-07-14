import '../core_presentation_import.dart';

Future<bool?> showInquiryConfirmDialog(
  BuildContext context, {
  required String title,
  required String content,
      bool? isShowButton=true,
}) {
  return showDialog<bool?>(
    // showDialog의 반환 타입을 명시적으로 bool?로 지정
    context: context,
    builder: (dialogContext) {
      // 다이얼로그 내부의 BuildContext를 명확히 구분
      return Dialog(
        backgroundColor: Colors.transparent, // CommonConfirmDialog와 동일한 투명 배경
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
                crossAxisAlignment: CrossAxisAlignment.center, // ✅ 중앙 정렬
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
                        height(15), // 제목과 내용 사이 간격
                        Text(content,textAlign: TextAlign.center, ),
                      ],
                    ),
                  ),
                  if(isShowButton==true)   height(20), // 내용과 버튼 사이 간격
                  if(isShowButton==true)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center, // 버튼들을 중앙에 정렬
                    children: [
                      // 취소 버튼
                      FilledButton(
                        onPressed: () {
                          Navigator.of(
                            dialogContext,
                          ).pop(false); // '취소' 시 false 반환
                        },
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
                      // 확인 버튼
                      FilledButton(
                        onPressed: () {
                          Navigator.of(
                            dialogContext,
                          ).pop(true); // '확인' 시 true 반환
                        },
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(80, 40), // 버튼 최소 크기 지정
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), // 둥근 모서리
                          ),
                        ),
                        child: const Text('확인'),
                      ),
                    ],
                  ),
                  height(10), // 하단 여백
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
