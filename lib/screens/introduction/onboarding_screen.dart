import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:salon_app/components/bottom_navigationbar.dart';
import 'package:salon_app/provider/user_provider.dart';
import 'package:salon_app/utils/app_theme.dart';

import '../../controller/auth_controller.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  ScrollController controller = ScrollController();
  double controllerOffset = 0.0;
  int index = 0;
  bool _isSigningIn = false;
  void move() {
    controller.animateTo(controllerOffset + 392,
        curve: Curves.easeIn, duration: const Duration(milliseconds: 500));
  }

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 3), () {
      move();
      setState(() {
        controllerOffset += 392;
      });
    });

    Future.delayed(const Duration(seconds: 8), () {
      move();
      setState(() {
        controllerOffset += 392;
      });
    });
    super.initState();
  }

  List imgUrl = [
    "https://thumbs.dreamstime.com/b/hairdresser-protective-mask-cutting-hair-curly-african-american-client-beauty-salon-free-space-195792989.jpg",
    "https://as2.ftcdn.net/v2/jpg/02/65/48/75/1000_F_265487582_hg1t4uvUI33fhRDTdxVyHTNjv0F5WdX4.jpg",
    "https://www.nextinsurance.com/wp-content/uploads/2018/05/shutterstock_256912663-802x454.jpg",
  ];

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return Scaffold(
        backgroundColor: Colors.grey[100],
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SingleChildScrollView(
              controller: controller,
              scrollDirection: Axis.horizontal,
              child: Row(
                  children: imgUrl
                      .map((e) => BannerImages(
                            height: height,
                            width: width,
                            image: e,
                          ))
                      .toList()),
            ),
            SingleChildScrollView(
              controller: controller,
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(seconds: 1),
                      curve: Curves.fastOutSlowIn,
                      height: 5,
                      width: 30,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: controllerOffset < 300
                              ? const Color(0xff721c80).withOpacity(0.8)
                              : Colors.grey.withOpacity(0.8)),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    AnimatedContainer(
                      duration: const Duration(seconds: 1),
                      curve: Curves.fastOutSlowIn,
                      height: 5,
                      width: 30,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color:
                              300 < controllerOffset && controllerOffset < 600
                                  ? const Color(0xff721c80).withOpacity(0.8)
                                  : Colors.grey.withOpacity(0.8)),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    AnimatedContainer(
                      duration: const Duration(seconds: 1),
                      curve: Curves.fastOutSlowIn,
                      height: 5,
                      width: 30,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color:
                              600 < controllerOffset && controllerOffset < 800
                                  ? const Color(0xff721c80).withOpacity(0.8)
                                  : Colors.grey.withOpacity(0.8)),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                  ],
                ),
              ),
            ),
            const Text(
              "The Professional Specialists",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                "Book appointments with top salon specialists.\nDiscover styles, services & exclusive offers.",
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                    height: 1.5),
                textAlign: TextAlign.center,
              ),
            ),
            GestureDetector(
              onTap: _isSigningIn
                  ? null
                  : () {
                      setState(() => _isSigningIn = true);
                      Authentication.signInWithGoogle(context: context)
                          .then(((value) {
                        if (value != null) {
                          userProvider.setUser(value);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (ctx) =>
                                    const BottomNavigationComponent()),
                          );
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                    'Sign in failed. Please try again.'),
                                backgroundColor: Colors.red[700],
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      })).whenComplete(() {
                        if (mounted) setState(() => _isSigningIn = false);
                      });
                    },
              child: Container(
                margin: const EdgeInsets.only(bottom: 30),
                height: 50,
                width: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: AppTheme.primaryGradient,
                ),
                child: Center(
                    child: _isSigningIn
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Get Started",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          )),
              ),
            )
          ],
        ));
  }
}

class BannerImages extends StatelessWidget {
  final String image;
  const BannerImages({
    Key? key,
    required this.image,
    required this.height,
    required this.width,
  }) : super(key: key);

  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1.8 * (height / 3),
      width: width,
      child: Image.network(
        image,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.grey[200],
          child: const Center(
            child: Icon(Icons.image_outlined, size: 60, color: Colors.grey),
          ),
        ),
        loadingBuilder: (_, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[100],
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.primaryColor,
              ),
            ),
          );
        },
      ),
    );
  }
}
