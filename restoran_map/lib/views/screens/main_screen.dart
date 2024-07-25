import 'package:dars_12/controllers/restaurants_cubit.dart';
import 'package:dars_12/models/restaurant.dart';
import 'package:dars_12/states/cubit_states.dart';
import 'package:dars_12/views/screens/map_screen.dart';
import 'package:dars_12/views/widgets/edit_restaurant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      context.read<RestaurantsCubit>().restaurants;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Ovqatlanish maskanlari"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const MapScreen()));
            },
            icon: const Icon(
              Icons.add,
            ),
          ),
        ],
      ),
      body: BlocBuilder<RestaurantsCubit, RestaurantState>(
          builder: (context, state) {
        if (state is InitialState) {
          return const Center(
            child: Text("Ma'lumot hali yuklanmadi"),
          );
        }

        if (state is LoadingState) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is ErrorState) {
          return Center(
            child: Text(state.message),
          );
        }

        List<Restaurant> restaurants = (state as LoadedState).restaurants;
        if (restaurants.isEmpty) {
          return const Center(
            child: Text("Ma'lumotlar mavjud emas"),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: ListView.builder(
              itemCount: restaurants.length,
              itemBuilder: (context, index) {
                final restaurant = restaurants[index];
                return Card(
                  color: Colors.amber,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 300,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20)),
                          clipBehavior: Clip.hardEdge,
                          child: Image.file(
                            restaurant.imageFile,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Restoran: ${restaurant.name}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Telefon raqam: ${restaurant.phoneNumber}",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Joylashuv: ${restaurant.location}",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                                onPressed: () async {
                                  await showDialog(
                                    context: context,
                                    builder: (context) => EditRestaurantDialog(
                                        restaurant: restaurant),
                                  );
                                },
                                icon: const Icon(
                                  Icons.edit,
                                  size: 30,
                                  color: Colors.blue,
                                )),
                            const SizedBox(width: 15),
                            IconButton(
                                onPressed: () {
                                  context
                                      .read<RestaurantsCubit>()
                                      .deleteRestaurant(restaurant.id);
                                },
                                icon: const Icon(
                                  Icons.delete,
                                  size: 30,
                                  color: Colors.red,
                                ))
                          ],
                        )
                      ],
                    ),
                  ),
                );
              }),
        );
      }),
    );
  }
}
