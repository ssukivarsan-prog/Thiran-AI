import { Router, Request, Response } from 'express';
import { v4 as uuidv4 } from 'uuid';
import { config } from '../../config/env';
import { db } from '../../database/db';

export const whatsappRouter = Router();

// Track idempotency keys
const processedWebhookIds = new Set<string>();

// Meta Webhook Verification
whatsappRouter.get('/', (req: Request, res: Response) => {
  const mode = req.query['hub.mode'];
  const token = req.query['hub.verify_token'];
  const challenge = req.query['hub.challenge'];

  if (mode === 'subscribe' && token === config.whatsappWebhookVerifyToken) {
    console.log('[WhatsApp Webhook] Verification successful');
    return res.status(200).send(challenge);
  } else {
    return res.sendStatus(403);
  }
});

// Inbound WhatsApp Event Handler
whatsappRouter.post('/', async (req: Request, res: Response) => {
  const body = req.body;

  // Validate payload format
  if (!body || !body.entry) {
    // Simulator payload support
    const simMessage = body.message || body.text;
    const fromPhone = body.from || '+919840112301';
    const messageId = body.id || uuidv4();

    if (processedWebhookIds.has(messageId)) {
      return res.status(200).json({ status: 'ALREADY_PROCESSED' });
    }
    processedWebhookIds.add(messageId);

    // Map to beneficiary
    let user = db.findOne('users', u => u.phone === fromPhone);
    let ben = user ? db.findOne('beneficiaryProfiles', p => p.userId === user.id) : null;

    if (!ben) {
      user = db.insert('users', {
        phone: fromPhone,
        fullName: 'WhatsApp Beneficiary',
        role: 'BENEFICIARY',
        status: 'ACTIVE',
        preferredLanguage: 'ta',
        isConsented: true
      });
      ben = db.insert('beneficiaryProfiles', {
        userId: user.id,
        fullName: 'WhatsApp Beneficiary',
        phone: fromPhone,
        preferredLanguage: 'ta',
        educationLevel: 'Not specified',
        currentWork: 'Unknown',
        previousExperience: 'None',
        location: 'Tamil Nadu',
        mobilityConstraints: 'Flexible',
        preferredWorkType: 'ANY',
        internetAccess: true,
        completionRate: 30
      });
    }

    // Find or create WhatsApp conversation
    let conv = db.findOne('conversations', c => c.beneficiaryId === ben.id && c.channel === 'WHATSAPP');
    if (!conv) {
      conv = db.insert('conversations', {
        beneficiaryId: ben.id,
        channel: 'WHATSAPP',
        language: 'ta',
        status: 'ACTIVE',
        messages: []
      });
    }

    // Append inbound message
    conv.messages.push({
      id: messageId,
      senderId: user.id,
      senderRole: 'BENEFICIARY',
      content: simMessage || 'WhatsApp message received',
      channel: 'WHATSAPP',
      timestamp: new Date().toISOString()
    });

    // Auto-respond via AI Gateway
    const aiResponseText = `வணக்கம்! Jeevika AI மூலம் உங்கள் தகவல் பெறப்பட்டது. நீங்கள் சோலார் மற்றும் தொழிற்கல்வி பயிற்சிகளை மொபைல் செயலியில் காணலாம்.`;
    conv.messages.push({
      id: uuidv4(),
      senderId: 'ai-gateway',
      senderRole: 'AI',
      content: aiResponseText,
      channel: 'WHATSAPP',
      timestamp: new Date(Date.now() + 600).toISOString()
    });

    db.update('conversations', conv.id, { messages: conv.messages });

    return res.status(200).json({
      success: true,
      status: 'DELIVERED',
      response: aiResponseText,
      conversationId: conv.id
    });
  }

  // Handle Meta Graph API payload
  try {
    const entry = body.entry[0];
    const changes = entry?.changes[0];
    const value = changes?.value;
    const message = value?.messages?.[0];

    if (message) {
      const msgId = message.id;
      if (processedWebhookIds.has(msgId)) {
        return res.status(200).json({ status: 'ALREADY_PROCESSED' });
      }
      processedWebhookIds.add(msgId);

      const senderPhone = '+' + message.from;
      const text = message.text?.body || (message.audio ? '[Voice Note]' : '[Unsupported Media]');

      let user = db.findOne('users', u => u.phone === senderPhone);
      let ben = user ? db.findOne('beneficiaryProfiles', p => p.userId === user.id) : null;

      if (!ben) {
        user = db.insert('users', {
          phone: senderPhone,
          fullName: 'WhatsApp User',
          role: 'BENEFICIARY',
          status: 'ACTIVE',
          preferredLanguage: 'ta',
          isConsented: true
        });
        ben = db.insert('beneficiaryProfiles', {
          userId: user.id,
          fullName: 'WhatsApp User',
          phone: senderPhone,
          preferredLanguage: 'ta',
          educationLevel: '10th Standard',
          currentWork: 'Seeking opportunity',
          previousExperience: 'None',
          location: 'Tamil Nadu',
          mobilityConstraints: 'Flexible',
          preferredWorkType: 'ANY',
          internetAccess: true,
          completionRate: 40
        });
      }

      let conv = db.findOne('conversations', c => c.beneficiaryId === ben.id && c.channel === 'WHATSAPP');
      if (!conv) {
        conv = db.insert('conversations', {
          beneficiaryId: ben.id,
          channel: 'WHATSAPP',
          language: 'ta',
          status: 'ACTIVE',
          messages: []
        });
      }

      conv.messages.push({
        id: msgId,
        senderId: user.id,
        senderRole: 'BENEFICIARY',
        content: text,
        channel: 'WHATSAPP',
        timestamp: new Date(parseInt(message.timestamp, 10) * 1000).toISOString()
      });

      db.update('conversations', conv.id, { messages: conv.messages });
    }

    return res.status(200).json({ status: 'EVENT_RECEIVED' });
  } catch (err) {
    console.error('Error processing WhatsApp webhook:', err);
    return res.status(200).json({ status: 'ACKNOWLEDGED' });
  }
});
