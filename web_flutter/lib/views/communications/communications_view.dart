import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/network/web_api_service.dart';
import '../../core/services/web_voice_recognition_service.dart';
import '../../core/theme/app_theme.dart';

class CommunicationsView extends StatefulWidget {
  const CommunicationsView({super.key});

  @override
  State<CommunicationsView> createState() => _CommunicationsViewState();
}

class _CommunicationsViewState extends State<CommunicationsView> with SingleTickerProviderStateMixin {
  final TextEditingController _waPhoneCtrl = TextEditingController(text: '+919840112301');
  final TextEditingController _waMsgCtrl = TextEditingController(text: 'வணக்கம், எனக்கு சோலார் பயிற்சி தகவல் வேண்டும்.');
  final TextEditingController _ivrPhoneCtrl = TextEditingController(text: '+919840112302');
  final TextEditingController _ivrSpeechCtrl = TextEditingController(text: 'I have 2 years stitching experience');

  final WebVoiceRecognitionService _voiceService = WebVoiceRecognitionService();
  late AnimationController _pulseController;

  bool _isIvrListening = false;
  bool _isWaListening = false;
  String _ivrLocale = 'en_IN';
  String _waLocale = 'ta_IN';
  double _soundLevel = 0.0;
  String? _voiceNotice;

