import 'package:dars_12/controllers/restaurants_cubit.dart';
import 'package:dars_12/models/restaurant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditRestaurantDialog extends StatefulWidget {
  final Restaurant restaurant;

  const EditRestaurantDialog({super.key, required this.restaurant});

  @override
  State<EditRestaurantDialog> createState() => _EditRestaurantDialogState();
}

class _EditRestaurantDialogState extends State<EditRestaurantDialog> {
  final nameController = TextEditingController();

  final phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController.text = widget.restaurant.name;
    phoneNumberController.text = widget.restaurant.phoneNumber;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit restaurant"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
                border: OutlineInputBorder(), hintText: "Restaurant name"),
          ),
          const SizedBox(
            height: 15,
          ),
          TextField(
            keyboardType: TextInputType.number,
            controller: phoneNumberController,
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Restaurant phone number"),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            context.read<RestaurantsCubit>().editRestaurant(
                widget.restaurant.id,
                nameController.text,
                phoneNumberController.text);
            Navigator.pop(context);
          },
          child: const Text("Edit Restaurant"),
        ),
      ],
    );
  }
}
