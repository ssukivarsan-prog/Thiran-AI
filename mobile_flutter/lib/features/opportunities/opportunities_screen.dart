import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_strings.dart';
import '../../core/models/models.dart';
import '../../core/network/api_service.dart';
import '../../core/theme/app_theme.dart';

class OpportunitiesScreen extends StatefulWidget {
  const OpportunitiesScreen({super.key});

  @override
  State<OpportunitiesScreen> createState() => _OpportunitiesScreenState();
}

class _OpportunitiesScreenState extends State<OpportunitiesScreen> {
  List<OpportunityModel> _opportunities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOpportunities();
  }

  Future<void> _fetchOpportunities() async {
    final api = Provider.of<ApiService>(context, listen: false);
    setState(() => _isLoading = true);
    final opps = await api.getMatchedOpportunities();
    if (mounted) {
      setState(() {
        _opportunities = opps;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = Provider.of<AppStrings>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.tr('opportunities')),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : RefreshIndicator(
              onRefresh: _fetchOpportunities,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: _opportunities.length,
                itemBuilder: (context, index) {
                  final opp = _opportunities[index];
                  return _buildDetailedCard(opp, strings);
                },
              ),
            ),
    );
  }

  Widget _buildDetailedCard(OpportunityModel opp, AppStrings strings) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      opp.title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      opp.organizationName,
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              if (opp.alignmentScore != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${opp.alignmentScore}% ${strings.tr('matched')}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 15, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(opp.location, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const Spacer(),
              Text(opp.compensation, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
            ],
          ),

          // WHY THIS WAS SHOWN TO YOU
          if (opp.whyShown != null && opp.whyShown!.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.psychology, size: 16, color: AppColors.primaryGreen),
                      const SizedBox(width: 6),
                      Text(
                        strings.tr('whyThisWasShown'),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ...opp.whyShown!.map((w) => Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text('• $w', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  )),
                ],
              ),
            ),
          ],

          // MISSING REQUIREMENTS
          if (opp.missingRequirements != null && opp.missingRequirements!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.warningAmber),
                      const SizedBox(width: 6),
                      Text(
                        strings.tr('missingRequirements'),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.warningAmber),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ...opp.missingRequirements!.map((m) => Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text('• $m', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  )),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 42)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.primaryGreen,
                  content: Text(strings.tr('applicationSubmittedSuccess')),
                ),
              );
            },
            child: Text(strings.tr('applyNow')),
          ),
        ],
      ),
    );
  }
}
