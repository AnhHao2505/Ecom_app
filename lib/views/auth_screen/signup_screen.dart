import 'package:e_mart/consts/consts.dart';
import 'package:e_mart/controllers/auth_controller.dart';
import 'package:e_mart/utils/auth_navigation.dart';
import 'package:e_mart/widget_common/applogo_widget.dart';
import 'package:e_mart/widget_common/bg_widget.dart';
import 'package:e_mart/widget_common/custom_textfield.dart';
import 'package:e_mart/widget_common/our_button.dart';
import 'package:get/get.dart';

class SignupScreen extends StatefulWidget {
  final bool isSeller;

  const SignupScreen({super.key, this.isSeller = false});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool? isCheck = false;
  late bool isSellerMode; 
  final controller = Get.put(AuthController());
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final retypePasswordController = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _retypePasswordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    isSellerMode = widget.isSeller; 
  }

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    passwordController.dispose();
    retypePasswordController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _retypePasswordFocus.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (controller.isLoading.value) return;

    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        retypePasswordController.text.isEmpty) {
      VxToast.show(context, msg: "Please fill all fields");
      return;
    }

    if (isCheck == false) {
      VxToast.show(context, msg: "Please agree to the terms and conditions");
      return;
    }

    FocusScope.of(context).unfocus();
    controller.isLoading(true);

    try {
      final credential = await controller.signupMethod(
        context: context,
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      if (credential?.user == null) {
        controller.isLoading(false);
        return;
      }
      await controller.storeUserData(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        name: nameController.text.trim(),
        role: isSellerMode ? 'Seller' : 'Customer',
      );
      if (!mounted) return;
      VxToast.show(context, msg: loggedIn);
      await openLandingForUser(credential!.user!);
    } catch (e) {
      auth.signOut();
      VxToast.show(context, msg: e.toString());
      controller.isLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {

    return bgWidget(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Center(
              child: Column(
                children: [
                  (context.screenHeight * 0.1).heightBox,
                  appLogoWidget(),
                  10.heightBox,
                  (isSellerMode
                          ? "Create your seller account"
                          : "Join the $appname")
                      .text
                      .fontFamily(bold)
                      .color(redColor)
                      .size(18)
                      .make(),
                  15.heightBox,
                  Obx(
                    () => Column(
                        children: [
                        if (isSellerMode) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.orange.withOpacity(0.2),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.storefront,
                                  color: Colors.orange,
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '⭐ Seller Account Mode',
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontFamily: bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          10.heightBox,
                        ],
                        // name
                        customTextField(
                          title: name,
                          hint: nameHint,
                          controller: nameController,
                          focusNode: _nameFocus,
                          textInputAction: TextInputAction.next,
                        ),
                        // email
                        customTextField(
                          title: email,
                          hint: emailHint,
                          controller: emailController,
                          focusNode: _emailFocus,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                        ),
                        // password
                        customTextField(
                          title: password,
                          hint: passwordHint,
                          controller: passwordController,
                          isPass: true,
                          focusNode: _passwordFocus,
                          textInputAction: TextInputAction.next,
                        ),
                        // retype password
                        customTextField(
                          title: retypePassword,
                          hint: passwordHint,
                          controller: retypePasswordController,
                          isPass: true,
                          focusNode: _retypePasswordFocus,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _handleSignup(),
                        ),
                        // forget pass
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: forgetPass.text
                                .color(Vx.blue500)
                                .make(),
                          ),
                        ),
                        // check policy
                        Row(
                          children: [
                            Checkbox(
                              checkColor: whiteColor,
                              activeColor: redColor,
                              value: isCheck,
                              onChanged: (newValue) {
                                setState(() {
                                  isCheck = newValue;
                                });
                              },
                            ),
                            10.widthBox,
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "I agree to the ",
                                      style: TextStyle(
                                        color: fontGrey,
                                        fontFamily: regular,
                                      ),
                                    ),
                                    TextSpan(
                                      text: termAndConditions,
                                      style: TextStyle(
                                        color: redColor,
                                        fontFamily: regular,
                                      ),
                                    ),
                                    TextSpan(
                                      text: " & ",
                                      style: TextStyle(
                                        color: fontGrey,
                                        fontFamily: regular,
                                      ),
                                    ),
                                    TextSpan(
                                      text: privacyPolicy,
                                      style: TextStyle(
                                        color: redColor,
                                        fontFamily: regular,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        5.heightBox,
                        // signup button
                        controller.isLoading.value
                            ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(
                                  redColor,
                                ),
                              )
                            : ourButton(
                                color: isCheck == true
                                    ? (isSellerMode ? Colors.orange : redColor)
                                    : lightGrey,
                                title: isSellerMode ? 'Create Seller Account' : signup,
                                textColor: whiteColor,
                                onPress: _handleSignup,
                              ).box
                              .width(context.screenWidth - 50)
                              .make(),
                        10.heightBox,
                        // return to log in
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: alreadyHaveAccount,
                                style: TextStyle(
                                  color: fontGrey,
                                  fontFamily: bold,
                                ),
                              ),
                              TextSpan(
                                text: login,
                                style: TextStyle(
                                  color: redColor,
                                  fontFamily: bold,
                                ),
                              ),
                            ],
                          ),
                        ).onTap(() {
                          Get.back();
                        }),
                      ],
                    ).box.white.rounded
                    .padding(const EdgeInsets.all(16))
                    .width(context.screenWidth - 70)
                    .shadowSm
                    .make(),
                  ),
                ],
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, right: 14),
                  child: Tooltip(
                    message: isSellerMode
                        ? 'Switch to Customer'
                        : 'Switch to Seller',
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          isSellerMode = !isSellerMode;
                        });
                        
                        setState(() {
                          isCheck = false;
                        });
                        emailController.clear();
                        nameController.clear();
                        passwordController.clear();
                        retypePasswordController.clear();
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: isSellerMode 
                            ? Colors.orange.withOpacity(0.2) 
                            : whiteColor.withOpacity(0.18),
                        disabledBackgroundColor: whiteColor.withOpacity(0.25),
                        foregroundColor: isSellerMode ? Colors.orange : Colors.black,
                        disabledForegroundColor: Colors.grey,
                      ),
                      icon: Icon(
                        isSellerMode
                            ? Icons.person_outline
                            : Icons.storefront_outlined,
                        color: isSellerMode ? Colors.orange : Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}