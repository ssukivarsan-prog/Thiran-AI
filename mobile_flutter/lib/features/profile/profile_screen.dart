import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_strings.dart';
import '../../core/network/api_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_components.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _openEditProfileSheet(BuildContext context) {
    final strings = Provider.of<AppStrings>(context, listen: false);
    final api = Provider.of<ApiService>(context, listen: false);
    final profile = api.currentProfile;

    final nameCtrl = TextEditingController(text: profile?.fullName ?? '');
    final phoneCtrl = TextEditingController(text: profile?.phone ?? '');
    final locCtrl = TextEditingController(text: profile?.location ?? '');
    final eduCtrl = TextEditingController(text: profile?.educationLevel ?? '');
    final workCtrl = TextEditingController(text: profile?.currentWork ?? '');
    final expCtrl = TextEditingController(text: profile?.previousExperience ?? '');
    final mobilityCtrl = TextEditingController(text: profile?.mobilityConstraints ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            final bottomInset = MediaQuery.of(modalCtx).viewInsets.bottom;
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.88,
              ),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: bottomInset + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        strings.tr('editProfile'),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 22),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: nameCtrl,
                            decoration: InputDecoration(
                              labelText: strings.tr('fullName'),
                              prefixIcon: const Icon(Icons.person_outline, color: AppColors.primaryGreen),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: phoneCtrl,
                            decoration: InputDecoration(
                              labelText: strings.tr('phone'),
                              prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.primaryGreen),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: locCtrl,
                            decoration: InputDecoration(
                              labelText: strings.tr('location'),
                              prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.primaryGreen),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: eduCtrl,
                            decoration: InputDecoration(
                              labelText: strings.tr('education'),
                              prefixIcon: const Icon(Icons.school_outlined, color: AppColors.primaryGreen),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: strings.getSuggestionsForQuestion(0).map((opt) {
                              return ActionChip(
                                label: Text(opt, style: const TextStyle(fontSize: 11)),
                                onPressed: () => setModalState(() => eduCtrl.text = opt),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: workCtrl,
                            decoration: InputDecoration(
                              labelText: strings.tr('currentWork'),
                              prefixIcon: const Icon(Icons.work_outline, color: AppColors.primaryGreen),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: strings.getSuggestionsForQuestion(1).map((opt) {
                              return ActionChip(
                                label: Text(opt, style: const TextStyle(fontSize: 11)),
                                onPressed: () => setModalState(() => workCtrl.text = opt),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: expCtrl,
                            decoration: InputDecoration(
                              labelText: strings.tr('experience'),
                              prefixIcon: const Icon(Icons.history, color: AppColors.primaryGreen),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: strings.getSuggestionsForQuestion(2).map((opt) {
                              return ActionChip(
                                label: Text(opt, style: const TextStyle(fontSize: 11)),
                                onPressed: () => setModalState(() => expCtrl.text = opt),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: mobilityCtrl,
                            decoration: InputDecoration(
                              labelText: strings.tr('mobility'),
                              prefixIcon: const Icon(Icons.directions_bus_outlined, color: AppColors.primaryGreen),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (profile != null) {
                        final updated = profile.copyWith(
                          fullName: nameCtrl.text.trim().isNotEmpty ? nameCtrl.text.trim() : profile.fullName,
                          phone: phoneCtrl.text.trim().isNotEmpty ? phoneCtrl.text.trim() : profile.phone,
                          location: locCtrl.text.trim().isNotEmpty ? locCtrl.text.trim() : profile.location,
                          educationLevel: eduCtrl.text.trim().isNotEmpty ? eduCtrl.text.trim() : profile.educationLevel,
                          currentWork: workCtrl.text.trim().isNotEmpty ? workCtrl.text.trim() : profile.currentWork,
                          previousExperience: expCtrl.text.trim().isNotEmpty ? expCtrl.text.trim() : profile.previousExperience,
                          mobilityConstraints: mobilityCtrl.text.trim().isNotEmpty ? mobilityCtrl.text.trim() : profile.mobilityConstraints,
                        );
                        api.updateCurrentProfile(updated);
                        setState(() {});
                      }
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.primaryGreen,
                          content: Text(strings.tr('profileUpdateSuccess')),
                        ),
                      );
                    },
                    child: Text(strings.tr('saveChanges')),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = Provider.of<AppStrings>(context);
    final api = Provider.of<ApiService>(context);
    final p = api.currentProfile;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.tr('myProfileTitle')),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note, color: AppColors.primaryGreen),
            tooltip: strings.tr('editProfile'),
            onPressed: () => _openEditProfileSheet(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Header Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _openEditProfileSheet(context),
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppColors.primaryGreen.withOpacity(0.15),
                          child: Text(
                            (p?.fullName.isNotEmpty ?? false) ? p!.fullName.substring(0, 1) : 'U',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryGreen,
                            ),
                            child: const Icon(Icons.edit, size: 12, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p?.fullName ?? strings.tr('profile'),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        Text(p?.phone ?? '+919840112301', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        Text(p?.location ?? 'Tamil Nadu', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primaryGreen),
                    tooltip: strings.tr('editProfile'),
                    onPressed: () => _openEditProfileSheet(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // SKILLS SECTION WITH VERIFICATION TIERS
            Text(
              strings.tr('competenciesAndVerification'),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    children: [
                      SkillChip(
                        skillName: strings.currentLanguage == 'ta' ? 'சூரிய ஒளி மின்கல வயரிங்' : 'Solar PV Inverter Wiring',
                        verificationType: 'AI_INFERRED',
                      ),
                      SkillChip(
                        skillName: strings.currentLanguage == 'ta' ? 'சொட்டு நீர் பாசனம்' : 'Drip Irrigation Setup',
                        verificationType: 'VERIFIED',
                      ),
                      SkillChip(
                        skillName: strings.currentLanguage == 'ta' ? 'வீட்டு மின்சார வயரிங்' : 'Domestic Electrical Repair',
                        verificationType: 'SELF_DECLARED',
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    strings.tr('skillsNote'),
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // STRUCTURED DETAILS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  strings.tr('educationAndBackground'),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                TextButton(
                  onPressed: () => _openEditProfileSheet(context),
                  child: Text(strings.tr('editDetail')),
                ),
              ],
            ),
            const SizedBox(height: 6),
            _buildProfileItem(Icons.school, strings.tr('education'), p?.educationLevel ?? '10th Standard'),
            _buildProfileItem(Icons.work, strings.tr('currentWork'), p?.currentWork ?? 'House wiring assistant'),
            _buildProfileItem(Icons.history, strings.tr('experience'), p?.previousExperience ?? '2 years practical wiring'),
            _buildProfileItem(Icons.directions_bus, strings.tr('mobility'), p?.mobilityConstraints ?? 'Local district travel OK'),

            const SizedBox(height: 20),

            // DATA PRIVACY & WITHDRAWAL
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.errorRed,
                side: const BorderSide(color: AppColors.errorRed),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(strings.tr('consentUpdated'))),
                );
              },
              icon: const Icon(Icons.privacy_tip_outlined, size: 18),
              label: Text(strings.tr('manageConsent')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primaryGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
