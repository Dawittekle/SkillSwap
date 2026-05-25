import 'package:flutter/material.dart';

class SkillSearchBar extends StatelessWidget {
  const SkillSearchBar({
    required this.hintText,
    this.onChanged,
    this.onFilterPressed,
    this.controller,
    super.key,
  });

  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterPressed;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: hintText,
        suffixIcon: IconButton(
          onPressed: onFilterPressed,
          icon: const Icon(Icons.tune),
          tooltip: 'Filters',
        ),
      ),
    );
  }
}
