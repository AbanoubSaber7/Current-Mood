import 'package:flutter/material.dart';

import 'package:mood_app/models/mood_history_entry.dart';
import 'package:mood_app/services/mood_history_service.dart';
import 'package:mood_app/widgets/background_widget.dart';

class MoodHistoryScreen extends StatefulWidget {
  final String userName;
  const MoodHistoryScreen({super.key, required this.userName});

  @override
  State<MoodHistoryScreen> createState() => _MoodHistoryScreenState();
}

class _MoodHistoryScreenState extends State<MoodHistoryScreen> {
  final _service = MoodHistoryService();
  List<MoodHistoryEntry> _entries = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entries = await _service.load();
    if (!mounted) return;
    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  Future<void> _clear() async {
    await _service.clear();
    await _load();
  }

  String _formatTs(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}-${two(dt.month)}-${two(dt.day)}  ${two(dt.hour)}:${two(dt.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final emotionForBg = _entries.isNotEmpty ? _entries.first.emotion : 'Neutral';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood History', style: TextStyle(fontSize: 18)),
        backgroundColor: const Color(0xFFC04F4C),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Clear',
            onPressed: _entries.isEmpty ? null : _clear,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: BackgroundWidget(
        emotion: emotionForBg,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _entries.isEmpty
                  ? Center(
                      child: Text(
                        'No history yet, ${widget.userName}.',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _entries.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final e = _entries[i];
                        final conf = e.confidencePercent;
                        final confText = conf == null ? '—' : '${conf.toStringAsFixed(1)}%';
                        final subtitle = [
                          _formatTs(e.timestamp),
                          'Source: ${e.source}',
                          'Confidence: $confText',
                          if (e.predictedEmotion != null && e.predictedEmotion != e.emotion)
                            'Predicted: ${e.predictedEmotion}',
                        ].join(' • ');

                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.92),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 6)),
                            ],
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFFC04F4C).withOpacity(0.12),
                              child: Text(
                                e.emotion.isNotEmpty ? e.emotion[0].toUpperCase() : '?',
                                style: const TextStyle(color: Color(0xFFC04F4C), fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(
                              e.emotion,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4E342E)),
                            ),
                            subtitle: Text(
                              subtitle,
                              style: const TextStyle(fontSize: 12, color: Colors.black54),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }
}

