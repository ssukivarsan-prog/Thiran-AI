import fs from 'fs';
import path from 'path';
import { v4 as uuidv4 } from 'uuid';

export interface BaseEntity {
  id: string;
  createdAt: string;
  updatedAt: string;
}

export interface User extends BaseEntity {
  phone: string;
  email?: string;
  fullName: string;
  role: 'BENEFICIARY' | 'MENTOR' | 'TRAINING_PROVIDER' | 'EMPLOYER' | 'SUPPORT_WORKER' | 'ADMINISTRATOR';
  status: 'ACTIVE' | 'PENDING_VERIFICATION' | 'SUSPENDED';
  preferredLanguage: string;
  isConsented: boolean;
  consentDate?: string;
}

export interface BeneficiaryProfile extends BaseEntity {
  userId: string;
  fullName: string;
  phone: string;
  preferredLanguage: string;
  educationLevel: string;
  currentWork: string;
  previousExperience: string;
  location: string;
  mobilityConstraints: string;
  preferredWorkType: 'WAGE_EMPLOYMENT' | 'SELF_EMPLOYMENT' | 'ANY';
  internetAccess: boolean;
  completionRate: number;
}

export interface Skill extends BaseEntity {
  name: string;
  category: string;
  description: string;
}

export interface UserSkill extends BaseEntity {
  userId: string;
  skillId: string;
  skillName: string;
  proficiency: 'BEGINNER' | 'INTERMEDIATE' | 'ADVANCED';
  verificationType: 'VERIFIED' | 'SELF_DECLARED' | 'AI_INFERRED' | 'ORGANIZATION_VERIFIED';
  evidenceDescription?: string;
}

export interface Opportunity extends BaseEntity {
  title: string;
  organizationName: string;
  category: string;
  location: string;
  workMode: 'ONSITE' | 'REMOTE' | 'HYBRID';
  compensation: string;
  vacancies: number;
  formalRequirements: string[];
  requiredSkills: string[];
  applicationDeadline: string;
  status: 'OPEN' | 'CLOSING_SOON' | 'CLOSED';
}

export interface Course extends BaseEntity {
  title: string;
  providerName: string;
  category: string;
  location: string;
  deliveryMode: 'IN_PERSON' | 'ONLINE' | 'HYBRID';
  durationWeeks: number;
  capacity: number;
  enrolledCount: number;
  prerequisites: string[];
  skillsTaught: string[];
  certificationName: string;
  status: 'OPEN_FOR_ENROLLMENT' | 'IN_PROGRESS' | 'COMPLETED';
}

export interface Pathway extends BaseEntity {
  beneficiaryId: string;
  targetRole: string;
  currentStage: 'CURRENT' | 'GAP' | 'TRAIN' | 'ASSESS' | 'CERTIFY' | 'APPLY';
  alignmentScore: number;
  satisfiedRequirements: string[];
  missingRequirements: string[];
  nextAction: string;
  estimatedWeeks: number;
}

export interface Mentor extends BaseEntity {
  userId: string;
  name: string;
  expertise: string[];
  languages: string[];
  serviceArea: string;
  yearsOfExperience: number;
  availabilityStatus: 'AVAILABLE' | 'BUSY' | 'ON_LEAVE';
  verificationStatus: 'VERIFIED' | 'PENDING';
  rating: number;
  menteesCount: number;
}

export interface MentorRequest extends BaseEntity {
  beneficiaryId: string;
  mentorId: string;
  beneficiaryName: string;
  topic: string;
  message: string;
  status: 'PENDING' | 'ACCEPTED' | 'REJECTED' | 'COMPLETED';
  scheduledDate?: string;
}

export interface ConversationMessage {
  id: string;
  senderId: string;
  senderRole: 'BENEFICIARY' | 'AI' | 'MENTOR' | 'SUPPORT_WORKER';
  content: string;
  channel: 'MOBILE_APP' | 'WEB_CHAT' | 'WHATSAPP' | 'IVR';
  timestamp: string;
  audioUrl?: string;
  transcript?: string;
}

export interface Conversation extends BaseEntity {
  beneficiaryId: string;
  channel: 'MOBILE_APP' | 'WEB_CHAT' | 'WHATSAPP' | 'IVR';
  language: string;
  status: 'ACTIVE' | 'ESCALATED_TO_HUMAN' | 'RESOLVED';
  escalationReason?: string;
  summary?: string;
  messages: ConversationMessage[];
}

