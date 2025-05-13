import '../../../domain/model/history_model.dart';

sealed class ProspectEvent {
  factory ProspectEvent.addHistory({
    required String customerKey,
    required Map<String, dynamic> historyData,
  }) = AddHistory;
}

class AddHistory implements ProspectEvent {
  final String customerKey;
  final Map<String, dynamic> historyData;

  AddHistory({required this.customerKey, required this.historyData});
}
