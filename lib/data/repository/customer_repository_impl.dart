import 'dart:async';

import 'package:withme/core/utils/transformers.dart';
import 'package:withme/data/data_source/remote/fbase.dart';
import 'package:withme/domain/model/customer_model.dart';
import 'package:withme/domain/repository/customer_repository.dart';

import '../../domain/model/history_model.dart';

class CustomerRepositoryImpl with Transformers implements CustomerRepository {
  final FBase fBase;

  CustomerRepositoryImpl({required this.fBase});

  @override
  Future<void> registerCustomer({
    required String userKey,
    required Map<String, dynamic> customerData,
    required Map<String, dynamic> historyData,
  }) async {
    await fBase.registerCustomer(
      userKey: userKey,
      customerData: customerData,
      historyData: historyData,
    );
  }

  @override
  Stream<List<CustomerModel>> getPools() {
    return fBase.getPools().transform(toPools);
  }

  @override
  Stream<List<HistoryModel>> fetchHistories({required String customerKey}) {
    return fBase.fetchHistories(customerKey: customerKey).transform(toHistories);
  }

  @override
  Future<void> addHistory(HistoryModel history) {
    // TODO: implement addHistory
    throw UnimplementedError();
  }


}
