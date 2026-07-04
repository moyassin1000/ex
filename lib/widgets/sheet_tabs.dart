import 'package:flutter/material.dart';

class SheetTabs extends StatelessWidget {
  const SheetTabs({
    super.key,
    required this.sheetNames,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> sheetNames;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: sheetNames.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final selected = index == selectedIndex;
          return ChoiceChip(
            selected: selected,
            label: Text(
              sheetNames[index],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            labelStyle: TextStyle(
              fontWeight: FontWeight.w700,
              color: selected ? colorScheme.onPrimary : colorScheme.onSurface,
            ),
            selectedColor: colorScheme.primary,
            backgroundColor: colorScheme.surfaceContainerHighest,
            showCheckmark: false,
            onSelected: (_) => onSelected(index),
          );
        },
      ),
    );
  }
}
