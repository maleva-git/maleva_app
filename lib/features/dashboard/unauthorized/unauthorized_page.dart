import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/app_preferences.dart';
import '../../../../core/theme/palette.dart';
import '../../../../core/theme/app_typography.dart';

class UnauthorizedPage extends StatelessWidget {
  const UnauthorizedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.grey100,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text('Maleva', style: AppTypography.heading1(color: Palette.textDark)),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Palette.blue400.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.admin_panel_settings_outlined,
                  size: 80,
                  color: Palette.blue400,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Welcome to Maleva!',
                style: AppTypography.heading1(color: Palette.textDark),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'It looks like your account has not been assigned a specific dashboard yet. Kindly reach out to your Admin or HR department to configure your access permissions.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyLarge(color: Palette.textMuted).copyWith(height: 1.5),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Palette.blue600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    await AppPreferences.clearOnLogout();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                  child: Text(
                    'Back to Login',
                    style: AppTypography.heading2(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
