import { Router, Response } from 'express';
import { db } from '../../database/db';
import { authenticateToken, AuthenticatedRequest } from '../../middleware/auth.middleware';

export const trainingRouter = Router();

trainingRouter.get('/', (req: AuthenticatedRequest, res: Response) => {
  const { category, deliveryMode } = req.query;
  let courses = db.getTable('courses');

  if (category && typeof category === 'string') {
    courses = courses.filter(c => c.category.toLowerCase() === category.toLowerCase());
  }
  if (deliveryMode && typeof deliveryMode === 'string') {
    courses = courses.filter(c => c.deliveryMode === deliveryMode);
  }

  return res.json({
    success: true,
    data: courses,
    meta: { total: courses.length }
  });
});

trainingRouter.get('/:id', (req: AuthenticatedRequest, res: Response) => {
  const course = db.findById('courses', req.params.id);
  if (!course) {
    return res.status(404).json({ success: false, error: { code: 'NOT_FOUND', message: 'Course not found' } });
  }
  return res.json({ success: true, data: course });
});

trainingRouter.post('/:id/apply', authenticateToken, (req: AuthenticatedRequest, res: Response) => {
  const course = db.findById('courses', req.params.id);
  if (!course) {
    return res.status(404).json({ success: false, error: { code: 'NOT_FOUND', message: 'Course not found' } });
  }

  // Update enrolled count
  db.update('courses', course.id, { enrolledCount: course.enrolledCount + 1 });
  db.recordAudit(req.user?.id || 'ben', 'BENEFICIARY', 'ENROLL_COURSE', 'courses', `Enrolled in ${course.title}`);

  return res.json({
    success: true,
    data: {
      message: 'Enrollment referral successfully generated',
      courseId: course.id,
      courseTitle: course.title,
      certificationName: course.certificationName,
      status: 'ENROLLED'
    }
  });
});
