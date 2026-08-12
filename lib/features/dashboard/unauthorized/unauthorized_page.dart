import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/app_preferences.dart';

class UnauthorizedPage extends StatefulWidget {
  const UnauthorizedPage({super.key});

  @override
  State<UnauthorizedPage> createState() => _UnauthorizedPageState();
}

class _UnauthorizedPageState extends State<UnauthorizedPage> {
  @override
  void initState() {
    super.initState();
    _handleAutoLogout();
  }

  Future<void> _handleAutoLogout() async {
    // Wait for 3 seconds to let the user read the message
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;
    
    // Clear user preferences and logout
    await AppPreferences.clearOnLogout();
    
    // Redirect to login page
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.block_outlined,
                size: 80,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 24),
              const Text(
                'Access Denied',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Please contact your IT team. You do not have access to this dashboard.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text(
                'Auto-logging out...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
