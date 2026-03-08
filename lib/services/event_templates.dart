import '../models/life_models.dart';

/// Central template system for life events.
/// Can be extended to support multiple countries.
class EventTemplates {
  
  static List<LifeTask> getTasksForEvent(LifeEventType type, {String country = 'DE'}) {
    // Current focus is on Germany (DE) as requested
    if (country == 'DE') {
      switch (type) {
        case LifeEventType.move:
          return _deMoveTemplates;
        case LifeEventType.newJob:
          return _deJobTemplates;
        case LifeEventType.buyCar:
          return _deCarTemplates;
        case LifeEventType.taxYear:
          return _deTaxTemplates;
        default:
          return [];
      }
    }
    return [];
  }

  // ── GERMANY: MOVE ──────────────────────────────────────────────────────────
  static final List<LifeTask> _deMoveTemplates = [
    LifeTask(
      id: 'de_move_1',
      title: 'Wohnsitz ummelden (Bürgeramt)',
      description: 'Gesetzliche Meldepflicht beim Einwohnermeldeamt.',
      explanation: 'In Deutschland musst du dich innerhalb von 14 Tagen nach Einzug ummelden.',
      requiredDocs: ['Personalausweis oder Reisepass', 'Wohnungsgeberbestätigung (vom Vermieter)'],
      steps: [
        'Termin beim Bürgeramt online vereinbaren',
        'Wohnungsgeberbestätigung unterschreiben lassen',
        'Persönlich zum Termin erscheinen'
      ],
      priority: TaskPriority.urgent,
      eventType: LifeEventType.move,
      timeSaved: 30,
    ),
    LifeTask(
      id: 'de_move_2',
      title: 'Nachsendeauftrag einrichten',
      description: 'Post von der alten zur neuen Adresse umleiten.',
      explanation: 'Verhindert, dass wichtige Briefe im alten Briefkasten landen.',
      requiredDocs: ['Zahlungsmittel'],
      steps: [
        'Website der Deutschen Post besuchen',
        'Laufzeit wählen (empfohlen: 12 Monate)',
        'Auftrag online bezahlen'
      ],
      priority: TaskPriority.high,
      eventType: LifeEventType.move,
      timeSaved: 20,
    ),
    LifeTask(
      id: 'de_move_3',
      title: 'Strom & Gas umziehen',
      description: 'Zählerstände melden und Verträge aktualisieren.',
      explanation: 'Du musst deinen Energieversorger über den Auszug und Einzug informieren.',
      requiredDocs: ['Zählernummer (alt & neu)', 'Zählerstände'],
      steps: [
        'Zählerstand in der alten Wohnung am Tag der Übergabe fotografieren',
        'Versorger kontaktieren und "Umzug" melden',
        'Zählerstand in der neuen Wohnung melden'
      ],
      priority: TaskPriority.high,
      eventType: LifeEventType.move,
      timeSaved: 45,
    ),
    LifeTask(
      id: 'de_move_4',
      title: 'Internet & Telefon ummelden',
      description: 'Vertrag an die neue Adresse mitnehmen.',
      explanation: 'Oft ist ein Technikereinsatz nötig, daher frühzeitig (4-6 Wochen vorher) melden.',
      requiredDocs: ['Kundennummer', 'Anschlussdetails der neuen Wohnung'],
      steps: [
        'Verfügbarkeit an der neuen Adresse prüfen',
        'Umzugsservice des Anbieters beauftragen',
        'Termin für die Freischaltung bestätigen'
      ],
      priority: TaskPriority.medium,
      eventType: LifeEventType.move,
      timeSaved: 30,
    ),
    LifeTask(
      id: 'de_move_5',
      title: 'Rundfunkbeitrag (GEZ) anpassen',
      description: 'Wohnung bei ARD/ZDF/Deutschlandradio ummelden.',
      explanation: 'Der Beitrag wird pro Wohnung gezahlt. Bei Zusammenzug kann ein Konto gelöscht werden.',
      requiredDocs: ['Beitragsnummer'],
      steps: [
        'Online-Formular auf rundfunkbeitrag.de aufrufen',
        'Adressänderung eingeben',
        'Bestätigung abwarten'
      ],
      priority: TaskPriority.low,
      eventType: LifeEventType.move,
      timeSaved: 15,
    ),
    LifeTask(
      id: 'de_move_6',
      title: 'KFZ-Ummeldung',
      description: 'Adresse im Fahrzeugschein ändern.',
      explanation: 'Wenn du in einen anderen Zulassungsbezirk ziehst, brauchst du ggf. neue Kennzeichen.',
      requiredDocs: ['Fahrzeugschein (Zulassungsbescheinigung I)', 'eVB-Nummer der Versicherung', 'TÜV-Bericht'],
      steps: [
        'Termin bei der Zulassungsstelle buchen',
        'Ggf. neue Schilder prägen lassen',
        'Unterlagen vorlegen'
      ],
      priority: TaskPriority.medium,
      eventType: LifeEventType.move,
      timeSaved: 60,
    ),
  ];

