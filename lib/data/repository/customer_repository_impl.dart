import 'dart:async';

import 'package:withme/data/data_source/remote/fbase.dart';
import 'package:withme/domain/model/customer_model.dart';
import 'package:withme/domain/repository/customer_repository.dart';

import '../../core/utils/transformers.dart';

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
  Future<void> updateCustomer({
    required String userKey,
    required Map<String, dynamic> customerData,
  }) async {
    await fBase.updateCustomer(userKey: userKey, customerData: customerData);
  }

  @override
  Stream<List<CustomerModel>> getAll() {
    fBase.getAll().transform(toPools).listen((data){
      print('pools length: ${data.length}');
    });
    return fBase.getAll().transform(toPools);
  }

  // @override
  // Stream<List<HistoryModel>> getHistories({required String customerKey}) {
  //   return fBase.getHistories(customerKey: customerKey).transform(toHistories);
  // }
  //
  // @override
  // Future<void> addHistory({
  //   required String userKey,
  //   required String customerKey,
  //   required Map<String, dynamic> historyData,
  // }) async {
  //   return await fBase.addHistory(
  //     userKey: userKey,
  //     customerKey: customerKey,
  //     historyData: historyData,
  //   );
  // }

  @override
  Future<void> deleteCustomer({required String customerKey}) async {
    return await fBase.deleteCustomer(customerKey: customerKey);
  }
}
