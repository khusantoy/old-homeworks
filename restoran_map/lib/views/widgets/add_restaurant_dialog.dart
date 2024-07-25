import 'dart:io';

import 'package:dars_12/controllers/restaurants_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

class AddRestaurantDialog extends StatefulWidget {
  final String locationName;
  final LatLng latLng;

  const AddRestaurantDialog(
      {super.key, required this.locationName, required this.latLng});

  @override
  State<AddRestaurantDialog> createState() => _AddRestaurantDialogState();
}

class _AddRestaurantDialogState extends State<AddRestaurantDialog> {
  final nameController = TextEditingController();
  File? imageFile;

  final phoneNumberController = TextEditingController();

  void openCamera() async {
    final imagePicker = ImagePicker();
    final XFile? pickedImage = await imagePicker.pickImage(
        source: ImageSource.camera,
        requestFullMetadata: false,
        imageQuality: 50);
    if (pickedImage != null) {
      setState(() {
        imageFile = File(pickedImage.path);
      });
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Restaran nomi"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
                border: OutlineInputBorder(), hintText: "Restaran nomi"),
          ),
          const SizedBox(
            height: 15,
          ),
          TextField(
            keyboardType: TextInputType.number,
            controller: phoneNumberController,
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Restaran telefon raqami"),
          ),
          const SizedBox(
            height: 15,
          ),
          TextButton.icon(
            onPressed: () {
              openCamera();
            },
            label: const Text("Camera"),
            icon: const Icon(
              Icons.camera,
            ),
          ),
          if (imageFile != null)
            Container(
              height: 200,
              width: 200,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.file(
                imageFile!,
                fit: BoxFit.cover,
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            context.read<RestaurantsCubit>().addRestaurant(
                nameController.text,
                phoneNumberController.text,
                widget.locationName,
                widget.latLng,
                imageFile!);
            Navigator.pop(context);
            Navigator.pop(context);
          },
          child: const Text("Qo'shish"),
        ),
      ],
    );
  }
}
