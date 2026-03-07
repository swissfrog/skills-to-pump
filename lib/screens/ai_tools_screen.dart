import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_widgets.dart';

class AiToolsScreen extends StatefulWidget {
  const AiToolsScreen({super.key});
  @override
  State<AiToolsScreen> createState() => _AiToolsScreenState();
}

class _AiToolsScreenState extends State<AiToolsScreen> {
  final _controller = TextEditingController();
  bool _loading = false;
  String? _result;

  final List<Map<String, dynamic>> _tools = [
    {'icon': Icons.translate_outlined,     'title': 'Erklären',       'subtitle': 'Einfach erklärt', 'color': const Color(0xFF7C3AED)},
    {'icon': Icons.summarize_outlined,     'title': 'Zusammenfassen', 'subtitle': 'Kurz & klar',    'color': const Color(0xFF0284C7)},
    {'icon': Icons.task_alt_outlined,      'title': 'Aufgaben',       'subtitle': 'Was tun?',        'color': const Color(0xFFEA580C)},
    {'icon': Icons.reply_outlined,         'title': 'Antwort',        'subtitle': 'Brief erstellen', 'color': const Color(0xFF059669)},
    {'icon': Icons.checklist_outlined,     'title': 'Formular',       'subtitle': 'Ausfüllen',       'color': const Color(0xFFDB2777)},
    {'icon': Icons.lightbulb_outline,      'title': 'Nächste Schritte','subtitle': 'Was als nächstes', 'color': const Color(0xFFF59E0B)},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.bgTop, AppTheme.bgMid, AppTheme.bgBottom],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tool grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.6,
                        ),
                        itemCount: _tools.length,
                        itemBuilder: (_, i) => _ToolChip(tool: _tools[i], onTap: () => _runTool(_tools[i]['title'] as String)),
                      ),
                      const SizedBox(height: 20),
                      // Chat input
                      _buildChatInput(),
                      const SizedBox(height: 12),
                      // Result
                      if (_loading) const Center(child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(color: LP.purple),
                      )),
                      if (_result != null) _buildResult(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _runTool(String tool) {
    setState(() { _loading = true; _result = null; });
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _result = 'KI-Ergebnis für „$tool":\n\nDies ist ein Platzhalter für die KI-Analyse. '
            'In der echten App wird hier das Dokument analysiert und eine hilfreiche '
            'Antwort generiert. Die KI erkennt Fristen, Aufgaben und erstellt Antwortbriefe.';
      });
    });
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
      child: Row(
        children: [
          GestureDetector(onTap: () => Navigator.pop(context),
            child: const GlassIconBtn(icon: Icons.arrow_back_ios_new_rounded)),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('KI-Tools', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
              Text('Powered by AI', style: TextStyle(color: LP.label3, fontSize: 11)),
            ],
          ),
          const Spacer(),
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(
              color: AppTheme.green, shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: AppTheme.green.withValues(alpha: 0.6), blurRadius: 8)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatInput() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  maxLines: 3,
                  minLines: 1,
                  decoration: const InputDecoration(
                    hintText: 'Frage zur KI stellen oder Dokument beschreiben…',
                    hintStyle: TextStyle(color: LP.label3, fontSize: 13),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _runTool(_controller.text.isEmpty ? 'Analyse' : _controller.text),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: LP.purple,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: LP.purple.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResult() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [LP.purple.withValues(alpha: 0.25), AppTheme.blue.withValues(alpha: 0.15)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: LP.purple.withValues(alpha: 0.35), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.auto_awesome, color: LP.purple, size: 16),
                const SizedBox(width: 6),
                const Text('KI Antwort', style: TextStyle(color: LP.purple, fontSize: 12, fontWeight: FontWeight.w700)),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() => _result = null),
                  child: const Icon(Icons.close, color: LP.label3, size: 16),
                ),
              ]),
              const SizedBox(height: 10),
              Text(_result!, style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.5)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolChip extends StatelessWidget {
  final Map<String, dynamic> tool;
  final VoidCallback onTap;
  const _ToolChip({required this.tool, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = tool['color'] as Color;
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
            ),
            child: Row(
              children: [
                Icon(tool['icon'] as IconData, color: color, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(tool['title'] as String,
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                      Text(tool['subtitle'] as String,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
