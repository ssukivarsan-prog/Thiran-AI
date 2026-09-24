import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_strings.dart';
import '../../core/network/api_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_components.dart';
import '../../core/widgets/voice_input_modal.dart';
import '../home/home_screen.dart';

class VoiceOnboardingScreen extends StatefulWidget {
  const VoiceOnboardingScreen({super.key});

  @override
  State<VoiceOnboardingScreen> createState() => _VoiceOnboardingScreenState();
}

class _VoiceOnboardingScreenState extends State<VoiceOnboardingScreen> {
  final TextEditingController _answerController = TextEditingController();
  String _currentQuestion = '';
  List<String> _quickReplies = [];
  final List<Map<String, String>> _interviewHistory = [];
  bool _isSummaryMode = false;
  Map<String, dynamic>? _extractedSummary;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNextQuestion();
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _loadNextQuestion() async {
    setState(() => _isLoading = true);
    final strings = Provider.of<AppStrings>(context, listen: false);
    final apiService = Provider.of<ApiService>(context, listen: false);

    final data = await apiService.getVoiceNextQuestion(strings.currentLanguage, _interviewHistory);
    setState(() {
      _currentQuestion = data['questionText'] ?? '';
      _quickReplies = List<String>.from(data['suggestedQuickReplies'] ?? []);
      _answerController.clear();
      _isLoading = false;
    });
  }

  Future<void> _openVoiceInput(AppStrings strings) async {
    final result = await VoiceInputModal.show(
      context: context,
      title: _currentQuestion,
      initialText: _answerController.text,
      quickOptions: _quickReplies,
    );

    if (result != null && result.trim().isNotEmpty) {
      setState(() {
        _answerController.text = result.trim();
      });
    }
  }

