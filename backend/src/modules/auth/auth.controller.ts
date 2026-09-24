import { Router, Request, Response } from 'express';
import jwt from 'jsonwebtoken';
import { config } from '../../config/env';
import { db, User } from '../../database/db';
import { authenticateToken, AuthenticatedRequest } from '../../middleware/auth.middleware';

export const authRouter = Router();

// Store temporary OTPs
const otpStore = new Map<string, { code: string; expiresAt: number }>();

authRouter.post('/send-otp', (req: Request, res: Response) => {
  const { phone } = req.body;
  if (!phone) {
    return res.status(400).json({ success: false, error: { code: 'PHONE_REQUIRED', message: 'Phone number is required' } });
  }

  // Generate OTP (fixed 123456 in dev/synthetic mode)
  const code = '123456';
  otpStore.set(phone, { code, expiresAt: Date.now() + 5 * 60 * 1000 });

  return res.json({
    success: true,
    data: {
      message: 'OTP sent successfully',
      phone,
      debugCode: config.nodeEnv === 'development' ? code : undefined
    }
  });
});

authRouter.post('/verify-otp', (req: Request, res: Response) => {
  const { phone, code, role = 'BENEFICIARY', fullName = 'Beneficiary User', language = 'ta' } = req.body;

  if (!phone || !code) {
    return res.status(400).json({ success: false, error: { code: 'INVALID_INPUT', message: 'Phone and code are required' } });
  }

  const record = otpStore.get(phone);
  if (!record || record.code !== code || Date.now() > record.expiresAt) {
    // Allow default test passcode '123456' for ease of testing
    if (code !== '123456') {
      return res.status(400).json({ success: false, error: { code: 'INVALID_OTP', message: 'Invalid or expired OTP' } });
    }
  }

  // Find or create user
  let user = db.findOne('users', u => u.phone === phone);
  if (!user) {
    user = db.insert('users', {
      phone,
      fullName,
      role,
      status: 'ACTIVE',
      preferredLanguage: language,
      isConsented: false
    });

    if (role === 'BENEFICIARY') {
      db.insert('beneficiaryProfiles', {
        userId: user.id,
        fullName,
        phone,
        preferredLanguage: language,
        educationLevel: 'Not specified',
        currentWork: 'Seeking opportunity',
        previousExperience: 'None',
        location: 'Tamil Nadu',
        mobilityConstraints: 'Flexible',
        preferredWorkType: 'ANY',
        internetAccess: true,
        completionRate: 20
      });
    }
  }

  const token = jwt.sign(
    { userId: user.id, role: user.role },
    config.jwtSecret,
    { expiresIn: 60 * 60 * 24 * 7 }
  );

  db.recordAudit(user.id, user.role, 'LOGIN_OTP', 'users', `User ${user.phone} logged in via OTP`);

  return res.json({
    success: true,
    data: {
      token,
      user
    }
  });
});

authRouter.post('/login', (req: Request, res: Response) => {
  const { role = 'BENEFICIARY', phone, email } = req.body;

  let user: User | undefined;
  if (email) {
    user = db.findOne('users', u => u.email === email);
  } else if (phone) {
    user = db.findOne('users', u => u.phone === phone);
  } else {
    // Pick the first active user for this role
    user = db.findOne('users', u => u.role === role);
  }

  if (!user) {
    return res.status(404).json({ success: false, error: { code: 'USER_NOT_FOUND', message: 'User not found' } });
  }

  const token = jwt.sign(
    { userId: user.id, role: user.role },
    config.jwtSecret,
    { expiresIn: 60 * 60 * 24 * 7 }
  );

  db.recordAudit(user.id, user.role, 'DIRECT_LOGIN', 'users', `Direct login for role ${user.role}`);

  return res.json({
    success: true,
    data: {
      token,
      user
    }
  });
});

authRouter.get('/me', authenticateToken, (req: AuthenticatedRequest, res: Response) => {
  const profile = db.findOne('beneficiaryProfiles', p => p.userId === req.user?.id);
  return res.json({
    success: true,
    data: {
      user: req.user,
      profile
    }
  });
});
