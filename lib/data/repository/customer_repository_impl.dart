import 'dart:async';

import 'package:withme/data/data_source/remote/fbase.dart';
import 'package:withme/domain/model/customer_model.dart';
import 'package:withme/domain/repository/customer_repository.dart';

import '../../core/utils/transformers/transformers.dart';

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
  Stream<List<CustomerModel>> getAll({required String userKey}) {
    return fBase.getAll(userKey: userKey).transform(toPools);
  }
  // @override
  // Future<List<CustomerModel>> getAll({required String userKey}) {
  //   return fBase.getAll(userKey: userKey);
  // }

  @override
  Future<void> deleteCustomer({required String userKey, required String customerKey}) async {
    return await fBase.deleteCustomer(userKey: userKey, customerKey: customerKey);
  }

  @override
  Future<List<CustomerModel>> getEditedAll({required String userKey})async {
   return await fBase.getEditedAll(userKey: userKey);
  }
}
