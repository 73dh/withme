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
  Future<void> updateCustomer({
    required String userKey,
    required Map<String, dynamic> customerData,
  }) async {
    await fBase.updateCustomer(
      userKey: userKey,
      customerData: customerData,
    );
  }

  @override
  Stream<List<CustomerModel>> getPools() {
    return fBase.getPools().transform(toPools);
  }

  @override
  Stream<List<HistoryModel>> fetchHistories({required String customerKey}) {
    return fBase
        .fetchHistories(customerKey: customerKey)
        .transform(toHistories);
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
}
