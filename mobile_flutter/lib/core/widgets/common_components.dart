import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../localization/app_strings.dart';
import '../network/api_service.dart';
import '../theme/app_theme.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final List<Widget>? actions;

  const AppHeader({
    super.key,
    required this.title,
    this.showBack = true,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context);
    final strings = Provider.of<AppStrings>(context);

    return AppBar(
      automaticallyImplyLeading: showBack,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: apiService.networkState == NetworkState.online ? AppColors.successGreen : AppColors.warningAmber,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                apiService.networkState == NetworkState.online
                    ? strings.tr('networkStatusOnline')
                    : strings.tr('networkStatusOffline'),
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
      actions: actions ?? [
        IconButton(
          tooltip: 'Language',
          icon: const Icon(Icons.translate, color: AppColors.primaryGreen),
          onPressed: () => _showLanguageModal(context),
        ),
        const SizedBox(width: 8),
      ],
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

class StatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const StatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: backgroundColor, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textColor),
      ),
    );
  }
}

class SkillChip extends StatelessWidget {
  final String skillName;
  final String verificationType;
  final String proficiency;

  const SkillChip({
    super.key,
    required this.skillName,
    required this.verificationType,
    this.proficiency = 'INTERMEDIATE',
  });

  @override
  Widget build(BuildContext context) {
    final strings = Provider.of<AppStrings>(context);
    Color badgeColor;
    final badgeText = strings.tr('badge_$verificationType');

    switch (verificationType) {
      case 'VERIFIED':
      case 'ORGANIZATION_VERIFIED':
        badgeColor = AppColors.verifiedBadge;
        break;
      case 'AI_INFERRED':
        badgeColor = AppColors.aiInferredBadge;
        break;
      default:
        badgeColor = AppColors.selfDeclaredBadge;
    }

    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              skillName,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              badgeText,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: badgeColor),
            ),
          ),
        ],
      ),
    );
  }
}

class EligibilityStepper extends StatelessWidget {
  final String currentStage; // CURRENT | GAP | TRAIN | ASSESS | CERTIFY | APPLY

  const EligibilityStepper({super.key, required this.currentStage});

  static const stages = ['CURRENT', 'GAP', 'TRAIN', 'ASSESS', 'CERTIFY', 'APPLY'];

  @override
  Widget build(BuildContext context) {
    final strings = Provider.of<AppStrings>(context);
    final currentIndex = stages.indexOf(currentStage);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(stages.length, (index) {
          final isPastOrCurrent = index <= currentIndex;
          final isCurrent = index == currentIndex;

          return Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    if (index > 0)
                      Expanded(
                        child: Container(
                          height: 3,
                          color: index <= currentIndex ? AppColors.primaryGreen : AppColors.borderLight,
                        ),
                      ),
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCurrent
                            ? AppColors.primaryGreen
                            : (isPastOrCurrent ? AppColors.primaryGreenLight : Colors.white),
                        border: Border.all(
                          color: isPastOrCurrent ? AppColors.primaryGreen : AppColors.borderLight,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: isPastOrCurrent && !isCurrent
                            ? const Icon(Icons.check, size: 14, color: Colors.white)
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isCurrent ? Colors.white : AppColors.textMuted,
                                ),
                              ),
                      ),
                    ),
                    if (index < stages.length - 1)
                      Expanded(
                        child: Container(
                          height: 3,
                          color: index < currentIndex ? AppColors.primaryGreen : AppColors.borderLight,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  strings.tr('stage_${stages[index]}'),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                    color: isCurrent ? AppColors.primaryGreen : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class VoicePulseButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isListening;
  final String label;

  const VoicePulseButton({
    super.key,
    required this.onPressed,
    this.isListening = false,
    this.label = 'Talk to Thiran AI',
  });

  @override
  State<VoicePulseButton> createState() => _VoicePulseButtonState();
}

class _VoicePulseButtonState extends State<VoicePulseButton> with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.isListening) {
      _animController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(VoicePulseButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening != oldWidget.isListening) {
      if (widget.isListening) {
        _animController.repeat(reverse: true);
      } else {
        _animController.stop();
        _animController.reset();
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        final scale = widget.isListening ? 1.0 + (_animController.value * 0.15) : 1.0;

        return Transform.scale(
          scale: scale,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onPressed,
              borderRadius: BorderRadius.circular(40),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.isListening
                        ? [AppColors.warningAmber, const Color(0xFFB45309)]
                        : [AppColors.primaryGreen, AppColors.primaryGreenDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: (widget.isListening ? AppColors.warningAmber : AppColors.primaryGreen).withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.isListening ? Icons.graphic_eq : Icons.mic,
                      color: Colors.white,
                      size: 26,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
