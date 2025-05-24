import '../../model/customer_model.dart';

abstract class FilterNoBirthUseCase {
  static Future<List<CustomerModel>> call(List<CustomerModel> customers) async {
    return customers.where((customer) => customer.birth == null).toList();
  }
}