import 'package:flutter/material.dart';
import 'package:mobile_app_project/Controller/delete_product_controller.dart';

class DeleteProductLogic {
  final DeleteProductController controller;

  DeleteProductLogic(this.controller);

  void deleteProduct(BuildContext context, String docId, VoidCallback updateTotals) {
    controller.deleteProduct(context, docId, updateTotals);
  }
}