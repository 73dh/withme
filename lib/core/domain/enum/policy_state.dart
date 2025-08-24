enum PolicyStatus {
  keep('정상'),
  lapsed('실효'),
  cancelled('해지'),
  fired('철회 or 반송');

  final String label; // UI 한글 라벨
  const PolicyStatus(this.label);
}
