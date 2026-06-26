import 'package:e_mart/consts/consts.dart';
import 'package:e_mart/models/store_model.dart';
import 'package:e_mart/services/seller_service.dart';
import 'package:e_mart/views/auth_screen/login_screen.dart';
import 'package:e_mart/views/seller_screen/seller_dashboard_screen.dart';
import 'package:get/get.dart';

class SellerShopSetupScreen extends StatefulWidget {
  final bool allowBack;

  const SellerShopSetupScreen({super.key, this.allowBack = false});

  @override
  State<SellerShopSetupScreen> createState() => _SellerShopSetupScreenState();
}

class _SellerShopSetupScreenState extends State<SellerShopSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sellerService = SellerService();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _openingHoursController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  Store? _existingStore;

  @override
  void initState() {
    super.initState();
    _loadStore();
  }

  Future<void> _loadStore() async {
    if (auth.currentUser == null) {
      Get.offAll(() => const LoginScreen());
      return;
    }

    final store = await _sellerService.fetchCurrentSellerStore();
    if (!mounted) return;

    if (store != null) {
      _existingStore = store;
      _nameController.text = store.name;
      _descriptionController.text = store.description;
      _ownerNameController.text = store.ownerName;
      _phoneController.text = store.phone;
      _emailController.text = store.email;
      _addressController.text = store.address;
      _openingHoursController.text = store.openingHours;
    } else {
      _emailController.text = auth.currentUser?.email ?? '';
      _ownerNameController.text = auth.currentUser?.displayName ?? '';
      _openingHoursController.text = 'Mon - Sun, 8:00 AM - 10:00 PM';
    }

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _openingHoursController.dispose();
    super.dispose();
  }

  Future<void> _saveShop() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final now = DateTime.now();
      final store = Store(
        userId: auth.currentUser!.uid,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        ownerName: _ownerNameController.text.trim(),
        logo: icShop,
        coverImage: imgSlider1,
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        address: _addressController.text.trim(),
        openingHours: _openingHoursController.text.trim(),
        rating: _existingStore?.rating ?? 0,
        followerCount: _existingStore?.followerCount ?? 0,
        productCount: _existingStore?.productCount ?? 0,
        latitude: _existingStore?.latitude ?? 0,
        longitude: _existingStore?.longitude ?? 0,
        createdAt: _existingStore?.createdAt ?? now,
        updatedAt: now,
      );

      await _sellerService.saveCurrentSellerStore(store);

      if (!mounted) return;
      VxToast.show(context, msg: 'Shop information saved');
      if (widget.allowBack) {
        Get.back();
      } else {
        Get.offAll(() => const SellerDashboardScreen());
      }
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
        automaticallyImplyLeading: widget.allowBack,
        title: Text(
          'Shop Setup',
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: [
                    _section(
                      context,
                      title: 'Storefront',
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: primaryColor.withOpacity(0.2),
                                ),
                              ),
                              child: Image.asset(icShop),
                            ),
                            12.widthBox,
                            Expanded(
                              child: Text(
                                'Your shop will use the default shop icon.',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color
                                      ?.withOpacity(0.7),
                                ),
                              ),
                            ),
                          ],
                        ),
                        14.heightBox,
                        _field(_nameController, 'Shop name', isRequired: true),
                        _field(
                          _descriptionController,
                          'Description',
                          isRequired: true,
                          maxLines: 3,
                        ),
                        _field(_ownerNameController, 'Owner name'),
                      ],
                    ),
                    16.heightBox,
                    _section(
                      context,
                      title: 'Contact',
                      children: [
                        _field(_phoneController, 'Phone'),
                        _field(
                          _emailController,
                          'Email',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        _field(_addressController, 'Address', isRequired: true),
                        _field(_openingHoursController, 'Opening hours'),
                      ],
                    ),
                    24.heightBox,
                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _saveShop,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: whiteColor,
                                ),
                              )
                            : const Icon(Icons.storefront),
                        label: Text(
                          _isSaving ? 'Saving...' : 'Save shop',
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

  Widget _section(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? darkDivider : lightDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontFamily: bold,
              fontSize: 16,
            ),
          ),
          12.heightBox,
          ...children,
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool isRequired = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: isRequired
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return '$label is required';
                }
                return null;
              }
            : null,
        decoration: InputDecoration(
          labelText: label,
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
        ),
      ),
    );
  }
}
