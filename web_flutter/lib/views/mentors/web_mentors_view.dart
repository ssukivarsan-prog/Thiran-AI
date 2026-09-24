import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/network/web_api_service.dart';
import '../../core/theme/app_theme.dart';

class WebMentorsView extends StatefulWidget {
  const WebMentorsView({super.key});

  @override
  State<WebMentorsView> createState() => _WebMentorsViewState();
}

class _WebMentorsViewState extends State<WebMentorsView> {
  List<dynamic> _mentors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMentors();
  }

  Future<void> _fetchMentors() async {
    final api = Provider.of<WebApiService>(context, listen: false);
    setState(() => _isLoading = true);
    final data = await api.getMentors();
    if (mounted) {
      setState(() {
        _mentors = data;
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
                          'Accredited Mentors & Counselors Network',
                          style: TextStyle(
                            fontSize: isMobile ? 18 : 22,
                            fontWeight: FontWeight.bold,
                            color: WebColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Verified regional mentors providing candidate coaching, practical skill checks, and appointments',
                          style: TextStyle(fontSize: isMobile ? 11 : 13, color: WebColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchMentors),
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
                      itemCount: _mentors.length,
                      itemBuilder: (context, index) {
                        final m = _mentors[index];
                        final expertise = List<String>.from(m['expertise'] ?? []);

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
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: WebColors.primaryGreen.withValues(alpha: 0.12),
                                    child: Text(
                                      m['name'].substring(0, 1),
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: WebColors.primaryGreen),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(m['name'] ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                        Text(m['title'] ?? '', style: const TextStyle(fontSize: 11, color: WebColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.verified, size: 16, color: WebColors.successGreen),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 4,
                                runSpacing: 4,
                                children: expertise.take(3).map((exp) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: WebColors.surfaceBg,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(exp, style: const TextStyle(fontSize: 10, color: WebColors.textDark)),
                                )).toList(),
                              ),
                              const Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${m['menteesCount'] ?? 15} Mentees Active', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: WebColors.textMuted)),
                                  Text(m['availabilityStatus'] ?? 'AVAILABLE', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: WebColors.successGreen)),
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
