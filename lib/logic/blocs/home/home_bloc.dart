import 'package:bloc/bloc.dart';
import 'home_event.dart';
import 'home_state.dart';
import '../../../data/models/hotel.dart';
import '../../../data/services/api_service.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final ApiService _apiService = ApiService();

  HomeBloc() : super(HomeInitial()) {
    on<LoadHotels>(_onLoadHotels);
    on<LoadSampleHotels>(_onLoadSampleHotels); // ✅ handle new event
  }

  Future<void> _onLoadHotels(LoadHotels event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      final hotels = await _apiService.searchHotels(query: 'Goa');
      emit(HomeLoaded(hotels['hotels']));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  /// ✅ Loads local mock data for offline/sample display
  Future<void> _onLoadSampleHotels(
      LoadSampleHotels event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    await Future.delayed(const Duration(milliseconds: 500)); // simulate delay
    final mockHotels = [
      Hotel(
        id: '1',
        name: 'The Grand Palace',
        city: 'New Delhi',
        state: 'Delhi',
        country: 'India',
        imageUrl:
        'https://images.unsplash.com/photo-1505691938895-1758d7feb511?w=800', // ✅ working
        propertyUrl: '',
        code: 'DL01',
      ),
      Hotel(
        id: '2',
        name: 'Ocean View Resort',
        city: 'Goa',
        state: 'Goa',
        country: 'India',
        imageUrl:
        'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800', // ✅ working
        propertyUrl: '',
        code: 'GA02',
      ),
      Hotel(
        id: '3',
        name: 'Mountain Lodge',
        city: 'Manali',
        state: 'Himachal Pradesh',
        country: 'India',
        imageUrl:
        'https://images.unsplash.com/photo-1505691938895-1758d7feb511?w=800', // ✅ working
        propertyUrl: '',
        code: 'HP03',
      ),
    ];

    emit(HomeLoaded(mockHotels));
  }
}
