import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_strings.dart';
import '../../core/network/api_service.dart';
import '../../core/theme/app_theme.dart';
import 'voice_onboarding_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController(text: '+919840112301');
  final TextEditingController _otpController = TextEditingController(text: '123456');
  bool _otpSent = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = Provider.of<AppStrings>(context);
    final apiService = Provider.of<ApiService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.tr('login')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                strings.tr('enterMobileNumber'),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              Text(
                strings.tr('loginSubtitle'),
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: strings.tr('mobileNumberInput'),
                  prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.primaryGreen),
                ),
              ),
              const SizedBox(height: 16),
              if (_otpSent) ...[
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: strings.tr('passcodeInput'),
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primaryGreen),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        setState(() => _isLoading = true);
                        if (!_otpSent) {
                          setState(() {
                            _otpSent = true;
                            _isLoading = false;
                          });
                        } else {
                          await apiService.loginAsRole(
                            role: 'BENEFICIARY',
                            phone: _phoneController.text.trim(),
                          );
                          setState(() => _isLoading = false);
                          if (mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const VoiceOnboardingScreen()),
                            );
                          }
                        }
                      },
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(!_otpSent
                        ? strings.tr('getPasscode')
                        : strings.tr('verifyAndContinue')),
              ),
              const SizedBox(height: 32),
              const Divider(color: AppColors.borderLight),
              const SizedBox(height: 16),
              Text(
                strings.tr('quickDemoProfiles'),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              _buildPersonaButton(
                name: strings.currentLanguage == 'ta'
                    ? 'அருண் குமார் (சூரிய மின் பயிற்சி)'
                    : 'Arun Kumar (Solar Technical Apprentice)',
                phone: '+919840112301',
                lang: strings.currentLanguage,
              ),
              _buildPersonaButton(
                name: strings.currentLanguage == 'ta'
                    ? 'மீனாட்சி சுந்தரம் (ஆடை தையல் கலைஞர்)'
                    : 'Meenakshi Sundaram (Garments & Tailoring)',
                phone: '+919840112302',
                lang: strings.currentLanguage,
              ),
              _buildPersonaButton(
                name: strings.currentLanguage == 'ta'
                    ? 'சுரேஷ் மணி (விவசாய ட்ரோன் இயக்கம்)'
                    : 'Suresh Mani (Agri-Tech Drone Operator)',
                phone: '+919840112303',
                lang: strings.currentLanguage,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonaButton({required String name, required String phone, required String lang}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        onPressed: () {
          setState(() {
            _phoneController.text = phone;
            _otpSent = true;
          });
          Provider.of<AppStrings>(context, listen: false).setLanguage(lang);
        },
        child: Row(
          children: [
            const Icon(Icons.person_outline, size: 20, color: AppColors.primaryGreen),
            const SizedBox(width: 10),
            Expanded(child: Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
          ],
        ),
      ),
    );
  }
}
