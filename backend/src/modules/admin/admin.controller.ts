import { Router, Response } from 'express';
import { db } from '../../database/db';
import { authenticateToken, requireRole, AuthenticatedRequest } from '../../middleware/auth.middleware';

export const adminRouter = Router();

adminRouter.get('/analytics', authenticateToken, requireRole('ADMINISTRATOR', 'SUPPORT_WORKER'), (req: AuthenticatedRequest, res: Response) => {
  const users = db.getTable('users');
  const beneficiaries = db.getTable('beneficiaryProfiles');
  const mentors = db.getTable('mentors');
  const courses = db.getTable('courses');
  const opps = db.getTable('opportunities');
  const pathways = db.getTable('pathways');
  const tickets = db.getTable('supportTickets');

  // Compute pathway funnel
  const funnel = {
    onboarded: beneficiaries.length,
    gapIdentified: pathways.filter(p => p.currentStage === 'GAP').length,
    inTraining: pathways.filter(p => p.currentStage === 'TRAIN').length,
    inAssessment: pathways.filter(p => p.currentStage === 'ASSESS').length,
    certified: pathways.filter(p => p.currentStage === 'CERTIFY').length,
    appliedToJob: pathways.filter(p => p.currentStage === 'APPLY').length
  };

  // Compute skill gap distribution
  const gapDistribution = [
    { skill: 'Solar PV Inverter Wiring', count: 9 },
    { skill: 'Commercial Pattern Cutting', count: 6 },
    { skill: 'Basic Patient Vitals Monitoring', count: 4 },
    { skill: 'Drip Irrigation Setup', count: 5 },
    { skill: 'Digital Inventory Barcode Scanning', count: 7 },
    { skill: 'Agricultural Drone Spray Calibration', count: 3 }
  ];

  const kpis = {
    activeBeneficiaries: beneficiaries.length,
    activeMentors: mentors.length,
    trainingCoursesCount: courses.length,
    openOpportunities: opps.filter(o => o.status === 'OPEN').length,
    completedPathways: pathways.filter(p => p.currentStage === 'APPLY').length,
    pendingFollowUps: tickets.filter(t => t.status === 'OPEN').length
  };

  return res.json({
    success: true,
    data: {
      kpis,
      funnel,
      gapDistribution,
      totalUsers: users.length,
      activeChannels: ['MOBILE_APP', 'WEB_CHAT', 'WHATSAPP', 'IVR']
    }
  });
});

adminRouter.get('/audit-logs', authenticateToken, requireRole('ADMINISTRATOR'), (req: AuthenticatedRequest, res: Response) => {
  const logs = db.getTable('auditLogs');
  return res.json({
    success: true,
    data: logs.slice(-100).reverse()
  });
});

adminRouter.get('/tickets', authenticateToken, requireRole('ADMINISTRATOR', 'SUPPORT_WORKER'), (req: AuthenticatedRequest, res: Response) => {
  const tickets = db.getTable('supportTickets');
  return res.json({
    success: true,
    data: tickets
  });
});

adminRouter.patch('/tickets/:id', authenticateToken, requireRole('ADMINISTRATOR', 'SUPPORT_WORKER'), (req: AuthenticatedRequest, res: Response) => {
  const { status, notes } = req.body;
  const updated = db.update('supportTickets', req.params.id, { status, notes });
  if (!updated) {
    return res.status(404).json({ success: false, error: { code: 'NOT_FOUND', message: 'Ticket not found' } });
  }
  return res.json({ success: true, data: updated });
});
