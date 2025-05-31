import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Color getColorFromName(String colorName) {
  switch (colorName.toLowerCase()) {
    case 'red':
      return Colors.red;
    case 'blue':
      return Colors.blue;
    case 'green':
      return Colors.green;
    case 'black':
      return Colors.black;
    case 'white':
      return Colors.white;
    case 'yellow':
      return Colors.yellow;
    case 'purple':
      return Colors.purple;
    case 'orange':
      return Colors.orange;
    case 'pink':
      return Colors.pink;
    case 'brown':
      return Colors.brown;
    case 'beige':
      return Colors.brown.shade100;
    default:
      return Colors.white; // Changed to white for better UI visibility
  }
}

Future<File?> pickImage() async {
  final ImagePicker picker = ImagePicker();
  final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
  if (pickedFile != null) {
    print("Picked image: ${pickedFile.path} at ${DateTime.now()}");
    return File(pickedFile.path);
  }
  print("No image selected at ${DateTime.now()}");
  return null;
}

Future<String> uploadImage(File image) async {
  try {
    final fileName = 'product_images/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = FirebaseStorage.instance.ref().child(fileName);
    final uploadTask = ref.putFile(image);

    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      print('Upload progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100}% at ${DateTime.now()}');
    });

    final snapshot = await uploadTask.whenComplete(() {});
    final downloadUrl = await snapshot.ref.getDownloadURL();
    print("Image uploaded, URL: $downloadUrl at ${DateTime.now()}");

    if (!downloadUrl.startsWith('http')) {
      throw Exception("Invalid download URL: $downloadUrl");
    }
    return downloadUrl;
  } catch (e) {
    print("Error uploading image: $e at ${DateTime.now()}");
    throw e; // Fixed the missing expression after 'throw'
  }
}