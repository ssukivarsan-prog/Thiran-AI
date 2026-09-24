import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../localization/app_strings.dart';
import '../services/voice_recognition_service.dart';
import '../theme/app_theme.dart';

class VoiceInputModal extends StatefulWidget {
  final String title;
  final String initialText;
  final List<String> quickOptions;
  final ValueChanged<String> onConfirmed;

  const VoiceInputModal({
    super.key,
    required this.title,
    this.initialText = '',
    this.quickOptions = const [],
    required this.onConfirmed,
  });

  static Future<String?> show({
    required BuildContext context,
    required String title,
    String initialText = '',
    List<String> quickOptions = const [],
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => VoiceInputModal(
        title: title,
        initialText: initialText,
        quickOptions: quickOptions,
        onConfirmed: (text) => Navigator.pop(ctx, text),
      ),
    );
  }

  @override
  State<VoiceInputModal> createState() => _VoiceInputModalState();
}

class _VoiceInputModalState extends State<VoiceInputModal> with SingleTickerProviderStateMixin {
  late TextEditingController _textController;
  late AnimationController _animController;
  final VoiceRecognitionService _voiceService = VoiceRecognitionService();
  bool _isListening = false;
  double _soundLevel = 0.0;
  String? _micNotice;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    // Auto-start microphone listening when modal appears
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _startListening();
      }
    });
  }

  @override
  void dispose() {
    _voiceService.cancelListening();
    _animController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _startListening() async {
    final strings = Provider.of<AppStrings>(context, listen: false);
    setState(() {
      _micNotice = null;
      _isListening = true;
    });

    final success = await _voiceService.startListening(
      languageCode: strings.currentLanguage,
      onResult: (words, isFinal) {
        if (!mounted) return;
        setState(() {
          _textController.text = words;
          if (isFinal) {
            _isListening = false;
          }
        });
      },
      onSoundLevel: (level) {
        if (!mounted) return;
        setState(() {
          _soundLevel = level;
        });
      },
      onError: (err) {
        if (!mounted) return;
        setState(() {
          _isListening = false;
          _micNotice = err;
        });
      },
    );

    if (!success && mounted) {
      setState(() {
        _isListening = false;
        _micNotice = _voiceService.errorMessage ??
            'Microphone access is unavailable. You can tap quick suggestions or type.';
      });
    }
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _voiceService.stopListening();
      if (mounted) {
        setState(() {
          _isListening = false;
          _soundLevel = 0.0;
        });
      }
    } else {
      await _startListening();
    }
  }

  String _getLanguageDisplay(AppStrings strings) {
    for (final lang in AppStrings.supportedLanguages) {
      if (lang.code == strings.currentLanguage) {
        return '${lang.nativeName} (${lang.name})';
      }
    }
    return strings.currentLanguage.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final strings = Provider.of<AppStrings>(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: bottomInset + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Header Title
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),

            // Language & Audio Engine Badge
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.language, size: 14, color: AppColors.primaryGreen),
                    const SizedBox(width: 5),
                    Text(
                      _getLanguageDisplay(strings),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryGreenDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Status indicator banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _isListening
                    ? AppColors.primaryGreen.withOpacity(0.08)
                    : (_textController.text.isNotEmpty
                        ? const Color(0xFFF0FDF4)
                        : AppColors.surfaceLight),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _isListening
                      ? AppColors.primaryGreen.withOpacity(0.3)
                      : (_textController.text.isNotEmpty
                          ? const Color(0xFFBBF7D0)
                          : AppColors.borderLight),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isListening) ...[
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '${strings.tr('listeningActive')} (${strings.tr('speakNow')})',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGreenDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ] else if (_textController.text.isNotEmpty) ...[
                    const Icon(Icons.check_circle, size: 14, color: Color(0xFF16A34A)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        strings.tr('voiceInputCompleted'),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF15803D),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ] else ...[
                    const Icon(Icons.mic_none, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        strings.tr('tapToSpeak'),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMuted,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            if (_micNotice != null && !_isListening) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 14, color: Color(0xFFD97706)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _micNotice!,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF92400E)),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Soundwave Visualizer Bars (Driven by live audio sound level + sine wave)
            SizedBox(
              height: 48,
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, _) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(16, (i) {
                      final wave = _isListening
                          ? sin((_animController.value * 2 * pi) + (i * 0.4)).abs()
                          : 0.12;
                      final levelFactor = _isListening ? (_soundLevel * 24.0) : 0.0;
                      final height = (8.0 + (wave * 18.0) + levelFactor).clamp(6.0, 46.0);

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2.2),
                        width: 4,
                        height: height,
                        decoration: BoxDecoration(
                          color: _isListening
                              ? (_soundLevel > 0.1 ? AppColors.warningAmber : AppColors.primaryGreen)
                              : AppColors.borderLight,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Microphone Button
            Center(
              child: Tooltip(
                message: _isListening ? 'Tap to pause microphone' : 'Tap to start speaking',
                child: GestureDetector(
                  onTap: _toggleListening,
                  child: Container(
                    width: 66,
                    height: 66,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: _isListening
                            ? [AppColors.warningAmber, const Color(0xFFD97706)]
                            : [AppColors.primaryGreen, AppColors.primaryGreenDark],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_isListening ? AppColors.warningAmber : AppColors.primaryGreen)
                              .withOpacity(0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Editable Text Area (User can type or edit spoken text)
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: TextField(
                controller: _textController,
                maxLines: 3,
                minLines: 2,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(14),
                  border: InputBorder.none,
                  hintText: strings.tr('typeHere'),
                  hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                  suffixIcon: _textController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18, color: AppColors.textMuted),
                          onPressed: () => setState(() => _textController.clear()),
                        )
                      : null,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 12),

            // Suggested quick phrase chips
            if (widget.quickOptions.isNotEmpty) ...[
              Text(
                strings.tr('quickSuggestions'),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: widget.quickOptions.map((opt) {
                  return ActionChip(
                    label: Text(opt, style: const TextStyle(fontSize: 12)),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.borderLight),
                    onPressed: () {
                      setState(() {
                        _textController.text = opt;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Action Buttons (Cancel / Confirm)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _voiceService.cancelListening();
                      Navigator.pop(context);
                    },
                    child: Text(strings.tr('cancel')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _textController.text.trim().isNotEmpty
                        ? () {
                            _voiceService.stopListening();
                            widget.onConfirmed(_textController.text.trim());
                          }
                        : null,
                    child: Text(strings.tr('confirmInput')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
