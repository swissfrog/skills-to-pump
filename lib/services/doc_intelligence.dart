import '../models/models.dart';

/// Simulates AI-powered document analysis (on-device rule engine).
/// In production: replace with real LLM API calls.
class DocIntelligence {
  // ── Step 1: Classify document type ────────────────────────────────────────
  static DocType classify(String text) {
    final t = text.toLowerCase();
    if (_has(t, ['rechnung', 'rechnungsnummer', 'betrag', 'zahlung', 'fällig', 'invoice', 'eur', 'umsatzsteuer'])) return DocType.invoice;
    if (_has(t, ['finanzamt', 'behörde', 'bescheid', 'widerspruch', 'amtsgericht', 'jobcenter', 'agentur für arbeit'])) return DocType.govLetter;
    if (_has(t, ['versicherung', 'police', 'versicherungsschein', 'schaden', 'prämie', 'haftpflicht'])) return DocType.insurance;
    if (_has(t, ['vertrag', 'vereinbarung', 'unterschrift', 'vertragspartner', 'laufzeit', 'kündigung'])) return DocType.contract;
    if (_has(t, ['termin', 'einladung', 'datum', 'uhrzeit', 'erscheinen', 'erscheinungspflicht'])) return DocType.appointment;
    if (_has(t, ['formular', 'antrag', 'bitte ausfüllen', 'antragsformular', 'ausfüllen'])) return DocType.form;
    return DocType.unknown;
  }

  // ── Step 2: Extract sender ─────────────────────────────────────────────────
  static String? extractSender(String text) {
    final lines = text.split('\n').where((l) => l.trim().isNotEmpty).toList();
    // Common senders in German letters
    final patterns = [
      RegExp(r'(Finanzamt\s+\w+)', caseSensitive: false),
      RegExp(r'(Krankenkasse\s+\w+)', caseSensitive: false),
      RegExp(r'(Stadtwerke\s+\w+)', caseSensitive: false),
      RegExp(r'(Hausverwaltung\s+\w+)', caseSensitive: false),
      RegExp(r'(Jobcenter\s+\w+)', caseSensitive: false),
      RegExp(r'(AOK|TK|Barmer|DAK)\s+\w*', caseSensitive: false),
      RegExp(r'(Telekom|Vodafone|O2|1&1|Congstar)', caseSensitive: false),
    ];
    for (final p in patterns) {
      final m = p.firstMatch(text);
      if (m != null) return m.group(0)!.trim();
    }
    // Fallback: first non-empty line that looks like a company name
    if (lines.isNotEmpty) return lines.first.trim().length > 3 ? lines.first.trim() : null;
    return null;
  }

  // ── Step 3: Extract dates & deadlines ─────────────────────────────────────
  static List<String> extractDates(String text) {
    final results = <String>[];
    // DD.MM.YYYY or DD.MM.YY
    final datePattern = RegExp(r'\b(\d{1,2}\.\d{1,2}\.\d{2,4})\b');
    for (final m in datePattern.allMatches(text)) {
      results.add(m.group(0)!);
    }
    return results;
  }

  // ── Step 4: Detect tasks ───────────────────────────────────────────────────
  static List<DocTask> detectTasks(String text, String docId) {
    final tasks = <DocTask>[];
    final t = text.toLowerCase();
    final dates = extractDates(text);
    final deadline = dates.isNotEmpty ? _parseDate(dates.first) : null;
    int idx = 0;

    if (_has(t, ['antworten', 'antwort', 'reply', 'stellungnahme', 'rückmeldung'])) {
      tasks.add(DocTask(
        id: '${docId}_t${idx++}', title: 'Brief beantworten',
        description: 'Auf dieses Schreiben muss geantwortet werden.',
        deadline: deadline, priority: TaskPriority.high, linkedDocId: docId,
      ));
    }
    if (_has(t, ['zahlen', 'zahlung', 'überweisen', 'betrag', 'rechnung', 'fällig'])) {
      tasks.add(DocTask(
        id: '${docId}_t${idx++}', title: 'Rechnung bezahlen',
        description: 'Eine Zahlung ist erforderlich.',
        deadline: deadline, priority: TaskPriority.high, linkedDocId: docId,
      ));
    }
    if (_has(t, ['formular', 'ausfüllen', 'antrag', 'beantragen'])) {
      tasks.add(DocTask(
        id: '${docId}_t${idx++}', title: 'Formular ausfüllen',
        description: 'Ein Formular muss ausgefüllt werden.',
        deadline: deadline, priority: TaskPriority.medium, linkedDocId: docId,
      ));
    }
    if (_has(t, ['termin', 'erscheinen', 'vorstellungspflicht', 'persönlich'])) {
      tasks.add(DocTask(
        id: '${docId}_t${idx++}', title: 'Termin wahrnehmen',
        description: 'Ein persönlicher Termin ist erforderlich.',
        deadline: deadline, priority: TaskPriority.high, linkedDocId: docId,
      ));
    }
    if (_has(t, ['unterschrift', 'unterschreiben', 'unterzeichnen'])) {
      tasks.add(DocTask(
        id: '${docId}_t${idx++}', title: 'Dokument unterschreiben',
        description: 'Dieses Dokument muss unterschrieben werden.',
        deadline: deadline, priority: TaskPriority.medium, linkedDocId: docId,
      ));
    }
    return tasks;
  }

