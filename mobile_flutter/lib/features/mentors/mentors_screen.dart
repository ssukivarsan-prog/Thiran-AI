import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_strings.dart';
import '../../core/models/models.dart';
import '../../core/network/api_service.dart';
import '../../core/theme/app_theme.dart';

class MentorsScreen extends StatefulWidget {
  const MentorsScreen({super.key});

  @override
  State<MentorsScreen> createState() => _MentorsScreenState();
}

class _MentorsScreenState extends State<MentorsScreen> {
  List<MentorModel> _mentors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMentors();
  }

  Future<void> _fetchMentors() async {
    final api = Provider.of<ApiService>(context, listen: false);
    setState(() => _isLoading = true);
    final m = await api.getMentors();
    if (mounted) {
      setState(() {
        _mentors = m;
        _isLoading = false;
      });
    }
  }

  void _showRequestDialog(MentorModel mentor, AppStrings strings) {
    final topicCtrl = TextEditingController(
      text: strings.currentLanguage == 'ta'
          ? 'சூரிய மின் பயிற்சி மற்றும் சான்றிதழ் வழிகாட்டல்'
          : 'Rooftop Solar Certification Guidance',
    );
    final msgCtrl = TextEditingController(
      text: strings.currentLanguage == 'ta'
          ? 'செய்முறை தேர்வு மற்றும் களப்பணிக்கு உங்கள் வழிகாட்டலை விரும்புகிறேன்.'
          : 'I would like your guidance on passing the practical assessment exam.',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(strings.tr('connectWithMentor')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: topicCtrl,
              decoration: InputDecoration(
                labelText: strings.currentLanguage == 'ta' ? 'ஆலோசனை தலைப்பு' : 'Topic',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: msgCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: strings.currentLanguage == 'ta' ? 'உங்கள் செய்தி' : 'Message',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(strings.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              final api = Provider.of<ApiService>(context, listen: false);
              await api.requestMentor(mentor.id, topicCtrl.text.trim(), msgCtrl.text.trim());
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.primaryGreen,
                  content: Text(strings.tr('mentorshipRequestSent')),
                ),
              );
            },
            child: Text(strings.tr('sendRequest')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = Provider.of<AppStrings>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.tr('mentors')),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : RefreshIndicator(
              onRefresh: _fetchMentors,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: _mentors.length,
                itemBuilder: (context, index) {
                  final mentor = _mentors[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: AppColors.primaryGreen.withOpacity(0.12),
                              child: Text(
                                mentor.name.substring(0, 1),
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        mentor.name,
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(Icons.verified, color: AppColors.successGreen, size: 16),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${mentor.yearsOfExperience} ${strings.currentLanguage == 'ta' ? 'ஆண்டுகள் அனுபவம்' : 'years experience'} • ${mentor.serviceArea}',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 16),
                                const SizedBox(width: 2),
                                Text(
                                  mentor.rating.toStringAsFixed(1),
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: mentor.expertise.map((exp) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(exp, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 42)),
                          onPressed: () => _showRequestDialog(mentor, strings),
                          icon: const Icon(Icons.handshake_outlined, size: 18),
                          label: Text(strings.tr('connectWithMentor')),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
