
import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/journal_entry.dart';
import '../widgets/journal_entry_card.dart';
import 'entry_form_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final DatabaseHelper _database = DatabaseHelper.instance;

  List<JournalEntry> _entries = [];
  bool _isLoading = true;

  DateTime _focusedMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  static const List<String> _weekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  static const List<String> _months = [
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

  static const Map<String, Color> _moodColors = {
    'Happy': Color(0xFFFFC857),
    'Excited': Color(0xFFFF8A65),
    'Calm': Color(0xFF80CBC4),
    'Neutral': Color(0xFF90A4AE),
    'Sad': Color(0xFF64B5F6),
    'Angry': Color(0xFFE57373),
  };

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    try {
      final entries = await _database.getEntries();

      if (!mounted) return;

      setState(() {
        _entries = entries;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load calendar entries: $error')),
      );
    }
  }

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  List<JournalEntry> _entriesForDate(DateTime date) {
    return _entries.where((entry) {
      return _isSameDay(entry.createdAt, date);
    }).toList();
  }

  Color _colorForMood(String mood) {
    return _moodColors[mood] ?? Colors.grey;
  }

  void _changeMonth(int offset) {
    setState(() {
      _focusedMonth = DateTime(
        _focusedMonth.year,
        _focusedMonth.month + offset,
      );

      _selectedDate = DateTime(
        _focusedMonth.year,
        _focusedMonth.month,
        1,
      );
    });
  }

  Future<void> _openEntryForm({JournalEntry? entry}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EntryFormScreen(entry: entry),
      ),
    );

    if (result == true) {
      await _loadEntries();
    }
  }

  Future<void> _toggleFavorite(JournalEntry entry) async {
    await _database.updateEntry(
      entry.copyWith(isFavorite: !entry.isFavorite),
    );

    await _loadEntries();
  }

  Future<void> _deleteEntry(JournalEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete entry?'),
        content: const Text(
          'Are you sure you want to delete this journal entry?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && entry.id != null) {
      await _database.deleteEntry(entry.id!);
      await _loadEntries();
    }
  }

  Widget _buildMonthHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => _changeMonth(-1),
          icon: const Icon(Icons.chevron_left),
          color: const Color(0xFF567C68),
        ),
        Text(
          '${_months[_focusedMonth.month - 1]} ${_focusedMonth.year}',
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: Color(0xFF26382E),
          ),
        ),
        IconButton(
          onPressed: () => _changeMonth(1),
          icon: const Icon(Icons.chevron_right),
          color: const Color(0xFF567C68),
        ),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    final firstDay = DateTime(
      _focusedMonth.year,
      _focusedMonth.month,
      1,
    );

    final daysInMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month + 1,
      0,
    ).day;

    // Monday is the first day of the week.
    final leadingDays = firstDay.weekday - 1;
    final totalCells = leadingDays + daysInMonth;

    return Column(
      children: [
        Row(
          children: _weekdays.map((day) {
            return Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    day,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF89948C),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: totalCells,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 5,
            crossAxisSpacing: 5,
          ),
          itemBuilder: (context, index) {
            if (index < leadingDays) {
              return const SizedBox.shrink();
            }

            final day = index - leadingDays + 1;
            final date = DateTime(
              _focusedMonth.year,
              _focusedMonth.month,
              day,
            );

            final dayEntries = _entriesForDate(date);
            final isSelected = _isSameDay(date, _selectedDate);
            final isToday = _isSameDay(date, DateTime.now());

            final moods = dayEntries
                .map((entry) => entry.mood)
                .toSet()
                .take(3)
                .toList();

            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                setState(() => _selectedDate = date);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFE5EEE7)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: isToday
                      ? Border.all(
                          color: const Color(0xFF567C68),
                          width: 1.5,
                        )
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$day',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected || isToday
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: const Color(0xFF26382E),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: moods.map((mood) {
                        return Container(
                          width: 5,
                          height: 5,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            color: _colorForMood(mood),
                            shape: BoxShape.circle,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  String _formatSelectedDate(DateTime date) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return '${weekdays[date.weekday - 1]}, '
        '${_months[date.month - 1]} ${date.day}';
  }

  Widget _buildMoodLegend() {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: _moodColors.entries.map((item) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: item.value,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              item.key,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF89948C),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildSelectedEntries() {
    final entries = _entriesForDate(_selectedDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _formatSelectedDate(_selectedDate),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF26382E),
                ),
              ),
            ),
            Text(
              '${entries.length} ${entries.length == 1 ? 'entry' : 'entries'}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF89948C),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (entries.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE8ECE7)),
            ),
            child: const Column(
              children: [
                Text('📖', style: TextStyle(fontSize: 34)),
                SizedBox(height: 8),
                Text(
                  'No entries for this day',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF567C68),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Choose another date or create a new entry.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF89948C),
                  ),
                ),
              ],
            ),
          )
        else
          ...entries.map(
            (entry) => JournalEntryCard(
              entry: entry,
              onTap: () => _openEntryForm(entry: entry),
              onFavoriteTap: () => _toggleFavorite(entry),
              onDeleteTap: () => _deleteEntry(entry),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F6),
      appBar: AppBar(
        title: const Text(
          'Journal Calendar',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF26382E),
          ),
        ),
        backgroundColor: const Color(0xFFF7F9F6),
        foregroundColor: const Color(0xFF567C68),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF567C68),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadEntries,
              color: const Color(0xFF567C68),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE8ECE7)),
                    ),
                    child: Column(
                      children: [
                        _buildMonthHeader(),
                        const Divider(height: 16),
                        _buildCalendarGrid(),
                        const SizedBox(height: 16),
                        _buildMoodLegend(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSelectedEntries(),
                ],
              ),
            ),
    );
  }
}
