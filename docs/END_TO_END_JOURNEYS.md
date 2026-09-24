# Jeevika AI — Verified End-to-End User Journeys

### Journey 1: Beneficiary Voice Intake & Pathway Discovery
1. **Launch App**: Open `mobile_flutter`. The splash screen initializes the session and displays the deep-green civic identity.
2. **Language Selection**: Select **தமிழ் (Tamil)** or **English**. The UI strings update across all widgets instantly.
3. **Explicit Consent**: Review clear disclosures explaining how data is used for skill matching, AI-assisted advisory (not official legal decisions), and communication opt-ins.
4. **Login / OTP**: Enter phone number or select a synthetic test persona (e.g., Arun Kumar). Simulated OTP `123456` verifies the session.
5. **Adaptive Voice Interview**: Experience the voice intake with animated waveform pulses. Speak or select a quick option regarding education, current trade, and aspirations.
6. **Profile Confirmation**: Review the structured "Here is what I understood" summary distinguishing AI-inferred skills from declared skills.
7. **Pathway & Simulator**: Examine the active pathway stepper (`CURRENT → GAP → TRAIN → ASSESS → CERTIFY → APPLY`) and simulate completing a Level-4 Rooftop Solar course to see readiness jump to 92%.

---

### Journey 2: Omnichannel WhatsApp Inbound Sync
1. Open the Flutter Web Operations Portal (`http://localhost:3000`) and navigate to **Omnichannel Comms**.
2. Under **WhatsApp Webhook Tester**, enter phone `+919840112301` with message: *"வணக்கம், எனக்கு சோலார் பயிற்சி தகவல் வேண்டும்."*
3. Click **Send Simulated WhatsApp Event**.
4. The webhook is received at `POST /api/webhooks/whatsapp` idempotently, parsed, linked to Arun Kumar's unified conversation thread, and an automated response is returned.
5. In the message threads table below, the message appears with the green WhatsApp badge and delivery confirmation.

---

### Journey 3: Telephony IVR Call Flow
1. In the Web Operations Portal under **Omnichannel Comms**, locate the **IVR Telephony Tester**.
2. Enter mobile number and transcribed spoken phrase: *"I have 2 years stitching experience"*.
3. Click **Simulate Incoming IVR Call Flow**.
4. The backend receives `POST /api/webhooks/ivr/call-start`, triggers the multi-language greeting, captures DTMF/speech input, and outputs the audio TTS instructions for next actions.

---

### Journey 4: Mentorship Connection & Escalation
1. In the mobile app, navigate to **Mentors**.
2. Browse verified mentors (e.g. Murugan Sundaram, 9 years exp, Solar Rooftop specialist).
3. Tap **Connect & Schedule Call**, enter the inquiry topic, and submit.
4. In the Chat view, if the beneficiary clicks **Human Help**, the AI conversation is escalated to human support and creates a ticket in the counselor's queue.

---

### Journey 5: Operations & Program Administration
1. Log into the Web Console as **Admin Console** or **Support Counselor**.
2. Inspect live KPI cards (Active Beneficiaries, Active Mentors, Training Referrals, Open Opportunities, Completed Pathways, Pending Follow-Ups).
3. Review the **Pathway Funnel** showing drop-offs between intake and job application.
4. Open the **Beneficiary Directory**, click any candidate (e.g. Meenakshi Sundaram) to slide out the detailed candidate dossier showing verified skills and progress.
