import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:salon_app/utils/app_theme.dart';

class Carousel extends StatelessWidget {
  const Carousel({
    Key? key,
    this.onBookTap,
  }) : super(key: key);

  final VoidCallback? onBookTap;

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      items: [
        Container(
          height: 40,
          width: 400,
          margin: const EdgeInsets.all(6.0),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(
                    flex: 2,
                  ),
                  const Text(
                    "Look Awesome",
                    style: TextStyle(
                        color: Color(0xffffffff),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  const Text(
                    "& Save Some",
                    style: TextStyle(
                      color: Color(0xffffffff),
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  Btn(
                    text: "Get upto 20% off",
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Check out our latest offers!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const Spacer(),
              Align(
                child: AppTheme.networkImage(
                  url:
                      "https://images.squarespace-cdn.com/content/v1/5e867df9747b0e555c337eef/1589945925617-4NY8TG8F76FH1O0P46FW/Kampaamo-helsinki-hair-design-balayage-hiustenpidennys-varjays.png",
                  width: 120,
                  height: 400,
                  fallbackIcon: Icons.content_cut,
                ),
              ),
            ],
          ),
        ),

        Container(
          height: 40,
          width: 400,
          margin: const EdgeInsets.all(6.0),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(
                    flex: 2,
                  ),
                  const Text(
                    "Book your\nAppointment",
                    style: TextStyle(
                        color: Color(0xffffffff),
                        fontStyle: FontStyle.italic,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  const Text(
                    "Now",
                    style: TextStyle(
                      color: Color(0xffffffff),
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  Btn(
                    text: "Book Here!",
                    onTap: onBookTap,
                  ),
                ],
              ),
              const Spacer(),
              Align(
                child: AppTheme.networkImage(
                  url:
                      "https://img.grouponcdn.com/bynder/2sLSquS1xGWk4QjzYuL7h461CDsJ/2s-2048x1229/v1/sc600x600.jpg",
                  width: 120,
                  height: 400,
                  fallbackIcon: Icons.content_cut,
                ),
              ),
            ],
          ),
        ),

      ],
      options: CarouselOptions(
        //autoPlayInterval: Duration(minutes: 1),
        disableCenter: true,
        reverse: false,
        enableInfiniteScroll: false,
        height: 180.0,
        enlargeCenterPage: true,
        autoPlay: true,
        aspectRatio: 10 / 8,
        autoPlayCurve: Curves.easeInOut,
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        viewportFraction: 0.78,
      ),
    );
  }
}

class Btn extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  const Btn({
    Key? key,
    required this.text,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 30),
        padding: const EdgeInsets.all(12),
        height: 40,
        width: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor.withOpacity(0.8),
              AppTheme.primaryLight.withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
            child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        )),
      ),
    );
  }
}
