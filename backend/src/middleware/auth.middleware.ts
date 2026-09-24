import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { config } from '../config/env';
import { db, User } from '../database/db';

export interface AuthenticatedRequest extends Request {
  user?: User;
  requestId?: string;
}

export function authenticateToken(req: AuthenticatedRequest, res: Response, next: NextFunction) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({
      success: false,
      error: { code: 'UNAUTHORIZED', message: 'Authentication token required' }
    });
  }

  try {
    const decoded = jwt.verify(token, config.jwtSecret) as { userId: string; role: string };
    const user = db.findById('users', decoded.userId);
    if (!user) {
      return res.status(401).json({
        success: false,
        error: { code: 'INVALID_TOKEN', message: 'User not found or revoked' }
      });
    }
    req.user = user;
    next();
  } catch (err) {
    return res.status(403).json({
      success: false,
      error: { code: 'FORBIDDEN', message: 'Invalid or expired token' }
    });
  }
}

export function requireRole(...allowedRoles: Array<User['role']>) {
  return (req: AuthenticatedRequest, res: Response, next: NextFunction) => {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        error: { code: 'UNAUTHORIZED', message: 'Authentication required' }
      });
    }

    if (!allowedRoles.includes(req.user.role)) {
      return res.status(403).json({
        success: false,
        error: {
          code: 'FORBIDDEN_ROLE',
          message: `Role ${req.user.role} does not have permission to access this resource`
        }
      });
    }

    next();
  };
}
