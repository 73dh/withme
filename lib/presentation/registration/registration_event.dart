sealed class RegistrationEvent {
  factory RegistrationEvent.registerCustomer({
    required Map<String, dynamic> customerData,
    required Map<String, dynamic> historyData,
  }) = RegisterCustomer;

  factory RegistrationEvent.updateCustomer({
    required Map<String, dynamic> customerData,
  }) = UpdateCustomer;

factory RegistrationEvent.deleteCustomer({required String customerKey})=DeleteCustomer;
}

class RegisterCustomer implements RegistrationEvent {
  final Map<String, dynamic> customerData;
  final Map<String, dynamic> historyData;

  RegisterCustomer({required this.customerData, required this.historyData});
}

class UpdateCustomer implements RegistrationEvent {
  final Map<String, dynamic> customerData;

  UpdateCustomer({required this.customerData});
}

class DeleteCustomer implements RegistrationEvent{
  final String customerKey;

  DeleteCustomer({required this.customerKey});
}


