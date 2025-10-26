import 'package:get/get.dart';

import 'app_routes.dart';
import '../../modules/product/views/product_list_page.dart';
import '../../modules/product/views/add_edit_product_page.dart';

class AppPages {
  static final routes = [
    GetPage(name: AppRoutes.PRODUCT_LIST, page: () => ProductListPage()),
    GetPage(name: AppRoutes.PRODUCT_ADD, page: () => AddEditProductPage()),
  ];
}