  // ── GERMANY: NEW JOB ───────────────────────────────────────────────────────
  static final List<LifeTask> _deJobTemplates = [
    LifeTask(
      id: 'de_job_1',
      title: 'Steuer-ID einreichen',
      description: 'Arbeitgeber benötigt deine Identifikationsnummer.',
      explanation: 'Zur korrekten Berechnung der Lohnsteuer (ELStAM).',
      requiredDocs: ['Schreiben vom Bundeszentralamt für Steuern'],
      steps: ['Steuer-ID in alten Lohnabrechnungen suchen', 'An HR-Abteilung senden'],
      priority: TaskPriority.urgent,
      eventType: LifeEventType.newJob,
      timeSaved: 30,
    ),
    LifeTask(
      id: 'de_job_2',
      title: 'Sozialversicherungsausweis vorlegen',
      description: 'Nachweis der Rentenversicherungsnummer.',
      explanation: 'Dein Arbeitgeber meldet dich damit bei der Sozialversicherung an.',
      requiredDocs: ['Sozialversicherungsausweis'],
      steps: ['Kopie des Ausweises erstellen', 'Bei Einstellung abgeben'],
      priority: TaskPriority.high,
      eventType: LifeEventType.newJob,
      timeSaved: 20,
    ),
    LifeTask(
      id: 'de_job_3',
      title: 'Krankenkasse informieren',
      description: 'Mitgliedsbescheinigung für den Arbeitgeber anfordern.',
      explanation: 'Der Arbeitgeber muss wissen, wo du versichert bist.',
      requiredDocs: ['Versichertenkarte'],
      steps: ['Krankenkasse online oder per App kontaktieren', 'Bescheinigung für neuen Job anfordern', 'Link/Datei an HR weiterleiten'],
      priority: TaskPriority.high,
      eventType: LifeEventType.newJob,
      timeSaved: 25,
    ),
  ];

  // ── GERMANY: BUY CAR ───────────────────────────────────────────────────────
  static final List<LifeTask> _deCarTemplates = [
    LifeTask(
      id: 'de_car_1',
      title: 'KFZ-Versicherung (eVB)',
      description: 'Elektronische Versicherungsbestätigung anfordern.',
      explanation: 'Noch vor der Zulassung muss Versicherungsschutz bestehen.',
      requiredDocs: ['Fahrzeugdaten'],
      steps: ['Tarife vergleichen', 'Versicherung abschließen', 'eVB-Code per SMS/Email erhalten'],
      priority: TaskPriority.urgent,
      eventType: LifeEventType.buyCar,
      timeSaved: 30,
    ),
    LifeTask(
      id: 'de_car_2',
      title: 'Fahrzeug zulassen',
      description: 'Gang zur Zulassungsstelle.',
      explanation: 'Hier erhältst du das Kennzeichen und die offiziellen Stempel.',
      requiredDocs: ['eVB-Nummer', 'Ausweis', 'Zulassungsbescheinigung Teil I & II', 'TÜV-Bericht', 'SEPA-Mandat für Kfz-Steuer'],
      steps: ['Online-Termin buchen', 'Kennzeichen reservieren', 'Zum Amt gehen'],
      priority: TaskPriority.high,
      eventType: LifeEventType.buyCar,
      timeSaved: 90,
    ),
  ];

  // ── GERMANY: TAX YEAR ──────────────────────────────────────────────────────
  static final List<LifeTask> _deTaxTemplates = [
    LifeTask(
      id: 'de_tax_1',
      title: 'Werbungskosten sammeln',
      description: 'Belege für berufliche Ausgaben ordnen.',
      explanation: 'Arbeitsmittel, Fortbildungen und Fahrtkosten mindern die Steuerlast.',
      requiredDocs: ['Quittungen', 'Invoices', 'Fahrtenbuch'],
      steps: ['Rechnungen chronologisch sortieren', 'Kilometerpauschale berechnen', 'Fortbildungskosten addieren'],
      priority: TaskPriority.medium,
      eventType: LifeEventType.taxYear,
      timeSaved: 30,
    ),
    LifeTask(
      id: 'de_tax_2',
      title: 'Lohnsteuerbescheinigung prüfen',
      description: 'Jahresabrechnung vom Arbeitgeber kontrollieren.',
      explanation: 'Wird am Ende des Jahres vom Arbeitgeber übermittelt.',
      requiredDocs: ['Lohnsteuerbescheinigung'],
      steps: ['Bruttolohn und einbehaltene Steuer prüfen', 'Daten in Steuer-Software übertragen'],
      priority: TaskPriority.high,
      eventType: LifeEventType.taxYear,
      timeSaved: 45,
    ),
  ];
}
