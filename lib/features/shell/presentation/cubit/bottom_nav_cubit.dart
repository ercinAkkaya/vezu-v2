import 'package:flutter_bloc/flutter_bloc.dart';

class BottomNavCubit extends Cubit<int> {
  BottomNavCubit() : super(0);

  void setIndex(int index) {
    if (index != state) {
      emit(index);
    }
  }
}
