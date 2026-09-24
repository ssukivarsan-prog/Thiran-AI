import { Router, Response } from 'express';
import { db } from '../../database/db';
import { authenticateToken, AuthenticatedRequest } from '../../middleware/auth.middleware';

export const mentorsRouter = Router();

mentorsRouter.get('/', (req: AuthenticatedRequest, res: Response) => {
  const { language, serviceArea } = req.query;
  let mentors = db.getTable('mentors');

  if (language && typeof language === 'string') {
    mentors = mentors.filter(m => m.languages.some(l => l.toLowerCase() === language.toLowerCase()));
  }
  if (serviceArea && typeof serviceArea === 'string') {
    mentors = mentors.filter(m => m.serviceArea.toLowerCase().includes(serviceArea.toLowerCase()));
  }

  return res.json({
    success: true,
    data: mentors,
    meta: { total: mentors.length }
  });
});

mentorsRouter.get('/:id', (req: AuthenticatedRequest, res: Response) => {
  const mentor = db.findById('mentors', req.params.id);
  if (!mentor) {
    return res.status(404).json({ success: false, error: { code: 'NOT_FOUND', message: 'Mentor not found' } });
  }
  return res.json({ success: true, data: mentor });
});

mentorsRouter.post('/request', authenticateToken, (req: AuthenticatedRequest, res: Response) => {
  const { mentorId, topic, message, scheduledDate, beneficiaryId } = req.body;
  const benId = beneficiaryId || (req.user ? db.findOne('beneficiaryProfiles', p => p.userId === req.user?.id)?.id : 'ben-1');
  const benProfile = benId ? db.findById('beneficiaryProfiles', benId) : null;

  const mentor = db.findById('mentors', mentorId);
  if (!mentor) {
    return res.status(404).json({ success: false, error: { code: 'NOT_FOUND', message: 'Mentor not found' } });
  }

  const newRequest = db.insert('mentorRequests', {
    beneficiaryId: benId,
    mentorId,
    beneficiaryName: benProfile ? benProfile.fullName : (req.user?.fullName || 'Beneficiary'),
    topic: topic || 'Pathway & Skills Mentorship',
    message: message || 'Seeking guidance on practical industry requirements',
    status: 'PENDING',
    scheduledDate: scheduledDate || new Date(Date.now() + 86400000 * 2).toISOString()
  });

  db.recordAudit(req.user?.id || 'ben', 'BENEFICIARY', 'CREATE_MENTOR_REQUEST', 'mentorRequests', `Requested mentor ${mentor.name}`);

  return res.json({
    success: true,
    data: newRequest
  });
});

mentorsRouter.get('/requests/my', authenticateToken, (req: AuthenticatedRequest, res: Response) => {
  const user = req.user;
  if (!user) return res.status(401).json({ success: false, error: { code: 'UNAUTHORIZED', message: 'Login required' } });

  let requests = [];
  if (user.role === 'MENTOR') {
    const mentorRecord = db.findOne('mentors', m => m.userId === user.id);
    requests = mentorRecord ? db.find('mentorRequests', r => r.mentorId === mentorRecord.id) : [];
  } else {
    const benRecord = db.findOne('beneficiaryProfiles', p => p.userId === user.id);
    requests = benRecord ? db.find('mentorRequests', r => r.beneficiaryId === benRecord.id) : [];
  }

  return res.json({ success: true, data: requests });
});

mentorsRouter.patch('/requests/:id', authenticateToken, (req: AuthenticatedRequest, res: Response) => {
  const { status } = req.body;
  const updated = db.update('mentorRequests', req.params.id, { status });
  if (!updated) {
    return res.status(404).json({ success: false, error: { code: 'NOT_FOUND', message: 'Request not found' } });
  }
  return res.json({ success: true, data: updated });
});
