import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:storekeeper/modules/product/controllers/product_controller.dart';
import 'package:storekeeper/modules/product/models/product_model.dart';
import 'package:storekeeper/modules/product/views/add_edit_product_page.dart';
import 'package:storekeeper/modules/product/views/widget/product_card.dart';

class ProductListPage extends StatelessWidget {
  const ProductListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProductController());
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        toolbarHeight: 56,
        leadingWidth: 72,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: IconButton(
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            icon: const Icon(
              Icons.menu_rounded,
              color: Color(0xFF111827), // darker for contrast
              size: 22,
            ),
            splashRadius: 20,
          ),
        ),
        title: const Text(
          'Products',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827), // gray-900
            letterSpacing: -0.2,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              onPressed: () {
                // e.g., open QR scanner or share
              },
              icon: const Icon(
                Icons.qr_code,
                color: Color(0xFF111827),
                size: 20,
              ),
              splashRadius: 20,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          child: Column(
            children: [
              //Searchbar
              ProductSearchBar(),
              SizedBox(height: 16),
              //List of products
              Obx(() {
                final list = controller.products;
                if (list.isEmpty) {
                  // Empty state UI
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 50),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 72,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'No products yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add your first product to get started.\nYou can add images, price, quantity and category.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: list.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final product = list[index];
                    return Dismissible(
                      key: ValueKey(product.id ?? '${product.name}-$index'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) async {
                        final removed = product;
                        await controller.deleteProductAt(index);

                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${removed.name} deleted'),
                            action: SnackBarAction(
                              label: 'UNDO',
                              onPressed: () async {
                                await controller.createProduct(
                                  name: removed.name,
                                  imagePath: removed.imagePath ?? '',
                                  quantity: removed.quantity,
                                  price: removed.price,
                                  category: removed.category,
                                  status: removed.status,
                                );
                              },
                            ),
                          ),
                        );
                      },
                      child: InkWell(
                        onTap: () async {
                          // Open edit page and wait for result (updated product)
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AddEditProductPage(product: product),
                            ),
                          );
                        },
                        child: ProductCard(
                          product: product,
                          onOptionsTap: () {},
                        ),
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditProductPage()),
          );
        },
        label: const Text('Add'),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xFFFF7A18), // professional orange
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class ProductSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool enabled;

  const ProductSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E7EB), // gray-200
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onTap: onTap,
        enabled: enabled,
        decoration: const InputDecoration(
          hintText: 'Search for a product',
          hintStyle: TextStyle(
            color: Color(0xFF9CA3AF), // gray-400
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Color(0xFF9CA3AF), // gray-400
            size: 16,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF111827), // gray-900
        ),
      ),
    );
  }
}
