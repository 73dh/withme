import 'package:withme/core/utils/transformers.dart';
import 'package:withme/domain/model/history_model.dart';
import 'package:withme/domain/repository/history_repository.dart';

import '../data_source/remote/fbase.dart';

class HistoryRepositoryImpl with Transformers implements HistoryRepository {
  final FBase fBase;

  HistoryRepositoryImpl({required this.fBase});
  @override
  Stream<List<HistoryModel>> getHistories({required String customerKey}) {
    return fBase.getHistories(customerKey: customerKey).transform(toHistories);
  }

  @override
  Future<void> addHistory({
    required String userKey,
    required String customerKey,
    required Map<String, dynamic> historyData,
  }) async {
    return await fBase.addHistory(
      userKey: userKey,
      customerKey: customerKey,
      historyData: historyData,
    );
  }

  @override
  Future<List<HistoryModel>> getCustomerHistories({required String customerKey}) async{
   return (await fBase.getCustomerHistories(customerKey: customerKey)).docs.map((e)=>HistoryModel.fromSnapshot(e)).toList();
  }

}