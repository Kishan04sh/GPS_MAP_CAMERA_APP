
import 'package:flutter/cupertino.dart';
import '../../../core/constants/app_colors.dart';

class GalleryTab extends StatelessWidget {
  const GalleryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      height: size.height,
      color: AppColors.blueActionGradient.colors.first.withOpacity(0.05),
      child: const Center(
        child: Text(
          'Gallery Screen',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}