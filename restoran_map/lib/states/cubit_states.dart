//! InitialState - boshlang'ich holat
//! LoadingState - yuklanish holati
//! LoadedState - yuklanib bo'lgan holati
//! ErrorState - xatolik holati



import 'package:dars_12/models/restaurant.dart';

sealed class RestaurantState {}

final class InitialState extends RestaurantState {}

final class LoadingState extends RestaurantState {}

final class LoadedState extends RestaurantState {
  List<Restaurant> restaurants = [];

  LoadedState(this.restaurants);
}

final class ErrorState extends RestaurantState {
  String message;

  ErrorState(this.message);
}