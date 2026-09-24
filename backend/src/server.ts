import express from 'express';
import cors from 'cors';
import { config } from './config/env';
import { requestIdMiddleware, errorHandler } from './middleware/error.middleware';
import { authRouter } from './modules/auth/auth.controller';
import { beneficiariesRouter } from './modules/beneficiaries/beneficiaries.controller';
import { skillsRouter } from './modules/skills/skills.controller';
import { opportunitiesRouter } from './modules/opportunities/opportunities.controller';
import { pathwaysRouter } from './modules/pathways/pathways.controller';
import { trainingRouter } from './modules/training/training.controller';
import { mentorsRouter } from './modules/mentors/mentors.controller';
import { conversationsRouter } from './modules/conversations/conversations.controller';
import { whatsappRouter } from './modules/webhooks/whatsapp.controller';
import { ivrRouter } from './modules/webhooks/ivr.controller';
import { adminRouter } from './modules/admin/admin.controller';
import { db } from './database/db';

const app = express();

// Security & Parsing
app.use(cors({ origin: config.corsOrigin, credentials: true }));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(requestIdMiddleware);

// Request Logger
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.originalUrl} -> ${res.statusCode} (${duration}ms) [${(req as any).requestId}]`);
  });
  next();
});

// Health Checks
app.get('/health', (req, res) => {
  res.json({
    status: 'HEALTHY',
    service: 'Thiran AI API Gateway',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

app.get('/ready', (req, res) => {
  res.json({
    status: 'READY',
    database: 'CONNECTED',
    records: {
      users: db.getTable('users').length,
      beneficiaries: db.getTable('beneficiaryProfiles').length,
      mentors: db.getTable('mentors').length,
      opportunities: db.getTable('opportunities').length,
      courses: db.getTable('courses').length
    }
  });
});

// Mount Routes
app.use('/api/auth', authRouter);
app.use('/api/beneficiaries', beneficiariesRouter);
app.use('/api/skills', skillsRouter);
app.use('/api/opportunities', opportunitiesRouter);
app.use('/api/pathways', pathwaysRouter);
app.use('/api/training', trainingRouter);
app.use('/api/mentors', mentorsRouter);
app.use('/api/conversations', conversationsRouter);
app.use('/api/webhooks/whatsapp', whatsappRouter);
app.use('/api/webhooks/ivr', ivrRouter);
app.use('/api/admin', adminRouter);

// 404 Handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    error: {
      code: 'ROUTE_NOT_FOUND',
      message: `The endpoint ${req.method} ${req.originalUrl} was not found`
    }
  });
});

// Central Error Handler
app.use(errorHandler);

// Start Server
if (require.main === module) {
  app.listen(config.port, () => {
    console.log(`====================================================`);
    console.log(`🚀 Thiran AI Backend Service running on port ${config.port}`);
    console.log(`📡 Health: http://localhost:${config.port}/health`);
    console.log(`📊 Readiness: http://localhost:${config.port}/ready`);
    console.log(`🌍 Environment: ${config.nodeEnv}`);
    console.log(`🤖 AI Engine: Thiran Neural Intelligence Core`);
    console.log(`====================================================`);
  });
}

export default app;
