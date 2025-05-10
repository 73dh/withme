import '../../../domain/model/history_model.dart';

sealed class PoolEvent {
factory PoolEvent.addHistory({required String customerKey,required Map<String,dynamic> historyData})=AddHistory;


}

class AddHistory implements PoolEvent{
  final String customerKey;
  final  Map<String,dynamic> historyData;

  AddHistory({required this.customerKey, required this.historyData});



}