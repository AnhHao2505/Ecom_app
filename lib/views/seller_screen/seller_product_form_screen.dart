import 'package:e_mart/consts/consts.dart';
import 'package:e_mart/consts/lists.dart';
import 'package:e_mart/models/product_model.dart';
import 'package:e_mart/services/seller_service.dart';
import 'package:get/get.dart';

class SellerProductFormScreen extends StatefulWidget {
  final Product? product;

  const SellerProductFormScreen({super.key, this.product});

  @override
  State<SellerProductFormScreen> createState() =>
      _SellerProductFormScreenState();
}

class _SellerProductFormScreenState extends State<SellerProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sellerService = SellerService();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _imageController = TextEditingController();
  final _sizesController = TextEditingController();
  final _colorsController = TextEditingController();
  final _brandController = TextEditingController();

  String _category = categoriesData.first.key;
  bool _isSaving = false;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    if (product == null) return;

    _nameController.text = product.name;
    _descriptionController.text = product.description;
    _priceController.text = product.price.toString();
    _stockController.text = product.stock.toString();
    _imageController.text = product.images.join(', ');
    _sizesController.text = product.sizes.join(', ');
    _colorsController.text = product.colors.join(', ');
    _brandController.text = product.attributes['brand']?.toString() ?? '';
    if (categoriesData.any((category) => category.key == product.category)) {
      _category = product.category;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _imageController.dispose();
    _sizesController.dispose();
    _colorsController.dispose();
    _brandController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final userId = auth.currentUser!.uid;
      final now = DateTime.now();
      final price = double.parse(_priceController.text.trim());
      final stock = int.parse(_stockController.text.trim());
      final images = _splitValues(_imageController.text);
      final product = Product(
        id: widget.product?.id ?? '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _category,
        price: price,
        originalPrice: price,
        images: images.isEmpty ? [imgP1] : images,
        storeId: userId,
        userId: userId,
        rating: widget.product?.rating ?? 0,
        reviewCount: widget.product?.reviewCount ?? 0,
        stock: stock,
        isFeatured: widget.product?.isFeatured ?? false,
        isNew: widget.product?.isNew ?? true,
        sizes: _splitValues(_sizesController.text),
        colors: _splitValues(_colorsController.text),
        attributes: {
          if (_brandController.text.trim().isNotEmpty)
            'brand': _brandController.text.trim(),
        },
        createdAt: widget.product?.createdAt ?? now,
        updatedAt: now,
      );

      await _sellerService.saveProduct(product);

      if (!mounted) return;
      VxToast.show(
        context,
        msg: _isEditing ? 'Product updated' : 'Product created',
      );
      Get.back();
    } catch (e) {
      if (mounted) VxToast.show(context, msg: e.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Product' : 'Add Product',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontFamily: bold,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [darkBg, darkBgGradientEnd]
                : [lightBg, lightBgGradientEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              children: [
              _card(
                context,
                children: [
                  _field(
                    _nameController,
                    'Product name',
                    isRequired: true,
                    textInputAction: TextInputAction.next,
                  ),
                  _field(
                    _descriptionController,
                    'Description',
                    isRequired: true,
                    maxLines: 4,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                  ),
                  DropdownButtonFormField<String>(
                    value: _category,
                    decoration: _inputDecoration(context, 'Category'),
                    items: categoriesData
                        .map(
                          (category) => DropdownMenuItem(
                            value: category.key,
                            child: Text(category.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _category = value);
                    },
                  ),
                ],
              ),
              16.heightBox,
              _card(
                context,
                children: [
                  _field(
                    _priceController,
                    'Price',
                    isRequired: true,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    numeric: true,
                    textInputAction: TextInputAction.next,
                  ),
                  _field(
                    _stockController,
                    'Stock',
                    isRequired: true,
                    keyboardType: TextInputType.number,
                    integer: true,
                    textInputAction: TextInputAction.next,
                  ),
                ],
              ),
              16.heightBox,
              _card(
                context,
                children: [
                  _field(
                    _imageController,
                    'Image URL or asset path',
                    helper: 'Separate multiple images with commas.',
                    textInputAction: TextInputAction.next,
                  ),
                  _field(
                    _brandController,
                    'Brand',
                    textInputAction: TextInputAction.next,
                  ),
                  _field(
                    _sizesController,
                    'Sizes',
                    helper: 'Example: S, M, L',
                    textInputAction: TextInputAction.next,
                  ),
                  _field(
                    _colorsController,
                    'Colors',
                    helper: 'Example: Black, White, Blue',
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _isSaving ? null : _saveProduct(),
                  ),
                ],
              ),
              24.heightBox,
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveProduct,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: whiteColor,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    _isSaving ? 'Saving...' : 'Save product',
                    style: const TextStyle(fontFamily: bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: whiteColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(BuildContext context, {required List<Widget> children}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? darkDivider : lightDivider),
      ),
      child: Column(children: children),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool isRequired = false,
    bool numeric = false,
    bool integer = false,
    int maxLines = 1,
    String? helper,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    ValueChanged<String>? onFieldSubmitted,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onFieldSubmitted: onFieldSubmitted,
        validator: (value) {
          final text = value?.trim() ?? '';
          if (isRequired && text.isEmpty) return '$label is required';
          if (text.isEmpty) return null;
          if (integer && int.tryParse(text) == null) {
            return '$label must be a whole number';
          }
          if (numeric && double.tryParse(text) == null) {
            return '$label must be a number';
          }
          return null;
        },
        decoration: _inputDecoration(context, label, helper: helper),
      ),
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context,
    String label, {
    String? helper,
  }) {
    return InputDecoration(
      labelText: label,
      helperText: helper,
      filled: true,
      fillColor: Theme.of(context).scaffoldBackgroundColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor),
      ),
    );
  }

  List<String> _splitValues(String value) {
    return value
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }
}
