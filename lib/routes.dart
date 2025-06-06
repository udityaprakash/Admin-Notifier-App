import 'package:admin_notifier/screens/home_screen.dart';
import 'package:admin_notifier/screens/login_screen.dart';
import 'package:admin_notifier/screens/pending_approval_screen.dart';
import 'package:admin_notifier/screens/profile_screen.dart';
import 'package:admin_notifier/screens/registered_user_screen.dart';
import 'package:admin_notifier/screens/send_notification_screen.dart';
import 'package:admin_notifier/screens/signup_screen.dart';
import 'package:admin_notifier/screens/splash_screen.dart';
import 'package:go_router/go_router.dart';

class Routes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String pendingApproval = '/pendingapproval';
  static const String sendNotification = '/sendnotification';
  static const String registeredUsers = '/registeredUsers';

  final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const MyHomePage()),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/pendingapproval',
        builder: (context, state) => const PendingApprovalScreen(),
      ),
      GoRoute(
        path: '/sendnotification',
        builder: (context, state) => const SendNotificationScreen(),
      ),
      GoRoute(
        path: '/registeredUsers',
        builder: (context, state) => const RegisteredPeoples(),
      ),
    ],
  );
}
