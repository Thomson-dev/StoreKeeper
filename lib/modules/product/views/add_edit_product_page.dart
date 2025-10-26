import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:storekeeper/modules/product/controllers/product_controller.dart';
import 'package:storekeeper/modules/product/models/product_model.dart';
import 'package:storekeeper/modules/product/views/widget/product_form.dart';

class AddEditProductPage extends StatelessWidget {
  final Product? product;
  const AddEditProductPage({Key? key, this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isEditing = product != null;
    final controller = Get.find<ProductController>();
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(title: Text(isEditing ? 'Edit Product' : 'Add Product')),
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
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xFF111827), // darker for contrast
              size: 22,
            ),
            splashRadius: 20,
          ),
        ),
        title: Text(
          isEditing ? 'Edit Product' : 'Add Product',
          style: const TextStyle(
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
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ProductForm(
          initialName: product?.name,
          initialCategory: product?.category,
          initialPrice: product?.price?.toString(),
          initialStatus: product?.status,
          initialQuantity: product?.quantity,
          initialImagePath: product?.imagePath, // pass existing image path
          onSaved: (values) async {
            final name = values['name']!;
            final category = values['category']!;
            final status = values['status']!;
            final quantity = int.tryParse(values['quantity']!) ?? 0;
            final price = double.tryParse(values['price']!) ?? 0.0;
            final imageAction = values['imageAction'] ?? 'keep';
            String? imagePath;
            if (imageAction == 'set') {
              imagePath = values['imagePath'];
            } else if (imageAction == 'keep') {
              imagePath = product?.imagePath;
            } else {
              imagePath = null; // removed
            }

            if (isEditing) {
              final updated = Product(
                id: product!.id,
                name: name,
                imagePath: imagePath,
                quantity: quantity,
                price: price,
                category: category,
                status: status,
              );
              final ok = await controller.updateProductInDb(updated);
              if (ok)
                Navigator.of(context).pop(updated);
              else
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Update failed')));
            } else {
              final created = await controller.createProduct(
                name: name,
                imagePath: imagePath ?? '',
                quantity: quantity,
                price: price,
                category: category,
                status: status,
              );
              if (created != null) Navigator.of(context).pop(created);
            }
          },
        ),
      ),
    );
  }
}
