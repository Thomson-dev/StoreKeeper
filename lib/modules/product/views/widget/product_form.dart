import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:storekeeper/modules/product/controllers/product_controller.dart';
import 'custom_input.dart';

class ProductForm extends StatefulWidget {
  final String? initialName;
  final String? initialCategory;
  final String? initialPrice;
  final String? initialStatus;
  final int? initialQuantity;
  final String? initialImagePath; // <-- new
  final void Function(Map<String, String> values)? onSaved;

  const ProductForm({
    Key? key,
    this.initialName,
    this.initialCategory,
    this.initialPrice,
    this.initialStatus,
    this.initialQuantity,
    this.initialImagePath,
    this.onSaved,
  }) : super(key: key);

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtl = TextEditingController();
  final TextEditingController _priceCtl = TextEditingController();
  final TextEditingController _quantityCtl = TextEditingController();
  String _category = '';
  String _status = '';

  final List<String> _categories = [
    'Fruits',
    'Beverages',
    'Household',
    'Bakery',
    'Groceries',
  ];
  final List<String> _statuses = ['Active', 'Inactive', 'Low', 'Available'];

  // Image picker state
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;

  // keep track of an initial image path (if editing) and whether user removed it
  String? _initialImagePath;
  bool _imageRemoved = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _imageRemoved = false; // user chose a new image
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Image error: $e')));
    }
  }

  @override
  void initState() {
    super.initState();
    _nameCtl.text = widget.initialName ?? '';
    _priceCtl.text = widget.initialPrice ?? '';
    _quantityCtl.text = widget.initialQuantity?.toString() ?? '';
    _category = widget.initialCategory ?? '';
    _status = widget.initialStatus ?? '';
    _initialImagePath = widget.initialImagePath;
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _priceCtl.dispose();
    _quantityCtl.dispose();
    super.dispose();
  }

  void _onSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final name = _nameCtl.text.trim();
    final category = _category;
    final quantity = int.tryParse(_quantityCtl.text.trim()) ?? 0;
    final price = double.tryParse(_priceCtl.text.trim()) ?? 0.0;

    // decide image action and path:
    String imageAction;
    String imagePath;
    if (_imageFile != null) {
      imageAction = 'set';
      imagePath = _imageFile!.path;
    } else if (_initialImagePath != null &&
        _initialImagePath!.isNotEmpty &&
        !_imageRemoved) {
      imageAction = 'keep';
      imagePath = _initialImagePath!;
    } else {
      imageAction = 'remove';
      imagePath = '';
    }

    final controller = Get.find<ProductController>();

    // validate required dropdowns
    if (category.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }
    if (_status.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a status')));
      return;
    }
    // If a parent provided an onSaved callback, call it and let the
    // caller handle persistence (create vs update). This keeps the form
    // decoupled from storage and makes editing simpler.
    if (widget.onSaved != null) {
      final values = {
        'name': name,
        'category': category,
        'quantity': quantity.toString(),
        'price': price.toString(),
        'status': _status,
        'imagePath': imagePath,
        'imageAction': imageAction, // 'keep' | 'set' | 'remove'
      };
      widget.onSaved!(values);
      return;
    }

    // No onSaved provided -> fall back to creating a new product directly
    // from the form (legacy behavior).
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // For legacy create path: use imagePath unless it's 'remove' or empty
      final finalImagePath = (imageAction == 'set')
          ? imagePath
          : (imageAction == 'keep' ? _initialImagePath ?? '' : '');
      final created = await controller.createProduct(
        name: name,
        imagePath: finalImagePath,
        quantity: quantity,
        price: price,
        category: category,
        status: _status,
      );

      Navigator.of(context).pop(); // dismiss loading

      if (created != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Product saved')));
        Navigator.of(context).pop(created); // return created product to caller
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to save product')));
      }
    } catch (e) {
      Navigator.of(context).pop(); // dismiss loading on error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  InputDecoration _decoration({required String hint, String? prefixText}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.grey[400],
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      prefixText: prefixText,
      prefixStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A1A1A),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: true,
      fillColor: Colors.grey[50],
    );
  }

  void _showPicker({
    required List<String> items,
    required String title,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Container(
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    title,

                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                ...items.map(
                  (i) => ListTile(
                    title: Text(i, style: const TextStyle(fontSize: 12)),
                    onTap: () {
                      onSelected(i);
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: Color(0xFF1A1A1A),
      letterSpacing: 0.2,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: 12,

          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Center(
          child: Container(
            // professional image upload container inserted above form content
            padding: const EdgeInsets.all(6),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Professional Image Upload Container
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Product Image',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Upload a high-quality image of your product',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Image Preview Container
                        Center(
                          child: Container(
                            height: 200,
                            width: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                            child: (_imageFile != null)
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Stack(
                                      children: [
                                        Image.file(
                                          _imageFile!,
                                          height: 200,
                                          width: 200,
                                          fit: BoxFit.cover,
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _imageFile = null;
                                                // if there was an initial image, mark removed
                                                if (_initialImagePath != null &&
                                                    _initialImagePath!
                                                        .isNotEmpty) {
                                                  _imageRemoved = true;
                                                }
                                              });
                                            },
                                            child: Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                color: Colors.red.withOpacity(
                                                  0.9,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : (_initialImagePath != null &&
                                      _initialImagePath!.isNotEmpty &&
                                      !_imageRemoved)
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Stack(
                                      children: [
                                        Image.file(
                                          File(_initialImagePath!),
                                          height: 200,
                                          width: 200,
                                          fit: BoxFit.cover,
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _imageRemoved = true;
                                              });
                                            },
                                            child: Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                color: Colors.red.withOpacity(
                                                  0.9,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.cloud_upload_outlined,
                                          size: 30,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'No image selected',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Tap below to add an image',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Upload Buttons
                        Row(
                          children: [
                            Expanded(
                              child: _buildUploadButton(
                                icon: Icons.camera_alt,
                                label: 'Photo',
                                onPressed: () => _pickImage(ImageSource.camera),
                                isPrimary: true,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildUploadButton(
                                icon: Icons.photo_library,
                                label: ' Gallery',
                                onPressed: () =>
                                    _pickImage(ImageSource.gallery),
                                isPrimary: false,
                              ),
                            ),
                          ],
                        ),

                        // Image Requirements Info
                        if (_imageFile == null) ...[const SizedBox(height: 20)],
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),
                  Text(
                    'Enter the product information below',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Name
                  _label('Product Name'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameCtl,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1A1A),
                    ),
                    decoration: _decoration(hint: 'Enter product name'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Please enter a product name'
                        : null,
                  ),
                  const SizedBox(height: 24),

                  // Quantity
                  _label('Quantity'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _quantityCtl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1A1A),
                    ),
                    decoration: _decoration(hint: 'Enter quantity'),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty)
                        return 'Please enter quantity';
                      final n = int.tryParse(v.trim());
                      if (n == null || n < 0)
                        return 'Enter a valid non-negative integer';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Price
                  _label('Price'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _priceCtl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1A1A),
                    ),
                    decoration: _decoration(
                      hint: 'Enter price (e.g., 29.99)',
                      prefixText: '\$ ',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty)
                        return 'Please enter a price';
                      final n = double.tryParse(v.trim());
                      return (n == null) ? 'Enter a valid number' : null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Status & Category
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 520;
                      return isWide
                          ? Row(
                              children: [
                                Expanded(
                                  child: CustomInputField(
                                    label: 'Status',
                                    placeholder: 'Select status',
                                    value: _status,
                                    showArrow: true,
                                    onTap: () => _showPicker(
                                      items: _statuses,
                                      title: 'Select status',
                                      onSelected: (s) =>
                                          setState(() => _status = s),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: CustomInputField(
                                    label: 'Category',
                                    placeholder: 'Select category',
                                    value: _category,
                                    showArrow: true,
                                    onTap: () => _showPicker(
                                      items: _categories,
                                      title: 'Select category',
                                      onSelected: (s) =>
                                          setState(() => _category = s),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                CustomInputField(
                                  label: 'Status',
                                  placeholder: 'Select status',
                                  value: _status,
                                  showArrow: true,
                                  onTap: () => _showPicker(
                                    items: _statuses,
                                    title: 'Select status',
                                    onSelected: (s) =>
                                        setState(() => _status = s),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                CustomInputField(
                                  label: 'Category',
                                  placeholder: 'Select category',
                                  value: _category,
                                  showArrow: true,
                                  onTap: () => _showPicker(
                                    items: _categories,
                                    title: 'Select category',
                                    onSelected: (s) =>
                                        setState(() => _category = s),
                                  ),
                                ),
                              ],
                            );
                    },
                  ),
                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _onSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF7A18),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method for upload buttons
  Widget _buildUploadButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPrimary ? Colors.transparent : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? const Color(0xFF3B82F6) : Colors.white,
          foregroundColor: isPrimary ? Colors.white : const Color(0xFF1A1A1A),
          elevation: isPrimary ? 2 : 0,
          shadowColor: isPrimary
              ? const Color(0xFF3B82F6).withOpacity(0.3)
              : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
