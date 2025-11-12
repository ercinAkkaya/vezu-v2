import "dart:async";

import "package:bloc/bloc.dart";
import "package:equatable/equatable.dart";

part "home_state.dart";

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState());

  Future<void> loadDashboard() async {
    emit(state.copyWith(status: HomeStatus.loading, resetError: true));
    await Future<void>.delayed(const Duration(milliseconds: 600));
    emit(state.copyWith(status: HomeStatus.success));
  }

  Future<void> refreshWeather() async {
    emit(state.copyWith(status: HomeStatus.loading));
    await Future<void>.delayed(const Duration(milliseconds: 400));
    emit(
      state.copyWith(
        status: HomeStatus.success,
        temperature: "23\u00B0C",
        condition: "Partly Cloudy",
        humidity: "63%",
        wind: "11 km/h",
      ),
    );
  }
}