  Future<void> _confirmAnswer() async {
    final text = _answerController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _interviewHistory.add({
        'question': _currentQuestion,
        'answer': text,
      });
    });

    if (_interviewHistory.length >= 3) {
      // Completed interview -> run structured extraction
      setState(() => _isLoading = true);
      final apiService = Provider.of<ApiService>(context, listen: false);
      final strings = Provider.of<AppStrings>(context, listen: false);

      final result = await apiService.completeVoiceInterview(_interviewHistory, strings.currentLanguage);
      setState(() {
        _extractedSummary = Map<String, dynamic>.from(result['understoodSummary'] ?? {});
        _isSummaryMode = true;
        _isLoading = false;
      });
    } else {
      await _loadNextQuestion();
    }
  }

  void _skipQuestion() {
    setState(() {
      _interviewHistory.add({
        'question': _currentQuestion,
        'answer': 'Skipped',
      });
    });

    if (_interviewHistory.length >= 3) {
      _finishInterview();
    } else {
      _loadNextQuestion();
    }
  }

  Future<void> _finishInterview() async {
    setState(() => _isLoading = true);
    final apiService = Provider.of<ApiService>(context, listen: false);
    final strings = Provider.of<AppStrings>(context, listen: false);

    final result = await apiService.completeVoiceInterview(_interviewHistory, strings.currentLanguage);
    setState(() {
      _extractedSummary = Map<String, dynamic>.from(result['understoodSummary'] ?? {});
      _isSummaryMode = true;
      _isLoading = false;
    });
  }

  void _editSummaryField(String fieldKey, String fieldLabel, String currentValue, AppStrings strings) {
    final editController = TextEditingController(text: currentValue);
    List<String> options = [];

    if (fieldKey == 'education') {
      options = strings.getSuggestionsForQuestion(0);
    } else if (fieldKey == 'currentWork') {
      options = strings.getSuggestionsForQuestion(1);
    } else if (fieldKey == 'experience') {
      options = strings.getSuggestionsForQuestion(2);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            final bottomInset = MediaQuery.of(modalCtx).viewInsets.bottom;
            return Padding(
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
                        '${strings.tr('editDetail')}: $fieldLabel',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: editController,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: fieldLabel,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  if (options.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: options.map((opt) {
                        return ActionChip(
                          label: Text(opt, style: const TextStyle(fontSize: 12)),
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: AppColors.borderLight),
                          onPressed: () {
                            setModalState(() {
                              editController.text = opt;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: () {
                      final newVal = editController.text.trim();
                      if (newVal.isNotEmpty) {
                        setState(() {
                          _extractedSummary![fieldKey] = newVal;
                        });
                        final api = Provider.of<ApiService>(context, listen: false);
                        if (api.currentProfile != null) {
                          if (fieldKey == 'education') {
                            api.updateCurrentProfile(api.currentProfile!.copyWith(educationLevel: newVal));
                          } else if (fieldKey == 'currentWork') {
                            api.updateCurrentProfile(api.currentProfile!.copyWith(currentWork: newVal));
                          } else if (fieldKey == 'experience') {
                            api.updateCurrentProfile(api.currentProfile!.copyWith(previousExperience: newVal));
                          }
                        }
                      }
                      Navigator.pop(ctx);
                    },
                    child: Text(strings.tr('save')),
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

    if (_isSummaryMode && _extractedSummary != null) {
      return _buildSummaryReview(strings);
    }

    final currentStep = _interviewHistory.length + 1;

    return Scaffold(
      appBar: AppHeader(
        title: strings.tr('onboardingTitle'),
        showBack: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress Bar
              LinearProgressIndicator(
                value: currentStep / 3.0,
                backgroundColor: AppColors.borderLight,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${strings.tr('questionOf')} $currentStep ${strings.tr('of')} 3',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                  ),
                  Text(
                    '${((currentStep / 3.0) * 100).toInt()}%',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Question Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.psychology, color: AppColors.primaryGreen, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          strings.tr('assistantAsks'),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _isLoading
                        ? const Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator(color: AppColors.primaryGreen, strokeWidth: 2)))
                        : Text(
                            _currentQuestion,
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.35),
                          ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Answer Input Preview Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
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
                          strings.tr('yourAnswer'),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (_answerController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 18, color: AppColors.textMuted),
                            tooltip: 'Clear',
                            onPressed: () => setState(() => _answerController.clear()),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _answerController,
                      maxLines: 3,
                      textAlignVertical: TextAlignVertical.top,
                      style: const TextStyle(fontSize: 15, color: AppColors.textPrimary, height: 1.4),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: strings.tr('micPrompt'),
                        hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted, fontStyle: FontStyle.italic),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    // Quick reply suggestions chips
                    if (_quickReplies.isNotEmpty) ...[
                      const Divider(),
                      Text(
                        strings.tr('quickSuggestions'),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: _quickReplies.map((reply) {
                          return ActionChip(
                            label: Text(reply, style: const TextStyle(fontSize: 12)),
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: AppColors.borderLight),
                            onPressed: () {
                              setState(() {
                                _answerController.text = reply;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Voice Action Button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  VoicePulseButton(
                    isListening: false,
                    label: strings.tr('tapAndSpeak'),
                    onPressed: () => _openVoiceInput(strings),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Bottom Actions (Skip & Next)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _skipQuestion,
                      child: Text(strings.tr('skip')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _answerController.text.trim().isNotEmpty ? _confirmAnswer : null,
                      child: Text(strings.tr('next')),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryReview(AppStrings strings) {
    final education = _extractedSummary?['education'] ?? '10th Standard';
    final currentWork = _extractedSummary?['currentWork'] ?? 'Field Assistant';
    final experience = _extractedSummary?['experience'] ?? '2 years practical wiring';
    final aspiration = _extractedSummary?['aspirations'] ?? 'Solar PV Technician';

    return Scaffold(
      appBar: AppHeader(
        title: strings.tr('profileConfirmationTitle'),
        showBack: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryGreen.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: AppColors.primaryGreen, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings.tr('confirmationHeadline'),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryGreen),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            strings.tr('confirmationSubhead'),
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Editable Detail Cards
              _buildEditableFactRow(
                icon: Icons.school,
                label: strings.tr('education'),
                value: education,
                onEdit: () => _editSummaryField('education', strings.tr('education'), education, strings),
                strings: strings,
              ),
              _buildEditableFactRow(
                icon: Icons.work,
                label: strings.tr('currentWork'),
                value: currentWork,
                onEdit: () => _editSummaryField('currentWork', strings.tr('currentWork'), currentWork, strings),
                strings: strings,
              ),
              _buildEditableFactRow(
                icon: Icons.history,
                label: strings.tr('experience'),
                value: experience,
                onEdit: () => _editSummaryField('experience', strings.tr('experience'), experience, strings),
                strings: strings,
              ),
              _buildEditableFactRow(
                icon: Icons.flag,
                label: strings.tr('aspiration'),
                value: aspiration,
                onEdit: () => _editSummaryField('aspirations', strings.tr('aspiration'), aspiration, strings),
                strings: strings,
              ),

              const SizedBox(height: 16),
              Text(
                strings.tr('identifiedCompetencies'),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Wrap(
                children: [
                  SkillChip(
                    skillName: strings.currentLanguage == 'ta' ? 'சூரிய ஒளி மின்கல வயரிங்' : 'Solar PV Inverter Wiring',
                    verificationType: 'AI_INFERRED',
                  ),
                  SkillChip(
                    skillName: strings.currentLanguage == 'ta' ? 'வீட்டு மின்சார வயரிங்' : 'Basic Domestic Wiring',
                    verificationType: 'SELF_DECLARED',
                  ),
                ],
              ),

              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: () {
                  final apiService = Provider.of<ApiService>(context, listen: false);
                  if (apiService.currentProfile != null) {
                    apiService.updateCurrentProfile(
                      apiService.currentProfile!.copyWith(
                        educationLevel: _extractedSummary?['education'],
                        currentWork: _extractedSummary?['currentWork'],
                        previousExperience: _extractedSummary?['experience'],
                      ),
                    );
                  }
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                },
                child: Text(strings.tr('confirmAndProceedHome')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableFactRow({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onEdit,
    required AppStrings strings,
  }) {
    return InkWell(
      onTap: onEdit,
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
                  Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primaryGreen),
              tooltip: strings.tr('editDetail'),
              onPressed: onEdit,
            ),
          ],
        ),
      ),
    );
  }
}
