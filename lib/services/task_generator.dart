import '../models/life_models.dart';

/// Generates task checklists for each life event type.
class TaskGenerator {
  static List<LifeTask> generate(LifeEventType type) {
    switch (type) {
      case LifeEventType.move:       return _moveTasks();
      case LifeEventType.newJob:     return _newJobTasks();
      case LifeEventType.buyCar:     return _buyCarTasks();
      case LifeEventType.taxYear:    return _taxTasks();
      case LifeEventType.study:      return _studyTasks();
      case LifeEventType.family:     return _familyTasks();
    }
  }

  // ── MOVE ──────────────────────────────────────────────────────────────────
  static List<LifeTask> _moveTasks() => [
    LifeTask(
      id: 'move_1', title: 'Register Address (Anmeldung)',
      description: 'Officially register your new address at the local citizens office.',
      explanation: 'In Germany, you are legally required to register your new address within 14 days of moving in.',
      requiredDocs: ['Identity Card / Passport', 'Landlord Confirmation (Wohnungsgeberbestätigung)'],
      steps: [
        'Book an appointment online at the local Bürgeramt.',
        'Get the signed confirmation form from your landlord.',
        'Attend the appointment and receive your Meldebescheinigung.'
      ],
      priority: TaskPriority.urgent,
      deadline: DateTime.now().add(const Duration(days: 14)),
      eventType: LifeEventType.move,
      xpReward: 30,
    ),
    LifeTask(
      id: 'move_2', title: 'Forward Mail (Nachsendeauftrag)',
      description: 'Set up a mail forwarding service with Deutsche Post.',
      explanation: 'This ensures you don\'t miss important letters during your transition.',
      requiredDocs: ['Identity Card'],
      steps: [
        'Visit the Deutsche Post website.',
        'Choose the duration (e.g., 6 or 12 months).',
        'Pay the processing fee.'
      ],
      priority: TaskPriority.high,
      deadline: DateTime.now().add(const Duration(days: 3)),
      eventType: LifeEventType.move,
      xpReward: 20,
    ),
    LifeTask(
      id: 'move_3', title: 'Change Internet Provider',
      description: 'Update your service address or switch providers.',
      explanation: 'Internet moving services usually take several weeks to process.',
      requiredDocs: ['Customer Number', 'New Address'],
      steps: [
        'Check availability at your new address.',
        'Request moving service or cancel old contract.',
        'Coordinate technician visit if needed.'
      ],
      priority: TaskPriority.medium,
      eventType: LifeEventType.move,
      xpReward: 20,
    ),
    const LifeTask(
      id: 'move_4', title: 'Update Insurance Portfolios',
      description: 'Notify insurance companies about your new home size and location.',
      explanation: 'Premiums for household or liability insurance may change based on your new living situation.',
      requiredDocs: ['Policy Number'],
      steps: ['Contact your insurance consultant', 'Update address in the online portal'],
      priority: TaskPriority.medium,
      eventType: LifeEventType.move,
      xpReward: 15,
    ),
  ];

  // ── NEW JOB ──────────────────────────────────────────────────────────────
  static List<LifeTask> _newJobTasks() => [
    LifeTask(
      id: 'job_1', title: 'Submit Tax ID',
      description: 'Provide your 11-digit tax identification number to HR.',
      explanation: 'Your employer needs this to calculate your income tax correctly.',
      requiredDocs: ['Tax ID Document'],
      steps: ['Locate your Tax ID on previous tax statements', 'Send the number to your HR department'],
      priority: TaskPriority.urgent,
      deadline: DateTime.now().add(const Duration(days: 1)),
      eventType: LifeEventType.newJob,
      xpReward: 20,
    ),
    LifeTask(
      id: 'job_2', title: 'Check Social Security ID',
      description: 'Ensure your employer has your SV-Nummer.',
      explanation: 'Every employee in Germany has a unique social security number.',
      requiredDocs: ['Social Security Card'],
      steps: ['Take a copy of your card', 'Forward it to the payroll department'],
      priority: TaskPriority.high,
      eventType: LifeEventType.newJob,
      xpReward: 15,
    ),
  ];

  // ── BUY CAR ────────────────────────────────────────────────────────────
  static List<LifeTask> _buyCarTasks() => [
    LifeTask(
      id: 'car_1', title: 'Get Car Insurance (eVB)',
      description: 'Sign up for liability insurance to get your eVB number.',
      explanation: 'You cannot register a vehicle in Germany without proof of valid insurance.',
      requiredDocs: ['License', 'Vehicle Details'],
      steps: ['Compare rates online', 'Sign the contract', 'Receive the eVB code via SMS/Email'],
      priority: TaskPriority.urgent,
      eventType: LifeEventType.buyCar,
      xpReward: 30,
    ),
    LifeTask(
      id: 'car_2', title: 'Register the Vehicle',
      description: 'Visit the Zulassungsstelle to get your plates.',
      explanation: 'This finalize the transfer of ownership into your name.',
      requiredDocs: ['eVB Number', 'ID Card', 'Zulassungsbescheinigung Teil I & II', 'TÜV Report'],
      steps: ['Book an appointment', 'Bring old plates if applicable', 'Pay the registration tax'],
      priority: TaskPriority.high,
      eventType: LifeEventType.buyCar,
      xpReward: 40,
    ),
  ];

  // ── TAX YEAR ─────────────────────────────────────────────────────────────
  static List<LifeTask> _taxTasks() => [
    const LifeTask(
      id: 'tax_1', title: 'Collect Receipts & Invoices',
      description: 'Gather all documents related to work expenses or medical bills.',
      explanation: 'You can deduct work equipment, training, and commutes from your taxes.',
      requiredDocs: ['Lohnsteuerbescheinigung', 'Invoices', 'Train tickets'],
      steps: ['Sort receipts by category', 'Scan them for digital storage'],
      priority: TaskPriority.high,
      eventType: LifeEventType.taxYear,
      xpReward: 20,
    ),
  ];

  // ── STUDY ────────────────────────────────────────────────────────────────
  static List<LifeTask> _studyTasks() => [
    const LifeTask(
      id: 'study_1', title: 'Enrollment Certificate',
      description: 'Download your Immatrikulationsbescheinigung.',
      explanation: 'Used for health insurance discounts and transportation tickets.',
      requiredDocs: [],
      steps: ['Login to university portal', 'Save PDF version'],
      priority: TaskPriority.medium,
      eventType: LifeEventType.study,
      xpReward: 10,
    ),
  ];

  // ── FAMILY ────────────────────────────────────────────────────────────────
  static List<LifeTask> _familyTasks() => [
    const LifeTask(
      id: 'family_1', title: 'Birth Certificate',
      description: 'Register the birth at the Standesamt.',
      explanation: 'Essential for child benefits and health insurance.',
      requiredDocs: ['Hospital records', 'ID of parents'],
      steps: ['Visit registry office', 'Order multiple copies'],
      priority: TaskPriority.urgent,
      eventType: LifeEventType.family,
      xpReward: 20,
    ),
  ];
}
