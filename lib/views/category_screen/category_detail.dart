import 'package:e_mart/consts/consts.dart';
import 'package:e_mart/views/category_screen/item_detail.dart';
import 'package:e_mart/widget_common/bg_widget.dart';
import 'package:get/get.dart';

class CategoryDetail extends StatelessWidget {
  final String? title;

  const CategoryDetail({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return bgWidget(
      child: Scaffold(
        appBar: AppBar(title: title!.text.fontFamily(bold).white.make()),
        body: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    6,
                    (index) => "Baby Clothing".text
                        .fontFamily(semibold)
                        .color(darkFontGrey)
                        .makeCentered()
                        .box
                        .white
                        .rounded
                        .size(150, 60)
                        .margin(const EdgeInsets.symmetric(horizontal: 4))
                        .make(),
                  ),
                ),
              ),
              20.heightBox,
              // items container
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: 6,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    mainAxisExtent: 250,
                  ),
                  itemBuilder: (context, index) {
                    return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(
                              imgP5,
                              width: 200,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                            "Laptop 4GB/64GB".text
                                .fontFamily(semibold)
                                .color(darkFontGrey)
                                .make(),
                            10.heightBox,
                            "\$600".text
                                .color(redColor)
                                .fontFamily(bold)
                                .size(16)
                                .make(),
                            10.heightBox,
                          ],
                        ).box.white.roundedSM
                        .margin(const EdgeInsets.symmetric(horizontal: 4))
                        .padding(const EdgeInsets.all(12))
                        .outerShadowSm
                        .make()
                        .onTap(() {
                          Get.to(() => const ItemDetail(title: "Dummy Item"));
                        });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
