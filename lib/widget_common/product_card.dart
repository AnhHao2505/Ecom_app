import 'package:e_mart/consts/consts.dart';
import 'package:e_mart/controllers/cart_controller.dart';
import 'package:e_mart/controllers/home_controller.dart';
import 'package:e_mart/controllers/wishlist_controller.dart';
import 'package:e_mart/models/product_model.dart';
import 'package:e_mart/views/item_detail_screen/item_detail.dart';
import 'package:e_mart/widget_common/product_image.dart';
import 'package:e_mart/widget_common/quick_add_sheet.dart';
import 'package:get/get.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final double imageHeight;

  const ProductCard({super.key, required this.product, this.imageHeight = 160});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isCartPressed = false;

  @override
  Widget build(BuildContext context) {
    final image = widget.product.images.isEmpty
        ? ''
        : widget.product.images.first;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bool isNew =
        DateTime.now().difference(widget.product.createdAt).inDays < 14;
    final bool isBestSeller = widget.product.reviewCount >= 300;
    final bool isOutOfStock = !widget.product.isInStock;
    final bool hasOriginalPrice =
        widget.product.originalPrice > widget.product.price;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final isCompact = availableHeight < 290;
        final titleHeight = isCompact ? 30.0 : 34.0;
        final estimatedContentHeight =
            (isCompact ? 20.0 : 24.0) +
            titleHeight +
            (isCompact ? 2.0 : 3.0) +
            (isCompact ? 16.0 : 18.0) +
            (isCompact ? 1.0 : 3.0) +
            (hasOriginalPrice ? (isCompact ? 13.0 : 15.0) : 0.0) +
            (isCompact ? 21.0 : 23.0) +
            (isCompact ? 6.0 : 8.0) +
            (isCompact ? 28.0 : 32.0) +
            8.0;
        final targetImageHeight = availableHeight - estimatedContentHeight;
        final effectiveImageHeight = targetImageHeight
            .clamp(isCompact ? 112.0 : 130.0, availableHeight * 0.6)
            .toDouble();

        return SizedBox.expand(
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    Get.to(() => ItemDetail(product: widget.product));
                  }
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? darkDivider : lightDivider.withOpacity(0.5),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.transparent
                          : Colors.black.withOpacity(0.06),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image & Badges
                      Stack(
                        children: [
                          ProductImage(
                            source: image,
                            width: double.infinity,
                            height: effectiveImageHeight,
                          ),
                          if (isOutOfStock)
                            Container(
                              width: double.infinity,
                              height: effectiveImageHeight,
                              color: Colors.black.withOpacity(0.5),
                              alignment: Alignment.center,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  outOfStock,
                                  style: const TextStyle(
                                    color: whiteColor,
                                    fontFamily: bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),

                          // Badges (Top Left)
                          Positioned(
                            top: 10,
                            left: 10,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (widget.product.discountPercentage > 0)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 6),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: redColor,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: redColor.withOpacity(0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      '-${widget.product.discountPercentage.round()}%',
                                      style: const TextStyle(
                                        color: whiteColor,
                                        fontSize: 10,
                                        fontFamily: bold,
                                      ),
                                    ),
                                  ),
                                if (isNew)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 6),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: primaryColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      newLabel,
                                      style: const TextStyle(
                                        color: whiteColor,
                                        fontSize: 10,
                                        fontFamily: bold,
                                      ),
                                    ),
                                  ),
                                if (isBestSeller)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: warningColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.local_fire_department,
                                          color: whiteColor,
                                          size: 12,
                                        ),
                                        4.widthBox,
                                        Text(
                                          bestSeller,
                                          style: const TextStyle(
                                            color: whiteColor,
                                            fontSize: 10,
                                            fontFamily: bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          // Wishlist (Top Right)
                          Positioned(
                            top: 10,
                            right: 10,
                            child: GestureDetector(
                              onTap: () {
                                Get.find<WishlistController>().toggle(
                                  widget.product.id,
                                );
                              },
                              child: Obx(() {
                                final isWishlisted =
                                    Get.find<WishlistController>().isWishlisted(
                                      widget.product.id,
                                    );
                                return Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).cardColor.withOpacity(0.95),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    isWishlisted
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    size: 18,
                                    color: isWishlisted
                                        ? redColor
                                        : Theme.of(
                                            context,
                                          ).textTheme.bodyMedium?.color,
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),

                      // Content
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(isCompact ? 10 : 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: titleHeight,
                                child: Text(
                                  widget.product.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.color,
                                    fontSize: isCompact ? 12 : 13,
                                    fontFamily: semibold,
                                    height: 1.25,
                                  ),
                                ),
                              ),
                              SizedBox(height: isCompact ? 2 : 3),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star_rounded,
                                    color: golden,
                                    size: isCompact ? 14 : 16,
                                  ),
                                  SizedBox(width: isCompact ? 3 : 4),
                                  Text(
                                    '${widget.product.rating}',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.color,
                                      fontSize: isCompact ? 11 : 12,
                                      fontFamily: bold,
                                    ),
                                  ),
                                  SizedBox(width: isCompact ? 3 : 4),
                                  Text(
                                    '(${widget.product.reviewCount})',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color
                                          ?.withOpacity(0.9),
                                      fontSize: isCompact ? 10 : 11,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: isCompact ? 1 : 3),
                              if (hasOriginalPrice)
                                Text(
                                  '\$${widget.product.originalPrice.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color
                                            ?.withOpacity(0.5) ??
                                        fontGrey,
                                    fontSize: isCompact ? 10 : 11,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      const Text(
                                        '\$',
                                        style: TextStyle(
                                          color: redColor,
                                          fontSize: 12,
                                          fontFamily: bold,
                                        ),
                                      ),
                                      Text(
                                        widget.product.price.toStringAsFixed(2),
                                        style: TextStyle(
                                          color: redColor,
                                          fontSize: isCompact ? 16 : 18,
                                          fontFamily: bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${widget.product.reviewCount} sold', // Proxying reviewCount to sold temporarily
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color
                                          ?.withOpacity(0.9),
                                      fontSize: isCompact ? 10 : 11,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: isCompact ? 6 : 8),
                              // CTA Button
                              SizedBox(
                                width: double.infinity,
                                height: isCompact ? 28 : 32,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isOutOfStock
                                        ? Theme.of(context).disabledColor
                                        : primaryColor,
                                    foregroundColor: whiteColor,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        isCompact ? 8 : 10,
                                      ),
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                  onPressed: isOutOfStock
                                      ? null
                                      : () async {
                                          setState(() => _isCartPressed = true);

                                          if (widget.product.colors.length <=
                                                  1 &&
                                              widget.product.sizes.length <=
                                                  1) {
                                            // Auto add
                                            Get.find<CartController>()
                                                .addToCart(
                                                  product: widget.product,
                                                  quantity: 1,
                                                  selectedColor:
                                                      widget
                                                          .product
                                                          .colors
                                                          .isNotEmpty
                                                      ? widget
                                                            .product
                                                            .colors
                                                            .first
                                                      : null,
                                                  selectedSize:
                                                      widget
                                                          .product
                                                          .sizes
                                                          .isNotEmpty
                                                      ? widget
                                                            .product
                                                            .sizes
                                                            .first
                                                      : null,
                                                );
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.check_circle,
                                                      color: whiteColor,
                                                    ),
                                                    8.widthBox,
                                                    const Text(
                                                      addedToCart,
                                                      style: TextStyle(
                                                        fontFamily: semibold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                action: SnackBarAction(
                                                  label: viewCart,
                                                  textColor: whiteColor,
                                                  onPressed: () =>
                                                      Get.find<HomeController>()
                                                              .currentNavIndex
                                                              .value =
                                                          2,
                                                ),
                                                backgroundColor: successColor,
                                                duration: const Duration(
                                                  seconds: 2,
                                                ),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                            );
                                          } else {
                                            // Open bottom sheet
                                            showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              backgroundColor:
                                                  Colors.transparent,
                                              builder: (context) =>
                                                  QuickAddSheet(
                                                    product: widget.product,
                                                  ),
                                            );
                                          }

                                          await Future.delayed(
                                            const Duration(milliseconds: 200),
                                          );
                                          if (mounted) {
                                            setState(
                                              () => _isCartPressed = false,
                                            );
                                          }
                                        },
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    child:
                                        _isCartPressed &&
                                            widget.product.colors.length <= 1 &&
                                            widget.product.sizes.length <= 1
                                        ? const Icon(
                                            Icons.check,
                                            color: whiteColor,
                                            size: 18,
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.shopping_cart_outlined,
                                                size: isCompact ? 14 : 16,
                                              ),
                                              SizedBox(
                                                width: isCompact ? 4 : 6,
                                              ),
                                              Text(
                                                'Add to Cart',
                                                style: TextStyle(
                                                  fontFamily: bold,
                                                  fontSize: isCompact ? 11 : 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                            ],
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
      },
    );
  }
}
