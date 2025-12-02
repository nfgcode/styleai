import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../page/auth/login_page.dart';
import '../page/home_page.dart';

/// Auth Gate - Automatically redirects users based on authentication status
/// 
/// This widget listens to Supabase auth state changes and navigates
/// to the appropriate page (login or home) based on user session.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Wait a bit for Supabase to initialize
    await Future.delayed(const Duration(milliseconds: 100));
    
    final session = Supabase.instance.client.auth.currentSession;
    
    if (mounted) {
      if (session != null) {
        // User is logged in, navigate to home
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        // User is not logged in, navigate to login
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SupabaseLoginPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

/// Stream-based Auth Gate - Listens to real-time auth state changes
/// 
/// This is a more advanced version that uses stream to automatically
/// update when user logs in or out without manual navigation.
class StreamAuthGate extends StatelessWidget {
  const StreamAuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Check if user is authenticated
        final session = snapshot.hasData ? snapshot.data?.session : null;

        if (session != null) {
          // User is logged in
          return const HomePage();
        } else {
          // User is not logged in
          return const SupabaseLoginPage();
        }
      },
    );
  }
}

/// Auth State Provider - For more complex state management
/// 
/// Use this if you need to access auth state from multiple widgets
class AuthStateProvider extends InheritedWidget {
  final User? user;
  final bool isLoading;

  const AuthStateProvider({
    super.key,
    required this.user,
    required this.isLoading,
    required super.child,
  });

  static AuthStateProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AuthStateProvider>();
  }

  @override
  bool updateShouldNotify(AuthStateProvider oldWidget) {
    return user != oldWidget.user || isLoading != oldWidget.isLoading;
  }
}

/// Wrapper widget that provides auth state to children
class AuthStateWrapper extends StatefulWidget {
  final Widget child;

  const AuthStateWrapper({super.key, required this.child});

  @override
  State<AuthStateWrapper> createState() => _AuthStateWrapperState();
}

class _AuthStateWrapperState extends State<AuthStateWrapper> {
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initAuthListener();
  }

  void _initAuthListener() {
    // Get initial auth state
    _user = Supabase.instance.client.auth.currentUser;
    setState(() => _isLoading = false);

    // Listen to auth state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (mounted) {
        setState(() {
          _user = data.session?.user;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthStateProvider(
      user: _user,
      isLoading: _isLoading,
      child: widget.child,
    );
  }
}

/// Auth Guard - Protect routes that require authentication
/// 
/// Wrap any page with this to ensure only logged-in users can access it
class AuthGuard extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const AuthGuard({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      return child;
    } else {
      return fallback ?? const SupabaseLoginPage();
    }
  }
}

/// Role-based Auth Guard - Protect routes based on user roles
/// 
/// Example: Only admins can access certain pages
class RoleGuard extends StatelessWidget {
  final Widget child;
  final List<String> allowedRoles;
  final Widget? fallback;

  const RoleGuard({
    super.key,
    required this.child,
    required this.allowedRoles,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      final userRole = user.userMetadata?['role'] as String?;
      
      if (userRole != null && allowedRoles.contains(userRole)) {
        return child;
      }
    }

    return fallback ?? 
      Scaffold(
        appBar: AppBar(title: const Text('Access Denied')),
        body: const Center(
          child: Text('You do not have permission to access this page.'),
        ),
      );
  }
}
