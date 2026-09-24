import { Router, Response } from 'express';
import { db } from '../../database/db';
import { authenticateToken, AuthenticatedRequest } from '../../middleware/auth.middleware';

export const pathwaysRouter = Router();

pathwaysRouter.get('/:beneficiaryId', authenticateToken, (req: AuthenticatedRequest, res: Response) => {
  const benId = req.params.beneficiaryId;
  const pathway = db.findOne('pathways', p => p.beneficiaryId === benId);

  if (!pathway) {
    // Generate a default Solar PV pathway if none exists
    const defaultPathway = db.insert('pathways', {
      beneficiaryId: benId,
      targetRole: 'Solar PV Installation Technician',
      currentStage: 'GAP',
      alignmentScore: 78,
      satisfiedRequirements: ['10th Standard or ITI Electrician', 'Local district mobility confirmed'],
      missingRequirements: ['Certified Solar Rooftop Installer (Level 4)', 'Safety Earthing Field Assessment'],
      nextAction: 'Enroll in 6-week subsidized hybrid course with NSDC partner',
      estimatedWeeks: 6
    });

    return res.json({ success: true, data: defaultPathway });
  }

  return res.json({ success: true, data: pathway });
});

// Update pathway stage
pathwaysRouter.patch('/:id/stage', authenticateToken, (req: AuthenticatedRequest, res: Response) => {
  const { stage } = req.body;
  const updated = db.update('pathways', req.params.id, { currentStage: stage });
  if (!updated) {
    return res.status(404).json({ success: false, error: { code: 'NOT_FOUND', message: 'Pathway not found' } });
  }
  return res.json({ success: true, data: updated });
});

// What-If Simulation endpoint (Page 8)
pathwaysRouter.post('/simulate', authenticateToken, (req: AuthenticatedRequest, res: Response) => {
  const { beneficiaryId, simulatedSkill, simulatedCourseId, simulatedLocation, simulatedWorkType } = req.body;

  let baseScore = 72;
  const satisfied = ['Baseline Education Satisfied', 'Regional Residency Verified'];
  const gaps = ['Practical Competency Assessment'];

  if (simulatedSkill) {
    baseScore += 12;
    satisfied.push(`Added Simulated Skill: ${simulatedSkill}`);
  }

  if (simulatedCourseId) {
    baseScore += 15;
    satisfied.push('Completed Accredited Vocational Certification');
  } else {
    gaps.push('Accredited Certification Required');
  }

  if (simulatedWorkType === 'SELF_EMPLOYMENT') {
    satisfied.push('SHG / Micro-enterprise credit linkage eligible');
  }

  const finalScore = Math.min(98, baseScore);
  const simulatedStage = finalScore >= 90 ? 'APPLY' : (finalScore >= 80 ? 'ASSESS' : 'TRAIN');

  return res.json({
    success: true,
    data: {
      simulatedStage,
      projectedAlignmentScore: finalScore,
      formalRequirementsSatisfied: satisfied,
      remainingGaps: gaps,
      estimatedWeeksToJobReady: simulatedStage === 'APPLY' ? 0 : (simulatedStage === 'ASSESS' ? 2 : 5),
      simulationRationale: 'Simulated preview recalculates alignment deterministically without modifying verified records.'
    }
  });
});
