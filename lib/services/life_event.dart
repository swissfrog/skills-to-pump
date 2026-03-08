import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/life_models.dart';
import '../theme/app_theme.dart';

// ──────────────────────────────────────────────────────────
// Sample data
// ──────────────────────────────────────────────────────────
List<LifeEvent> _buildSampleEvents() {
  final now = DateTime.now();
  return [
    LifeEvent(
      id: 'move',
      title: 'Umzug',
      description: 'Alles rund um deinen neuen Wohnsitz',
      icon: Icons.moving_rounded,
      color: AppTheme.primary,
      startedAt: now.subtract(const Duration(days: 3)),
      tasks: [
        const LifeTask(
          id: 'move_1',
          title: 'Wohnsitz anmelden',
          description:
              'Du hast 14 Tage nach Einzug Zeit, dich beim zuständigen Einwohnermeldeamt anzumelden.',
          estimatedMinutes: 60,
          docs: [
            RequiredDoc(id: 'd1', name: 'Personalausweis', available: true),
            RequiredDoc(id: 'd2', name: 'Wohnungsgeberbestätigung', available: false),
            RequiredDoc(id: 'd3', name: 'Anmeldeformular', available: false),
          ],
          steps: [
            TaskStep(number: 1, text: 'Wohnungsgeberbestätigung vom Vermieter anfordern'),
            TaskStep(number: 2, text: 'Termin beim Einwohnermeldeamt buchen (online möglich)'),
            TaskStep(number: 3, text: 'Personalausweis & Bestätigung mitbringen'),
            TaskStep(number: 4, text: 'Neue Adresse bestätigen lassen'),
          ],
          completed: true,
        ),
        const LifeTask(
          id: 'move_2',
          title: 'Internetvertrag ummelden',
          description:
              'Kündige deinen alten Vertrag oder lass ihn umziehen. Viele Anbieter bieten einen Umzugsservice an.',
          estimatedMinutes: 20,
          docs: [
            RequiredDoc(id: 'd4', name: 'Kundennummer', available: true),
            RequiredDoc(id: 'd5', name: 'Neue Adresse', available: true),
          ],
          steps: [
            TaskStep(number: 1, text: 'Anbieter kontaktieren (Website / Hotline)'),
            TaskStep(number: 2, text: 'Umzugstermin & neue Adresse mitteilen'),
            TaskStep(number: 3, text: 'Bestätigung abwarten'),
          ],
          completed: false,
        ),
        const LifeTask(
          id: 'move_3',
          title: 'Stromanbieter informieren',
          description:
              'Zählerstände ablesen und Anbieter über Umzug informieren.',
          estimatedMinutes: 15,
          docs: [
            RequiredDoc(id: 'd6', name: 'Zählerstand alt', available: false),
            RequiredDoc(id: 'd7', name: 'Zählerstand neu', available: false),
          ],
          steps: [
            TaskStep(number: 1, text: 'Zählerstand in alter & neuer Wohnung fotografieren'),
            TaskStep(number: 2, text: 'Anbieter online oder per Telefon informieren'),
            TaskStep(number: 3, text: 'Bei Bedarf neuen Vertrag abschließen'),
          ],
          completed: false,
        ),
        const LifeTask(
          id: 'move_4',
          title: 'KFZ-Adresse ändern',
          description:
              'Fahrzeugschein und Versicherung müssen auf neue Adresse aktualisiert werden.',
          estimatedMinutes: 30,
          docs: [
            RequiredDoc(id: 'd8', name: 'Fahrzeugschein', available: true),
            RequiredDoc(id: 'd9', name: 'Personalausweis', available: true),
            RequiredDoc(id: 'd10', name: 'Neue Meldeadresse', available: false),
          ],
          steps: [
            TaskStep(number: 1, text: 'Zulassungsstelle aufsuchen (Termin empfohlen)'),
            TaskStep(number: 2, text: 'КFZ-Versicherung informieren'),
            TaskStep(number: 3, text: 'Neue Adresse im Fahrzeugschein eintragen lassen'),
          ],
          completed: false,
        ),
      ],
    ),
    LifeEvent(
      id: 'job',
      title: 'Neuer Job',
      description: 'Dokumente und Schritte für deinen Start',
      icon: Icons.work_rounded,
      color: AppTheme.secondary,
      startedAt: now.subtract(const Duration(days: 7)),
      tasks: [
        const LifeTask(
          id: 'job_1',
          title: 'Arbeitsvertrag prüfen & unterschreiben',
          description:
              'Lies den Vertrag sorgfältig. Achte auf Arbeitszeit, Urlaub, Probezeit und Kündigungsfristen.',
          estimatedMinutes: 45,
          docs: [
            RequiredDoc(id: 'j1', name: 'Arbeitsvertrag (2-fach)', available: true),
            RequiredDoc(id: 'j2', name: 'Personalausweis', available: true),
          ],
          steps: [
            TaskStep(number: 1, text: 'Vertrag vollständig lesen'),
            TaskStep(number: 2, text: 'Unklarheiten mit HR klären'),
            TaskStep(number: 3, text: 'Beide Exemplare unterschreiben'),
            TaskStep(number: 4, text: 'Eigenes Exemplar sicher aufbewahren'),
          ],
          completed: true,
        ),
        const LifeTask(
          id: 'job_2',
          title: 'Lohnsteuerunterlagen einreichen',
          description:
              'Der Arbeitgeber benötigt deine Steuer-ID und Sozialversicherungsnummer.',
          estimatedMinutes: 20,
          docs: [
            RequiredDoc(id: 'j3', name: 'Steueridentifikationsnummer', available: true),
            RequiredDoc(id: 'j4', name: 'Sozialversicherungsausweis', available: false),
            RequiredDoc(id: 'j5', name: 'Krankenkassenbescheinigung', available: false),
          ],
          steps: [
            TaskStep(number: 1, text: 'Steuer-ID aus alten Unterlagen oder Finanzamt'),
            TaskStep(number: 2, text: 'SV-Ausweis bei Krankenkasse anfragen'),
            TaskStep(number: 3, text: 'Unterlagen an HR weiterleiten'),
          ],
          completed: false,
        ),
        const LifeTask(
          id: 'job_3',
          title: 'Betriebliche Altersvorsorge einrichten',
          description:
              'Viele Arbeitgeber bieten einen Zuschuss zur betrieblichen Altersvorsorge.',
          estimatedMinutes: 30,
          docs: [
            RequiredDoc(id: 'j6', name: 'IBAN', available: true),
          ],
          steps: [
            TaskStep(number: 1, text: 'HR nach bAV-Optionen fragen'),
            TaskStep(number: 2, text: 'Angebote vergleichen'),
            TaskStep(number: 3, text: 'Formular ausfüllen und einreichen'),
          ],
          completed: false,
        ),
      ],
    ),
    LifeEvent(
      id: 'car',
      title: 'Auto kaufen',
      description: 'Von der Suche bis zur Zulassung',
      icon: Icons.directions_car_rounded,
      color: AppTheme.amber,
      startedAt: now.subtract(const Duration(days: 1)),
      tasks: [
        const LifeTask(
          id: 'car_1',
          title: 'Kaufvertrag prüfen & abschließen',
          description:
              'Lass dir alle Fahrzeugdokumente zeigen und unterschreibe erst nach vollständiger Prüfung.',
          estimatedMinutes: 60,
          docs: [
            RequiredDoc(id: 'c1', name: 'Personalausweis', available: true),
            RequiredDoc(id: 'c2', name: 'Fahrzeugbrief (ZB II)', available: false),
            RequiredDoc(id: 'c3', name: 'HU-Bericht', available: false),
          ],
          steps: [
            TaskStep(number: 1, text: 'Fahrzeugbrief auf Übereinstimmung prüfen'),
            TaskStep(number: 2, text: 'HU-Datum und km-Stand notieren'),
            TaskStep(number: 3, text: 'Kaufvertrag in doppelter Ausfertigung unterschreiben'),
          ],
          completed: false,
        ),
        const LifeTask(
          id: 'car_2',
          title: 'Kfz-Versicherung abschließen',
          description:
              'Ohne gültige Versicherung keine Zulassung. Vergleiche Angebote vorab.',
          estimatedMinutes: 30,
          docs: [
            RequiredDoc(id: 'c4', name: 'Fahrzeugidentifikationsnummer (FIN)', available: false),
            RequiredDoc(id: 'c5', name: 'Führerschein', available: true),
          ],
          steps: [
            TaskStep(number: 1, text: 'Vergleichsportale nutzen (Check24, Verivox)'),
            TaskStep(number: 2, text: 'eVB-Nummer nach Abschluss notieren'),
          ],
          completed: false,
        ),
        const LifeTask(
          id: 'car_3',
          title: 'Fahrzeug zulassen',
          description:
              'Zum Straßenverkehrsamt mit allen Dokumenten.',
          estimatedMinutes: 90,
          docs: [
            RequiredDoc(id: 'c6', name: 'Personalausweis', available: true),
            RequiredDoc(id: 'c7', name: 'eVB-Nummer', available: false),
            RequiredDoc(id: 'c8', name: 'Fahrzeugbrief (ZB II)', available: false),
            RequiredDoc(id: 'c9', name: 'SEPA-Mandat (KFZ-Steuer)', available: false),
          ],
          steps: [
            TaskStep(number: 1, text: 'Termin beim Straßenverkehrsamt buchen'),
            TaskStep(number: 2, text: 'Alle Dokumente zusammenstellen'),
            TaskStep(number: 3, text: 'Wunschkennzeichen vorab online reservieren'),
            TaskStep(number: 4, text: 'Zulassungsgebühr (~30€) bezahlen'),
          ],
          completed: false,
        ),
      ],
    ),
    LifeEvent(
      id: 'tax',
      title: 'Steuererklärung',
      description: 'Jährliche Abgabe optimieren',
      icon: Icons.receipt_long_rounded,
      color: AppTheme.green,
      startedAt: now.subtract(const Duration(days: 14)),
      tasks: [
        const LifeTask(
          id: 'tax_1',
          title: 'Belege sammeln',
          description:
              'Sammle alle relevanten Belege: Lohnsteuerbescheinigung, Sonderausgaben, Werbungskosten.',
          estimatedMinutes: 40,
          docs: [
            RequiredDoc(id: 't1', name: 'Lohnsteuerbescheinigung', available: true),
            RequiredDoc(id: 't2', name: 'Kontoauszüge', available: true),
            RequiredDoc(id: 't3', name: 'Spendenquittungen', available: false),
            RequiredDoc(id: 't4', name: 'Handwerkerrechnungen', available: false),
          ],
          steps: [
            TaskStep(number: 1, text: 'Lohnsteuerbescheinigung vom Arbeitgeber'),
            TaskStep(number: 2, text: 'Sonderausgaben zusammensuchen (Versicherungen, Spenden)'),
            TaskStep(number: 3, text: 'Werbungskosten dokumentieren (Fahrten, Arbeitsmaterial)'),
          ],
          completed: true,
        ),
        const LifeTask(
          id: 'tax_2',
          title: 'Steuererklärung ausfüllen',
          description:
              'Nutze ELSTER (kostenlos) oder eine Steuer-App. Frist: 31. Juli des Folgejahres.',
          estimatedMinutes: 120,
          docs: [
            RequiredDoc(id: 't5', name: 'Steuer-ID', available: true),
            RequiredDoc(id: 't6', name: 'IBAN', available: true),
          ],
          steps: [
            TaskStep(number: 1, text: 'ELSTER-Konto anlegen (einmalig)'),
            TaskStep(number: 2, text: 'Formulare ausfüllen (Mantelbogen, Anlage N)'),
            TaskStep(number: 3, text: 'Plausibilität prüfen'),
            TaskStep(number: 4, text: 'Elektronisch einreichen'),
          ],
          completed: false,
        ),
      ],
    ),
  ];
}

