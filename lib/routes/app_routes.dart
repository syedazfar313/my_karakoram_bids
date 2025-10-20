// lib/routes/app_routes.dart
import 'package:flutter/material.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/forget_password_screen.dart';
import '../screens/client/client_home.dart';
import '../screens/contractor/contractor_home.dart';
import '../screens/admin/admin_home.dart'; // ✅ NEW IMPORT
import '../screens/client/post_project.dart';
import '../screens/contractor/browse_projects.dart';
import '../screens/contractor/project_details.dart';
import '../screens/common/chat_screen.dart';
import '../models/user.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forget = '/forget';
  static const String clientHome = '/client/home';
  static const String contractorHome = '/contractor/home';
  static const String adminHome = '/admin/home'; // ✅ NEW ROUTE
  static const String postProject = '/client/post-project';
  static const String browseProjects = '/contractor/browse-projects';
  static const String projectDetails = '/contractor/project-details';
  static const String chat = '/chat';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());

      case forget:
        return MaterialPageRoute(builder: (_) => const ForgetPasswordScreen());

      case clientHome:
        final user = settings.arguments as UserModel;
        return MaterialPageRoute(builder: (_) => ClientHome(user: user));

      case contractorHome:
        final user = settings.arguments as UserModel;
        return MaterialPageRoute(builder: (_) => ContractorHome(user: user));

      // ✅ NEW ADMIN ROUTE
      case adminHome:
        final user = settings.arguments as UserModel;
        return MaterialPageRoute(builder: (_) => AdminHome(user: user));

      case postProject:
        return MaterialPageRoute(
          builder: (_) => PostProjectScreen(
            onProjectPosted: (p) => debugPrint("Project posted: $p"),
          ),
        );

      case browseProjects:
        return MaterialPageRoute(
          builder: (_) =>
              BrowseProjectsScreen(projects: const [], onBid: (_) {}),
        );

      case projectDetails:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ContractorProjectDetailsScreen(
            project: args['project'],
            onBid: args['onBid'],
          ),
        );

      case chat:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ChatScreen(
            chatId: args['chatId'] ?? '',
            otherUserId: args['otherUserId'] ?? '',
            otherUserName: args['otherUserName'] ?? args['userName'] ?? 'User',
            otherUserAvatar:
                args['otherUserAvatar'] ??
                args['userImage'] ??
                'assets/images/avatar.png',
            currentUserId: args['currentUserId'] ?? 'demo_user',
            currentUserName: args['currentUserName'] ?? 'You',
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Page not found'))),
        );
    }
  }
}
