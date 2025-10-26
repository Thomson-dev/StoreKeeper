import 'package:get/get.dart';

import '../../modules/product/bindings/product_binding.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Register feature bindings here
    ProductBinding().dependencies();
  }
}
