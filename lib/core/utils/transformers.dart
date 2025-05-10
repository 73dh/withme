import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:withme/domain/model/history_model.dart';

import '../../domain/model/customer_model.dart';

mixin class Transformers {
  final toPools = StreamTransformer<
    QuerySnapshot<Map<String, dynamic>>,
    List<CustomerModel>
  >.fromHandlers(
    handleData: (snapshot, sink) {
      List<CustomerModel> pools = [];
      for (var documentSnapshot in snapshot.docs) {
        pools.add(CustomerModel.fromSnapshot(documentSnapshot));
      }
      pools.sort((a, b) => a.registeredDate.compareTo(b.registeredDate));
      sink.add(pools);
    },
  );

  final toHistories = StreamTransformer<
    QuerySnapshot<Map<String, dynamic>>,
    List<HistoryModel>
  >.fromHandlers(
    handleData: (snapshot, sink) {
      List<HistoryModel> histories = [];
      for (var documentSnapshot in snapshot.docs) {
        histories.add(HistoryModel.fromSnapshot(documentSnapshot));
      }
      sink.add(histories);
    },
  );
}
