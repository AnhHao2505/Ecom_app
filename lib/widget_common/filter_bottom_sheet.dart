import 'package:e_mart/consts/consts.dart';
import 'package:e_mart/controllers/home_controller.dart';
import 'package:get/get.dart';

class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? darkDivider : lightDivider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    filterProducts,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontFamily: bold,
                      fontSize: 18,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.close, color: Theme.of(context).textTheme.bodyMedium?.color),
                  ),
                ],
              ),
            ),
            const Divider(),
            
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Price Range
                    Text(
                      priceRange,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontFamily: bold,
                        fontSize: 16,
                      ),
                    ),
                    16.heightBox,
                    Obx(() => RangeSlider(
                      values: RangeValues(controller.filterMinPrice.value, controller.filterMaxPrice.value),
                      min: 0,
                      max: 2000,
                      divisions: 40,
                      activeColor: primaryColor,
                      inactiveColor: isDark ? darkDivider : lightDivider,
                      labels: RangeLabels(
                        '\$${controller.filterMinPrice.value.round()}',
                        '\$${controller.filterMaxPrice.value.round()}',
                      ),
                      onChanged: (RangeValues values) {
                        controller.filterMinPrice.value = values.start;
                        controller.filterMaxPrice.value = values.end;
                      },
                    )),
                    Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('\$${controller.filterMinPrice.value.round()}', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                        Text('\$${controller.filterMaxPrice.value.round()}', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                      ],
                    )),
                    
                    24.heightBox,
                    // Minimum Rating
                    Text(
                      minimumRating,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontFamily: bold,
                        fontSize: 16,
                      ),
                    ),
                    16.heightBox,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(5, (index) {
                        return Obx(() {
                          final isSelected = controller.filterMinRating.value >= (index + 1);
                          return GestureDetector(
                            onTap: () {
                              if (controller.filterMinRating.value == index + 1.0) {
                                controller.filterMinRating.value = 0; // Toggle off
                              } else {
                                controller.filterMinRating.value = index + 1.0;
                              }
                            },
                            child: Icon(
                              isSelected ? Icons.star : Icons.star_border,
                              color: isSelected ? golden : (isDark ? darkDivider : lightDivider),
                              size: 32,
                            ),
                          );
                        });
                      }),
                    ),
                    
                    24.heightBox,
                    // Brands
                    Obx(() {
                      if (controller.availableBrands.isEmpty) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            brand,
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                              fontFamily: bold,
                              fontSize: 16,
                            ),
                          ),
                          16.heightBox,
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: controller.availableBrands.map((b) {
                              return Obx(() {
                                final isSelected = controller.filterBrands.contains(b);
                                return FilterChip(
                                  label: Text(b),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    if (selected) {
                                      controller.filterBrands.add(b);
                                    } else {
                                      controller.filterBrands.remove(b);
                                    }
                                  },
                                  selectedColor: primaryColor.withOpacity(0.1),
                                  checkmarkColor: primaryColor,
                                  backgroundColor: Theme.of(context).cardColor,
                                  labelStyle: TextStyle(
                                    color: isSelected ? primaryColor : Theme.of(context).textTheme.bodyMedium?.color,
                                    fontFamily: isSelected ? bold : semibold,
                                    fontSize: 13,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(
                                      color: isSelected ? primaryColor : (isDark ? darkDivider : lightDivider),
                                    ),
                                  ),
                                );
                              });
                            }).toList(),
                          ),
                          24.heightBox,
                        ],
                      );
                    }),
                    
                    // In Stock Only
                    Obx(() => SwitchListTile(
                      title: Text(
                        inStockOnly,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontFamily: bold,
                          fontSize: 16,
                        ),
                      ),
                      contentPadding: EdgeInsets.zero,
                      value: controller.filterInStockOnly.value,
                      activeColor: primaryColor,
                      onChanged: (value) {
                        controller.filterInStockOnly.value = value;
                      },
                    )),
                  ],
                ),
              ),
            ),
            
            // Buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: isDark ? darkDivider : lightDivider),
                      ),
                      onPressed: () {
                        controller.resetFilters();
                      },
                      child: Text(
                        reset,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontFamily: bold,
                        ),
                      ),
                    ),
                  ),
                  16.widthBox,
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: () => Get.back(),
                      child: Obx(() {
                        final count = controller.activeFilterCount;
                        return Text(
                          count > 0 ? '$apply ($count)' : apply,
                          style: const TextStyle(
                            color: whiteColor,
                            fontFamily: bold,
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
