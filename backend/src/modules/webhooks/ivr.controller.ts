import { Router, Request, Response } from 'express';
import { v4 as uuidv4 } from 'uuid';
import { db } from '../../database/db';

export const ivrRouter = Router();

// Store active call states in memory
interface IVRCallState {
  callSid: string;
  fromPhone: string;
  selectedLanguage: string;
  step: 'LANGUAGE_PROMPT' | 'CONSENT_PROMPT' | 'QUESTION_1' | 'QUESTION_2' | 'SUMMARY' | 'AGENT_TRANSFER';
  answers: Array<{ question: string; answer: string }>;
}

const activeCalls = new Map<string, IVRCallState>();

// Handle incoming call start
ivrRouter.post('/call-start', (req: Request, res: Response) => {
  const { CallSid = uuidv4(), From = '+919840112301' } = req.body;

  const state: IVRCallState = {
    callSid: CallSid,
    fromPhone: From,
    selectedLanguage: 'ta',
    step: 'LANGUAGE_PROMPT',
    answers: []
  };
  activeCalls.set(CallSid, state);

  // Return provider-agnostic IVR TwiML / response instructions
  return res.json({
    success: true,
    callSid: CallSid,
    responseType: 'PLAY_AND_GATHER',
    ttsMessage: 'Welcome to Jeevika AI Livelihood Support. தமிழுக்கு 1ஐ அழுத்தவும். For English, press 2. हिंदी के लिए 3 दबाएं.',
    gather: {
      inputMethod: 'DTMF_OR_SPEECH',
      timeoutSeconds: 5,
      numDigits: 1,
      actionUrl: '/api/webhooks/ivr/input'
    }
  });
});

// Handle call input (Speech or DTMF keypad digits)
ivrRouter.post('/input', (req: Request, res: Response) => {
  const { CallSid, Digits, SpeechResult } = req.body;
  const state = activeCalls.get(CallSid) || {
    callSid: CallSid || uuidv4(),
    fromPhone: '+919840112301',
    selectedLanguage: 'ta',
    step: 'LANGUAGE_PROMPT',
    answers: []
  };

  const input = Digits || SpeechResult || '1';

  if (state.step === 'LANGUAGE_PROMPT') {
    if (input === '2' || input.toLowerCase().includes('english')) {
      state.selectedLanguage = 'en';
    } else if (input === '3' || input.toLowerCase().includes('hindi')) {
      state.selectedLanguage = 'hi';
    } else {
      state.selectedLanguage = 'ta';
    }
    state.step = 'CONSENT_PROMPT';
    activeCalls.set(state.callSid, state);

    const consentPrompt = state.selectedLanguage === 'ta'
      ? 'ஜீவிகா வழிகாட்டலுக்காக உங்கள் குரல் விவரங்களை பதிவு செய்ய சம்மதமா? ஆம் எனில் 1, மனித உதவியாளருக்கு 0 அழுத்தவும்.'
      : 'Do you consent to voice analysis for career pathways? Press 1 to agree, or press 0 for human agent.';

    return res.json({
      success: true,
      callSid: state.callSid,
      responseType: 'PLAY_AND_GATHER',
      ttsMessage: consentPrompt,
      gather: { inputMethod: 'DTMF_OR_SPEECH', numDigits: 1, actionUrl: '/api/webhooks/ivr/input' }
    });
  }

  if (state.step === 'CONSENT_PROMPT') {
    if (input === '0') {
      state.step = 'AGENT_TRANSFER';
      return res.json({
        success: true,
        callSid: state.callSid,
        responseType: 'TRANSFER_AGENT',
        ttsMessage: 'Connecting you to our community support counselor. Please stay on the line.'
      });
    }

    state.step = 'QUESTION_1';
    activeCalls.set(state.callSid, state);

    const q1 = state.selectedLanguage === 'ta'
      ? 'நீங்கள் தற்போது என்ன வேலை அல்லது அனுபவம் கொண்டிருக்கிறீர்கள்? பீப் ஒலிக்கு பின் பேசவும்.'
      : 'Please state your current work or practical trade after the tone.';

    return res.json({
      success: true,
      callSid: state.callSid,
      responseType: 'RECORD_AND_TRANSCRIBE',
      ttsMessage: q1,
      gather: { inputMethod: 'SPEECH', timeoutSeconds: 6, actionUrl: '/api/webhooks/ivr/input' }
    });
  }

  if (state.step === 'QUESTION_1') {
    state.answers.push({ question: 'Current Experience', answer: input });
    state.step = 'SUMMARY';

    // Map IVR session to beneficiary profile and store conversation
    let user = db.findOne('users', u => u.phone === state.fromPhone);
    let ben = user ? db.findOne('beneficiaryProfiles', p => p.userId === user.id) : null;

    if (!ben) {
      user = db.insert('users', {
        phone: state.fromPhone,
        fullName: 'IVR Beneficiary',
        role: 'BENEFICIARY',
        status: 'ACTIVE',
        preferredLanguage: state.selectedLanguage,
        isConsented: true
      });
      ben = db.insert('beneficiaryProfiles', {
        userId: user.id,
        fullName: 'IVR Beneficiary',
        phone: state.fromPhone,
        preferredLanguage: state.selectedLanguage,
        educationLevel: '10th Standard',
        currentWork: input,
        previousExperience: input,
        location: 'Tamil Nadu Region',
        mobilityConstraints: 'District level',
        preferredWorkType: 'ANY',
        internetAccess: false,
        completionRate: 65
      });
    }

    let conv = db.findOne('conversations', c => c.beneficiaryId === ben.id && c.channel === 'IVR');
    if (!conv) {
      conv = db.insert('conversations', {
        beneficiaryId: ben.id,
        channel: 'IVR',
        language: state.selectedLanguage,
        status: 'ACTIVE',
        summary: `IVR call completed. Recorded: ${input}`,
        messages: []
      });
    }

    conv.messages.push({
      id: uuidv4(),
      senderId: user.id,
      senderRole: 'BENEFICIARY',
      content: `[IVR Voice Audio]: ${input}`,
      channel: 'IVR',
      timestamp: new Date().toISOString()
    });
    db.update('conversations', conv.id, { messages: conv.messages });

    const completionMsg = state.selectedLanguage === 'ta'
      ? 'நன்றி! உங்கள் விவரங்கள் பதிவு செய்யப்பட்டன. உங்களுக்கு ஏற்ற சோலார் மற்றும் தொழிற்கல்வி வாய்ப்புகள் SMS மூலம் அனுப்பப்படும்.'
      : 'Thank you. Your profile is updated. Suitable livelihood pathways will be shared via SMS.';

    return res.json({
      success: true,
      callSid: state.callSid,
      responseType: 'HANGUP',
      ttsMessage: completionMsg
    });
  }

  return res.json({
    success: true,
    responseType: 'HANGUP',
    ttsMessage: 'Call completed. Thank you for calling Jeevika AI.'
  });
});

// Call status updates
ivrRouter.post('/call-status', (req: Request, res: Response) => {
  const { CallSid, CallStatus, CallDuration } = req.body;
  console.log(`[IVR Status] Call: ${CallSid} Status: ${CallStatus} Duration: ${CallDuration}s`);
  if (CallStatus === 'completed') {
    activeCalls.delete(CallSid);
  }
  return res.json({ success: true, status: 'RECORDED' });
});