  // ── Step 5: Generate AI summary (template-based) ──────────────────────────
  static String generateSummary(String text, DocType type) {
    final words = text.trim().split(RegExp(r'\s+')).length;
    final dates = extractDates(text);
    switch (type) {
      case DocType.invoice:
        return 'Dieses Dokument ist eine Rechnung${dates.isNotEmpty ? " mit Fälligkeitsdatum ${dates.first}" : ""}. '
            'Es enthält $words Wörter. Bitte prüfen Sie den Betrag und zahlen Sie rechtzeitig.';
      case DocType.govLetter:
        return 'Dies ist ein offizielles Schreiben einer Behörde. '
            '${dates.isNotEmpty ? "Es enthält ein Datum: ${dates.first}. " : ""}'
            'Bitte lesen Sie das Schreiben sorgfältig und handeln Sie ggf. innerhalb der genannten Frist.';
      case DocType.contract:
        return 'Dieses Dokument ist ein Vertrag. '
            'Bitte prüfen Sie alle Konditionen, Laufzeiten und Kündigungsfristen sorgfältig.';
      case DocType.insurance:
        return 'Dieses Versicherungsdokument enthält wichtige Informationen zu Ihrer Versicherungspolice.';
      case DocType.appointment:
        return 'Dieses Schreiben enthält einen Termin${dates.isNotEmpty ? " am ${dates.first}" : ""}. '
            'Bitte tragen Sie den Termin in Ihren Kalender ein.';
      case DocType.form:
        return 'Dieses Dokument enthält ein Formular, das ausgefüllt werden muss.';
      case DocType.unknown:
        return 'Das Dokument enthält $words Wörter${dates.isNotEmpty ? " und ein Datum (${dates.first})" : ""}. '
            'Bitte prüfen Sie den Inhalt manuell.';
    }
  }

  // ── Step 6: Simple language explanation ──────────────────────────────────
  static String generateExplanation(String text, DocType type) {
    switch (type) {
      case DocType.invoice:
        return '💡 Einfach erklärt:\n\nSie haben eine Rechnung erhalten. '
            'Das bedeutet: Jemand möchte Geld von Ihnen für eine Leistung oder ein Produkt. '
            'Bitte prüfen Sie, ob der Betrag korrekt ist. '
            'Wenn ja, überweisen Sie den Betrag bis zum angegebenen Datum.';
      case DocType.govLetter:
        return '💡 Einfach erklärt:\n\nSie haben Post von einer Behörde bekommen. '
            'Behördenpost klingt oft kompliziert, aber meistens geht es um eine dieser Dinge: '
            'Sie sollen etwas bezahlen, etwas ausfüllen, oder irgendwo erscheinen. '
            'Lesen Sie das Schreiben genau und beachten Sie alle genannten Fristen. '
            'Wenn Sie etwas nicht verstehen, fragen Sie nach.';
      case DocType.contract:
        return '💡 Einfach erklärt:\n\nSie haben einen Vertrag bekommen. '
            'Ein Vertrag ist eine schriftliche Vereinbarung zwischen zwei Parteien. '
            'Prüfen Sie: Laufzeit, Kosten, Kündigungsfrist und Ihre Pflichten.';
      case DocType.insurance:
        return '💡 Einfach erklärt:\n\nDieses Schreiben kommt von Ihrer Versicherung. '
            'Es könnte sich um Ihre Policedetails, eine Beitragsänderung oder einen Schadenfall handeln.';
      case DocType.appointment:
        return '💡 Einfach erklärt:\n\nSie haben einen Termin bekommen. '
            'Tragen Sie das Datum in Ihren Kalender ein und erscheinen Sie pünktlich. '
            'Falls Sie nicht können, sagen Sie rechtzeitig ab.';
      case DocType.form:
        return '💡 Einfach erklärt:\n\nSie müssen ein Formular ausfüllen. '
            'Füllen Sie alle Felder sorgfältig aus, unterschreiben Sie wo nötig, '
            'und senden Sie es bis zur Frist zurück.';
      default:
        return '💡 Einfach erklärt:\n\nDieses Dokument sollte sorgfältig gelesen werden. '
            'Achten Sie auf Fristen, Beträge und erforderliche Aktionen.';
    }
  }

