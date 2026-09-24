import { Router, Response } from 'express';
import { db } from '../../database/db';
import { authenticateToken, AuthenticatedRequest } from '../../middleware/auth.middleware';

export const skillsRouter = Router();

skillsRouter.get('/', (req: AuthenticatedRequest, res: Response) => {
  const skills = db.getTable('skills');
  return res.json({ success: true, data: skills });
});

skillsRouter.post('/user', authenticateToken, (req: AuthenticatedRequest, res: Response) => {
  const { skillName, category, proficiency = 'BEGINNER', verificationType = 'SELF_DECLARED', evidenceDescription } = req.body;
  const user = req.user;

  if (!user) {
    return res.status(401).json({ success: false, error: { code: 'UNAUTHORIZED', message: 'User required' } });
  }

  let skill = db.findOne('skills', s => s.name.toLowerCase() === skillName.toLowerCase());
  if (!skill) {
    skill = db.insert('skills', {
      name: skillName,
      category: category || 'Vocational',
      description: `User-declared practical skill: ${skillName}`
    });
  }

  const userSkill = db.insert('userSkills', {
    userId: user.id,
    skillId: skill.id,
    skillName: skill.name,
    proficiency,
    verificationType,
    evidenceDescription
  });

  return res.json({ success: true, data: userSkill });
});
