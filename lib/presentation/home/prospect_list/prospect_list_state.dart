import '../../../domain/domain_import.dart';

class ProspectListState {
  final List<CustomerModel> cachedProspects;
  final bool hasLoadedOnce;
  final bool isLoading;

  ProspectListState({
     this.cachedProspects=const [],
     this.hasLoadedOnce=false,
     this.isLoading=false,
  });

  ProspectListState copyWith({
    List<CustomerModel>? cachedProspects,
    bool? hasLoadedOnce,
    bool? isLoading,
  }) {
    return ProspectListState(
      cachedProspects: cachedProspects ?? this.cachedProspects,
      hasLoadedOnce: hasLoadedOnce ?? this.hasLoadedOnce,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
