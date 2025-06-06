class ProspectListState {
  final bool hasLoadedOnce;
  final bool isLoading;

  ProspectListState({this.hasLoadedOnce = false, this.isLoading = false});

  ProspectListState copyWith({bool? hasLoadedOnce, bool? isLoading}) {
    return ProspectListState(
      hasLoadedOnce: hasLoadedOnce ?? this.hasLoadedOnce,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
