
import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/tag.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final DatabaseHelper _database = DatabaseHelper.instance;

  int _totalEntries = 0;
  int _writingStreak = 0;
  Map<String, int> _moodStatistics = {};
  Map<String, int> _monthlyStatistics = {};
  List<Tag> _popularTags = [];

  bool _isLoading = true;

  static const Map<String, String> _moodEmojis = {
    'Happy': '😊',
    'Excited': '🤩',
    'Calm': '😌',
    'Neutral': '😐',
    'Sad': '😔',
    'Angry': '😡',
  };

  static const Map<String, Color> _moodColors = {
    'Happy': Color(0xFFFFC857),
    'Excited': Color(0xFFFF9F68),
    'Calm': Color(0xFF78BFA0),
    'Neutral': Color(0xFF9EAAA2),
    'Sad': Color(0xFF82A9D6),
    'Angry': Color(0xFFE57D7D),
  };

  @override
  void initState() {
  super.initState();
  _loadStatistics();
  _loadWordCount();
  }

  Future<void> _loadStatistics() async {
    try {
      final results = await Future.wait([
        _database.getTotalEntries(),
        _database.getMoodStatistics(),
        _database.getMonthlyStatistics(),
        _database.getMostUsedTags(),
        _database.getWritingStreak(),
      ]);

      if (!mounted) return;

      setState(() {
        _totalEntries = results[0] as int;
        _moodStatistics = results[1] as Map<String, int>;
        _monthlyStatistics = results[2] as Map<String, int>;
        _popularTags = results[3] as List<Tag>;
        _writingStreak = results[4] as int;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load statistics: $error')),
      );
    }
  }

  int get _totalWords {
    // Word counts are stored in journal_entries.
    // The total is loaded directly from all journal entries below.
    return _cachedTotalWords;
  }

  int _cachedTotalWords = 0;

  Future<void> _loadWordCount() async {
    final entries = await _database.getEntries();
    if (!mounted) return;

    setState(() {
      _cachedTotalWords = entries.fold<int>(
        0,
        (sum, entry) => sum + entry.wordCount,
      );
    });
  }

  String _formatMonth(String key) {
    final parts = key.split('-');
    if (parts.length != 2) return key;

    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final month = int.tryParse(parts[1]);
    final year = parts[0];

    if (month == null || month < 1 || month > 12) {
      return key;
    }

    return '${months[month - 1]} $year';
  }

  Color _tagColor(Tag tag) {
    try {
      final hex = tag.color.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return const Color(0xFF78BFA0);
    }
  }

  Widget _buildOverviewCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8ECE7)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 25),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF89948C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF26382E),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF89948C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Color(0xFF26382E),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF89948C),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMoodStatistics() {
    if (_moodStatistics.isEmpty) {
      return _buildEmptyMessage('No mood data available yet.');
    }

    final maxValue = _moodStatistics.values.reduce(
      (a, b) => a > b ? a : b,
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        children: _moodStatistics.entries.map((item) {
          final color = _moodColors[item.key] ??
              const Color(0xFF9EAAA2);
          final emoji = _moodEmojis[item.key] ?? '🙂';
          final percentage = _totalEntries == 0
              ? 0.0
              : item.value / _totalEntries;

          return Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 21)),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        item.key,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF365B45),
                        ),
                      ),
                    ),
                    Text(
                      '${item.value} (${(percentage * 100).round()}%)',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF89948C),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: maxValue == 0 ? 0 : item.value / maxValue,
                    minHeight: 9,
                    backgroundColor: const Color(0xFFEFF2EE),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPopularTags() {
    if (_popularTags.isEmpty ||
        _popularTags.every((tag) => tag.usageCount == 0)) {
      return _buildEmptyMessage('No tags have been used yet.');
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        children: _popularTags
            .where((tag) => tag.usageCount > 0)
            .toList()
            .asMap()
            .entries
            .map((item) {
          final tag = item.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: _tagColor(tag).withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.label_outline,
                    color: _tagColor(tag),
                    size: 19,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tag.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF365B45),
                    ),
                  ),
                ),
                Text(
                  '${tag.usageCount} uses',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF89948C),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMonthlyStatistics() {
    if (_monthlyStatistics.isEmpty) {
      return _buildEmptyMessage('No monthly data available yet.');
    }

    final entries = _monthlyStatistics.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    final visibleEntries = entries.take(6).toList();

    final maxValue = visibleEntries
        .map((item) => item.value)
        .reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        children: visibleEntries.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    _formatMonth(item.key),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF567C68),
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: maxValue == 0
                          ? 0
                          : item.value / maxValue,
                      minHeight: 9,
                      backgroundColor: const Color(0xFFEFF2EE),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF78BFA0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 25,
                  child: Text(
                    '${item.value}',
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF365B45),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyMessage(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Color(0xFF89948C)),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE8ECE7)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F6),
      appBar: AppBar(
        title: const Text(
          'Statistics',
          style: TextStyle(
            color: Color(0xFF26382E),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFF7F9F6),
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Color(0xFF567C68),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh statistics',
            onPressed: () async {
              await _loadStatistics();
              await _loadWordCount();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await _loadStatistics();
                await _loadWordCount();
              },
              color: const Color(0xFF567C68),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
                children: [
                  const Text(
                    'Your writing journey',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF89948C),
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'A look at your memories',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF26382E),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildOverviewCard(
                    title: 'Total entries',
                    value: '$_totalEntries',
                    subtitle: 'Memories saved',
                    icon: Icons.menu_book,
                    color: const Color(0xFF78BFA0),
                  ),
                  const SizedBox(height: 12),
                  _buildOverviewCard(
                    title: 'Writing streak',
                    value: '$_writingStreak days',
                    subtitle: 'Consecutive days',
                    icon: Icons.local_fire_department,
                    color: const Color(0xFFFF9F68),
                  ),
                  const SizedBox(height: 12),
                  _buildOverviewCard(
                    title: 'Words written',
                    value: '$_totalWords',
                    subtitle: 'Words across all entries',
                    icon: Icons.edit_note,
                    color: const Color(0xFF82A9D6),
                  ),
                  const SizedBox(height: 28),
                  _buildSectionTitle(
                    'Mood distribution',
                    subtitle: 'How you have been feeling',
                  ),
                  _buildMoodStatistics(),
                  const SizedBox(height: 28),
                  _buildSectionTitle(
                    'Most popular tags',
                    subtitle: 'Your frequently used categories',
                  ),
                  _buildPopularTags(),
                  const SizedBox(height: 28),
                  _buildSectionTitle(
                    'Monthly activity',
                    subtitle: 'Number of entries per month',
                  ),
                  _buildMonthlyStatistics(),
                ],
              ),
            ),
    );
  }
}