  String? _waResult;
  String? _ivrResult;
  bool _isProcessing = false;
  List<dynamic> _conversations = [];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _loadConversations();
  }

  @override
  void dispose() {
    _voiceService.cancelListening();
    _pulseController.dispose();
    _waPhoneCtrl.dispose();
    _waMsgCtrl.dispose();
    _ivrPhoneCtrl.dispose();
    _ivrSpeechCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadConversations() async {
    final api = Provider.of<WebApiService>(context, listen: false);
    final convs = await api.getConversations();
    if (mounted) {
      setState(() => _conversations = convs);
    }
  }

  Future<void> _toggleIvrListening() async {
    if (_isIvrListening) {
      await _voiceService.stopListening();
      if (mounted) {
        setState(() {
          _isIvrListening = false;
          _soundLevel = 0.0;
        });
      }
    } else {
      if (_isWaListening) {
        await _voiceService.stopListening();
      }
      setState(() {
        _isIvrListening = true;
        _isWaListening = false;
        _voiceNotice = null;
        _ivrSpeechCtrl.clear();
      });

      final success = await _voiceService.startListening(
        localeId: _ivrLocale,
        onResult: (text, isFinal) {
          if (!mounted) return;
          setState(() {
            _ivrSpeechCtrl.text = text;
            if (isFinal) {
              _isIvrListening = false;
              _soundLevel = 0.0;
            }
          });
        },
        onSoundLevel: (level) {
          if (!mounted) return;
          setState(() => _soundLevel = level);
        },
        onError: (err) {
          if (!mounted) return;
          setState(() {
            _isIvrListening = false;
            _voiceNotice = err;
            _soundLevel = 0.0;
          });
        },
      );

      if (!success && mounted) {
        setState(() {
          _isIvrListening = false;
          _voiceNotice = _voiceService.errorMessage ?? 'Microphone speech recognition unavailable.';
        });
      }
    }
  }

  Future<void> _toggleWaListening() async {
    if (_isWaListening) {
      await _voiceService.stopListening();
      if (mounted) {
        setState(() {
          _isWaListening = false;
          _soundLevel = 0.0;
        });
      }
    } else {
      if (_isIvrListening) {
        await _voiceService.stopListening();
      }
      setState(() {
        _isWaListening = true;
        _isIvrListening = false;
        _voiceNotice = null;
        _waMsgCtrl.clear();
      });

      final success = await _voiceService.startListening(
        localeId: _waLocale,
        onResult: (text, isFinal) {
          if (!mounted) return;
          setState(() {
            _waMsgCtrl.text = text;
            if (isFinal) {
              _isWaListening = false;
              _soundLevel = 0.0;
            }
          });
        },
        onSoundLevel: (level) {
          if (!mounted) return;
          setState(() => _soundLevel = level);
        },
        onError: (err) {
          if (!mounted) return;
          setState(() {
            _isWaListening = false;
            _voiceNotice = err;
            _soundLevel = 0.0;
          });
        },
      );

      if (!success && mounted) {
        setState(() {
          _isWaListening = false;
          _voiceNotice = _voiceService.errorMessage ?? 'Microphone speech recognition unavailable.';
        });
      }
    }
  }

  Future<void> _triggerWhatsAppTest() async {
    final api = Provider.of<WebApiService>(context, listen: false);
    setState(() => _isProcessing = true);
    final res = await api.simulateWhatsAppMessage(_waPhoneCtrl.text.trim(), _waMsgCtrl.text.trim());
    await _loadConversations();
    setState(() {
      _waResult = 'Delivered -> AI Response: "${res['response'] ?? 'Acknowledged'}"';
      _isProcessing = false;
    });
  }

  Future<void> _triggerIVRTest() async {
    final api = Provider.of<WebApiService>(context, listen: false);
    setState(() => _isProcessing = true);
    final res = await api.simulateIVRCall(_ivrPhoneCtrl.text.trim(), _ivrSpeechCtrl.text.trim());
    await _loadConversations();
    setState(() {
      _ivrResult = 'IVR Call Finished -> TTS Output: "${res['ttsMessage'] ?? 'Call Completed'}"';
      _isProcessing = false;
    });
  }

  Widget _buildSoundWave(bool active) {
    if (!active) return const SizedBox.shrink();
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, _) {
        return Container(
          margin: const EdgeInsets.only(top: 8, bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Listening live to microphone...',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF)),
              ),
              const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(8, (i) {
                  final wave = sin((_pulseController.value * 2 * pi) + (i * 0.5)).abs();
                  final h = (6.0 + (wave * 12.0) + (_soundLevel * 14.0)).clamp(4.0, 24.0);
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    width: 3,
                    height: h,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6),
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isMobile = screenWidth < 900;

        final waCard = Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: WebColors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.message, color: Color(0xFF25D366), size: 22),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'WhatsApp Webhook & Voice Dictation',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _waPhoneCtrl,
                decoration: const InputDecoration(labelText: 'Sender Phone Number', prefixIcon: Icon(Icons.phone, size: 16)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _waMsgCtrl,
                decoration: InputDecoration(
                  labelText: 'Inbound Message Payload / Voice Note',
                  prefixIcon: const Icon(Icons.chat, size: 16),
                  suffixIcon: Tooltip(
                    message: _isWaListening ? 'Stop listening' : 'Dictate with microphone',
                    child: IconButton(
                      icon: Icon(
                        _isWaListening ? Icons.mic : Icons.mic_none,
                        color: _isWaListening ? const Color(0xFFDC2626) : const Color(0xFF25D366),
                      ),
                      onPressed: _toggleWaListening,
                    ),
                  ),
                ),
              ),
              _buildSoundWave(_isWaListening),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('Dictation Language: ', style: TextStyle(fontSize: 11, color: WebColors.textMuted)),
                  const SizedBox(width: 6),
                  DropdownButton<String>(
                    value: _waLocale,
                    isDense: true,
                    style: const TextStyle(fontSize: 12, color: WebColors.textDark),
                    items: const [
                      DropdownMenuItem(value: 'ta_IN', child: Text('Tamil (ta-IN)')),
                      DropdownMenuItem(value: 'en_IN', child: Text('English (en-IN)')),
                      DropdownMenuItem(value: 'hi_IN', child: Text('Hindi (hi-IN)')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _waLocale = val);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 42),
                ),
                onPressed: _isProcessing ? null : _triggerWhatsAppTest,
                icon: const Icon(Icons.send, size: 16),
                label: const Text('Send Simulated WhatsApp Event'),
              ),
              if (_waResult != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Text(_waResult!, style: const TextStyle(fontSize: 12, color: Color(0xFF15803D), fontWeight: FontWeight.w600)),
                ),
              ],
            ],
          ),
        );

        final ivrCard = Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: WebColors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.phone_in_talk, color: Color(0xFF0284C7), size: 22),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'IVR Telephony Tester & Live Speech Recognition',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _ivrPhoneCtrl,
                decoration: const InputDecoration(labelText: 'Caller Mobile Number', prefixIcon: Icon(Icons.phone, size: 16)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _ivrSpeechCtrl,
                decoration: InputDecoration(
                  labelText: 'Speech Input / Transcribed Audio',
                  prefixIcon: const Icon(Icons.mic, size: 16),
                  suffixIcon: Tooltip(
                    message: _isIvrListening ? 'Stop listening' : 'Speak into microphone',
                    child: IconButton(
                      icon: Icon(
                        _isIvrListening ? Icons.mic : Icons.mic_none,
                        color: _isIvrListening ? const Color(0xFFDC2626) : const Color(0xFF0284C7),
                      ),
                      onPressed: _toggleIvrListening,
                    ),
                  ),
                ),
              ),
              _buildSoundWave(_isIvrListening),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('Recognition Language: ', style: TextStyle(fontSize: 11, color: WebColors.textMuted)),
                  const SizedBox(width: 6),
                  DropdownButton<String>(
                    value: _ivrLocale,
                    isDense: true,
                    style: const TextStyle(fontSize: 12, color: WebColors.textDark),
                    items: const [
                      DropdownMenuItem(value: 'en_IN', child: Text('English (en-IN)')),
                      DropdownMenuItem(value: 'ta_IN', child: Text('Tamil (ta-IN)')),
                      DropdownMenuItem(value: 'hi_IN', child: Text('Hindi (hi-IN)')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _ivrLocale = val);
                    },
                  ),
                  const Spacer(),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: _toggleIvrListening,
                    icon: Icon(
                      _isIvrListening ? Icons.stop : Icons.mic,
                      size: 16,
                      color: _isIvrListening ? const Color(0xFFDC2626) : const Color(0xFF0284C7),
                    ),
                    label: Text(
                      _isIvrListening ? 'Stop' : 'Speak Now',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _isIvrListening ? const Color(0xFFDC2626) : const Color(0xFF0284C7),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 42),
                ),
                onPressed: _isProcessing ? null : _triggerIVRTest,
                icon: const Icon(Icons.call, size: 16),
                label: const Text('Simulate Incoming IVR Call Flow'),
              ),
              if (_ivrResult != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F9FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFBAE6FD)),
                  ),
                  child: Text(_ivrResult!, style: const TextStyle(fontSize: 12, color: Color(0xFF0369A1), fontWeight: FontWeight.w600)),
                ),
              ],
            ],
          ),
        );

        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16.0 : 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Omnichannel Communication Center & Live Webhook Testers',
                style: TextStyle(fontSize: isMobile ? 18 : 22, fontWeight: FontWeight.bold, color: WebColors.textDark),
              ),
              const SizedBox(height: 4),
              Text(
                'Unified orchestration across WhatsApp Business API, Telephony IVR, and Live Voice Input',
                style: TextStyle(fontSize: isMobile ? 11 : 13, color: WebColors.textMuted),
              ),
              if (_voiceNotice != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: Color(0xFFD97706)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _voiceNotice!,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF92400E)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),

              if (isMobile)
                Column(
                  children: [
                    waCard,
                    const SizedBox(height: 16),
                    ivrCard,
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: waCard),
                    const SizedBox(width: 24),
                    Expanded(child: ivrCard),
                  ],
                ),

              const SizedBox(height: 32),

              // Omnichannel Log Table
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: WebColors.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Live Unified Communication Threads', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.refresh, size: 18, color: WebColors.textMuted),
                          onPressed: _loadConversations,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_conversations.isEmpty)
                      const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('No communication events recorded yet', style: TextStyle(color: WebColors.textMuted))))
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _conversations.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final c = _conversations[i];
                          final msgs = c['messages'] as List<dynamic>? ?? [];
                          final lastMsg = msgs.isNotEmpty ? msgs.last['content'] : 'Session Started';

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: c['channel'] == 'WHATSAPP'
                                    ? const Color(0xFF25D366).withValues(alpha: 0.1)
                                    : (c['channel'] == 'IVR' ? Colors.blue.withValues(alpha: 0.1) : WebColors.primaryGreen.withValues(alpha: 0.1)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                c['channel'] == 'WHATSAPP'
                                    ? Icons.chat
                                    : (c['channel'] == 'IVR' ? Icons.phone : Icons.smartphone),
                                color: c['channel'] == 'WHATSAPP'
                                    ? const Color(0xFF25D366)
                                    : (c['channel'] == 'IVR' ? Colors.blue : WebColors.primaryGreen),
                                size: 18,
                              ),
                            ),
                            title: Text('Channel: ${c['channel']} • Language: ${c['language'].toUpperCase()}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                            subtitle: Text('Last: $lastMsg', style: const TextStyle(fontSize: 12, color: WebColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: c['status'] == 'ESCALATED_TO_HUMAN'
                                    ? WebColors.warningAmber.withValues(alpha: 0.1)
                                    : WebColors.successGreen.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                c['status'],
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: c['status'] == 'ESCALATED_TO_HUMAN' ? WebColors.warningAmber : WebColors.successGreen,
                                ),
                              ),
                            ),
                          );
                        },
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
}
