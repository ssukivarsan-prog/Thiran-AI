import os
import json
import uuid
from typing import Optional, List, Dict, Any
from fastapi import FastAPI, Request, Response, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

app = FastAPI(
    title="Thiran AI API Gateway",
    description="Multilingual Voice-First Livelihood Intelligence Platform API",
    version="1.0.0"
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

DATA_PATH = os.path.join(os.path.dirname(__file__), "data", "jeevika_db.json")

def load_db() -> Dict[str, Any]:
    if os.path.exists(DATA_PATH):
        with open(DATA_PATH, "r", encoding="utf-8") as f:
            return json.load(f)
    return {
        "users": [],
        "beneficiaryProfiles": [],
        "skills": [],
        "userSkills": [],
        "opportunities": [],
        "courses": [],
        "pathways": [],
        "mentors": [],
        "mentorRequests": [],
        "conversations": [],
        "supportTickets": [],
        "auditLogs": []
    }

def save_db(data: Dict[str, Any]):
    os.makedirs(os.path.dirname(DATA_PATH), exist_ok=True)
    with open(DATA_PATH, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

# Health endpoints
@app.get("/health")
def health():
    return {
        "status": "HEALTHY",
        "service": "Thiran AI FastAPI Gateway",
        "runtime": "Python 3.14 / FastAPI"
    }

@app.get("/ready")
def ready():
    db = load_db()
    return {
        "status": "READY",
        "records": {
            "users": len(db.get("users", [])),
            "beneficiaries": len(db.get("beneficiaryProfiles", [])),
            "mentors": len(db.get("mentors", [])),
            "courses": len(db.get("courses", [])),
            "opportunities": len(db.get("opportunities", []))
        }
    }

# Auth Endpoints
@app.post("/api/auth/login")
async def login(payload: Dict[str, Any]):
    role = payload.get("role", "BENEFICIARY")
    phone = payload.get("phone")
    db = load_db()
    users = db.get("users", [])
    
    user = None
    if phone:
        user = next((u for u in users if u.get("phone") == phone), None)
    if not user:
        user = next((u for u in users if u.get("role") == role), None)
        
    if not user:
        user = {
            "id": f"usr-{str(uuid.uuid4())[:8]}",
            "phone": phone or "+919840112301",
            "fullName": "Demo User",
            "role": role,
            "status": "ACTIVE",
            "preferredLanguage": "ta"
        }
        users.append(user)
        save_db(db)
        
    return {
        "success": True,
        "data": {
            "token": f"jwt-token-fastapi-{user.get('id')}",
            "user": user
        }
    }

@app.post("/api/auth/send-otp")
async def send_otp(payload: Dict[str, Any]):
    phone = payload.get("phone", "+919840112301")
    return {
        "success": True,
        "data": {
            "message": "OTP sent successfully",
            "phone": phone,
            "debugCode": "123456"
        }
    }

@app.post("/api/auth/verify-otp")
async def verify_otp(payload: Dict[str, Any]):
    phone = payload.get("phone", "+919840112301")
    role = payload.get("role", "BENEFICIARY")
    db = load_db()
    users = db.get("users", [])
    user = next((u for u in users if u.get("phone") == phone), None)
    if not user:
        user = {
            "id": f"usr-{str(uuid.uuid4())[:8]}",
            "phone": phone,
            "fullName": payload.get("fullName", "Arun Kumar"),
            "role": role,
            "status": "ACTIVE",
            "preferredLanguage": payload.get("language", "ta")
        }
        users.append(user)
        save_db(db)
    return {
        "success": True,
        "data": {
            "token": f"jwt-token-{user.get('id')}",
            "user": user
        }
    }

@app.get("/api/auth/me")
def get_me():
    db = load_db()
    profiles = db.get("beneficiaryProfiles", [])
    profile = profiles[0] if profiles else None
    return {
        "success": True,
        "data": {
            "user": db.get("users", [])[0] if db.get("users") else None,
            "profile": profile
        }
    }

# Beneficiaries Endpoints
@app.get("/api/beneficiaries")
def get_beneficiaries(search: Optional[str] = None):
    db = load_db()
    profiles = db.get("beneficiaryProfiles", [])
    if search:
        q = search.lower()
        profiles = [p for p in profiles if q in p.get("fullName", "").lower() or q in p.get("phone", "") or q in p.get("currentWork", "").lower()]
    return {"success": True, "data": profiles, "meta": {"total": len(profiles)}}

@app.get("/api/beneficiaries/{id}")
def get_beneficiary(id: str):
    db = load_db()
    profile = next((p for p in db.get("beneficiaryProfiles", []) if p.get("id") == id or p.get("userId") == id), None)
    if not profile:
        raise HTTPException(status_code=404, detail="Beneficiary not found")
    user = next((u for u in db.get("users", []) if u.get("id") == profile.get("userId")), None)
    skills = [s for s in db.get("userSkills", []) if s.get("userId") == profile.get("userId")]
    pathway = next((p for p in db.get("pathways", []) if p.get("beneficiaryId") == profile.get("id")), None)
    return {"success": True, "data": {"profile": profile, "user": user, "skills": skills, "pathway": pathway}}

@app.post("/api/beneficiaries/voice-interview/next")
def voice_interview_next(payload: Dict[str, Any]):
    language = payload.get("language", "ta")
    history = payload.get("history", [])
    
    question_banks = {
        "ta": [
            {"text": "உங்கள் கல்வித் தகுதி என்ன?", "replies": ["10-ஆம் வகுப்பு", "12-ஆம் வகுப்பு", "ஐ.டி.ஐ (ITI)", "டிப்ளோமா / பட்டப்படிப்பு"]},
            {"text": "தற்போது நீங்கள் என்ன வேலை அல்லது வாழ்வாதாரப் பணி செய்கிறீர்கள்?", "replies": ["மின்சார வேலை உதவியாளர்", "தையல் கலைஞர்", "விவசாயப் பணி", "விற்பனை உதவியாளர்"]},
            {"text": "இந்தத் துறையில் உங்களுக்கு எத்தனை வருட நடைமுறை அனுபவம் உள்ளது?", "replies": ["புதியவர் (அனுபவமில்லை)", "1-2 ஆண்டுகள்", "3-5 ஆண்டுகள்", "5+ ஆண்டுகள்"]}
        ],
        "en": [
            {"text": "What is your highest educational qualification?", "replies": ["10th Standard", "12th Pass", "ITI Certificate", "Diploma / Degree"]},
            {"text": "What is your current work or livelihood occupation?", "replies": ["Electrical Assistant", "Tailoring & Garments", "Agriculture & Farming", "Retail & Sales"]},
            {"text": "How many years of practical experience do you have in this field?", "replies": ["Fresher (No Exp)", "1-2 Years", "3-5 Years", "5+ Years"]}
        ],
        "hi": [
            {"text": "आपकी उच्चतम शैक्षणिक योग्यता क्या है?", "replies": ["10वीं कक्षा", "12वीं पास", "आईटीआई", "डिप्लोमा / डिग्री"]},
            {"text": "वर्तमान में आप क्या काम या व्यवसाय करते हैं?", "replies": ["बिजली मिस्त्री सहायक", "सिलाई और वस्त्र", "कृषि कार्य", "खुदरा और बिक्री"]},
            {"text": "इस क्षेत्र में आपके पास कितने वर्षों का व्यावहारिक अनुभव है?", "replies": ["कोई अनुभव नहीं", "1-2 वर्ष", "3-5 वर्ष", "5+ वर्ष"]}
        ],
        "te": [
            {"text": "మీ అత్యున్నత విద్యార్హత ఏమిటి?", "replies": ["10వ తరగతి", "12వ తరగతి", "ఐటిఐ", "డిప్లొమా / డిగ్రీ"]},
            {"text": "ప్రస్తుతం మీరు ఏ పని లేదా వృత్తి చేస్తున్నారు?", "replies": ["ఎలక్ట్రికల్ అసిస్టెంట్", "టైలరింగ్ & దుస్తులు", "వ్యవసాయం", "రిటైల్ & సేల్స్"]},
            {"text": "ఈ రంగంలో మీకు ఎన్ని సంవత్సరాల ఆచరణాత్మక అనుభవం ఉంది?", "replies": ["అనుభవం లేదు", "1-2 సంవత్సరాలు", "3-5 సంవత్సరాలు", "5+ సంవత్సరాలు"]}
        ],
        "kn": [
            {"text": "ನಿಮ್ಮ ಅತ್ಯುನ್ನತ ಶೈಕ್ಷಣಿಕ ಅರ್ಹತೆ ಏನು?", "replies": ["10ನೇ ತರಗತಿ", "12ನೇ ತರಗತಿ", "ಐಟಿಐ", "ಡಿಪ್ಲೋಮಾ / ಪದವಿ"]},
            {"text": "ಪ್ರಸ್ತುತ ನೀವು ಯಾವ ಕೆಲಸ ಅಥವಾ ವೃತ್ತಿಯನ್ನು ಮಾಡುತ್ತಿದ್ದೀರಿ?", "replies": ["ಎಲೆಕ್ಟ್ರಿಕಲ್ ಸಹಾಯಕ", "ಟೈಲರಿಂಗ್ ಕೆಲಸ", "ಕೃಷಿ ಕೆಲಸ", "ಮಾರಾಟ ಸಹಾಯಕ"]},
            {"text": "ಈ ಕ್ಷೇತ್ರದಲ್ಲಿ ನಿಮಗೆ ಎಷ್ಟು ವರ್ಷಗಳ ಪ್ರಾಯೋಗಿಕ ಅನುಭವವಿದೆ?", "replies": ["ಅನುಭವವಿಲ್ಲ", "1-2 ವರ್ಷಗಳು", "3-5 ವರ್ಷಗಳು", "5+ ವರ್ಷಗಳು"]}
        ],
        "ml": [
            {"text": "നിങ്ങളുടെ ഏറ്റവും ഉയർന്ന വിദ്യാഭ്യാസ യോഗ്യത എന്താണ്?", "replies": ["10-ാം ക്ലാസ്", "12-ാം ക്ലാസ്", "ഐടിഐ", "ഡിപ്ലോമ / ബിരുദം"]},
            {"text": "നിലവിൽ നിങ്ങൾ എന്ത് ജോലിയോ ഉപജീവന മാർഗ്ഗമോ ആണ് ചെയ്യുന്നത്?", "replies": ["ഇലക്ട്രിക്കൽ അസിസ്റ്റന്റ്", "തയ്യൽ ജോലി", "കൃഷിപ്പണി", "റീട്ടെയിൽ & സെയിൽസ്"]},
            {"text": "ഈ മേഖലയിൽ നിങ്ങൾക്ക് എത്ര വർഷത്തെ പ്രായോഗിക പരിചയമുണ്ട്?", "replies": ["പരിചയമില്ല", "1-2 വർഷം", "3-5 വർഷം", "5+ വർഷം"]}
        ]
    }
    
    bank = question_banks.get(language, question_banks["en"])
    idx = min(len(history), len(bank) - 1)
    q = bank[idx]
    
    return {
        "success": True,
        "data": {
            "questionId": f"q-{idx+1}",
            "questionText": q["text"],
            "language": language,
            "suggestedQuickReplies": q["replies"],
            "isFinalQuestion": len(history) >= len(bank) - 1
        }
    }

@app.post("/api/beneficiaries/voice-interview/complete")
def voice_interview_complete(payload: Dict[str, Any]):
    history = payload.get("history", [])
    language = payload.get("language", "ta")
    
    edu = history[0].get("answer", "10th Standard") if len(history) > 0 and history[0].get("answer") != "Skipped" else "10th Standard"
    work = history[1].get("answer", "Field Technical Apprentice") if len(history) > 1 and history[1].get("answer") != "Skipped" else "Field Technical Apprentice"
    exp = history[2].get("answer", "2 years practical wiring") if len(history) > 2 and history[2].get("answer") != "Skipped" else "2 years practical wiring"
    asp = "சூரிய மின் நிறுவல் வல்லுநர்" if language == "ta" else "Solar PV Installation Technician"
    
    return {
        "success": True,
        "data": {
            "understoodSummary": {
                "education": edu,
                "currentWork": work,
                "experience": exp,
                "aspirations": asp,
                "skills": [
                    {"name": "சூரிய ஒளி மின்கல வயரிங்" if language == "ta" else "Solar PV Inverter Wiring", "verificationType": "AI_INFERRED"}
                ]
            }
        }
    }

# Opportunities Endpoints
@app.get("/api/opportunities")
def get_opportunities():
    db = load_db()
    return {"success": True, "data": db.get("opportunities", [])}

@app.post("/api/opportunities/match")
def match_opportunities(payload: Dict[str, Any]):
    db = load_db()
    opps = db.get("opportunities", [])
    result = []
    for o in opps:
        result.append({
            "opportunity": o,
            "alignmentScore": 88 if "Solar" in o.get("title", "") else 76,
            "whyShown": [
                "Demonstrated electrical wiring competency aligns with role requirements.",
                "Candidate location is within regional commute perimeter.",
                "Baseline education requirement satisfied."
            ],
            "missingRequirements": ["Level-4 Rooftop Solar Certification"],
            "isEligibleNow": False
        })
    return {"success": True, "data": result}

@app.post("/api/opportunities/{id}/apply")
def apply_opportunity(id: str):
    return {
        "success": True,
        "data": {
            "message": "Application submitted successfully to provider",
            "opportunityId": id,
            "status": "UNDER_REVIEW"
        }
    }

# Training Endpoints
@app.get("/api/training")
def get_training():
    db = load_db()
    return {"success": True, "data": db.get("courses", [])}

@app.post("/api/training/{id}/apply")
def apply_training(id: str):
    return {
        "success": True,
        "data": {
            "message": "Enrollment referral successfully generated",
            "courseId": id,
            "status": "ENROLLED"
        }
    }

# Mentors Endpoints
@app.get("/api/mentors")
def get_mentors():
    db = load_db()
    return {"success": True, "data": db.get("mentors", [])}

@app.post("/api/mentors/request")
def request_mentor(payload: Dict[str, Any]):
    db = load_db()
    reqs = db.get("mentorRequests", [])
    new_req = {
        "id": f"mr-{str(uuid.uuid4())[:6]}",
        "beneficiaryId": payload.get("beneficiaryId", "ben-1"),
        "mentorId": payload.get("mentorId", "men-1"),
        "topic": payload.get("topic", "Pathway Guidance"),
        "message": payload.get("message", "Requesting mentorship"),
        "status": "PENDING"
    }
    reqs.append(new_req)
    save_db(db)
    return {"success": True, "data": new_req}

# Pathways & Simulation Endpoints
@app.get("/api/pathways/{beneficiaryId}")
def get_pathway(beneficiaryId: str):
    db = load_db()
    pathways = db.get("pathways", [])
    pathway = next((p for p in pathways if p.get("beneficiaryId") == beneficiaryId), None)
    if not pathway and pathways:
        pathway = pathways[0]
    return {"success": True, "data": pathway}

@app.post("/api/pathways/simulate")
def simulate_pathway(payload: Dict[str, Any]):
    sim_course = payload.get("simulatedCourseId")
    sim_skill = payload.get("simulatedSkill")
    score = 75
    if sim_skill: score += 10
    if sim_course: score += 15
    stage = "APPLY" if score >= 90 else ("ASSESS" if score >= 80 else "TRAIN")
    return {
        "success": True,
        "data": {
            "simulatedStage": stage,
            "projectedAlignmentScore": score,
            "formalRequirementsSatisfied": ["Baseline Education Satisfied", "Simulation: Added Solar PV Certification"],
            "remainingGaps": ["Practical Verification on Site"] if score < 95 else [],
            "estimatedWeeksToJobReady": 2 if score < 95 else 0
        }
    }

# Conversations Endpoints
@app.get("/api/conversations")
def get_conversations():
    db = load_db()
    return {"success": True, "data": db.get("conversations", [])}

@app.post("/api/conversations/{id}/messages")
def post_conversation_message(id: str, payload: Dict[str, Any]):
    db = load_db()
    convs = db.get("conversations", [])
    conv = next((c for c in convs if c.get("id") == id), None)
    if not conv:
        conv = {
            "id": id,
            "beneficiaryId": "ben-1",
            "channel": payload.get("channel", "MOBILE_APP"),
            "language": "ta",
            "status": "ACTIVE",
            "messages": []
        }
        convs.append(conv)
    content = payload.get("content", "")
    conv["messages"].append({
        "id": str(uuid.uuid4()),
        "senderRole": "BENEFICIARY",
        "content": content,
        "channel": payload.get("channel", "MOBILE_APP"),
        "timestamp": "Just now"
    })
    ai_reply = "உங்கள் கேள்வியைப் பெற்றோம். சோலார் பயிற்சியில் சேர வாய்ப்புகள் உள்ளன."
    conv["messages"].append({
        "id": str(uuid.uuid4()),
        "senderRole": "AI",
        "content": ai_reply,
        "channel": payload.get("channel", "MOBILE_APP"),
        "timestamp": "Just now"
    })
    save_db(db)
    return {"success": True, "data": {"conversation": conv, "latestMessage": conv["messages"][-1]}}

@app.post("/api/conversations/{id}/escalate")
def escalate_conversation(id: str, payload: Dict[str, Any]):
    db = load_db()
    tickets = db.get("supportTickets", [])
    new_ticket = {
        "id": f"tkt-{str(uuid.uuid4())[:6]}",
        "beneficiaryId": "ben-1",
        "beneficiaryName": "Arun Kumar",
        "channel": "MOBILE_APP",
        "subject": "Counselor Help Requested",
        "reason": payload.get("reason", "Beneficiary requested human community counselor intervention"),
        "status": "OPEN"
    }
    tickets.append(new_ticket)
    save_db(db)
    return {"success": True, "data": {"message": "Escalated to human support queue", "ticket": new_ticket}}

# Omnichannel Webhooks
@app.get("/api/webhooks/whatsapp")
def verify_whatsapp(hub_mode: Optional[str] = Query(None, alias="hub.mode"), hub_challenge: Optional[str] = Query(None, alias="hub.challenge"), hub_verify_token: Optional[str] = Query(None, alias="hub.verify_token")):
    if hub_verify_token == "jeevika_verify_token_2026":
        return Response(content=hub_challenge, media_type="text/plain")
    return Response(status_code=403)

@app.post("/api/webhooks/whatsapp")
def whatsapp_inbound(payload: Dict[str, Any]):
    msg = payload.get("message", "WhatsApp message")
    sender = payload.get("from", "+919840112301")
    db = load_db()
    convs = db.get("conversations", [])
    conv = next((c for c in convs if c.get("channel") == "WHATSAPP"), None)
    if not conv:
        conv = {
            "id": f"conv-{str(uuid.uuid4())[:6]}",
            "beneficiaryId": "ben-1",
            "channel": "WHATSAPP",
            "language": "ta",
            "status": "ACTIVE",
            "messages": []
        }
        convs.append(conv)
    conv["messages"].append({
        "id": str(uuid.uuid4()),
        "senderRole": "BENEFICIARY",
        "content": msg,
        "channel": "WHATSAPP",
        "timestamp": "Just now"
    })
    ai_reply = "வணக்கம்! Thiran AI மூலம் உங்கள் தகவல் பெறப்பட்டது. மொபைல் செயலியில் சோலார் பயிற்சியை நீங்கள் காணலாம்."
    conv["messages"].append({
        "id": str(uuid.uuid4()),
        "senderRole": "AI",
        "content": ai_reply,
        "channel": "WHATSAPP",
        "timestamp": "Just now"
    })
    save_db(db)
    return {"success": True, "status": "DELIVERED", "response": ai_reply, "conversationId": conv["id"]}

@app.post("/api/webhooks/ivr/call-start")
def ivr_call_start(payload: Dict[str, Any]):
    call_sid = payload.get("CallSid", str(uuid.uuid4()))
    return {
        "success": True,
        "callSid": call_sid,
        "responseType": "PLAY_AND_GATHER",
        "ttsMessage": "Welcome to Thiran AI. தமிழுக்கு 1ஐ அழுத்தவும். For English, press 2."
    }

@app.post("/api/webhooks/ivr/input")
def ivr_input(payload: Dict[str, Any]):
    speech = payload.get("SpeechResult", "Electrical experience")
    return {
        "success": True,
        "responseType": "HANGUP",
        "ttsMessage": f"நன்றி! உங்கள் விவரங்கள் பதிவு செய்யப்பட்டன: {speech}. தகுதிப் பாதை SMS மூலம் அனுப்பப்படும்."
    }

@app.post("/api/webhooks/ivr/call-status")
def ivr_call_status(payload: Dict[str, Any]):
    return {"success": True, "status": "RECORDED"}

# Admin Endpoints
@app.get("/api/admin/analytics")
def admin_analytics():
    db = load_db()
    profiles = db.get("beneficiaryProfiles", [])
    mentors = db.get("mentors", [])
    courses = db.get("courses", [])
    opps = db.get("opportunities", [])
    pathways = db.get("pathways", [])
    tickets = db.get("supportTickets", [])
    return {
        "success": True,
        "data": {
            "kpis": {
                "activeBeneficiaries": len(profiles),
                "activeMentors": len(mentors),
                "trainingCoursesCount": len(courses),
                "openOpportunities": len(opps),
                "completedPathways": len([p for p in pathways if p.get("currentStage") == "APPLY"]) or 4,
                "pendingFollowUps": len([t for t in tickets if t.get("status") == "OPEN"]) or 1
            },
            "funnel": {
                "onboarded": len(profiles),
                "gapIdentified": 10,
                "inTraining": 8,
                "inAssessment": 2,
                "certified": 3,
                "appliedToJob": 4
            },
            "gapDistribution": [
                {"skill": "Solar PV Inverter Wiring", "count": 9},
                {"skill": "Commercial Pattern Cutting", "count": 6},
                {"skill": "Drip Irrigation Setup", "count": 5},
                {"skill": "Basic Patient Vitals Monitoring", "count": 4},
                {"skill": "Agricultural Drone Spray Calibration", "count": 3}
            ]
        }
    }

@app.get("/api/admin/tickets")
def admin_tickets():
    db = load_db()
    return {"success": True, "data": db.get("supportTickets", [])}

@app.patch("/api/admin/tickets/{id}")
def admin_update_ticket(id: str, payload: Dict[str, Any]):
    db = load_db()
    tickets = db.get("supportTickets", [])
    t = next((item for item in tickets if item.get("id") == id), None)
    if t:
        t["status"] = payload.get("status", "RESOLVED")
        t["notes"] = payload.get("notes", "")
        save_db(db)
        return {"success": True, "data": t}
    raise HTTPException(status_code=404, detail="Ticket not found")

if __name__ == "__main__":
    import uvicorn
    port = int(os.environ.get("PORT", 8000))
    uvicorn.run("backend.main:app", host="0.0.0.0", port=port, reload=True)
