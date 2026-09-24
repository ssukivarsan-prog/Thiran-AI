import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/app_theme.dart';
import 'login_screen.dart';

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool dataProcessingConsent = true;
  bool aiAssistanceConsent = true;
  bool whatsAppConsent = true;
  bool ivrPhoneConsent = true;

  @override
  Widget build(BuildContext context) {
    final strings = Provider.of<AppStrings>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.tr('consentTitle')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryGreen.withOpacity(0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.shield_outlined, color: AppColors.primaryGreen, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings.tr('consentHeadline'),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryGreen),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            strings.tr('consentDescription'),
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                strings.tr('consentClauses'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              _buildConsentItem(
                title: strings.tr('clause1_title'),
                desc: strings.tr('clause1_desc'),
                value: dataProcessingConsent,
                onChanged: (val) => setState(() => dataProcessingConsent = val ?? false),
              ),
              _buildConsentItem(
                title: strings.tr('clause2_title'),
                desc: strings.tr('clause2_desc'),
                value: aiAssistanceConsent,
                onChanged: (val) => setState(() => aiAssistanceConsent = val ?? false),
              ),
              _buildConsentItem(
                title: strings.tr('clause3_title'),
                desc: strings.tr('clause3_desc'),
                value: whatsAppConsent,
                onChanged: (val) => setState(() => whatsAppConsent = val ?? false),
              ),
              _buildConsentItem(
                title: strings.tr('clause4_title'),
                desc: strings.tr('clause4_desc'),
                value: ivrPhoneConsent,
                onChanged: (val) => setState(() => ivrPhoneConsent = val ?? false),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: (dataProcessingConsent && aiAssistanceConsent)
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      }
                    : null,
                child: Text(strings.tr('continueAction')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConsentItem({
    required String title,
    required String desc,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryGreen,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
