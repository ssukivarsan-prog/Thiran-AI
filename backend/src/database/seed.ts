import { db, DatabaseSchema } from './db';

export function runSeed(): DatabaseSchema {
  console.log('Seeding Jeevika AI database with synthetic records...');

  const schema: DatabaseSchema = {
    users: [],
    beneficiaryProfiles: [],
    skills: [
      { id: 'sk-1', name: 'Drip Irrigation Setup', category: 'Agriculture', description: 'Installing and maintaining micro-drip water delivery networks', createdAt: new Date().toISOString(), updatedAt: new Date().toISOString() },
      { id: 'sk-2', name: 'Solar PV Inverter Wiring', category: 'Renewable Energy', description: 'Safe DC to AC inverter circuit connection and earthing', createdAt: new Date().toISOString(), updatedAt: new Date().toISOString() },
      { id: 'sk-3', name: 'Commercial Pattern Cutting', category: 'Apparel & Textiles', description: 'Precision template cutting for commercial garment production', createdAt: new Date().toISOString(), updatedAt: new Date().toISOString() },
      { id: 'sk-4', name: 'Basic Patient Vitals Monitoring', category: 'Healthcare Assistance', description: 'Accurate measurement of pulse, BP, temperature, and record keeping', createdAt: new Date().toISOString(), updatedAt: new Date().toISOString() },
      { id: 'sk-5', name: 'E-Rickshaw Battery Maintenance', category: 'Electric Mobility', description: 'Li-ion battery cell balancing and thermal terminal care', createdAt: new Date().toISOString(), updatedAt: new Date().toISOString() },
      { id: 'sk-6', name: 'Organic Vermicomposting', category: 'Agriculture', description: 'Microbial decomposition and earthworm soil amendment preparation', createdAt: new Date().toISOString(), updatedAt: new Date().toISOString() },
      { id: 'sk-7', name: 'Industrial Single Needle Stitching', category: 'Apparel & Textiles', description: 'Operating high-speed industrial lockstitch machines', createdAt: new Date().toISOString(), updatedAt: new Date().toISOString() },
      { id: 'sk-8', name: 'Digital Inventory Barcode Scanning', category: 'Retail & Warehousing', description: 'Using handheld scanners and inventory logging software', createdAt: new Date().toISOString(), updatedAt: new Date().toISOString() },
      { id: 'sk-9', name: 'Customer Grievance Resolution', category: 'Customer Care', description: 'Professional active listening, ticketing, and resolution communication', createdAt: new Date().toISOString(), updatedAt: new Date().toISOString() },
      { id: 'sk-10', name: 'Agricultural Drone Spray Calibration', category: 'Agri-Tech', description: 'Calibrating pesticide nozzles and waypoint flight planning', createdAt: new Date().toISOString(), updatedAt: new Date().toISOString() },
      { id: 'sk-11', name: 'Sanitary Plumbing Rough-in', category: 'Construction', description: 'Laying CPVC and PVC drain waste pipes', createdAt: new Date().toISOString(), updatedAt: new Date().toISOString() },
      { id: 'sk-12', name: 'Food Safety & Hygiene Protocols', category: 'Food Processing', description: 'Adherence to FSSAI packaging and temperature controls', createdAt: new Date().toISOString(), updatedAt: new Date().toISOString() }
    ],
    userSkills: [],
    opportunities: [
      {
        id: 'opp-1',
        title: 'Solar PV Installation Technician (Field)',
        organizationName: 'SunVanguard CleanTech Solutions (Synthetic)',
        category: 'Renewable Energy',
        location: 'Tiruchirappalli, Tamil Nadu',
        workMode: 'ONSITE',
        compensation: '₹18,000 - ₹24,000 / month',
        vacancies: 12,
        formalRequirements: ['10th Standard or ITI Electrician', 'Age 18-35', 'Valid two-wheeler license'],
        requiredSkills: ['Solar PV Inverter Wiring'],
        applicationDeadline: '2026-10-30',
        status: 'OPEN',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      },
      {
        id: 'opp-2',
        title: 'Community Greenhouse Drone Operator',
        organizationName: 'Gramin Krishi Automation Cooperative (Synthetic)',
        category: 'Agri-Tech',
        location: 'Coimbatore / Erode, Tamil Nadu',
        workMode: 'ONSITE',
        compensation: '₹20,000 - ₹26,000 / month',
        vacancies: 6,
        formalRequirements: ['12th Pass or Diploma', 'Basic English or regional literacy'],
        requiredSkills: ['Agricultural Drone Spray Calibration', 'Drip Irrigation Setup'],
        applicationDeadline: '2026-11-15',
        status: 'OPEN',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      },
      {
        id: 'opp-3',
        title: 'Geriatric Care & Home Health Assistant',
        organizationName: 'Ayush Seva Community Trust (Synthetic)',
        category: 'Healthcare Assistance',
        location: 'Madurai, Tamil Nadu',
        workMode: 'ONSITE',
        compensation: '₹16,000 - ₹22,000 / month',
        vacancies: 15,
        formalRequirements: ['10th Pass', 'Certified Caregiver Course completion'],
        requiredSkills: ['Basic Patient Vitals Monitoring'],
        applicationDeadline: '2026-10-25',
        status: 'OPEN',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      },
      {
        id: 'opp-4',
        title: 'Apparel Finishing & Quality Inspector',
        organizationName: 'Kaveri EcoWeave Exports (Synthetic)',
        category: 'Apparel & Textiles',
        location: 'Tiruppur, Tamil Nadu',
        workMode: 'ONSITE',
        compensation: '₹15,000 - ₹19,500 / month',
        vacancies: 25,
        formalRequirements: ['8th Pass minimum', 'Minimum 6 months industrial stitching'],
        requiredSkills: ['Commercial Pattern Cutting', 'Industrial Single Needle Stitching'],
        applicationDeadline: '2026-11-05',
        status: 'OPEN',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      },
      {
        id: 'opp-5',
        title: 'EV Fleet Terminal Battery Technician',
        organizationName: 'GreenRide Logistics Network (Synthetic)',
        category: 'Electric Mobility',
        location: 'Bengaluru / Hosur',
        workMode: 'ONSITE',
        compensation: '₹22,000 - ₹28,000 / month',
        vacancies: 8,
        formalRequirements: ['ITI Electrical or Motor Mechanic', 'Electrical Safety Certificate'],
        requiredSkills: ['E-Rickshaw Battery Maintenance'],
        applicationDeadline: '2026-11-20',
        status: 'OPEN',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      },
      {
        id: 'opp-6',
        title: 'Organic Farm Cluster Manager',
        organizationName: 'Bhoomi Samriddhi FPO (Synthetic)',
        category: 'Agriculture',
        location: 'Thanjavur, Tamil Nadu',
        workMode: 'HYBRID',
        compensation: '₹20,000 - ₹25,000 / month',
        vacancies: 4,
        formalRequirements: ['Diploma in Agriculture or 3+ years progressive farming'],
        requiredSkills: ['Organic Vermicomposting', 'Drip Irrigation Setup'],
        applicationDeadline: '2026-12-01',
        status: 'OPEN',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      },
      {
        id: 'opp-7',
        title: 'Regional Fulfillment Center Associate',
        organizationName: 'DeshKart Express Logistics (Synthetic)',
        category: 'Retail & Warehousing',
        location: 'Salem, Tamil Nadu',
        workMode: 'ONSITE',
        compensation: '₹14,500 - ₹18,000 / month',
        vacancies: 30,
        formalRequirements: ['10th Pass', 'Ability to lift 15kg'],
        requiredSkills: ['Digital Inventory Barcode Scanning'],
        applicationDeadline: '2026-10-18',
        status: 'CLOSING_SOON',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      },
      {
        id: 'opp-8',
        title: 'Micro-Enterprise Bakery Team Lead',
        organizationName: 'Shakti Gramin Self Help Alliance (Synthetic)',
        category: 'Food Processing',
        location: 'Dindigul, Tamil Nadu',
        workMode: 'ONSITE',
        compensation: '₹15,000 - ₹20,000 / month',
        vacancies: 5,
        formalRequirements: ['Basic numeracy & literacy', 'FSSAI Food Handling Certificate'],
        requiredSkills: ['Food Safety & Hygiene Protocols'],
        applicationDeadline: '2026-11-10',
        status: 'OPEN',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      },
      {
        id: 'opp-9',
        title: 'Solar Micro-Grid Maintenance Associate',
        organizationName: 'GramUrja Off-Grid Power (Synthetic)',
        category: 'Renewable Energy',
        location: 'Dharmapuri, Tamil Nadu',
        workMode: 'ONSITE',
        compensation: '₹17,000 - ₹22,000 / month',
        vacancies: 7,
        formalRequirements: ['10th Pass + Basic Electrical training'],
        requiredSkills: ['Solar PV Inverter Wiring'],
        applicationDeadline: '2026-11-12',
        status: 'OPEN',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      },
      {
        id: 'opp-10',
        title: 'Multilingual Customer Support Representative',
        organizationName: 'SarvaBhasha BPO Hub (Synthetic)',
        category: 'Customer Care',
        location: 'Chennai / Remote',
        workMode: 'REMOTE',
        compensation: '₹18,000 - ₹24,000 / month',
        vacancies: 20,
        formalRequirements: ['12th Pass', 'Fluency in Tamil + Hindi or English'],
        requiredSkills: ['Customer Grievance Resolution'],
        applicationDeadline: '2026-11-01',
        status: 'OPEN',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      },
      {
        id: 'opp-11',
        title: 'Sanitary Plumbing Assistant',
        organizationName: 'Nirman Jal Infrastructure (Synthetic)',
        category: 'Construction',
        location: 'Vellore, Tamil Nadu',
        workMode: 'ONSITE',
        compensation: '₹16,000 - ₹21,000 / month',
        vacancies: 10,
        formalRequirements: ['8th Pass', 'Physical fitness'],
        requiredSkills: ['Sanitary Plumbing Rough-in'],
        applicationDeadline: '2026-10-31',
        status: 'OPEN',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      },
      {
        id: 'opp-12',
        title: 'Millets Processing & Packaging Operator',
        organizationName: 'Shree Anna Agro Cluster (Synthetic)',
        category: 'Food Processing',
        location: 'Krishnagiri, Tamil Nadu',
        workMode: 'ONSITE',
        compensation: '₹14,000 - ₹17,500 / month',
        vacancies: 14,
        formalRequirements: ['10th Pass', 'Food hygiene orientation'],
        requiredSkills: ['Food Safety & Hygiene Protocols'],
        applicationDeadline: '2026-11-15',
        status: 'OPEN',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      },
      {
        id: 'opp-13',
        title: 'Artisan Embroidery & Boutique Stitcher',
        organizationName: 'Chola Heritage Weaves (Synthetic)',
        category: 'Apparel & Textiles',
        location: 'Kanchipuram, Tamil Nadu',
        workMode: 'ONSITE',
        compensation: '₹16,000 - ₹22,000 / month',
        vacancies: 8,
        formalRequirements: ['Traditional or informal tailoring experience'],
        requiredSkills: ['Industrial Single Needle Stitching', 'Commercial Pattern Cutting'],
        applicationDeadline: '2026-11-30',
        status: 'OPEN',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      },
      {
        id: 'opp-14',
        title: 'Cold-Chain Warehouse Supervisor',
        organizationName: 'HimGhar Agro Storage (Synthetic)',
        category: 'Retail & Warehousing',
        location: 'Namakkal, Tamil Nadu',
        workMode: 'ONSITE',
        compensation: '₹19,000 - ₹25,000 / month',
        vacancies: 5,
        formalRequirements: ['12th Pass or ITI', 'Prior warehouse exposure'],
        requiredSkills: ['Digital Inventory Barcode Scanning'],
        applicationDeadline: '2026-11-25',
        status: 'OPEN',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      },
      {
        id: 'opp-15',
        title: 'Precision Micro-Irrigation Field Technician',
        organizationName: 'JalDhara Conservation Alliance (Synthetic)',
        category: 'Agriculture',
        location: 'Karur, Tamil Nadu',
        workMode: 'ONSITE',
        compensation: '₹17,500 - ₹23,000 / month',
        vacancies: 9,
        formalRequirements: ['10th Pass', 'Field travel capability'],
        requiredSkills: ['Drip Irrigation Setup'],
        applicationDeadline: '2026-11-18',
        status: 'OPEN',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      }
    ],
    courses: [
      {
        id: 'crs-1',
        title: 'Government-Aligned Solar PV Technician Certification',
        providerName: 'National Skill Development Institute (Synthetic)',
        category: 'Renewable Energy',
        location: 'Tiruchirappalli Skill Center',
        deliveryMode: 'HYBRID',
        durationWeeks: 6,
        capacity: 30,
        enrolledCount: 22,
        prerequisites: ['10th Pass or basic electrician experience'],
        skillsTaught: ['Solar PV Inverter Wiring'],
        certificationName: 'Certified Solar Rooftop Installer (Level 4)',
        status: 'OPEN_FOR_ENROLLMENT',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      },
      {
        id: 'crs-2',
        title: 'Agricultural Drone Pilot Ground School & Calibration',
        providerName: 'Kisan Drone Academy (Synthetic)',
        category: 'Agri-Tech',
        location: 'Coimbatore Campus',
        deliveryMode: 'IN_PERSON',
        durationWeeks: 4,
        capacity: 20,
        enrolledCount: 16,
        prerequisites: ['10th Pass', 'Valid Aadhaar ID'],
        skillsTaught: ['Agricultural Drone Spray Calibration'],
        certificationName: 'DGCA-Aligned Remote Pilot Micro-Drone Certificate',
        status: 'OPEN_FOR_ENROLLMENT',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      },
      {
        id: 'crs-3',
        title: 'Professional Geriatric & Patient Care Assistant',
        providerName: 'St. Mary Community Healthcare Institute (Synthetic)',
        category: 'Healthcare Assistance',
        location: 'Madurai Health Hub',
        deliveryMode: 'IN_PERSON',
        durationWeeks: 8,
        capacity: 25,
        enrolledCount: 19,
        prerequisites: ['10th Pass', 'Empathetic bedside interest'],
        skillsTaught: ['Basic Patient Vitals Monitoring'],
        certificationName: 'Certified Home Health Caregiver',
        status: 'OPEN_FOR_ENROLLMENT',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      },
      {
        id: 'crs-4',
        title: 'Industrial High-Speed Apparel Stitching & Finishing',
        providerName: 'Apparel Training & Design Center (Synthetic)',
        category: 'Apparel & Textiles',
        location: 'Tiruppur Textile Complex',
        deliveryMode: 'IN_PERSON',
        durationWeeks: 5,
        capacity: 40,
        enrolledCount: 35,
        prerequisites: ['Basic tailoring familiarity'],
        skillsTaught: ['Industrial Single Needle Stitching', 'Commercial Pattern Cutting'],
        certificationName: 'Apparel Export Quality Tailor Level 3',
        status: 'OPEN_FOR_ENROLLMENT',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      },
      {
        id: 'crs-5',
        title: 'Light EV Battery Diagnostics & Servicing',
        providerName: 'Apex E-Mobility Skill Lab (Synthetic)',
        category: 'Electric Mobility',
        location: 'Hosur Training Facility',
        deliveryMode: 'IN_PERSON',
        durationWeeks: 6,
        capacity: 20,
        enrolledCount: 14,
        prerequisites: ['Basic electrical or wiring knowledge'],
        skillsTaught: ['E-Rickshaw Battery Maintenance'],
        certificationName: 'EV Battery Service Specialist',
        status: 'OPEN_FOR_ENROLLMENT',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      },
      {
        id: 'crs-6',
        title: 'Organic Farming & Bio-Fertilizer Production',
        providerName: 'Tamil Nadu Rural Livelihood Mission (Synthetic)',
        category: 'Agriculture',
        location: 'Thanjavur Agro Park',
        deliveryMode: 'HYBRID',
        durationWeeks: 3,
        capacity: 35,
        enrolledCount: 28,
        prerequisites: ['Interest in organic cultivation'],
        skillsTaught: ['Organic Vermicomposting'],
        certificationName: 'Certified Organic Bio-Input Specialist',
        status: 'OPEN_FOR_ENROLLMENT',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      },
      {
        id: 'crs-7',
        title: 'Warehouse Operations & Inventory Management Systems',
        providerName: 'SupplyChain Skill Council (Synthetic)',
        category: 'Retail & Warehousing',
        location: 'Online + Salem Logistics Yard',
        deliveryMode: 'HYBRID',
        durationWeeks: 4,
        capacity: 30,
        enrolledCount: 21,
        prerequisites: ['10th Pass', 'Smartphone literacy'],
        skillsTaught: ['Digital Inventory Barcode Scanning'],
        certificationName: 'Certified Warehouse Associate',
        status: 'OPEN_FOR_ENROLLMENT',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      },
      {
        id: 'crs-8',
        title: 'Safe Food Production & FSSAI Standards',
        providerName: 'Rural Entrepreneurship Center (Synthetic)',
        category: 'Food Processing',
        location: 'Dindigul Training Hall',
        deliveryMode: 'IN_PERSON',
        durationWeeks: 2,
        capacity: 25,
        enrolledCount: 20,
        prerequisites: ['None'],
        skillsTaught: ['Food Safety & Hygiene Protocols'],
        certificationName: 'FoSTaC Food Safety Supervisor',
        status: 'OPEN_FOR_ENROLLMENT',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      },
      {
        id: 'crs-9',
        title: 'Customer Experience & Regional BPO Excellence',
        providerName: 'Vocational Bridge Foundation (Synthetic)',
        category: 'Customer Care',
        location: 'Online Interactive Lab',
        deliveryMode: 'ONLINE',
        durationWeeks: 3,
        capacity: 50,
        enrolledCount: 42,
        prerequisites: ['12th Pass', 'Spoken regional fluency'],
        skillsTaught: ['Customer Grievance Resolution'],
        certificationName: 'Certified Customer Support Specialist',
        status: 'OPEN_FOR_ENROLLMENT',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      },
      {
        id: 'crs-10',
        title: 'Modern Sanitary Plumbing & Pipe Jointing',
        providerName: 'Builders Skill Consortium (Synthetic)',
        category: 'Construction',
        location: 'Vellore Practical Yard',
        deliveryMode: 'IN_PERSON',
        durationWeeks: 4,
        capacity: 25,
        enrolledCount: 18,
        prerequisites: ['8th Pass'],
        skillsTaught: ['Sanitary Plumbing Rough-in'],
        certificationName: 'Certified Plumber General',
        status: 'OPEN_FOR_ENROLLMENT',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      }
    ],
    pathways: [],
    mentors: [
      {
        id: 'men-1',
        userId: 'usr-mentor-1',
        name: 'Murugan Sundaram',
        expertise: ['Solar Rooftop Installation', 'Micro-Grid Maintenance', 'Electrical Safety'],
        languages: ['Tamil', 'English'],
        serviceArea: 'Tiruchirappalli & Central TN',
        yearsOfExperience: 9,
        availabilityStatus: 'AVAILABLE',
        verificationStatus: 'VERIFIED',
        rating: 4.9,
        menteesCount: 28,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      },
      {
        id: 'men-2',
        userId: 'usr-mentor-2',
        name: 'Kavitha Radhakrishnan',
        expertise: ['Industrial Apparel Production', 'Self-Help Group Handloom', 'Pattern Design'],
        languages: ['Tamil', 'Malayalam'],
        serviceArea: 'Tiruppur & Coimbatore',
        yearsOfExperience: 12,
        availabilityStatus: 'AVAILABLE',
        verificationStatus: 'VERIFIED',
        rating: 4.8,
        menteesCount: 44,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      },
      {
        id: 'men-3',
        userId: 'usr-mentor-3',
        name: 'Dr. Ramesh Balan',
        expertise: ['Organic Farming Certification', 'Drip Systems', 'Soil Amendment'],
        languages: ['Tamil', 'Hindi', 'English'],
        serviceArea: 'Thanjavur & Delta Region',
        yearsOfExperience: 15,
        availabilityStatus: 'AVAILABLE',
        verificationStatus: 'VERIFIED',
        rating: 5.0,
        menteesCount: 52,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      },
      {
        id: 'men-4',
        userId: 'usr-mentor-4',
        name: 'Revathi Sengupta',
        expertise: ['Elder Care Management', 'First Aid', 'Palliative Community Care'],
        languages: ['Tamil', 'Hindi', 'Telugu'],
        serviceArea: 'Madurai & South TN',
        yearsOfExperience: 8,
        availabilityStatus: 'AVAILABLE',
        verificationStatus: 'VERIFIED',
        rating: 4.7,
        menteesCount: 19,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      },
      {
        id: 'men-5',
        userId: 'usr-mentor-5',
        name: 'Praveen Kumar Yadav',
        expertise: ['EV Fleet Operations', 'Battery Testing', 'Auto Electricals'],
        languages: ['Hindi', 'Tamil', 'Kannada'],
        serviceArea: 'Bengaluru & Hosur Corridor',
        yearsOfExperience: 7,
        availabilityStatus: 'AVAILABLE',
        verificationStatus: 'VERIFIED',
        rating: 4.9,
        menteesCount: 31,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      },
      {
        id: 'men-6',
        userId: 'usr-mentor-6',
        name: 'Ananya Deshmukh',
        expertise: ['Agri-Drone Navigation', 'Sensor Calibration', 'Flight Planning'],
        languages: ['English', 'Hindi', 'Kannada'],
        serviceArea: 'Coimbatore & Erode',
        yearsOfExperience: 6,
        availabilityStatus: 'AVAILABLE',
        verificationStatus: 'VERIFIED',
        rating: 4.8,
        menteesCount: 15,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      },
      {
        id: 'men-7',
        userId: 'usr-mentor-7',
        name: 'Selvakumar Natarajan',
        expertise: ['Warehouse Logistics', 'Barcode Integration', 'Fleet Dispatch'],
        languages: ['Tamil', 'Telugu'],
        serviceArea: 'Salem & Namakkal',
        yearsOfExperience: 11,
        availabilityStatus: 'AVAILABLE',
        verificationStatus: 'VERIFIED',
        rating: 4.6,
        menteesCount: 23,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      },
      {
        id: 'men-8',
        userId: 'usr-mentor-8',
        name: 'Fatima Begum',
        expertise: ['FSSAI Food Compliance', 'Millets Micro-Enterprise', 'Packaging'],
        languages: ['Tamil', 'Urdu', 'English'],
        serviceArea: 'Dindigul & Theni',
        yearsOfExperience: 10,
        availabilityStatus: 'AVAILABLE',
        verificationStatus: 'VERIFIED',
        rating: 4.9,
        menteesCount: 38,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      },
      {
        id: 'men-9',
        userId: 'usr-mentor-9',
        name: 'Karthikeyan Veerappan',
        expertise: ['Commercial Plumbing', 'Pumping Station Lines', 'Sanitary Layouts'],
        languages: ['Tamil', 'Kannada'],
        serviceArea: 'Vellore & Ranipet',
        yearsOfExperience: 14,
        availabilityStatus: 'AVAILABLE',
        verificationStatus: 'VERIFIED',
        rating: 4.7,
        menteesCount: 26,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      },
      {
        id: 'men-10',
        userId: 'usr-mentor-10',
        name: 'Deepa Narayanan',
        expertise: ['Voice Process Quality', 'Regional Dialect Training', 'Soft Skills'],
        languages: ['Malayalam', 'Tamil', 'English', 'Hindi'],
        serviceArea: 'Chennai & Remote',
        yearsOfExperience: 8,
        availabilityStatus: 'AVAILABLE',
        verificationStatus: 'VERIFIED',
        rating: 4.8,
        menteesCount: 41,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      }
    ],
    mentorRequests: [],
    conversations: [],
    supportTickets: [],
    auditLogs: []
  };

  // Create 20+ Synthetic Beneficiaries across multiple regions and sectors
  const beneficiaryData = [
    { name: 'Arun Kumar', phone: '+919840112301', lang: 'ta', edu: '10th Standard', curr: 'House wiring assistant', exp: '2 years informal domestic electrical repair', loc: 'Tiruchirappalli, Tamil Nadu', mob: 'Local district travel OK', workType: 'WAGE_EMPLOYMENT', targetRole: 'Solar PV Installation Technician', skill: 'Solar PV Inverter Wiring', ver: 'SELF_DECLARED' },
    { name: 'Meenakshi Sundaram', phone: '+919840112302', lang: 'ta', edu: '8th Standard', curr: 'Home tailoring', exp: '4 years blouse and salwar stitching', loc: 'Tiruppur, Tamil Nadu', mob: 'Within 10km only', workType: 'WAGE_EMPLOYMENT', targetRole: 'Apparel Finishing & Quality Inspector', skill: 'Commercial Pattern Cutting', ver: 'ORGANIZATION_VERIFIED' },
    { name: 'Suresh Mani', phone: '+919840112303', lang: 'ta', edu: 'Diploma in Agriculture', curr: 'Smallholder farm laborer', exp: 'Cultivation and furrow watering', loc: 'Coimbatore, Tamil Nadu', mob: 'Can commute 25km', workType: 'WAGE_EMPLOYMENT', targetRole: 'Community Greenhouse Drone Operator', skill: 'Drip Irrigation Setup', ver: 'VERIFIED' },
    { name: 'Lakshmi Priya', phone: '+919840112304', lang: 'ta', edu: '10th Pass', curr: 'Elderly caretaker', exp: '1 year home patient assistance', loc: 'Madurai, Tamil Nadu', mob: 'City limits', workType: 'WAGE_EMPLOYMENT', targetRole: 'Geriatric Care & Home Health Assistant', skill: 'Basic Patient Vitals Monitoring', ver: 'SELF_DECLARED' },
    { name: 'Praveen Chander', phone: '+919840112305', lang: 'hi', edu: 'ITI Electrician', curr: 'Auto garage mechanic helper', exp: 'Lead acid battery replacement', loc: 'Hosur, Tamil Nadu', mob: 'Flexible', workType: 'WAGE_EMPLOYMENT', targetRole: 'EV Fleet Terminal Battery Technician', skill: 'E-Rickshaw Battery Maintenance', ver: 'AI_INFERRED' },
    { name: 'Dhanalakshmi R', phone: '+919840112306', lang: 'ta', edu: '12th Pass', curr: 'SHG organic manure vendor', exp: 'Community composting', loc: 'Thanjavur, Tamil Nadu', mob: 'Local block', workType: 'SELF_EMPLOYMENT', targetRole: 'Organic Farm Cluster Manager', skill: 'Organic Vermicomposting', ver: 'VERIFIED' },
    { name: 'Manoj Venkat', phone: '+919840112307', lang: 'te', edu: '10th Pass', curr: 'Grocery shop stock boy', exp: 'Shelf stocking and manual ledger', loc: 'Salem, Tamil Nadu', mob: 'Commute OK', workType: 'WAGE_EMPLOYMENT', targetRole: 'Regional Fulfillment Center Associate', skill: 'Digital Inventory Barcode Scanning', ver: 'SELF_DECLARED' },
    { name: 'Fatima Zohra', phone: '+919840112308', lang: 'ta', edu: '10th Standard', curr: 'Home snacks maker', exp: 'Homemade savories production', loc: 'Dindigul, Tamil Nadu', mob: 'Home based or nearby SHG', workType: 'SELF_EMPLOYMENT', targetRole: 'Micro-Enterprise Bakery Team Lead', skill: 'Food Safety & Hygiene Protocols', ver: 'AI_INFERRED' },
    { name: 'Karthik Raja', phone: '+919840112309', lang: 'ta', edu: '10th Pass', curr: 'Motor rewinding trainee', exp: 'Submersible pump motor winding', loc: 'Dharmapuri, Tamil Nadu', mob: 'Open to rural camps', workType: 'WAGE_EMPLOYMENT', targetRole: 'Solar Micro-Grid Maintenance Associate', skill: 'Solar PV Inverter Wiring', ver: 'VERIFIED' },
    { name: 'Santhi Anbarasan', phone: '+919840112310', lang: 'ta', edu: '12th Pass', curr: 'Village data entry volunteer', exp: 'Tamil and English typing', loc: 'Chennai, Tamil Nadu', mob: 'Work from home or Chennai center', workType: 'WAGE_EMPLOYMENT', targetRole: 'Multilingual Customer Support Representative', skill: 'Customer Grievance Resolution', ver: 'ORGANIZATION_VERIFIED' },
    { name: 'Gopalakrishnan V', phone: '+919840112311', lang: 'ta', edu: '8th Pass', curr: 'Plumbing helper', exp: 'G.I. pipe threading and trench digging', loc: 'Vellore, Tamil Nadu', mob: 'Within district', workType: 'WAGE_EMPLOYMENT', targetRole: 'Sanitary Plumbing Assistant', skill: 'Sanitary Plumbing Rough-in', ver: 'SELF_DECLARED' },
    { name: 'Revathi Mohan', phone: '+919840112312', lang: 'ta', edu: '10th Pass', curr: 'Millet flour packing', exp: 'Manual packaging and sealing', loc: 'Krishnagiri, Tamil Nadu', mob: '10km commute', workType: 'WAGE_EMPLOYMENT', targetRole: 'Millets Processing & Packaging Operator', skill: 'Food Safety & Hygiene Protocols', ver: 'AI_INFERRED' },
    { name: 'Bhavani Shankar', phone: '+919840112313', lang: 'kn', edu: '10th Standard', curr: 'Boutique tailor', exp: 'Zari and embroidery work', loc: 'Kanchipuram, Tamil Nadu', mob: 'Local', workType: 'SELF_EMPLOYMENT', targetRole: 'Artisan Embroidery & Boutique Stitcher', skill: 'Industrial Single Needle Stitching', ver: 'VERIFIED' },
    { name: 'Vigneshwaran P', phone: '+919840112314', lang: 'ta', edu: '12th Pass', curr: 'Cold storage gatekeeper', exp: 'Temperature log book entry', loc: 'Namakkal, Tamil Nadu', mob: 'Can relocate 50km', workType: 'WAGE_EMPLOYMENT', targetRole: 'Cold-Chain Warehouse Supervisor', skill: 'Digital Inventory Barcode Scanning', ver: 'SELF_DECLARED' },
    { name: 'Chitra Pandian', phone: '+919840112315', lang: 'ta', edu: '10th Pass', curr: 'Nursery seedling grafter', exp: 'Polyhouse drip lines and planting', loc: 'Karur, Tamil Nadu', mob: 'Within block', workType: 'WAGE_EMPLOYMENT', targetRole: 'Precision Micro-Irrigation Field Technician', skill: 'Drip Irrigation Setup', ver: 'ORGANIZATION_VERIFIED' },
    { name: 'Ravi Teja', phone: '+919840112316', lang: 'te', edu: '10th Standard', curr: 'Rural electrician apprentice', exp: 'Single phase line repair', loc: 'Tiruchirappalli, Tamil Nadu', mob: 'District wide', workType: 'WAGE_EMPLOYMENT', targetRole: 'Solar PV Installation Technician', skill: 'Solar PV Inverter Wiring', ver: 'AI_INFERRED' },
    { name: 'Naveen Joseph', phone: '+919840112317', lang: 'ml', edu: '12th Pass', curr: 'Ambulance helper', exp: 'Patient transport and stretcher care', loc: 'Madurai, Tamil Nadu', mob: 'Flexible hours', workType: 'WAGE_EMPLOYMENT', targetRole: 'Geriatric Care & Home Health Assistant', skill: 'Basic Patient Vitals Monitoring', ver: 'VERIFIED' },
    { name: 'Poongodi G', phone: '+919840112318', lang: 'ta', edu: '10th Pass', curr: 'Garment alteration shop', exp: 'Hemming and button hole stitching', loc: 'Tiruppur, Tamil Nadu', mob: 'Commute OK', workType: 'WAGE_EMPLOYMENT', targetRole: 'Apparel Finishing & Quality Inspector', skill: 'Industrial Single Needle Stitching', ver: 'SELF_DECLARED' },
    { name: 'Rajesh Sharma', phone: '+919840112319', lang: 'hi', edu: '10th Pass', curr: 'Delivery rider', exp: 'Smartphone app navigation and scanning', loc: 'Salem, Tamil Nadu', mob: 'Two-wheeler available', workType: 'WAGE_EMPLOYMENT', targetRole: 'Regional Fulfillment Center Associate', skill: 'Digital Inventory Barcode Scanning', ver: 'VERIFIED' },
    { name: 'Sumathi Murugesan', phone: '+919840112320', lang: 'ta', edu: '8th Pass', curr: 'Poultry farm caretaker', exp: 'Feeder cleaning and bio-waste collection', loc: 'Thanjavur, Tamil Nadu', mob: 'Within village', workType: 'SELF_EMPLOYMENT', targetRole: 'Organic Farm Cluster Manager', skill: 'Organic Vermicomposting', ver: 'SELF_DECLARED' },
    { name: 'Kishore Kumar', phone: '+919840112321', lang: 'en', edu: 'Diploma in Mechatronics', curr: 'Drone hobbyist & battery repairer', exp: 'Quadcopter flight controller soldering', loc: 'Coimbatore, Tamil Nadu', mob: 'State-wide travel', workType: 'WAGE_EMPLOYMENT', targetRole: 'Community Greenhouse Drone Operator', skill: 'Agricultural Drone Spray Calibration', ver: 'VERIFIED' }
  ];

  // Admin & Staff users
  const adminUser = {
    id: 'usr-admin-1',
    phone: '+919000000001',
    email: 'admin@jeevika.ai',
    fullName: 'Jeevika Operations Administrator',
    role: 'ADMINISTRATOR' as const,
    status: 'ACTIVE' as const,
    preferredLanguage: 'en',
    isConsented: true,
    consentDate: new Date().toISOString(),
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  };
  schema.users.push(adminUser);

  const supportUser = {
    id: 'usr-support-1',
    phone: '+919000000002',
    email: 'support@jeevika.ai',
    fullName: 'Shalini Devi (Community Support Lead)',
    role: 'SUPPORT_WORKER' as const,
    status: 'ACTIVE' as const,
    preferredLanguage: 'ta',
    isConsented: true,
    consentDate: new Date().toISOString(),
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  };
  schema.users.push(supportUser);

  // Add Mentor Users
  schema.mentors.forEach((m, idx) => {
    schema.users.push({
      id: m.userId,
      phone: `+9198000000${10 + idx}`,
      email: `mentor.${idx + 1}@jeevika.network`,
      fullName: m.name,
      role: 'MENTOR',
      status: 'ACTIVE',
      preferredLanguage: m.languages[0].toLowerCase().slice(0, 2),
      isConsented: true,
      consentDate: new Date().toISOString(),
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    });
  });

  // Populate Beneficiaries, Profiles, Skills, Pathways, and Conversations
  beneficiaryData.forEach((b, idx) => {
    const userId = `usr-ben-${idx + 1}`;
    const benId = `ben-${idx + 1}`;
    const user = {
      id: userId,
      phone: b.phone,
      email: `${b.name.toLowerCase().replace(/\s+/g, '.')}@example.synthetic`,
      fullName: b.name,
      role: 'BENEFICIARY' as const,
      status: 'ACTIVE' as const,
      preferredLanguage: b.lang,
      isConsented: true,
      consentDate: new Date().toISOString(),
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };
    schema.users.push(user);

    const profile = {
      id: benId,
      userId: userId,
      fullName: b.name,
      phone: b.phone,
      preferredLanguage: b.lang,
      educationLevel: b.edu,
      currentWork: b.curr,
      previousExperience: b.exp,
      location: b.loc,
      mobilityConstraints: b.mob,
      preferredWorkType: b.workType as any,
      internetAccess: true,
      completionRate: 85 + (idx % 15),
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };
    schema.beneficiaryProfiles.push(profile);

    // Link skill
    const skillObj = schema.skills.find(s => s.name === b.skill) || schema.skills[0];
    schema.userSkills.push({
      id: `usk-${idx + 1}`,
      userId: userId,
      skillId: skillObj.id,
      skillName: skillObj.name,
      proficiency: idx % 2 === 0 ? 'INTERMEDIATE' : 'ADVANCED',
      verificationType: b.ver as any,
      evidenceDescription: `Extracted through structured voice interview and ${b.exp}`,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    });

    // Link Pathway
    const isStepTrain = idx % 2 === 0;
    schema.pathways.push({
      id: `pth-${idx + 1}`,
      beneficiaryId: benId,
      targetRole: b.targetRole,
      currentStage: isStepTrain ? 'TRAIN' : 'GAP',
      alignmentScore: 75 + (idx % 20),
      satisfiedRequirements: [b.edu, 'Regional residency satisfied', `Practical skill: ${b.skill}`],
      missingRequirements: isStepTrain ? ['Accredited Level-4 Certification', 'Practical Field Assessment'] : ['Mandatory Safety Certification'],
      nextAction: isStepTrain ? 'Enroll in subsidized certified training module' : 'Upload proof or schedule skill assessment with mentor',
      estimatedWeeks: 4 + (idx % 6),
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    });

    // Create a sample unified conversation for the first 5 beneficiaries
    if (idx < 5) {
      const convId = `conv-${idx + 1}`;
      const channel = idx % 3 === 0 ? 'MOBILE_APP' : (idx % 3 === 1 ? 'WHATSAPP' : 'IVR');
      const isEscalated = idx === 3 || idx === 7;
      
      schema.conversations.push({
        id: convId,
        beneficiaryId: benId,
        channel,
        language: b.lang,
        status: isEscalated ? 'ESCALATED_TO_HUMAN' : 'ACTIVE',
        escalationReason: isEscalated ? `Beneficiary case escalated for field support review: ${b.name}` : undefined,
        summary: `Livelihood intake completed. Expressed strong interest in ${b.targetRole}. Recommended ${b.skill} pathway.`,
        messages: [
          {
            id: `msg-${idx}-1`,
            senderId: userId,
            senderRole: 'BENEFICIARY',
            content: idx === 0
              ? 'வணக்கம், நான் சோலார் பேனல் வேலை செய்ய விரும்புகிறேன்.'
              : (idx === 1
                ? 'வணக்கம், திருப்பூர் எக்ஸ்போர்ட் தையல் வேலை வாய்ப்பு பற்றி தகவல் வேண்டும்.'
                : (idx === 2
                  ? '[Voice Call] விவசாய ட்ரோன் பைலட் பயிற்சி எப்போது தொடங்குகிறது?'
                  : (idx === 3
                    ? 'பயிற்சி மையத்திற்கு செல்ல இலவச பேருந்து அட்டை கிடைக்குமா?'
                    : (idx === 4
                      ? 'नमस्ते, मैं होसुर में ईवी बैटरी रिपेयरिंग का काम सीखना चाहता हूँ।'
                      : 'வேலை வாய்ப்புகள் பற்றி மேலும் விவரம் அறிய விரும்புகிறேன்.')))),
            channel,
            timestamp: new Date(Date.now() - (3600000 * (idx + 1))).toISOString()
          },
          {
            id: `msg-${idx}-2`,
            senderId: 'ai-gateway',
            senderRole: 'AI',
            content: idx === 0
              ? 'வணக்கம் அருண்! உங்கள் மின்சார அனுபவத்தை அடிப்படையாகக் கொண்டு, சோலார் PV தொழில்நுட்பப் பாதை உருவாக்கப்பட்டுள்ளது.'
              : (idx === 1
                ? 'மீனாட்சி அவர்களுக்கு வணக்கம்! டெக்ஸ்கிராப்ட் எக்ஸ்போர்ட் நிறுவனத்தில் 20 காலியிடங்கள் உள்ளன.'
                : (idx === 2
                  ? 'கோவை கிசான் ட்ரோன் அகாடமியில் புதிய பயிற்சி அக்டோபர் 12-ல் தொடங்குகிறது.'
                  : (idx === 3
                    ? 'உங்கள் கோரிக்கை கள ஆலோசகர் ஷாலினி தேவி அவர்களுக்கு அனுப்பப்பட்டுள்ளது.'
                    : (idx === 4
                      ? 'होसुर में एएसडीसी द्वारा 6 सप्ताह का ईवी बैटरी तकनीशियन कोर्स उपलब्ध है।'
                      : 'உங்கள் விவரங்கள் சரிபார்க்கப்பட்டு சிறந்த வாய்ப்புகள் பட்டியலிடப்பட்டுள்ளன.')))),
            channel,
            timestamp: new Date(Date.now() - (3500000 * (idx + 1))).toISOString()
          }
        ],
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      });
    }
  });

  // Seed 8 realistic human support tickets across categories
  const ticketDefs = [
    {
      id: 'tkt-1',
      beneficiaryId: 'ben-4',
      beneficiaryName: 'Lakshmi Priya',
      channel: 'MOBILE_APP' as const,
      subject: 'Rural Bus Transport Pass Subsidy Assistance',
      reason: 'Beneficiary requested guidance on claiming district transport concession for attending the 12-week Madurai GDA healthcare center training.',
      status: 'OPEN' as const,
    },
    {
      id: 'tkt-2',
      beneficiaryId: 'ben-8',
      beneficiaryName: 'Fatima Zohra',
      channel: 'WHATSAPP' as const,
      subject: 'FSSAI Home Bakery Food License Documentation',
      reason: 'Micro-entrepreneur needs handholding to upload Aadhaar and home water quality test certificate for FSSAI registration portal.',
      status: 'OPEN' as const,
    },
    {
      id: 'tkt-3',
      beneficiaryId: 'ben-11',
      beneficiaryName: 'Gopalakrishnan V',
      channel: 'IVR' as const,
      subject: 'Tamil Vernacular Question Clarification (Plumbing Course)',
      reason: 'Elderly candidate requires voice-based clarification in regional dialect regarding IPSC plumbing tool kit stipend disbursement.',
      status: 'OPEN' as const,
    },
    {
      id: 'tkt-4',
      beneficiaryId: 'ben-5',
      beneficiaryName: 'Praveen Chander',
      channel: 'MOBILE_APP' as const,
      subject: 'Hostel Accommodation Query for Hosur EV Program',
      reason: 'Candidate resides 40km away from Hosur center and asked if subsidized dormitory accommodation is available during the 6-week hands-on training.',
      status: 'IN_REVIEW' as const,
    },
    {
      id: 'tkt-5',
      beneficiaryId: 'ben-13',
      beneficiaryName: 'Bhavani Shankar',
      channel: 'WHATSAPP' as const,
      subject: 'Artisan Mudra Loan Application Link',
      reason: 'Zari embroidery artisan requested review of her small business micro-enterprise Mudra loan proposal for purchasing motorized stitching machinery.',
      status: 'OPEN' as const,
    },
    {
      id: 'tkt-6',
      beneficiaryId: 'ben-3',
      beneficiaryName: 'Suresh Mani',
      channel: 'IVR' as const,
      subject: 'DGCA Drone Pilot Medical Fitness Verification',
      reason: 'Candidate requires standard government hospital medical fitness form format before attending DGCA drone ground school in Coimbatore.',
      status: 'RESOLVED' as const,
    },
    {
      id: 'tkt-7',
      beneficiaryId: 'ben-1',
      beneficiaryName: 'Arun Kumar',
      channel: 'MOBILE_APP' as const,
      subject: 'Safety Harness & Two-Wheeler License Update',
      reason: 'Candidate updated valid learner license and verified proof of electrician helper experience for SunVanguard field technician placement.',
      status: 'RESOLVED' as const,
    },
    {
      id: 'tkt-8',
      beneficiaryId: 'ben-12',
      beneficiaryName: 'Revathi Mohan',
      channel: 'WHATSAPP' as const,
      subject: 'SHG Millet Packaging Tool Kit Allocation',
      reason: 'Cluster coordinator verified Krishnagiri self-help group equipment allocation for packaging unit.',
      status: 'RESOLVED' as const,
    },
  ];

  for (const td of ticketDefs) {
    schema.supportTickets.push({
      ...td,
      assignedTo: supportUser.id,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    });
  }

  // Assign multiple realistic mentor requests
  schema.mentorRequests.push(
    {
      id: 'mr-1',
      beneficiaryId: 'ben-1',
      mentorId: 'men-1',
      beneficiaryName: 'Arun Kumar',
      topic: 'Guidance on Rooftop Solar Inverter Earthing Certification',
      message: 'Hello Murugan Sir, I am preparing for the Level-4 Solar exam and would appreciate practical tips.',
      status: 'ACCEPTED',
      scheduledDate: '2026-10-05T10:30:00Z',
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    },
    {
      id: 'mr-2',
      beneficiaryId: 'ben-2',
      mentorId: 'men-2',
      beneficiaryName: 'Meenakshi Sundaram',
      topic: 'Industrial Overlock Machine Settings for Cotton Blouse Export',
      message: 'Kavitha madam, I would like tips on meeting export inspection standards.',
      status: 'PENDING',
      scheduledDate: '2026-10-08T14:00:00Z',
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    },
    {
      id: 'mr-3',
      beneficiaryId: 'ben-3',
      mentorId: 'men-6',
      beneficiaryName: 'Suresh Mani',
      topic: 'Nozzle Calibration for Drone Pesticide Spraying',
      message: 'Dr. Ramesh and Ananya, seeking advice on droplet size for cotton bollworm spraying.',
      status: 'ACCEPTED',
      scheduledDate: '2026-10-06T11:00:00Z',
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    }
  );

  // Write to database
  db.resetTo(schema);
  console.log(`Database seeded successfully!
  - Users: ${schema.users.length}
  - Beneficiaries: ${schema.beneficiaryProfiles.length}
  - Mentors: ${schema.mentors.length}
  - Courses: ${schema.courses.length}
  - Opportunities: ${schema.opportunities.length}
  - Pathways: ${schema.pathways.length}
  - Conversations: ${schema.conversations.length}`);
  return schema;
}

if (require.main === module) {
  runSeed();
}
