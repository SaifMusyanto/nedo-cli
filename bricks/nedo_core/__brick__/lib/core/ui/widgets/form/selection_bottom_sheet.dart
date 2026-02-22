import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../config/constants/app_colors.dart';
import '../../../utils/extensions/extensions.dart';

class SelectionItem<T> {
  final String label;
  final T value;

  const SelectionItem({required this.label, required this.value});
}

void showSelectionBottomSheet<T>({
  required BuildContext context,
  required String title,
  required List<SelectionItem<T>> items,
  required ValueChanged<T> onSelected,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.black40,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: context.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (_, index) {
                  final item = items[index];
                  return ListTile(
                    title: Text(
                      item.label,
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      onSelected(item.value);
                      Navigator.pop(sheetContext);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

class SelectionBottomSheet<T> extends StatelessWidget {
  final String selectedLabel;
  final String title;
  final List<SelectionItem<T>> items;
  final ValueChanged<T> onSelected;
  final bool expand;

  const SelectionBottomSheet({
    required this.selectedLabel,
    required this.title,
    required this.items,
    required this.onSelected,
    this.expand = true,
    super.key,
  });

  void _show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.black40,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: context.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (_, index) {
                    final item = items[index];
                    return ListTile(
                      title: Text(
                        item.label,
                        style: const TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        onSelected(item.value);
                        Navigator.pop(sheetContext);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    final trigger = GestureDetector(
      onTap: () => _show(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.black40,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.black30, width: 1),
        ),
        child: Row(
          spacing: 4,
          children: [
            Expanded(
              child: Text(
                selectedLabel,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const Icon(
              Iconsax.arrow_down_1_copy,
              color: AppColors.grey50,
              size: 12,
            ),
          ],
        ),
      ),
    );

    return trigger;
  }
}
