import "dart:async";

import "package:bloc/bloc.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:equatable/equatable.dart";
import "package:vezu/features/auth/presentation/cubit/auth_cubit.dart";

part "history_state.dart";

class HistoryCombination extends Equatable {
  const HistoryCombination({
    required this.id,
    required this.theme,
    required this.summary,
    required this.mood,
    required this.createdAt,
    required this.piecesCount,
    required this.primaryImageUrl,
  });

  final String id;
  final String theme;
  final String summary;
  final String? mood;
  final DateTime? createdAt;
  final int piecesCount;
  final String? primaryImageUrl;

  @override
  List<Object?> get props =>
      [id, theme, summary, mood, createdAt, piecesCount, primaryImageUrl];
}

class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit({
    required AuthCubit authCubit,
    FirebaseFirestore? firestore,
  })  : _authCubit = authCubit,
        _firestore = firestore ?? FirebaseFirestore.instance,
        super(const HistoryState());

  final AuthCubit _authCubit;
  final FirebaseFirestore _firestore;

  Future<void> loadHistory() async {
    final userId = _authCubit.state.user?.id;
    if (userId == null || userId.isEmpty) {
      emit(
        state.copyWith(
          status: HistoryStatus.success,
          combinations: const [],
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: HistoryStatus.loading,
        resetError: true,
      ),
    );

    try {
      final snapshot = await _firestore
          .collection("users")
          .doc(userId)
          .collection("saved_combinations")
          .orderBy("created_at", descending: true)
          .limit(50)
          .get();

      final combinations = snapshot.docs.map((doc) {
        final data = doc.data();
        final createdAt = data["created_at"];
        final itemsRaw = (data["items"] as List<dynamic>? ?? []);
        final primary =
            itemsRaw.isNotEmpty ? itemsRaw.first as Map<String, dynamic> : null;

        return HistoryCombination(
          id: data["id"] as String? ?? doc.id,
          theme: (data["theme"] as String?) ?? "",
          summary: (data["summary"] as String?) ?? "",
          mood: data["mood"] as String?,
          createdAt: createdAt is Timestamp ? createdAt.toDate() : null,
          piecesCount: itemsRaw.length,
          primaryImageUrl: primary?["image_url"] as String?,
        );
      }).toList();

      emit(
        state.copyWith(
          status: HistoryStatus.success,
          combinations: combinations,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: HistoryStatus.failure,
          errorKey: "historyLoadError",
        ),
      );
    }
  }
}


