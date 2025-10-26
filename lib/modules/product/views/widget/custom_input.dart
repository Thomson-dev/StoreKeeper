import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget {
  final String label;
  final String placeholder;
  final String value;
  final VoidCallback? onTap;
  final bool showArrow;
  final TextInputType? keyboardType;

  const CustomInputField({
    Key? key,
    required this.label,
    required this.placeholder,
    required this.value,
    this.onTap,
    this.showArrow = false,
    this.keyboardType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C2C2C),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value.isEmpty ? placeholder : value,
                    style: TextStyle(
                      fontSize: 12,
                      color: value.isEmpty
                          ? const Color(0xFF9E9E9E)
                          : const Color(0xFF2C2C2C),
                    ),
                  ),
                ),
                if (showArrow)
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Color(0xFF2C2C2C),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
