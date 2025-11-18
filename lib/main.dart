import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/theme/app_theme.dart';
import 'routes/app_routes.dart';
import 'views/login/login_screen.dart';
import 'views/customer_list/customer_list_screen.dart';
import 'controllers/auth_controller.dart';
import 'controllers/customer_controller.dart';
import 'core/utils/storage_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Customer Management',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialBinding: AppBinding(),
      initialRoute: AppRoutes.login,
      getPages: [
        GetPage(
          name: AppRoutes.login,
          page: () => const LoginScreen(),
        ),
        GetPage(
          name: AppRoutes.customers,
          page: () => const CustomerListScreen(),
        ),
      ],
      home: FutureBuilder<bool>(
        future: StorageUtils.isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // Navigate based on login status
          if (snapshot.data == true) {
            // User is logged in, go to customer list
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Get.offAllNamed(AppRoutes.customers);
            });
          } else {
            // User is not logged in, go to login
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Get.offAllNamed(AppRoutes.login);
            });
          }

          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }
}

/// Dependency injection binding
class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize controllers immediately (put instead of lazyPut)
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.put<CustomerController>(CustomerController(), permanent: true);
  }
}