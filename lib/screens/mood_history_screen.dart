import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

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
  static const List<String> _emotionOrder = [
    'Neutral',
    'Happy',
    'Surprise',
    'Sad',
    'Angry',
    'Disgust',
    'Fear',
    'Contempt',
  ];

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

  List<BarChartGroupData> _buildMoodCountBars() {
    final counts = <String, int>{
      for (final e in _emotionOrder) e: 0,
    };
    for (final entry in _entries) {
      final key = entry.emotion;
      counts[key] = (counts[key] ?? 0) + 1;
    }

    return List.generate(_emotionOrder.length, (i) {
      final emotion = _emotionOrder[i];
      final value = (counts[emotion] ?? 0).toDouble();
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: value,
            width: 14,
            borderRadius: BorderRadius.circular(6),
            color: const Color(0xFFC04F4C),
          ),
        ],
      );
    });
  }

  Widget _buildChartCard() {
    final maxCount = _entries.isEmpty ? 1 : _entries.length;
    final barGroups = _buildMoodCountBars();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mood distribution (last 20)',
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4E342E)),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 190,
            child: BarChart(
              BarChartData(
                maxY: (maxCount.toDouble()).clamp(1, 20),
                minY: 0,
                alignment: BarChartAlignment.spaceAround,
                gridData: FlGridData(show: true, drawVerticalLine: false),
                borderData: FlBorderData(show: false),
                barGroups: barGroups,
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value % 1 != 0) return const SizedBox.shrink();
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 10, color: Colors.black54),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 38,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= _emotionOrder.length) return const SizedBox.shrink();
                        final label = _emotionOrder[i];
                        final short = label.length <= 3 ? label : label.substring(0, 3);
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Transform.rotate(
                            angle: -0.6,
                            child: Text(short, style: const TextStyle(fontSize: 10, color: Colors.black54)),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Total entries: ${_entries.length}',
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
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
                      itemCount: _entries.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        if (i == 0) return _buildChartCard();

                        final e = _entries[i - 1];
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

