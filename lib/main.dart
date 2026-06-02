import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/app_colors.dart';
import 'app/app_routes.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/home_viewmodel.dart';
import 'viewmodels/document_viewmodel.dart';
import 'viewmodels/report_viewmodel.dart';
import 'viewmodels/profile_viewmodel.dart';
import 'views/splash/splash_screen.dart';
import 'views/landing/landing_page.dart';
import 'views/auth/login_page.dart';
import 'views/auth/register_page.dart';
import 'views/home/home_page.dart';
import 'views/project/project_page.dart';
import 'views/reports/reports_page.dart';
import 'views/profile/profile_page.dart';
import 'views/notification/notification_page.dart';
import 'views/profile/user_information_page.dart';
import 'views/profile/edit_profile_page.dart';
import 'views/profile/change_password_page.dart';
import 'views/reports/document_detail_page.dart';
import 'app/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SandanaTrackFlowApp());
}

class SandanaTrackFlowApp extends StatelessWidget {
  const SandanaTrackFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => DocumentViewModel()),
        ChangeNotifierProvider(create: (_) => ReportViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
      ],
      child: MaterialApp(
        title: 'SandanaTrackFlow',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
          fontFamily: 'Roboto',
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          useMaterial3: true,
        ),
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (_) => const SplashScreen(),
          AppRoutes.landing: (_) => const LandingPage(),
          AppRoutes.login: (_) => const LoginPage(),
          AppRoutes.register: (_) => const RegisterPage(),
          AppRoutes.home: (_) => const HomePage(),
          AppRoutes.project: (_) => const ProjectPage(),
          AppRoutes.reports: (_) => const ReportsPage(),
          AppRoutes.profile: (_) => const ProfilePage(),
          AppRoutes.notification: (_) => const NotificationPage(),
          AppRoutes.userInfo: (_) => const UserInformationPage(),
          AppRoutes.editProfile: (_) => const EditProfilePage(),
          AppRoutes.changePassword: (_) => const ChangePasswordPage(),
          AppRoutes.documentDetail: (_) => const DocumentDetailPage(),
        },
      ),
    );
  }
}