
import 'package:admin_notifier/screens/home_screen.dart';
import 'package:admin_notifier/screens/login_screen.dart';
import 'package:admin_notifier/screens/signup_screen.dart';
import 'package:admin_notifier/screens/splash_screen.dart';
import 'package:go_router/go_router.dart';

class Routes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String otpverification = '/otpverification';

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
    ],
  );
}
  