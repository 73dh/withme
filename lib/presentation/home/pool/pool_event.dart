import '../../../domain/model/history_model.dart';

sealed class PoolEvent {
factory PoolEvent.addHistory(HistoryModel history)=AddHistory;


}

class AddHistory implements PoolEvent{
  final HistoryModel history;

  AddHistory(this.history);

}