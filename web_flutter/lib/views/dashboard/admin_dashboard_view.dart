import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/network/web_api_service.dart';
import '../../core/theme/app_theme.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  Map<String, dynamic>? _analytics;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final api = Provider.of<WebApiService>(context, listen: false);
    setState(() => _isLoading = true);
    final res = await api.getAnalytics();
    if (mounted) {
      setState(() {
        _analytics = res;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: WebColors.primaryGreen));
    }

    final kpis = _analytics?['kpis'] ?? {};
    final funnel = _analytics?['funnel'] ?? {};
    final gaps = (_analytics?['gapDistribution'] as List?) ?? [];

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isMobile = screenWidth < 650;
        final isTablet = screenWidth >= 650 && screenWidth < 1000;
        final isLargeDesktop = screenWidth >= 1350;

        // Dynamic cross-axis count for KPI cards
        final int kpiColumns = isLargeDesktop ? 6 : (isTablet ? 3 : (isMobile ? 2 : 3));
        final double kpiAspectRatio = isLargeDesktop ? 1.6 : (isMobile ? 1.7 : 2.1);

        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 10,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Program Operations & Intelligence Overview',
                        style: TextStyle(
                          fontSize: isMobile ? 18 : 22,
                          fontWeight: FontWeight.bold,
                          color: WebColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Live metrics across beneficiary onboarding, skill gaps, pathway progression, and support channels',
                        style: TextStyle(fontSize: isMobile ? 11 : 13, color: WebColors.textMuted),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: _loadData,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Refresh Data'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // KPI CARDS RESPONSIVE GRID
              GridView.count(
                crossAxisCount: kpiColumns,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: kpiAspectRatio,
                children: [
                  _buildKpiCard('Active Beneficiaries', '${kpis['activeBeneficiaries'] ?? 21}', Icons.groups, WebColors.primaryGreen),
                  _buildKpiCard('Active Mentors', '${kpis['activeMentors'] ?? 10}', Icons.handshake, WebColors.accentTeal),
                  _buildKpiCard('Training Courses', '${kpis['trainingCoursesCount'] ?? 10}', Icons.school, const Color(0xFF2563EB)),
                  _buildKpiCard('Open Opportunities', '${kpis['openOpportunities'] ?? 15}', Icons.work, const Color(0xFF7C3AED)),
                  _buildKpiCard('Completed Pathways', '${kpis['completedPathways'] ?? 4}', Icons.task_alt, WebColors.successGreen),
                  _buildKpiCard('Pending Follow-Ups', '${kpis['pendingFollowUps'] ?? 1}', Icons.support_agent, WebColors.warningAmber),
                ],
              ),

              const SizedBox(height: 24),

              // RESPONSIVE TWO-COLUMN OR SINGLE-COLUMN LAYOUT
              if (screenWidth >= 950)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _buildFunnelCard(funnel)),
                    const SizedBox(width: 16),
                    Expanded(flex: 2, child: _buildSkillGapsCard(gaps)),
                  ],
                )
              else
                Column(
                  children: [
                    _buildFunnelCard(funnel),
                    const SizedBox(height: 16),
                    _buildSkillGapsCard(gaps),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: WebColors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: WebColors.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFunnelCard(Map<String, dynamic> funnel) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: WebColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Beneficiary Pathway Funnel',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: WebColors.textDark),
          ),
          const SizedBox(height: 4),
          const Text(
            'Progression from voice intake to certified opportunity placement',
            style: TextStyle(fontSize: 12, color: WebColors.textMuted),
          ),
          const SizedBox(height: 18),
          _buildFunnelRow('1. Voice-Onboarded & Profiled', funnel['onboarded'] ?? 21, 25, WebColors.primaryGreen),
          _buildFunnelRow('2. Skill Gap Identified', funnel['gapIdentified'] ?? 10, 25, WebColors.accentTeal),
          _buildFunnelRow('3. In Vocational Training', funnel['inTraining'] ?? 8, 25, const Color(0xFF2563EB)),
          _buildFunnelRow('4. Competency Assessment', funnel['inAssessment'] ?? 2, 25, const Color(0xFF7C3AED)),
          _buildFunnelRow('5. Certified & Job-Ready', funnel['certified'] ?? 3, 25, const Color(0xFFD97706)),
          _buildFunnelRow('6. Applied to Live Vacancy', funnel['appliedToJob'] ?? 4, 25, WebColors.successGreen),
        ],
      ),
    );
  }

  Widget _buildSkillGapsCard(List<dynamic> gaps) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: WebColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Identified Skill Gaps',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: WebColors.textDark),
          ),
          const SizedBox(height: 4),
          const Text(
            'Skills required by local industry lacking in candidate profiles',
            style: TextStyle(fontSize: 12, color: WebColors.textMuted),
          ),
          const SizedBox(height: 16),
          ...gaps.map((g) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        g['skill'] ?? '',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: WebColors.textDark),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${g['count']} candidates', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: WebColors.textMuted)),
                  ],
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: (g['count'] ?? 1) / 10.0,
                  backgroundColor: WebColors.surfaceBg,
                  valueColor: const AlwaysStoppedAnimation<Color>(WebColors.accentTeal),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildFunnelRow(String stage, int count, int max, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  stage,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: WebColors.textDark),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text('$count beneficiaries', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: count / max.toDouble(),
            backgroundColor: WebColors.surfaceBg,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}
