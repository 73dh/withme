enum HistoryContent {
  title,
  initContact,
  needsAssessment,
  presentation,
  proposal,
  etc;

  @override
  String toString() => switch (this) {
    HistoryContent.title => '관리내용을 선택 하세요.',
    HistoryContent.initContact => '안부 전화, 문자',
    HistoryContent.needsAssessment => '니즈 확인, 보장분석',
    HistoryContent.presentation => '상품, 보장내용 등 설명',
    HistoryContent.proposal => '상품 등 제안',
    HistoryContent.etc => '직접 입력',
  };
}
