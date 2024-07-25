import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dars_12/models/restaurant.dart';
import 'package:dars_12/states/cubit_states.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RestaurantsCubit extends Cubit<RestaurantState> {
  RestaurantsCubit() : super(InitialState());
  List<Restaurant> restaurants = [];

  Future<void> addRestaurant(String name, String phoneNumber,
      String locationName, LatLng latlng, File imageFile) async {
    try {
      if (state is LoadedState) {
        restaurants = (state as LoadedState).restaurants;
      }

      emit(LoadingState());
      await Future.delayed(const Duration(seconds: 1));

      restaurants.add(Restaurant(
          id: UniqueKey().toString(),
          name: name,
          phoneNumber: phoneNumber,
          location: locationName,
          latLng: latlng,
          imageFile: imageFile));
      emit(LoadedState(restaurants));
    } catch (e) {
      emit(ErrorState("Qo'shishda xatolik"));
    }
  }

  Future<void> editRestaurant(
    String id,
    String name,
    String phoneNumber,
  ) async {
    try {
      if (state is LoadedState) {
        restaurants = (state as LoadedState).restaurants;
      }

      emit(LoadingState());
      await Future.delayed(const Duration(seconds: 1));

      for (var i = 0; i < restaurants.length; i++) {
        if (restaurants[i].id == id) {
          restaurants[i].name = name;
          restaurants[i].phoneNumber = phoneNumber;
        }
      }
      emit(LoadedState(restaurants));
    } catch (e) {
      emit(ErrorState("Qo'shishda xatolik"));
    }
  }

  Future<void> deleteRestaurant(String id) async {
    try {
      if (state is LoadedState) {
        restaurants = (state as LoadedState).restaurants;
      }

      emit(LoadingState());
      await Future.delayed(const Duration(seconds: 1));

      restaurants.removeWhere(
        (element) => element.id == id,
      );
      emit(LoadedState(restaurants));
    } catch (e) {
      emit(ErrorState("O'chirishda xatolik"));
    }
  }
}
