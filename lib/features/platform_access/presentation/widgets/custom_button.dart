import 'package:flutter/material.dart';

class CustomImageButton extends StatelessWidget {
  final String assetPath; // Resim için asset yolu
  final VoidCallback onTap;
  final Color backgroundColor; // Yeni: Arka plan rengi

  const CustomImageButton({
    required this.assetPath,
    required this.onTap,
    this.backgroundColor = Colors.transparent, // Varsayılan: Şeffaf
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    // Ekran genişliğine göre dinamik boyutlandırma
    double buttonSize =
        screenWidth * 0.115; // %12 oranında genişlik (45 yerine dinamik)

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: backgroundColor, // Arka plan rengi
          borderRadius: BorderRadius.circular(
              buttonSize * 0.3), // Köşelerin yuvarlatılması
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5), // Gölgelendirme
              spreadRadius: screenWidth * 0.005,
              blurRadius: screenWidth * 0.02,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(buttonSize * 0.3),
          child: Image.asset(
            assetPath, // Asset yolu
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
