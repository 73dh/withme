enum PolicyState {
  keep('유지'),
  cancelled('해지'),
  lapsed('실효');

  final String label; // UI 한글 라벨
  const PolicyState(this.label);
}