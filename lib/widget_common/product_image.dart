import 'package:e_mart/consts/consts.dart';

class ProductImage extends StatelessWidget {
  final String source;
  final double? width;
  final double? height;
  final BoxFit fit;

  const ProductImage({
    super.key,
    required this.source,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (source.startsWith('http://') || source.startsWith('https://')) {
      return Image.network(
        source,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) => _placeholder(),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return _placeholder(showProgress: true);
        },
      );
    }

    if (source.isNotEmpty) {
      return Image.asset(
        source,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) => _placeholder(),
      );
    }

    return _placeholder();
  }

  Widget _placeholder({bool showProgress = false}) {
    return Container(
      width: width,
      height: height,
      color: lightGrey,
      alignment: Alignment.center,
      child: showProgress
          ? const CircularProgressIndicator(color: redColor)
          : const Icon(Icons.image_outlined, color: fontGrey, size: 42),
    );
  }
}
