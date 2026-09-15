import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../features/auth/services/auth_service.dart';
import '../pages/home_page.dart';
import '../pages/login_page.dart';
import '../pages/register_page.dart';
import 'theme.dart';

class AM5RoyalApp extends StatefulWidget {
  const AM5RoyalApp({
    super.key,
  });

  @override
  State<AM5RoyalApp> createState() => _AM5RoyalAppState();
}

class _AM5RoyalAppState extends State<AM5RoyalApp> {
  final AuthService _auth = AuthService.instance;

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  HomePage? _homePage;

  @override
  void initState() {
    super.initState();

    // Create HomePage ONLY ONCE.
    // This is very important because HomePage owns the
    // selected navbar section state.
    _homePage = HomePage(
      key: const ValueKey<String>('am5royal-home-page'),
      authService: _auth,
    );

    _auth.addListener(_onAuthChanged);

    _auth.initialize();
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  // ---------------------------------------------------------------------------
  // BROWSER ROUTE
  // ---------------------------------------------------------------------------

  String _getCurrentRoute() {
    if (!kIsWeb) {
      return '/';
    }

    final Uri uri = Uri.base;

    String route = uri.fragment.trim();

    if (route.isEmpty) {
      return '/';
    }

    if (route.startsWith('#')) {
      route = route.substring(1);
    }

    if (!route.startsWith('/')) {
      route = '/$route';
    }

    return _normalizeRoute(route);
  }

  String _normalizeRoute(String route) {
    String normalized = route.trim();

    if (normalized.isEmpty) {
      return '/';
    }

    if (normalized.startsWith('#')) {
      normalized = normalized.substring(1);
    }

    if (!normalized.startsWith('/')) {
      normalized = '/$normalized';
    }

    if (normalized.length > 1 && normalized.endsWith('/')) {
      normalized = normalized.substring(
        0,
        normalized.length - 1,
      );
    }

    switch (normalized) {
      case '/':
        return '/';

      case '/login':
        return '/login';

      case '/register':
        return '/register';

      // HomePage internal sections.
      //
      // These are NOT separate Flutter Navigator pages.
      // HomePage itself controls them using the browser hash.
      case '/services':
        return '/services';

      case '/vendor':
        return '/vendor';

      case '/customer':
        return '/customer';

      case '/freelancer':
        return '/freelancer';

      case '/careers':
        return '/careers';

      case '/contact':
        return '/contact';

      case '/how-it-works':
        return '/how-it-works';

      case '/faqs':
        return '/faqs';

      case '/privacy-policy':
        return '/privacy-policy';

      case '/terms-conditions':
        return '/terms-conditions';

      // Backward-compatible aliases.
      case '/privacy':
        return '/privacy-policy';

      case '/terms-and-conditions':
        return '/terms-conditions';

      default:
        return '/';
    }
  }

  // ---------------------------------------------------------------------------
  // LOGIN
  // ---------------------------------------------------------------------------

  void _openLogin() {
    final NavigatorState? navigator = _navigatorKey.currentState;

    if (navigator == null) {
      return;
    }

    navigator.pushReplacementNamed('/login');
  }

  // ---------------------------------------------------------------------------
  // REGISTER
  // ---------------------------------------------------------------------------

  void _openRegister() {
    final NavigatorState? navigator = _navigatorKey.currentState;

    if (navigator == null) {
      return;
    }

    navigator.pushReplacementNamed('/register');
  }

  // ---------------------------------------------------------------------------
  // INITIAL PAGE
  // ---------------------------------------------------------------------------

  Widget _buildInitialPage() {
    final String route = _getCurrentRoute();

    if (route == '/login') {
      return _buildLoginPage();
    }

    if (route == '/register') {
      return _buildRegisterPage();
    }

    final HomePage? homePage = _homePage;

    if (homePage != null) {
      return homePage;
    }

    // This should practically never be reached because _homePage
    // is created inside initState before build().
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // LOGIN PAGE
  // ---------------------------------------------------------------------------

  Widget _buildLoginPage() {
    return LoginPage(
      onRegisterPressed: _openRegister,
      onLoginSuccess: () {
        _navigatorKey.currentState?.pushReplacementNamed('/');
      },
    );
  }

  // ---------------------------------------------------------------------------
  // REGISTER PAGE
  // ---------------------------------------------------------------------------

  Widget _buildRegisterPage() {
    return RegisterPage(
      onLoginPressed: _openLogin,
      onRegisterSuccess: () {
        _navigatorKey.currentState?.pushReplacementNamed('/');
      },
    );
  }

  // ---------------------------------------------------------------------------
  // FLUTTER NAVIGATOR ROUTES
  //
  // IMPORTANT:
  //
  // Services / Careers / Freelancer / Contact etc. are NOT Navigator
  // routes. They are sections inside the single HomePage.
  // ---------------------------------------------------------------------------

  Route<dynamic>? _onGenerateRoute(
    RouteSettings settings,
  ) {
    final String routeName = _normalizeRoute(
      settings.name ?? '/',
    );

    switch (routeName) {
      case '/login':
        return MaterialPageRoute<void>(
          settings: const RouteSettings(
            name: '/login',
          ),
          builder: (_) {
            return _buildLoginPage();
          },
        );

      case '/register':
        return MaterialPageRoute<void>(
          settings: const RouteSettings(
            name: '/register',
          ),
          builder: (_) {
            return _buildRegisterPage();
          },
        );

      // IMPORTANT:
      //
      // Every website section returns the SAME HomePage instance.
      //
      // Do NOT create:
      // ServicesPage
      // CareersPage
      // FreelancerPage
      // ContactPage
      //
      // HomePage handles all of them.
      case '/':
      case '/services':
      case '/vendor':
      case '/customer':
      case '/freelancer':
      case '/careers':
      case '/contact':
      case '/how-it-works':
      case '/faqs':
      case '/privacy-policy':
      case '/terms-conditions':
        final HomePage? homePage = _homePage;

        if (homePage == null) {
          return MaterialPageRoute<void>(
            builder: (_) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
          );
        }

        return MaterialPageRoute<void>(
          settings: const RouteSettings(
            name: '/',
          ),
          builder: (_) {
            return homePage;
          },
        );

      default:
        final HomePage? homePage = _homePage;

        if (homePage == null) {
          return MaterialPageRoute<void>(
            builder: (_) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
          );
        }

        return MaterialPageRoute<void>(
          settings: const RouteSettings(
            name: '/',
          ),
          builder: (_) {
            return homePage;
          },
        );
    }
  }

  // ---------------------------------------------------------------------------
  // APP
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AM5 ROYAL',
      theme: AM5RoyalTheme.lightTheme,
      navigatorKey: _navigatorKey,

      // ONE MaterialApp ONLY.
      //
      // We do NOT return another MaterialApp while auth is loading.
      //
      // This keeps Navigator + HomePage stable.
      home: _auth.isLoading ? const _AppLoadingScreen() : _buildInitialPage(),

      onGenerateRoute: _onGenerateRoute,
    );
  }
}

// -----------------------------------------------------------------------------
// LOADING SCREEN
// -----------------------------------------------------------------------------

class _AppLoadingScreen extends StatelessWidget {
  const _AppLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
