import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_strings.dart';
import '../../core/network/api_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/voice_input_modal.dart';

class ChatMessageItem {
  final String text;
  final bool isUser;
  final String senderTitle;
  final String timestamp;
  final bool isAudio;

  ChatMessageItem({
    required this.text,
    required this.isUser,
    required this.senderTitle,
    required this.timestamp,
    this.isAudio = false,
  });
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessageItem> _messages = [];
  bool _isTyping = false;
  bool _isEscalated = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final strings = Provider.of<AppStrings>(context, listen: false);
      _messages.add(
        ChatMessageItem(
          text: strings.tr('chatInitialGreeting'),
          isUser: false,
          senderTitle: '${strings.tr('appName')} Assistant',
          timestamp: strings.tr('justNow'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _sendMessage(String content) {
    final query = content.trim();
    if (query.isEmpty) return;
    _textController.clear();

    final strings = Provider.of<AppStrings>(context, listen: false);
    final apiService = Provider.of<ApiService>(context, listen: false);
    final profile = apiService.currentProfile;
    final lang = strings.currentLanguage;

    setState(() {
      _messages.add(ChatMessageItem(
        text: query,
        isUser: true,
        senderTitle: strings.tr('you'),
        timestamp: strings.tr('justNow'),
      ));
      _isTyping = true;
    });

    // Generate intelligent, profile-aware response
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      final reply = _generateAIResponse(query, profile, lang, strings);

      setState(() {
        _isTyping = false;
        _messages.add(ChatMessageItem(
          text: reply,
          isUser: false,
          senderTitle: _isEscalated
              ? strings.tr('humanHelp')
              : '${strings.tr('appName')} Assistant',
          timestamp: strings.tr('justNow'),
        ));
      });
    });
  }

  String _generateAIResponse(String query, dynamic profile, String lang, AppStrings strings) {
    final lower = query.toLowerCase();
    final edu = profile?.educationLevel ?? '10th Standard';
    final work = profile?.currentWork ?? 'Assistant';

    if (lang == 'ta') {
      if (lower.contains('சோலார்') || lower.contains('சூரிய') || lower.contains('solar')) {
        return 'உங்கள் $edu தகுதிக்கு ஏற்றவாறு, அரசு உதவித்தொகையுடன் கூடிய 6 வார சூரிய ஒளி மின்கல (Solar PV Rooftop) பயிற்சி திருச்சியில் உள்ளது. இதில் செய்முறை வயரிங் மற்றும் பாதுகாப்பு பயிற்சிகள் வழங்கப்பட்டு சான்றிதழ் அளிக்கப்படும். பயிற்சி முடித்தவுடன் ₹18,000 - ₹24,000 வரை தொடக்க ஊதியத்துடன் வேலைவாய்ப்பு கிடைக்கும்.';
      } else if (lower.contains('பயிற்சி') || lower.contains('course') || lower.contains('கற்க')) {
        return 'தற்போது உங்கள் அனுபவத்திற்கு ஏற்றவாறு 3 முக்கிய பயிற்சிகள் உள்ளன: 1) சோலார் PV இன்வெர்ட்டர் நிறுவல், 2) விவசாய ட்ரோன் இயக்கம், 3) மின்வாகன பேட்டரி பழுதுநீக்கம். இவை அனைத்தும் அரசு அங்கீகாரம் பெற்றவை. தகுதிப் பாதை பிரிவில் விண்ணப்பிக்கலாம்.';
      } else if (lower.contains('வேலை') || lower.contains('job') || lower.contains('சம்பளம்') || lower.contains('salary')) {
        return 'உங்கள் தற்போதைய $work அனுபவத்திற்கு உள்ளூர் மற்றும் மாவட்ட அளவில் 12 நேரடி வேலைவாய்ப்புகள் உள்ளன. தொடக்க ஊதியம் ₹18,000 முதல் ₹26,000 வரை. நேர்காணல் வழிகாட்டலுக்கு எங்கள் ஆலோசகரை தொடர்பு கொள்ளலாம்.';
      } else if (lower.contains('வழிகாட்டி') || lower.contains('mentor') || lower.contains('உதவி')) {
        return 'மூத்த சோலார் தொழில்நுட்ப நிபுணர் திரு. முருகன் சுந்தரம் அவர்களின் நேரடி வழிகாட்டலை நீங்கள் கோரலாம். அவர்கள் உங்களுக்கு தேர்வு மற்றும் களப் பயிற்சிக்கான நுணுக்கங்களை கற்றுக் கொடுப்பார்கள்.';
      } else {
        return 'உங்கள் கேள்வி பெறப்பட்டது. உங்கள் $work மற்றும் $edu பின்னணிக்கு உகந்த வாழ்வாதார வாய்ப்புகள் மற்றும் தொழில் முன்னேற்றப் பாதைகள் திறன் AI-இல் தயாராக உள்ளன. மேலும் விவரங்களுக்கு பயிற்சிகள் அல்லது வேலைவாய்ப்புகள் பக்கத்தைப் பார்வையிடலாம்.';
      }
    } else if (lang == 'hi') {
      if (lower.contains('solar') || lower.contains('सोलर')) {
        return 'आपकी $edu योग्यता के आधार पर, पीएम सूर्य घर योजना के तहत 6 सप्ताह का निःशुल्क सोलर रूफटॉप इंस्टॉलर प्रशिक्षण उपलब्ध है। इसे पूरा करने पर ₹18,000 से ₹24,000 प्रतिमाह तक का रोजगार अवसर प्राप्त हो सकता है।';
      } else if (lower.contains('job') || lower.contains('नौकरी') || lower.contains('काम')) {
        return 'आपके $work अनुभव के लिए 12 नए अवसर उपलब्ध हैं। आप सीधे आवेदन कर सकते हैं या आवश्यक प्रमाणीकरण के लिए कौशल प्रशिक्षण शुरू कर सकते हैं।';
      } else {
        return 'नमस्ते! आपकी $work पृष्ठभूमि और $edu योग्यता के आधार पर थिरन AI आपके करियर पाथवे को आगे बढ़ाने में मदद कर सकता है।';
      }
    } else if (lang == 'te') {
      if (lower.contains('solar') || lower.contains('సోలార్')) {
        return 'మీ $edu విద్యార్హతకు అనుగుణంగా, 6 వారాల సోలార్ రూఫ్‌టాప్ టెక్నీషియన్ శిక్షణ అందుబాటులో ఉంది. పూర్తి చేసిన తర్వాత ₹18,000 నుండి ₹24,000 వరకు వేతనం లభిస్తుంది.';
      } else {
        return 'మీ $work అనుభవం మరియు విద్యకు అనుగుణంగా తిరన్ AI మీకు సరైన జీవనోపాధి మార్గాన్ని సూచిస్తుంది.';
      }
    } else if (lang == 'kn') {
      if (lower.contains('solar') || lower.contains('ಸೋಲಾರ್')) {
        return 'ನಿಮ್ಮ $edu ವಿದ್ಯಾರ್ಹತೆಗೆ ಅನುಗುಣವಾಗಿ 6 ವಾರಗಳ ಸೋಲಾರ್ ತಂತ್ರಜ್ಞ ತರಬೇತಿ ಲಭ್ಯವಿದೆ. ಪ್ರಮಾಣೀಕರಣದ ನಂತರ ₹18,000 ರಿಂದ ₹24,000 ವರೆಗೆ ಮಾಸಿಕ ವೇತನದ ಅವಕಾಶವಿದೆ.';
      } else {
        return 'ನಿಮ್ಮ $work ಹಿನ್ನೆಲೆಗೆ ಸೂಕ್ತವಾದ ಉದ್ಯೋಗ ಮತ್ತು ಕೌಶಲ್ಯ ಮಾರ್ಗಗಳನ್ನು ತಿರನ್ AI ಒದಗಿಸುತ್ತದೆ.';
      }
    } else if (lang == 'ml') {
      if (lower.contains('solar') || lower.contains('സോളാർ')) {
        return 'നിങ്ങളുടെ $edu യോഗ്യതയ്ക്ക് അനുയോജ്യമായ 6 ആഴ്ചത്തെ സോളാർ പിവി ഇൻസ്റ്റാളേഷൻ പരിശീലനം ലഭ്യമാണ്. പൂർത്തിയാക്കിയ ശേഷം ₹18,000 മുതൽ ₹24,000 വരെ വേതനം ലഭിക്കുന്നതാണ്.';
      } else {
        return 'നിങ്ങളുടെ $work അനുഭവത്തിനും യോഗ്യതയ്ക്കും അനുയോജ്യമായ മികച്ച അവസരങ്ങൾ തിരൻ AI കണ്ടെത്തുന്നു.';
      }
    } else {
      // English default
      if (lower.contains('solar') || lower.contains('training') || lower.contains('course')) {
        return 'Based on your $edu background and $work experience, accredited 6-week Solar PV Installation Technician courses are open for enrollment. This includes subsidized practical safety modules, field wiring, and Level-4 certification, leading to onsite placements paying ₹18,000 - ₹24,000/month.';
      } else if (lower.contains('job') || lower.contains('opportunity') || lower.contains('salary') || lower.contains('wage')) {
        return 'There are currently 12 active verified opportunities matching your skills in renewable energy and electrical services, offering starting compensation between ₹18,000 and ₹26,000/month with local district commuting.';
      } else if (lower.contains('mentor') || lower.contains('help') || lower.contains('guide')) {
        return 'You can request 1-on-1 career guidance with Senior Solar Specialist Murugan Sundaram or Community Agritech Mentor Dr. Radhika Iyer in the Mentors tab.';
      } else {
        return 'Thank you for your message. Thiran AI has analyzed your profile as an aspiring technical technician with $edu qualification. You can explore accredited training pathways, apply for matched openings, or simulate skill impact on your dashboard.';
      }
    }
  }

  Future<void> _handleVoiceInput() async {
    final strings = Provider.of<AppStrings>(context, listen: false);
    final result = await VoiceInputModal.show(
      context: context,
      title: strings.tr('chatTitle'),
      quickOptions: strings.currentLanguage == 'ta'
          ? ['சோலார் பயிற்சி பற்றி சொல்லுங்கள்', 'எனக்கு ஏற்ற வேலை வாய்ப்புகள் என்ன?', 'வழிகாட்டல் எவ்வாறு பெறுவது?']
          : ['Tell me about solar training', 'What opportunities match my profile?', 'How to connect with a mentor?'],
    );

    if (result != null && result.trim().isNotEmpty) {
      _sendMessage(result.trim());
    }
  }

  void _escalateToHuman() {
    final strings = Provider.of<AppStrings>(context, listen: false);
    setState(() {
      _isEscalated = true;
      _messages.add(ChatMessageItem(
        text: strings.tr('escalatedMessage'),
        isUser: false,
        senderTitle: strings.tr('humanHelp'),
        timestamp: strings.tr('justNow'),
      ));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primaryGreen,
        content: Text(strings.tr('escalatedMessage')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = Provider.of<AppStrings>(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.tr('chatTitle'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isEscalated ? AppColors.warningAmber : AppColors.successGreen,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  _isEscalated ? strings.tr('counselorActive') : strings.tr('chatOnline'),
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (!_isEscalated)
            TextButton.icon(
              onPressed: _escalateToHuman,
              icon: const Icon(Icons.support_agent, color: AppColors.warningAmber, size: 18),
              label: Text(
                strings.tr('humanHelp'),
                style: const TextStyle(color: AppColors.warningAmber, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Row(
                children: [
                  const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryGreen)),
                  const SizedBox(width: 8),
                  Text(strings.tr('aiThinking'), style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
          // Input row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.borderLight)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.mic, color: AppColors.primaryGreen),
                    tooltip: strings.tr('tapAndSpeak'),
                    onPressed: _handleVoiceInput,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: strings.tr('chatHint'),
                        hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send, color: AppColors.primaryGreen),
                    onPressed: () => _sendMessage(_textController.text),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessageItem msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: msg.isUser ? AppColors.primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: msg.isUser ? null : Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  msg.senderTitle,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: msg.isUser ? Colors.white70 : AppColors.accentTeal,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  msg.timestamp,
                  style: TextStyle(fontSize: 9, color: msg.isUser ? Colors.white60 : AppColors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              msg.text,
              style: TextStyle(
                fontSize: 14,
                color: msg.isUser ? Colors.white : AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
