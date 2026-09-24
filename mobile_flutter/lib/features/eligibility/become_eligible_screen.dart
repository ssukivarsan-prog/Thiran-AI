import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_strings.dart';
import '../../core/models/models.dart';
import '../../core/network/api_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_components.dart';

class BecomeEligibleScreen extends StatefulWidget {
  const BecomeEligibleScreen({super.key});

  @override
  State<BecomeEligibleScreen> createState() => _BecomeEligibleScreenState();
}

class _BecomeEligibleScreenState extends State<BecomeEligibleScreen> {
  PathwayModel? _pathway;
  bool _isLoading = true;

  // What-if simulation parameters
  bool _simCourseCompleted = false;
  bool _simSkillAdded = false;
  String _simWorkType = 'WAGE_EMPLOYMENT';
  Map<String, dynamic>? _simResult;

  @override
  void initState() {
    super.initState();
    _loadPathway();
  }

  Future<void> _loadPathway() async {
    final api = Provider.of<ApiService>(context, listen: false);
    setState(() => _isLoading = true);
    final p = await api.getPathway();
    setState(() {
      _pathway = p;
      _isLoading = false;
    });
  }

  Future<void> _runSimulation() async {
    final api = Provider.of<ApiService>(context, listen: false);
    final res = await api.simulatePathway(
      simulatedSkill: _simSkillAdded ? 'Advanced Solar Micro-Grid Synchronization' : null,
      simulatedCourseId: _simCourseCompleted ? 'crs-1' : null,
      simulatedWorkType: _simWorkType,
    );
    setState(() {
      _simResult = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = Provider.of<AppStrings>(context);
    final isTa = strings.currentLanguage == 'ta';

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
    }

    final p = _pathway!;
    final effectiveScore = _simResult != null ? _simResult!['projectedAlignmentScore'] : p.alignmentScore;
    final effectiveStage = _simResult != null ? _simResult!['simulatedStage'] : p.currentStage;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.tr('pathway')),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Target Goal Card
            Container(
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        strings.tr('activePathway'),
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$effectiveScore% ${strings.tr('matched')}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    p.targetRole,
                    style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                  ),
                  const SizedBox(height: 14),
                  EligibilityStepper(currentStage: effectiveStage),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // FORMAL REQUIREMENTS VS CURRENT STATUS VS GAPS
            Text(
              isTa ? '1. முறையான தகுதி நிபந்தனைகள்' : '1. Formal Requirements & Status',
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
                children: [
                  ...p.satisfiedRequirements.map((sat) => _buildRequirementRow(
                    label: sat,
                    isSatisfied: true,
                    isTa: isTa,
                  )),
                  ...p.missingRequirements.map((gap) => _buildRequirementRow(
                    label: gap,
                    isSatisfied: false,
                    isTa: isTa,
                  )),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ACTION PLAN STEPPER
            Text(
              isTa ? '2. தகுதி பெற வழிகள்' : '2. How to Become Fully Eligible',
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
                children: [
                  _buildActionStep('1', isTa ? 'அங்கீகரிக்கப்பட்ட சோலார் பயிற்சியை முடிக்கவும்' : 'Complete 6-week accredited rooftop solar training', isDone: _simCourseCompleted),
                  _buildActionStep('2', isTa ? 'நடைமுறை களத் திறனை வழிகாட்டியுடன் சோதிக்கவும்' : 'Pass practical on-site wiring assessment with mentor', isDone: _simSkillAdded),
                  _buildActionStep('3', isTa ? 'சான்றிதழ் பதிவேற்றி தகுதி நிலையை உறுதி செய்யவும்' : 'Submit official Level-4 certificate proof', isDone: _simCourseCompleted),
                  _buildActionStep('4', isTa ? '100% தகுதியுடன் வேலைக்கு நேரடியாக விண்ணப்பிக்கவும்' : 'Directly apply to verified vacancies with high priority matching', isDone: false),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // "WHAT IF?" SIMULATOR
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF86EFAC)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.bolt, color: AppColors.primaryGreen, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        isTa ? '‘என்ன நடக்கும்?’ உருவகப்படுத்துதல்' : 'Interactive "What-If" Simulator',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isTa
                        ? 'நீங்கள் புதிய பயிற்சி அல்லது சான்றிதழ் முடித்தால் உங்கள் தகுதி எப்படி உயரும் என்பதை முன்கூட்டியே பாருங்கள்.'
                        : 'Preview how your alignment score changes if you finish a course or gain a skill.',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 14),

                  // Switches
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.primaryGreen,
                    title: Text(
                      isTa ? 'சோலார் சான்றிதழ் பயிற்சி முடித்திருந்தால்' : 'Simulate: Completed Accredited Course',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    value: _simCourseCompleted,
                    onChanged: (val) {
                      setState(() => _simCourseCompleted = val);
                      _runSimulation();
                    },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.primaryGreen,
                    title: Text(
                      isTa ? 'கூடுதல் தொழில்நுட்ப திறன் பெற்றிருந்தால்' : 'Simulate: Acquired Advanced Inverter Skill',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    value: _simSkillAdded,
                    onChanged: (val) {
                      setState(() => _simSkillAdded = val);
                      _runSimulation();
                    },
                  ),

                  if (_simResult != null) ...[
                    const Divider(color: Color(0xFF86EFAC)),
                    const SizedBox(height: 8),
                    Text(
                      '${isTa ? "கணிக்கப்பட்ட புதிய தகுதி நிலை:" : "Projected Alignment:"} ${_simResult!['projectedAlignmentScore']}% (Stage: ${_simResult!['simulatedStage']})',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${isTa ? "வேலை தயார் நிலைக்கு தேவையான காலம்:" : "Estimated time to job-ready:"} ${_simResult!['estimatedWeeksToJobReady']} weeks',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementRow({required String label, required bool isSatisfied, required bool isTa}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isSatisfied ? Icons.check_circle : Icons.cancel,
            color: isSatisfied ? AppColors.successGreen : AppColors.errorRed,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSatisfied ? AppColors.textPrimary : AppColors.errorRed,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: (isSatisfied ? AppColors.successGreen : AppColors.errorRed).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              isSatisfied ? (isTa ? 'பூர்த்தியானது' : 'Satisfied') : (isTa ? 'இடைவெளி' : 'Gap'),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isSatisfied ? AppColors.successGreen : AppColors.errorRed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionStep(String number, String title, {bool isDone = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: isDone ? AppColors.primaryGreen : AppColors.surfaceLight,
              shape: BoxShape.circle,
              border: Border.all(color: isDone ? AppColors.primaryGreen : AppColors.borderLight),
            ),
            child: Center(
              child: isDone
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : Text(number, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isDone ? FontWeight.bold : FontWeight.w500,
                color: isDone ? AppColors.primaryGreen : AppColors.textPrimary,
                decoration: isDone ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
