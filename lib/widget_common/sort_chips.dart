import 'package:e_mart/consts/consts.dart';
import 'package:e_mart/controllers/home_controller.dart';
import 'package:e_mart/widget_common/filter_bottom_sheet.dart';
import 'package:get/get.dart';

class SortChips extends StatelessWidget {
  const SortChips({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final sortOptions = [
      {'key': 'popular', 'label': popular},
      {'key': 'newest', 'label': newest},
      {'key': 'price_asc', 'label': priceAsc},
      {'key': 'price_desc', 'label': priceDesc},
      {'key': 'rating', 'label': ratingSort},
    ];

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          ...sortOptions.map((option) {
            return Obx(() {
              final isSelected = controller.sortOption.value == option['key'];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(option['label']!),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      controller.sortOption.value = option['key']!;
                    }
                  },
                  selectedColor: primaryColor,
                  backgroundColor: Theme.of(context).cardColor,
                  labelStyle: TextStyle(
                    color: isSelected ? whiteColor : Theme.of(context).textTheme.bodyMedium?.color,
                    fontFamily: isSelected ? bold : semibold,
                    fontSize: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? Colors.transparent : (isDark ? darkDivider : lightDivider),
                    ),
                  ),
                  showCheckmark: false,
                ),
              );
            });
          }),
          Obx(() {
            final activeFilters = controller.activeFilterCount;
            return ActionChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(filterProducts),
                  if (activeFilters > 0) ...[
                    4.widthBox,
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: redColor,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$activeFilters',
                        style: const TextStyle(
                          color: whiteColor,
                          fontSize: 10,
                          fontFamily: bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              avatar: const Icon(Icons.tune, size: 16),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const FilterBottomSheet(),
                );
              },
              backgroundColor: Theme.of(context).cardColor,
              labelStyle: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontFamily: semibold,
                fontSize: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: activeFilters > 0 ? primaryColor : (isDark ? darkDivider : lightDivider),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
