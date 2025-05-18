sealed class ProspectListEvent {
  factory ProspectListEvent.addHistory({
    required String customerKey,
    required Map<String, dynamic> historyData,
  }) = AddHistory;
}

class AddHistory implements ProspectListEvent {
  final String customerKey;
  final Map<String, dynamic> historyData;

  AddHistory({required this.customerKey, required this.historyData});
}
