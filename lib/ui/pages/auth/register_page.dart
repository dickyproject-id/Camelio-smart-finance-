import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/settings_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_popup.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _whatsappController = TextEditingController();
  String _accountType = 'Personal';

  Future<void> _handleRegister() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final pwd = _passwordController.text.trim();
    final whatsapp = _whatsappController.text.trim();

    if (name.isEmpty || email.isEmpty || pwd.isEmpty || whatsapp.isEmpty) {
      CustomPopup.show(
        context: context,
        title: 'Oops!',
        message: settings.translate(
          'Lengkapi semua data dulu ya!',
          'Please complete all fields!',
        ),
        isSuccess: false,
      );
      return;
    }

    final success = await authProvider.registerWithEmail(
      email,
      pwd,
      name,
      email,
      whatsapp,
      _accountType,
    );

    if (success && mounted) {
      CustomPopup.show(
        context: context,
        title: settings.translate('Berhasil! ✨', 'Success! ✨'),
        message: settings.translate(
          'Akun Anda sudah terdaftar. Silakan login.',
          'Your account has been registered. Please login.',
        ),
        isSuccess: true,
        onConfirm: () {
          Navigator.pop(context); // Balik ke Login
        },
      );
    } else {
      if (mounted && authProvider.errorMessage != null) {
        CustomPopup.show(
          context: context,
          title: settings.translate('Gagal', 'Failed'),
          message: authProvider.errorMessage!,
          isSuccess: false,
        );
        authProvider.clearError();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          settings.translate('Daftar Akun', 'Register Account'),
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        iconTheme: IconThemeData(
          color: Theme.of(context).textTheme.titleLarge?.color,
        ),
        actions: [
          Row(
            children: [
              Icon(
                Theme.of(context).brightness == Brightness.dark
                    ? Icons.dark_mode
                    : Icons.light_mode,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                Theme.of(context).brightness == Brightness.dark ? 'ON' : 'OFF',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Switch(
                value: Theme.of(context).brightness == Brightness.dark,
                onChanged: (val) => settings.toggleTheme(val),
                activeThumbColor: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            CustomTextField(
              label: settings.translate('Nama Lengkap', 'Full Name'),
              controller: _nameController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: settings.translate('Email', 'Email'),
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: settings.translate('Nomor WhatsApp', 'WhatsApp Number'),
              controller: _whatsappController,
              hintText: '08123456789',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: settings.translate('Password', 'Password'),
              controller: _passwordController,
              isPassword: true,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _accountType,
              decoration: InputDecoration(
                labelText: settings.translate(
                  'Konteks AI (Mode Akun)',
                  'AI Context (Account Mode)',
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                prefixIcon: const Icon(Icons.storefront_rounded, size: 20),
              ),
              items: [
                DropdownMenuItem<String>(
                  value: 'Personal',
                  child: Text(settings.translate('Pribadi', 'Personal')),
                ),
                DropdownMenuItem<String>(
                  value: 'Business',
                  child: Text(settings.translate('Bisnis', 'Business')),
                ),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() => _accountType = val);
                }
              },
            ),
            const SizedBox(height: 32),
            Consumer<AuthProvider>(
              builder: (context, auth, _) => auth.isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          settings.translate('Buat Akun', 'Create Account'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
