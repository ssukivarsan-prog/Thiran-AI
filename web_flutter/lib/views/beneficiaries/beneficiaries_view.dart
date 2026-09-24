import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/web_models.dart';
import '../../core/network/web_api_service.dart';
import '../../core/theme/app_theme.dart';

class BeneficiariesView extends StatefulWidget {
  const BeneficiariesView({super.key});

  @override
  State<BeneficiariesView> createState() => _BeneficiariesViewState();
}

class _BeneficiariesViewState extends State<BeneficiariesView> {
  List<WebBeneficiary> _beneficiaries = [];
  WebBeneficiary? _selectedBeneficiary;
  bool _isLoading = true;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchBeneficiaries();
  }

  Future<void> _fetchBeneficiaries() async {
    final api = Provider.of<WebApiService>(context, listen: false);
    setState(() => _isLoading = true);
    final res = await api.getBeneficiaries(search: _searchCtrl.text.trim());
    if (mounted) {
      setState(() {
        _beneficiaries = res;
        _isLoading = false;
      });
    }
  }

  void _showMobileDetails(WebBeneficiary b) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollCtrl) => SingleChildScrollView(
          controller: scrollCtrl,
          padding: const EdgeInsets.all(20),
          child: _buildDrawerContent(b, isModal: true),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isMobile = screenWidth < 900;

        return Scaffold(
          body: Row(
            children: [
              // Table Section
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                                'Beneficiary Management Directory',
                                style: TextStyle(
                                  fontSize: isMobile ? 18 : 20,
                                  fontWeight: FontWeight.bold,
                                  color: WebColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${_beneficiaries.length} registered candidates with voice onboarding & skill profiles',
                                style: TextStyle(fontSize: isMobile ? 11 : 12, color: WebColors.textMuted),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: isMobile ? double.infinity : 260,
                            height: 38,
                            child: TextField(
                              controller: _searchCtrl,
                              decoration: InputDecoration(
                                hintText: 'Filter by name, phone, trade...',
                                hintStyle: const TextStyle(fontSize: 12),
                                prefixIcon: const Icon(Icons.search, size: 16),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.arrow_forward, size: 16),
                                  onPressed: _fetchBeneficiaries,
                                ),
                                contentPadding: EdgeInsets.zero,
                              ),
                              onSubmitted: (_) => _fetchBeneficiaries(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Data Table
                      Expanded(
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator(color: WebColors.primaryGreen))
                            : Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: WebColors.borderSubtle),
                                ),
                                child: ListView.separated(
                                  itemCount: _beneficiaries.length,
                                  separatorBuilder: (_, _) => const Divider(height: 1, color: WebColors.borderSubtle),
                                  itemBuilder: (context, index) {
                                    final b = _beneficiaries[index];
                                    final isSelected = _selectedBeneficiary?.id == b.id;

                                    return ListTile(
                                      selected: !isMobile && isSelected,
                                      selectedTileColor: WebColors.primaryGreen.withValues(alpha: 0.06),
                                      onTap: () {
                                        if (isMobile) {
                                          _showMobileDetails(b);
                                        } else {
                                          setState(() => _selectedBeneficiary = b);
                                        }
                                      },
                                      leading: CircleAvatar(
                                        backgroundColor: WebColors.primaryGreen.withValues(alpha: 0.12),
                                        child: Text(
                                          b.fullName.substring(0, 1),
                                          style: const TextStyle(color: WebColors.primaryGreen, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      title: Text(b.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                      subtitle: Text('${b.currentWork} • ${b.location}', style: const TextStyle(fontSize: 12, color: WebColors.textMuted)),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: WebColors.successGreen.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              '${b.completionRate}% Profiled',
                                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: WebColors.successGreen),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(Icons.chevron_right, size: 18, color: WebColors.textMuted),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),

              // Detail Drawer Panel for Desktop
              if (!isMobile && _selectedBeneficiary != null)
                Container(
                  width: 380,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(left: BorderSide(color: WebColors.borderSubtle)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: WebColors.borderSubtle)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Candidate Dossier', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              onPressed: () => setState(() => _selectedBeneficiary = null),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: _buildDrawerContent(_selectedBeneficiary!),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDrawerContent(WebBeneficiary b, {bool isModal = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: WebColors.primaryGreen.withValues(alpha: 0.15),
                child: Text(
                  b.fullName.substring(0, 1),
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: WebColors.primaryGreen),
                ),
              ),
              const SizedBox(height: 10),
              Text(b.fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(b.phone, style: const TextStyle(fontSize: 13, color: WebColors.textMuted)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 10),

        _buildDrawerItem('Education Level', b.educationLevel),
        _buildDrawerItem('Current Work', b.currentWork),
        _buildDrawerItem('Experience', b.previousExperience),
        _buildDrawerItem('Location & Mobility', '${b.location} (${b.mobilityConstraints})'),
        _buildDrawerItem('Preferred Language', b.preferredLanguage.toUpperCase()),

        const SizedBox(height: 16),
        const Text('Verified & Extracted Skills', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _buildSkillBadge('Solar PV Wiring', 'AI-Inferred'),
            _buildSkillBadge('Domestic Repair', 'Verified'),
          ],
        ),

        const SizedBox(height: 24),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 42)),
          onPressed: () {
            if (isModal) Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Intervention note added to beneficiary log.')),
            );
          },
          icon: const Icon(Icons.note_add_outlined, size: 18),
          label: const Text('Add Counselor Note'),
        ),
      ],
    );
  }

  Widget _buildDrawerItem(String label, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: WebColors.textMuted)),
          const SizedBox(height: 2),
          Text(val, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: WebColors.textDark)),
        ],
      ),
    );
  }

  Widget _buildSkillBadge(String name, String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: WebColors.surfaceBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: WebColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: WebColors.primaryGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(type, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: WebColors.primaryGreen)),
          ),
        ],
      ),
    );
  }
}