  // ── Step 7: Generate reply draft ──────────────────────────────────────────
  static String generateReplyDraft(String text, DocType type, String? sender) {
    final from = sender ?? 'Absender';
    final date = _today();
    return '''$date

An: $from

Betreff: Antwort auf Ihr Schreiben

Sehr geehrte Damen und Herren,

vielen Dank für Ihr Schreiben${type == DocType.invoice ? ' (Rechnung)' : ''}.

${_replyBody(type)}

Mit freundlichen Grüßen

[Ihr Name]
[Ihre Adresse]
[Ihre Telefonnummer]''';
  }

  static String _replyBody(DocType type) {
    switch (type) {
      case DocType.invoice:
        return 'Ich bestätige den Erhalt Ihrer Rechnung. Der Betrag wird fristgerecht überwiesen.';
      case DocType.govLetter:
        return 'Ich nehme Ihren Bescheid zur Kenntnis und komme meinen Verpflichtungen fristgerecht nach. '
            'Bei Rückfragen stehe ich gerne zur Verfügung.';
      case DocType.contract:
        return 'Bezüglich des genannten Vertrags möchte ich Ihnen mitteilen, dass ich die Unterlagen geprüft habe.';
      case DocType.form:
        return 'Anbei übersende ich Ihnen das ausgefüllte Formular mit allen erforderlichen Angaben.';
      default:
        return 'Ich habe Ihr Schreiben erhalten und werde mich um die angesprochenen Punkte kümmern.';
    }
  }

  // ── Detect category ───────────────────────────────────────────────────────
  static DocCategory detectCategory(DocType type) {
    switch (type) {
      case DocType.invoice: return DocCategory.bills;
      case DocType.govLetter: return DocCategory.government;
      case DocType.insurance: return DocCategory.insurance;
      case DocType.contract: return DocCategory.contracts;
      case DocType.appointment: return DocCategory.appointments;
      default: return DocCategory.other;
    }
  }

  // ── Run full pipeline ─────────────────────────────────────────────────────
  static ScannedDocument analyze(ScannedDocument doc) {
    final text = doc.ocrText ?? '';
    if (text.isEmpty) return doc;

    final type = classify(text);
    final category = detectCategory(type);
    final sender = extractSender(text);
    final tasks = detectTasks(text, doc.id);
    final summary = generateSummary(text, type);
    final explanation = generateExplanation(text, type);
    final reply = generateReplyDraft(text, type, sender);
    final hasForm = type == DocType.form || text.toLowerCase().contains('formular');

    final now = DateTime.now();
    final timeline = [
      TimelineEvent(id: '${doc.id}_t0', title: 'Dokument empfangen', date: doc.scannedAt),
      TimelineEvent(id: '${doc.id}_t1', title: 'OCR abgeschlossen', note: '${text.split(' ').length} Wörter erkannt', date: now),
      TimelineEvent(id: '${doc.id}_t2', title: 'KI-Analyse abgeschlossen', note: type.label, date: now),
      if (tasks.isNotEmpty) TimelineEvent(id: '${doc.id}_t3', title: '${tasks.length} Aufgabe(n) erkannt', date: now),
    ];

    return doc.copyWith(
      docType: type, category: category, sender: sender,
      tasks: tasks, aiSummary: summary, aiExplanation: explanation,
      replyDraft: reply, timeline: timeline, hasForm: hasForm,
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  static bool _has(String text, List<String> keywords) =>
      keywords.any((k) => text.contains(k));

  static DateTime? _parseDate(String s) {
    try {
      final parts = s.split('.');
      if (parts.length >= 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        var year = int.parse(parts[2]);
        if (year < 100) year += 2000;
        return DateTime(year, month, day);
      }
    } catch (_) {}
    return null;
  }

  static String _today() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}';
  }
}
