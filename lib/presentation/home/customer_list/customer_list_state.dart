class CustomerListState {
  final bool hasLoadedOnce;
  final bool isLoading;

  CustomerListState({this.hasLoadedOnce = false, this.isLoading = false});

  CustomerListState copyWith({bool? hasLoadedOnce, bool? isLoading}) {
    return CustomerListState(
      hasLoadedOnce: hasLoadedOnce ?? this.hasLoadedOnce,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}