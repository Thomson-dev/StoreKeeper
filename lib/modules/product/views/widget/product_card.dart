import 'dart:io';

import 'package:flutter/material.dart';

import '../../models/product_model.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onOptionsTap;

  const ProductCard({Key? key, required this.product, this.onOptionsTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    final path = product.imagePath ?? '';
    if (path.isNotEmpty) {
      if (path.startsWith('http')) {
        imageWidget = Image.network(path, fit: BoxFit.cover);
      } else {
        final file = File(path);
        imageWidget = file.existsSync()
            ? Image.file(file, fit: BoxFit.cover)
            : const SizedBox.shrink();
      }
    } else {
      imageWidget = const SizedBox.shrink();
    }

    final formattedPrice = '\$${product.price.toStringAsFixed(2)}';
    final status = product.status ?? '';
    final statusColor =
        status.toLowerCase() == 'active' || status.toLowerCase() == 'available'
        ? Colors.green[700]
        : Colors.red[700];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Container(
                  width: 60,
                  height: 80,
                  
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: Colors.grey[100],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: imageWidget,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2C2C2C),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            formattedPrice,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C2C2C),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Category: ${product.category ?? ''}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            status,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onOptionsTap,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      children: [
                        Container(
                          width: 3,
                          height: 3,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2C2C2C),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2C2C2C),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2C2C2C),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ID: ${product.id}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF2C2C2C),
                  ),
                ),
                Text(
                  'Stock Level: ${product.quantity}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF2C2C2C),
                  ),
                ),
                Text(
                  'Exp. Date: -',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF2C2C2C),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
