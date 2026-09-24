import { Router, Response } from 'express';
import { v4 as uuidv4 } from 'uuid';
import { db } from '../../database/db';
import { authenticateToken, AuthenticatedRequest } from '../../middleware/auth.middleware';

export const conversationsRouter = Router();

// Get conversations (Support Worker / Admin or for current user)
conversationsRouter.get('/', authenticateToken, (req: AuthenticatedRequest, res: Response) => {
  const user = req.user;
  let conversations = db.getTable('conversations');

  if (user && user.role === 'BENEFICIARY') {
    const ben = db.findOne('beneficiaryProfiles', p => p.userId === user.id);
    conversations = ben ? conversations.filter(c => c.beneficiaryId === ben.id) : [];
  }

  return res.json({
    success: true,
    data: conversations,
    meta: { total: conversations.length }
  });
});

// Get single conversation with full message thread
conversationsRouter.get('/:id', authenticateToken, (req: AuthenticatedRequest, res: Response) => {
  const conv = db.findById('conversations', req.params.id);
  if (!conv) {
    return res.status(404).json({ success: false, error: { code: 'NOT_FOUND', message: 'Conversation not found' } });
  }
  return res.json({ success: true, data: conv });
});

// Post a message to conversation (Chat, Voice note, or Agent response)
conversationsRouter.post('/:id/messages', authenticateToken, (req: AuthenticatedRequest, res: Response) => {
  const convId = req.params.id;
  const { content, channel = 'MOBILE_APP', audioUrl, transcript } = req.body;
  const user = req.user;

  let conv = db.findById('conversations', convId);
  if (!conv) {
    // If not found, create new conversation for user
    const ben = user ? db.findOne('beneficiaryProfiles', p => p.userId === user.id) : null;
    conv = db.insert('conversations', {
      beneficiaryId: ben ? ben.id : 'ben-1',
      channel,
      language: user?.preferredLanguage || 'ta',
      status: 'ACTIVE',
      messages: []
    });
  }

  const userMessage = {
    id: uuidv4(),
    senderId: user?.id || 'anon',
    senderRole: (user?.role === 'ADMINISTRATOR' || user?.role === 'SUPPORT_WORKER') ? 'SUPPORT_WORKER' : 'BENEFICIARY',
    content,
    channel,
    timestamp: new Date().toISOString(),
    audioUrl,
    transcript
  };

  conv.messages.push(userMessage);

  // If message from beneficiary, generate automated contextual AI assistance
  if (userMessage.senderRole === 'BENEFICIARY') {
    const lower = content.toLowerCase();
    let replyText = 'உங்கள் செய்தியைப் பெற்றோம். உங்கள் திறன் விவரங்கள் புதுப்பிக்கப்பட்டன.';
    if (conv.language === 'en') {
      replyText = 'Received your inquiry. Based on your profile, we recommend checking verified Solar & Agri-Tech courses.';
    } else if (conv.language === 'hi') {
      replyText = 'आपका संदेश प्राप्त हुआ। आपकी प्रोफाइल के आधार पर हमने नए अवसर जोड़े हैं।';
    }

    if (lower.includes('solar') || lower.includes('சோலார்')) {
      replyText = 'சோலார் துறையில் 12 புதிய வாய்ப்புகள் மற்றும் 1 அரசாங்க அங்கீகார பயிற்சி உள்ளது.';
    }

    const aiMessage = {
      id: uuidv4(),
      senderId: 'ai-gateway',
      senderRole: 'AI' as const,
      content: replyText,
      channel,
      timestamp: new Date(Date.now() + 500).toISOString()
    };
    conv.messages.push(aiMessage);
  }

  db.update('conversations', conv.id, {
    messages: conv.messages,
    updatedAt: new Date().toISOString()
  });

  return res.json({
    success: true,
    data: {
      conversation: conv,
      latestMessage: conv.messages[conv.messages.length - 1]
    }
  });
});

// Human Handoff / Escalation trigger (Page 9)
conversationsRouter.post('/:id/escalate', authenticateToken, (req: AuthenticatedRequest, res: Response) => {
  const convId = req.params.id;
  const { reason = 'Beneficiary requested human community counselor intervention' } = req.body;
  const user = req.user;

  const conv = db.findById('conversations', convId);
  if (!conv) {
    return res.status(404).json({ success: false, error: { code: 'NOT_FOUND', message: 'Conversation not found' } });
  }

  const ben = db.findById('beneficiaryProfiles', conv.beneficiaryId);
  const supportWorker = db.findOne('users', u => u.role === 'SUPPORT_WORKER');

  const ticket = db.insert('supportTickets', {
    beneficiaryId: conv.beneficiaryId,
    beneficiaryName: ben ? ben.fullName : 'Beneficiary',
    channel: conv.channel,
    subject: `Escalation: ${reason.slice(0, 50)}...`,
    reason,
    status: 'OPEN',
    assignedTo: supportWorker ? supportWorker.id : 'usr-support-1'
  });

  db.update('conversations', conv.id, {
    status: 'ESCALATED_TO_HUMAN',
    escalationReason: reason
  });

  db.recordAudit(user?.id || 'system', 'SUPPORT_WORKER', 'ESCALATE_CONVERSATION', 'supportTickets', `Ticket ${ticket.id} created for conversation ${conv.id}`);

  return res.json({
    success: true,
    data: {
      message: 'Escalated to human support worker queue',
      ticket,
      conversationId: conv.id
    }
  });
});
