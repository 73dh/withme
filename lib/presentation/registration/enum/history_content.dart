enum HistoryContent {
  title,
  generation,
  initContact,
  needsAssessment,
  presentation,
  proposal,
  etc;

  @override
  String toString() => switch (this) {
    HistoryContent.title => '(상담) 이력을 선택 하세요.',
    HistoryContent.generation => '고객 발굴(등록)',
    HistoryContent.initContact => '초기 면담 또는 통화',
    HistoryContent.needsAssessment => '고객 니즈 평가, 분석',
    HistoryContent.presentation => '상품 등 설명',
    HistoryContent.proposal => '구체적 제안',
    HistoryContent.etc => '직접 입력',
  };
}
