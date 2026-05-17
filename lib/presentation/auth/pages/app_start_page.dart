import 'package:flutter/material.dart';
import 'package:rail_one/core/di/injection.dart';
import 'package:rail_one/core/storage/local_storage_service.dart';
import 'package:rail_one/core/theme/app_colors.dart';
import 'package:rail_one/presentation/auth/pages/mpin_login_page.dart';
import 'package:rail_one/presentation/auth/pages/registration_page.dart';

/// Resolves the first screen from persisted user/session state.
class AppStartPage extends StatelessWidget {
  const AppStartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: sl<LocalStorageService>().hasStoredUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: AppColors.authBackground,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.authPrimary),
            ),
          );
        }

        final hasStoredUser = snapshot.data ?? false;
        return hasStoredUser ? const MpinLoginPage() : const RegistrationPage();
      },
    );
  }
}
