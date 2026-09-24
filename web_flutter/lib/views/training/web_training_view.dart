import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/network/web_api_service.dart';
import '../../core/theme/app_theme.dart';

class WebTrainingView extends StatefulWidget {
  const WebTrainingView({super.key});

  @override
  State<WebTrainingView> createState() => _WebTrainingViewState();
}

class _WebTrainingViewState extends State<WebTrainingView> {
  List<dynamic> _courses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    final api = Provider.of<WebApiService>(context, listen: false);
    setState(() => _isLoading = true);
    final data = await api.getCourses();
    if (mounted) {
      setState(() {
        _courses = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isMobile = screenWidth < 680;
        final cols = screenWidth >= 1100 ? 3 : (screenWidth >= 650 ? 2 : 1);
        final ratio = cols == 1 ? 2.2 : 1.35;

        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16.0 : 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Accredited Vocational Training Programs',
                          style: TextStyle(
                            fontSize: isMobile ? 18 : 22,
                            fontWeight: FontWeight.bold,
                            color: WebColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Courses configured with certified skill criteria, capacity, and candidate referral tracking',
                          style: TextStyle(fontSize: isMobile ? 11 : 13, color: WebColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchCourses),
                ],
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: WebColors.primaryGreen))
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: ratio,
                      ),
                      itemCount: _courses.length,
                      itemBuilder: (context, index) {
                        final c = _courses[index];
                        final enrolled = c['enrolledCount'] ?? 0;
                        final capacity = c['capacity'] ?? 30;

                    return Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: WebColors.borderSubtle),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: WebColors.accentTeal.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    c['category'] ?? 'Vocational',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: WebColors.accentTeal),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text('${c['durationWeeks']} Weeks', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: WebColors.textMuted)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(c['title'] ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text(c['providerName'] ?? '', style: const TextStyle(fontSize: 12, color: WebColors.textMuted)),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Enrollment: $enrolled / $capacity',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(c['status'] ?? 'OPEN', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: WebColors.successGreen)),
                            ],
                          ),
                        ],
                      ),
                    );
                      },
                    ),
            ],
          ),
        );
      },
    );
  }
}
