import { Router, Response } from 'express';
import { db } from '../../database/db';
import { authenticateToken, AuthenticatedRequest } from '../../middleware/auth.middleware';
import { aiService } from '../ai/gemini.service';

export const opportunitiesRouter = Router();

// Get opportunities with matching rationale if user is authenticated
opportunitiesRouter.get('/', (req: AuthenticatedRequest, res: Response) => {
  const { category, location, search, workMode } = req.query;
  let opps = db.getTable('opportunities');

  if (category && typeof category === 'string') {
    opps = opps.filter(o => o.category.toLowerCase() === category.toLowerCase());
  }

  if (location && typeof location === 'string') {
    opps = opps.filter(o => o.location.toLowerCase().includes(location.toLowerCase()));
  }

  if (workMode && typeof workMode === 'string') {
    opps = opps.filter(o => o.workMode === workMode);
  }

  if (search && typeof search === 'string') {
    const q = search.toLowerCase();
    opps = opps.filter(o => o.title.toLowerCase().includes(q) || o.organizationName.toLowerCase().includes(q));
  }

  return res.json({
    success: true,
    data: opps,
    meta: { total: opps.length }
  });
});

opportunitiesRouter.get('/:id', (req: AuthenticatedRequest, res: Response) => {
  const opp = db.findById('opportunities', req.params.id);
  if (!opp) {
    return res.status(404).json({ success: false, error: { code: 'NOT_FOUND', message: 'Opportunity not found' } });
  }

  return res.json({ success: true, data: opp });
});

// Personalized matching calculation for a beneficiary
opportunitiesRouter.post('/match', authenticateToken, (req: AuthenticatedRequest, res: Response) => {
  const { beneficiaryId } = req.body;
  const benId = beneficiaryId || (req.user ? db.findOne('beneficiaryProfiles', p => p.userId === req.user?.id)?.id : null);

  const profile = benId ? db.findById('beneficiaryProfiles', benId) : null;
  const userSkills = profile ? db.find('userSkills', s => s.userId === profile.userId).map(s => s.skillName) : [];

  const allOpps = db.getTable('opportunities').filter(o => o.status === 'OPEN' || o.status === 'CLOSING_SOON');

  const matched = allOpps.map(opp => {
    const rationale = aiService.generateMatchingRationale(userSkills, opp.requiredSkills, opp.title);
    return {
      opportunity: opp,
      alignmentScore: rationale.score,
      whyShown: rationale.whyShown,
      missingRequirements: rationale.missingItems,
      isEligibleNow: rationale.missingItems.length === 0
    };
  }).sort((a, b) => b.alignmentScore - a.alignmentScore);

  return res.json({
    success: true,
    data: matched
  });
});

// Apply to opportunity
opportunitiesRouter.post('/:id/apply', authenticateToken, (req: AuthenticatedRequest, res: Response) => {
  const opp = db.findById('opportunities', req.params.id);
  if (!opp) {
    return res.status(404).json({ success: false, error: { code: 'NOT_FOUND', message: 'Opportunity not found' } });
  }

  db.recordAudit(req.user?.id || 'anon', req.user?.role || 'BENEFICIARY', 'APPLY_OPPORTUNITY', 'opportunities', `Applied to ${opp.title} (${opp.id})`);

  return res.json({
    success: true,
    data: {
      message: 'Application submitted successfully to provider',
      opportunityId: opp.id,
      applicationDate: new Date().toISOString(),
      status: 'UNDER_REVIEW'
    }
  });
});
