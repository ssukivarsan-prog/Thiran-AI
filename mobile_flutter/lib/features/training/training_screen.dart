import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_strings.dart';
import '../../core/models/models.dart';
import '../../core/network/api_service.dart';
import '../../core/theme/app_theme.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  List<CourseModel> _courses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    final api = Provider.of<ApiService>(context, listen: false);
    setState(() => _isLoading = true);
    final c = await api.getCourses();
    if (mounted) {
      setState(() {
        _courses = c;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = Provider.of<AppStrings>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.tr('accreditedTrainings')),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : RefreshIndicator(
              onRefresh: _fetchCourses,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: _courses.length,
                itemBuilder: (context, index) {
                  final course = _courses[index];
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                course.title,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.accentTeal.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${course.durationWeeks} ${strings.tr('weeksDuration')}',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accentTeal),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(course.providerName, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 15, color: AppColors.textMuted),
                            const SizedBox(width: 4),
                            Text('${course.location} • ${course.deliveryMode}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.verified_outlined, size: 15, color: AppColors.successGreen),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                course.certificationName,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.successGreen),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 42)),
                          onPressed: () async {
                            final api = Provider.of<ApiService>(context, listen: false);
                            await api.applyCourse(course.id);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: AppColors.primaryGreen,
                                  content: Text(
                                    strings.currentLanguage == 'ta'
                                        ? 'பயிற்சி சேர்க்கை பரிந்துரை அனுப்பப்பட்டது!'
                                        : 'Training enrollment referral generated successfully!',
                                  ),
                                ),
                              );
                            }
                          },
                          child: Text(
                            strings.currentLanguage == 'ta' ? 'பயிற்சியில் சேரவும்' : 'Enroll in Training',
                          ),
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
