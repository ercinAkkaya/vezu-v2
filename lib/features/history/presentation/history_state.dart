part of "history_cubit.dart";

enum HistoryStatus { initial, loading, success, failure }

class HistoryState extends Equatable {
  const HistoryState({
    this.status = HistoryStatus.initial,
    this.combinations = const [],
    this.errorKey,
  });

  final HistoryStatus status;
  final List<HistoryCombination> combinations;
  final String? errorKey;

  HistoryState copyWith({
    HistoryStatus? status,
    List<HistoryCombination>? combinations,
    String? errorKey,
    bool resetError = false,
  }) {
    return HistoryState(
      status: status ?? this.status,
      combinations: combinations ?? this.combinations,
      errorKey: resetError ? null : errorKey ?? this.errorKey,
    );
  }

  @override
  List<Object?> get props => [status, combinations, errorKey];
}


