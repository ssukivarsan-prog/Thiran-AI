import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_strings.dart';
import '../../core/models/models.dart';
import '../../core/network/api_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_components.dart';
import '../chat/chat_screen.dart';
import '../eligibility/become_eligible_screen.dart';
import '../mentors/mentors_screen.dart';
import '../opportunities/opportunities_screen.dart';
import '../profile/profile_screen.dart';
import '../training/training_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTabIndex = 0;
  bool _isLoading = true;
  PathwayModel? _pathway;
  List<OpportunityModel> _recommendedOpps = [];
  List<CourseModel> _courses = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final api = Provider.of<ApiService>(context, listen: false);
    setState(() => _isLoading = true);

    final p = await api.getPathway();
    final opps = await api.getMatchedOpportunities();
    final c = await api.getCourses();

    if (mounted) {
      setState(() {
        _pathway = p;
        _recommendedOpps = opps.take(3).toList();
        _courses = c.take(2).toList();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = Provider.of<AppStrings>(context);
    final apiService = Provider.of<ApiService>(context);

    final pages = [
      _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : _buildHomeContent(strings, apiService),
      const OpportunitiesScreen(),
      const BecomeEligibleScreen(),
      const MentorsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      appBar: AppHeader(
        title: strings.tr('appName'),
        showBack: false,
        actions: [
          IconButton(
            tooltip: strings.tr('chatTitle'),
            icon: const Icon(Icons.forum_outlined, color: AppColors.primaryGreen),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
            },
          ),
          IconButton(
            tooltip: strings.tr('chooseLanguage'),
            icon: const Icon(Icons.translate, color: AppColors.primaryGreen),
            onPressed: () => _showLanguageModal(context),
          ),
        ],
      ),
      body: pages[_currentTabIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 11,
        unselectedFontSize: 10,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: AppColors.textMuted,
        currentIndex: _currentTabIndex,
        onTap: (index) => setState(() => _currentTabIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: strings.tr('home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.work_outline),
            activeIcon: const Icon(Icons.work),
            label: strings.tr('opportunities'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.timeline_outlined),
            activeIcon: const Icon(Icons.timeline),
            label: strings.tr('pathway'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.people_outline),
            activeIcon: const Icon(Icons.people),
            label: strings.tr('mentors'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: strings.tr('profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent(AppStrings strings, ApiService apiService) {
    final profile = apiService.currentProfile;

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Beneficiary Greeting & Profile completion
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${strings.tr('greetingPrefix')}, ${profile?.fullName ?? ""}!',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          strings.tr('livelihoodProgressAtGlance'),
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle, size: 16, color: AppColors.primaryGreen),
                        const SizedBox(width: 4),
                        Text(
                          '${profile?.completionRate ?? 85}% ${strings.tr('complete')}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // PRIMARY HERO VOICE CTA: "Talk to Thiran AI"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryGreen, AppColors.primaryGreenDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.mic, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                strings.tr('talkToAssistant'),
                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                strings.tr('voicePromptSubtitle'),
                                style: const TextStyle(fontSize: 12, color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primaryGreen,
                        minimumSize: const Size(double.infinity, 44),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
                      },
                      icon: const Icon(Icons.voice_chat, size: 20),
                      label: Text(
                        strings.tr('startVoiceConversation'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // CURRENT PATHWAY PROGRESS (FIXED 96PX OVERFLOW)
            if (_pathway != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        strings.tr('activePathway'),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => setState(() => _currentTabIndex = 2),
                      child: Text(strings.tr('viewFull')),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _pathway!.targetRole,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.accentTeal.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_pathway!.alignmentScore}% ${strings.tr('matched')}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accentTeal),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      EligibilityStepper(currentStage: _pathway!.currentStage),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.arrow_forward_rounded, color: AppColors.primaryGreen, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${strings.tr('nextAction')} ${_pathway!.nextAction}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // RECOMMENDED OPPORTUNITIES (FIXED 27PX OVERFLOW)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      strings.tr('recommendedOpportunities'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => setState(() => _currentTabIndex = 1),
                    child: Text(strings.tr('seeAll')),
                  ),
                ],
              ),
            ),
            ..._recommendedOpps.map((opp) => _buildOpportunityCard(opp, strings)),

            const SizedBox(height: 20),

            // TRAINING COURSES
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      strings.tr('accreditedTrainings'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const TrainingScreen()));
                    },
                    child: Text(strings.tr('explore')),
                  ),
                ],
              ),
            ),
            ..._courses.map((c) => _buildCourseCard(c, strings)),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOpportunityCard(OpportunityModel opp, AppStrings strings) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  opp.title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ),
              if (opp.alignmentScore != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${opp.alignmentScore}% ${strings.tr('matched')}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(opp.organizationName, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 15, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(opp.location, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const Spacer(),
              Text(opp.compensation, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
            ],
          ),
          if (opp.whyShown != null && opp.whyShown!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, size: 14, color: AppColors.accentTeal),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      opp.whyShown!.first,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCourseCard(CourseModel course, AppStrings strings) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            course.title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(course.providerName, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.schedule, size: 15, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text('${course.durationWeeks} ${strings.tr('weeksDuration')} (${course.deliveryMode})', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(strings.tr('badge_VERIFIED'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.successGreen)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showLanguageModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        final strings = Provider.of<AppStrings>(context);
        return SafeArea(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.72,
            ),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  strings.tr('chooseLanguage'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 14),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: AppStrings.supportedLanguages.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.borderLight),
                    itemBuilder: (context, idx) {
                      final lang = AppStrings.supportedLanguages[idx];
                      final isSelected = strings.currentLanguage == lang.code;
                      return ListTile(
                        title: Text('${lang.nativeName} (${lang.name})', style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(lang.sampleGreeting, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.primaryGreen) : null,
                        onTap: () {
                          strings.setLanguage(lang.code);
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
