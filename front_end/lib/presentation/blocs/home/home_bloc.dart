import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_home_data_usecase.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetHomeDataUseCase getHomeDataUseCase;

  HomeBloc({required this.getHomeDataUseCase}) : super(HomeInitial()) {
    on<HomeLoadRequested>(_onHomeLoadRequested);
    on<HomeRefreshRequested>(_onHomeRefreshRequested);
  }

  Future<void> _onHomeLoadRequested(
    HomeLoadRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      final homeData = await getHomeDataUseCase.execute();
      emit(HomeLoaded(
        nearbyStores: homeData.nearbyStores,
        popularStores: homeData.popularStores,
        popularRecipes: homeData.popularRecipes,
        seasonalProducts: homeData.seasonalProducts,
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> _onHomeRefreshRequested(
    HomeRefreshRequested event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final homeData = await getHomeDataUseCase.execute();
      emit(HomeLoaded(
        nearbyStores: homeData.nearbyStores,
        popularStores: homeData.popularStores,
        popularRecipes: homeData.popularRecipes,
        seasonalProducts: homeData.seasonalProducts,
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
