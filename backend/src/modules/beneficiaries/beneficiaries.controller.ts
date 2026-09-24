import { Router, Response } from 'express';
import { db } from '../../database/db';
import { authenticateToken, requireRole, AuthenticatedRequest } from '../../middleware/auth.middleware';
import { aiService } from '../ai/gemini.service';

export const beneficiariesRouter = Router();

// List all beneficiaries (Operations & Support staff)
beneficiariesRouter.get('/', authenticateToken, requireRole('ADMINISTRATOR', 'SUPPORT_WORKER', 'TRAINING_PROVIDER'), (req: AuthenticatedRequest, res: Response) => {
  const { search, location, minCompletion } = req.query;
  let profiles = db.getTable('beneficiaryProfiles');

  if (search && typeof search === 'string') {
    const q = search.toLowerCase();
    profiles = profiles.filter(p => p.fullName.toLowerCase().includes(q) || p.phone.includes(q) || p.currentWork.toLowerCase().includes(q));
  }

  if (location && typeof location === 'string') {
    profiles = profiles.filter(p => p.location.toLowerCase().includes(location.toLowerCase()));
  }

  if (minCompletion) {
    const min = parseInt(minCompletion as string, 10);
    profiles = profiles.filter(p => p.completionRate >= min);
  }

  return res.json({
    success: true,
    data: profiles,
    meta: { total: profiles.length }
  });
});

// Get single beneficiary detailed view
beneficiariesRouter.get('/:id', authenticateToken, (req: AuthenticatedRequest, res: Response) => {
  const id = req.params.id;
  const profile = db.findById('beneficiaryProfiles', id) || db.findOne('beneficiaryProfiles', p => p.userId === id);

  if (!profile) {
    return res.status(404).json({ success: false, error: { code: 'NOT_FOUND', message: 'Beneficiary not found' } });
  }

  const user = db.findById('users', profile.userId);
  const skills = db.find('userSkills', s => s.userId === profile.userId);
  const pathway = db.findOne('pathways', p => p.beneficiaryId === profile.id);
  const conversations = db.find('conversations', c => c.beneficiaryId === profile.id);

  return res.json({
    success: true,
    data: {
      profile,
      user,
      skills,
      pathway,
      conversations
    }
  });
});

// Update beneficiary profile
beneficiariesRouter.patch('/:id', authenticateToken, (req: AuthenticatedRequest, res: Response) => {
  const id = req.params.id;
  const updates = req.body;
  const updated = db.update('beneficiaryProfiles', id, updates);

  if (!updated) {
    return res.status(404).json({ success: false, error: { code: 'NOT_FOUND', message: 'Beneficiary profile not found' } });
  }

  db.recordAudit(req.user?.id || 'system', req.user?.role || 'BENEFICIARY', 'UPDATE_PROFILE', 'beneficiaryProfiles', `Updated profile ${id}`);

  return res.json({ success: true, data: updated });
});

// Record consent
beneficiariesRouter.post('/:id/consent', authenticateToken, (req: AuthenticatedRequest, res: Response) => {
  const id = req.params.id;
  const { consentChannels = ['IN_APP', 'WHATSAPP'], aiProcessingConsent = true } = req.body;

  const profile = db.findById('beneficiaryProfiles', id);
  if (!profile) {
    return res.status(404).json({ success: false, error: { code: 'NOT_FOUND', message: 'Beneficiary not found' } });
  }

  db.update('users', profile.userId, {
    isConsented: aiProcessingConsent,
    consentDate: new Date().toISOString()
  });

  db.recordAudit(profile.userId, 'BENEFICIARY', 'CONSENT_GRANTED', 'consents', `Consent granted for channels: ${consentChannels.join(', ')}`);

  return res.json({
    success: true,
    data: {
      message: 'Consent preferences recorded successfully',
      consentDate: new Date().toISOString(),
      channels: consentChannels
    }
  });
});

// Adaptive Voice Interview next question endpoint
beneficiariesRouter.post('/voice-interview/next', async (req: AuthenticatedRequest, res: Response) => {
  const { language = 'ta', history = [] } = req.body;
  const nextQ = await aiService.getNextInterviewQuestion(language, history);
  return res.json({ success: true, data: nextQ });
});

// Complete interview and extract structured profile
beneficiariesRouter.post('/voice-interview/complete', authenticateToken, async (req: AuthenticatedRequest, res: Response) => {
  const { history = [], language = 'ta', beneficiaryId } = req.body;
  const targetBenId = beneficiaryId || (req.user ? db.findOne('beneficiaryProfiles', p => p.userId === req.user?.id)?.id : null);

  const extracted = await aiService.extractProfileFromTranscript(history, language);

  let updatedProfile: any = null;
  if (targetBenId) {
    updatedProfile = db.update('beneficiaryProfiles', targetBenId, {
      educationLevel: extracted.educationLevel,
      currentWork: extracted.currentWork,
      previousExperience: extracted.previousExperience,
      mobilityConstraints: extracted.mobilityConstraints,
      completionRate: 90
    });

    // Add extracted skills
    extracted.extractedSkills.forEach(es => {
      let skillObj = db.findOne('skills', s => s.name === es.name);
      if (!skillObj) {
        skillObj = db.insert('skills', {
          name: es.name,
          category: es.category,
          description: `Skill generated via voice onboarding: ${es.name}`
        });
      }

      const existingUserSkill = db.findOne('userSkills', us => us.userId === updatedProfile.userId && us.skillName === es.name);
      if (!existingUserSkill) {
        db.insert('userSkills', {
          userId: updatedProfile.userId,
          skillId: skillObj.id,
          skillName: es.name,
          proficiency: es.proficiency,
          verificationType: es.verificationType,
          evidenceDescription: es.evidence
        });
      }
    });

    // Automatically create or update pathway
    const existingPathway = db.findOne('pathways', p => p.beneficiaryId === targetBenId);
    if (!existingPathway) {
      db.insert('pathways', {
        beneficiaryId: targetBenId,
        targetRole: extracted.aspirations.includes('Solar') ? 'Solar PV Installation Technician' : 'Apparel Finishing & Quality Inspector',
        currentStage: 'GAP',
        alignmentScore: Math.round(extracted.confidenceScore * 100) - 5,
        satisfiedRequirements: [extracted.educationLevel, 'Practical baseline experience declared'],
        missingRequirements: ['Level-4 Vocational Certification', 'Verified Field Assessment'],
        nextAction: 'Review recommended training modules and connect with a local mentor',
        estimatedWeeks: 4
      });
    }
  }

  return res.json({
    success: true,
    data: {
      understoodSummary: {
        education: extracted.educationLevel,
        currentWork: extracted.currentWork,
        experience: extracted.previousExperience,
        skills: extracted.extractedSkills,
        aspirations: extracted.aspirations,
        mobility: extracted.mobilityConstraints
      },
      profile: updatedProfile
    }
  });
});
