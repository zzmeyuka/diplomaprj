import 'package:flutter/material.dart';
import 'package:smartfly/core/theme/app_theme.dart';

/// City picker with text search (autocomplete).
class CitySearchField extends StatelessWidget {
  const CitySearchField({
    super.key,
    required this.value,
    required this.cities,
    required this.hint,
    required this.onSelected,
  });

  final String value;
  final List<String> cities;
  final String hint;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final options = cities.isEmpty ? [value] : cities;

    return Autocomplete<String>(
      initialValue: TextEditingValue(text: value),
      optionsBuilder: (textEditingValue) {
        final q = textEditingValue.text.trim().toLowerCase();
        if (q.isEmpty) return options.take(12);
        return options.where((c) => c.toLowerCase().contains(q)).take(12);
      },
      onSelected: onSelected,
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        if (controller.text != value) {
          controller.text = value;
        }
        return TextField(
          controller: controller,
          focusNode: focusNode,
          style: Theme.of(context).textTheme.titleMedium,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.transparent,
            hintText: hint,
            isDense: true,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            suffixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.primaryBright),
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
          onSubmitted: (v) {
            if (v.trim().isNotEmpty) onSelected(v.trim());
          },
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220, maxWidth: 320),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final city = options.elementAt(index);
                  return ListTile(
                    dense: true,
                    title: Text(city),
                    onTap: () => onSelected(city),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