// ──────────────────────────────────────────────────────────
// Notifier
// ──────────────────────────────────────────────────────────
class LifeEventsNotifier extends StateNotifier<List<LifeEvent>> {
  LifeEventsNotifier() : super(_buildSampleEvents());

  // ── Complete a task ──────────────────────────────────
  void completeTask(String eventId, String taskId) {
    state = [
      for (final ev in state)
        if (ev.id == eventId)
          ev.withTasks([
            for (final t in ev.tasks)
              if (t.id == taskId) t.markDone() else t,
          ])
        else
          ev,
    ];
  }

  // ── Toggle a document ────────────────────────────────
  void toggleDoc(String eventId, String taskId, int docIdx) {
    state = [
      for (final ev in state)
        if (ev.id == eventId)
          ev.withTasks([
            for (final t in ev.tasks)
              if (t.id == taskId)
                t.withDoc(docIdx, t.docs[docIdx].toggle())
              else
                t,
          ])
        else
          ev,
    ];
  }

  // ── Add a new event ──────────────────────────────────
  void addEvent(LifeEvent event) {
    state = [event, ...state];
  }
}

// ──────────────────────────────────────────────────────────
// Providers
// ──────────────────────────────────────────────────────────
final lifeEventsProvider =
    StateNotifierProvider<LifeEventsNotifier, List<LifeEvent>>(
  (_) => LifeEventsNotifier(),
);

// Computed: next most important task across ALL events
final nextImportantStepProvider =
    Provider<({LifeEvent event, LifeTask task})?>(
  (ref) {
    final events = ref.watch(lifeEventsProvider);
    for (final ev in events) {
      if (ev.isCompleted) continue;
      final task = ev.nextTask;
      if (task != null) return (event: ev, task: task);
    }
    return null;
  },
);

// Computed: global stats
final globalStatsProvider =
    Provider<({int done, int total, int minutesSaved})>(
  (ref) {
    final events = ref.watch(lifeEventsProvider);
    int done = 0;
    int total = 0;
    for (final ev in events) {
      done += ev.doneCount;
      total += ev.totalCount;
    }
    return (done: done, total: total, minutesSaved: done * 18);
  },
);