export interface SupportTicket extends BaseEntity {
  beneficiaryId: string;
  beneficiaryName: string;
  channel: 'MOBILE_APP' | 'WEB_CHAT' | 'WHATSAPP' | 'IVR';
  subject: string;
  reason: string;
  status: 'OPEN' | 'ASSIGNED' | 'RESOLVED';
  assignedTo?: string;
  notes?: string;
}

export interface AuditLog extends BaseEntity {
  actorId: string;
  actorRole: string;
  action: string;
  resource: string;
  details: string;
  ipAddress?: string;
}

export interface DatabaseSchema {
  users: User[];
  beneficiaryProfiles: BeneficiaryProfile[];
  skills: Skill[];
  userSkills: UserSkill[];
  opportunities: Opportunity[];
  courses: Course[];
  pathways: Pathway[];
  mentors: Mentor[];
  mentorRequests: MentorRequest[];
  conversations: Conversation[];
  supportTickets: SupportTicket[];
  auditLogs: AuditLog[];
}

const DB_PATH = path.resolve(__dirname, '../../data/jeevika_db.json');

class JSONDatabase {
  private data: DatabaseSchema;

  constructor() {
    this.data = this.loadData();
  }

  private defaultData(): DatabaseSchema {
    return {
      users: [],
      beneficiaryProfiles: [],
      skills: [],
      userSkills: [],
      opportunities: [],
      courses: [],
      pathways: [],
      mentors: [],
      mentorRequests: [],
      conversations: [],
      supportTickets: [],
      auditLogs: []
    };
  }

  private loadData(): DatabaseSchema {
    try {
      const dir = path.dirname(DB_PATH);
      if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
      }
      if (fs.existsSync(DB_PATH)) {
        const raw = fs.readFileSync(DB_PATH, 'utf-8');
        return JSON.parse(raw);
      }
    } catch (err) {
      console.error('Error loading database, initializing fresh state:', err);
    }
    const fresh = this.defaultData();
    this.persist(fresh);
    return fresh;
  }

  public persist(customData?: DatabaseSchema): void {
    const toSave = customData || this.data;
    try {
      const dir = path.dirname(DB_PATH);
      if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
      }
      fs.writeFileSync(DB_PATH, JSON.stringify(toSave, null, 2), 'utf-8');
    } catch (err) {
      console.error('Failed to persist database to file:', err);
    }
  }

  public getTable<K extends keyof DatabaseSchema>(tableName: K): DatabaseSchema[K] {
    return this.data[tableName];
  }

  public findById<K extends keyof DatabaseSchema>(tableName: K, id: string): any | undefined {
    return (this.data[tableName] as any[]).find((item) => item.id === id);
  }

  public find<K extends keyof DatabaseSchema>(tableName: K, predicate: (item: any) => boolean): any[] {
    return (this.data[tableName] as any[]).filter(predicate);
  }

  public findOne<K extends keyof DatabaseSchema>(tableName: K, predicate: (item: any) => boolean): any | undefined {
    return (this.data[tableName] as any[]).find(predicate);
  }

  public insert<K extends keyof DatabaseSchema>(tableName: K, item: Omit<any, 'id' | 'createdAt' | 'updatedAt'>): any {
    const now = new Date().toISOString();
    const newItem = {
      ...item,
      id: uuidv4(),
      createdAt: now,
      updatedAt: now
    };
    (this.data[tableName] as any[]).push(newItem);
    this.persist();
    return newItem;
  }

  public update<K extends keyof DatabaseSchema>(tableName: K, id: string, updates: Partial<any>): any | null {
    const table = this.data[tableName] as any[];
    const index = table.findIndex((item) => item.id === id);
    if (index === -1) return null;
    const updated = {
      ...table[index],
      ...updates,
      updatedAt: new Date().toISOString()
    };
    table[index] = updated;
    this.persist();
    return updated;
  }

  public delete<K extends keyof DatabaseSchema>(tableName: K, id: string): boolean {
    const table = this.data[tableName] as any[];
    const index = table.findIndex((item) => item.id === id);
    if (index === -1) return false;
    table.splice(index, 1);
    this.persist();
    return true;
  }

  public resetTo(schema: DatabaseSchema): void {
    this.data = schema;
    this.persist();
  }

  public recordAudit(actorId: string, actorRole: string, action: string, resource: string, details: string): void {
    this.insert('auditLogs', {
      actorId,
      actorRole,
      action,
      resource,
      details
    });
  }
}

export const db = new JSONDatabase();
