
import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/journal_entry.dart';
import '../models/tag.dart';
import '../widgets/journal_entry_card.dart';
import 'entry_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _database = DatabaseHelper.instance;
  final TextEditingController _searchController = TextEditingController();

  List<JournalEntry> _entries = [];
  List<Tag> _tags = [];

  String? _selectedMood;
  int? _selectedTagId;
  bool _favoritesOnly = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final entries = await _database.getEntries(
        searchQuery: _searchController.text,
        mood: _selectedMood,
        tagId: _selectedTagId,
        favoritesOnly: _favoritesOnly,
      );

      final tags = await _database.getTags();

      if (!mounted) return;

      setState(() {
        _entries = entries;
        _tags = tags;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load entries: $error')),
      );
    }
  }

  Future<void> _openEntryForm({JournalEntry? entry}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => EntryFormScreen(entry: entry)),
    );

    if (result == true) {
      _loadData();
    }
  }

  Future<void> _openCalendar() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CalendarScreen()),
    );

    _loadData();
  }

  Future<void> _toggleFavorite(JournalEntry entry) async {
    await _database.updateEntry(
      entry.copyWith(isFavorite: !entry.isFavorite),
    );

    _loadData();
  }

  Future<void> _deleteEntry(JournalEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete entry?'),
        content: const Text(
          'Are you sure you want to delete this journal entry?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
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
      _loadData();
    }
  }

  Map<String, List<JournalEntry>> _groupEntriesByDate() {
    final grouped = <String, List<JournalEntry>>{};

    for (final entry in _entries) {
      final date = entry.createdAt;
      final key =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(entry);
    }

    return grouped;
  }

  String _formatGroupDate(String key) {
    final date = DateTime.parse(key);
    final now = DateTime.now();

    if (DateUtils.isSameDay(date, now)) {
      return 'Today';
    }

    if (DateUtils.isSameDay(
      date,
      now.subtract(const Duration(days: 1)),
    )) {
      return 'Yesterday';
    }

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

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your personal space',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF89948C),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'My Journal',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Color(0xFF26382E),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFE5EEE7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Every day is a new page.',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF365B45),
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Write down your thoughts and capture your moments.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: Color(0xFF567C68),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Text('🌿', style: TextStyle(fontSize: 38)),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            const Text(
              'Your entries',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: Color(0xFF26382E),
              ),
            ),
            const Spacer(),
            Text(
              '${_entries.length} entries',
              style: const TextStyle(
                color: Color(0xFF89948C),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          onChanged: (_) => _loadData(),
          decoration: InputDecoration(
            hintText: 'Search your memories...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      _loadData();
                    },
                    icon: const Icon(Icons.close),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String?>(
                initialValue: _selectedMood,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Mood',
                  prefixIcon: Icon(Icons.mood),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All moods'),
                  ),
                  ...[
                    'Happy',
                    'Excited',
                    'Calm',
                    'Neutral',
                    'Sad',
                    'Angry',
                  ].map(
                    (mood) => DropdownMenuItem<String?>(
                      value: mood,
                      child: Text(mood),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _selectedMood = value);
                  _loadData();
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DropdownButtonFormField<int?>(
                initialValue: _selectedTagId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Tag',
                  prefixIcon: Icon(Icons.tag),
                ),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('All tags'),
                  ),
                  ..._tags.map(
                    (tag) => DropdownMenuItem<int?>(
                      value: tag.id,
                      child: Text(
                        tag.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _selectedTagId = value);
                  _loadData();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: FilterChip(
            label: const Text('Favorites only'),
            selected: _favoritesOnly,
            avatar: const Icon(Icons.favorite, size: 17),
            onSelected: (value) {
              setState(() => _favoritesOnly = value);
              _loadData();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEntries() {
    if (_entries.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 45,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE8ECE7)),
        ),
        child: Column(
          children: [
            const Text('📖', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            const Text(
              'No entries found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF26382E),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _searchController.text.isNotEmpty ||
                      _selectedMood != null ||
                      _selectedTagId != null ||
                      _favoritesOnly
                  ? 'Try changing your search or filters.'
                  : 'Start writing and save your first memory.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF89948C)),
            ),
          ],
        ),
      );
    }

    final grouped = _groupEntriesByDate();
    final dates = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: dates.map((date) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 18, bottom: 10),
              child: Text(
                _formatGroupDate(date),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF567C68),
                ),
              ),
            ),
            ...grouped[date]!.map(
              (entry) => JournalEntryCard(
                entry: entry,
                onTap: () => _openEntryForm(entry: entry),
                onFavoriteTap: () => _toggleFavorite(entry),
                onDeleteTap: () => _deleteEntry(entry),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9F6),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Open calendar',
            onPressed: _openCalendar,
            icon: const Icon(
              Icons.calendar_month,
              color: Color(0xFF567C68),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: const Color(0xFF567C68),
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildFilters(),
                    const SizedBox(height: 10),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else
                      _buildEntries(),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEntryForm(),
        backgroundColor: const Color(0xFF567C68),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New entry'),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Calendar screen
// -----------------------------------------------------------------------------

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final DatabaseHelper _database = DatabaseHelper.instance;

  List<JournalEntry> _entries = [];
  bool _isLoading = true;

  DateTime _focusedMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );

  DateTime _selectedDate = DateTime.now();

  static const List<String> _weekDays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

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

  List<JournalEntry> _entriesForDate(DateTime date) {
    return _entries.where((entry) {
      return DateUtils.isSameDay(entry.createdAt, date);
    }).toList();
  }

  Color _colorForMood(String mood) {
    return _moodColors[mood] ?? const Color(0xFF9EAAA2);
  }

  void _changeMonth(int offset) {
    setState(() {
      _focusedMonth = DateTime(
        _focusedMonth.year,
        _focusedMonth.month + offset,
      );
    });
  }

  Future<void> _openEntry(JournalEntry entry) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EntryFormScreen(entry: entry),
      ),
    );

    if (result == true) {
      _loadEntries();
    }
  }

  String get _monthTitle {
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

    return '${months[_focusedMonth.month - 1]} ${_focusedMonth.year}';
  }

  Widget _buildMonthHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () => _changeMonth(-1),
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: Text(
            _monthTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: Color(0xFF26382E),
            ),
          ),
        ),
        IconButton(
          onPressed: () => _changeMonth(1),
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = DateUtils.getDaysInMonth(
      _focusedMonth.year,
      _focusedMonth.month,
    );

    // DateTime.weekday: Monday = 1, Sunday = 7.
    final firstWeekday = DateTime(
      _focusedMonth.year,
      _focusedMonth.month,
      1,
    ).weekday;

    final totalCells = firstWeekday - 1 + daysInMonth;

    return Column(
      children: [
        Row(
          children: _weekDays.map((day) {
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
            mainAxisSpacing: 6,
            crossAxisSpacing: 4,
          ),
          itemBuilder: (context, index) {
            final dayNumber = index - firstWeekday + 2;

            if (dayNumber < 1 || dayNumber > daysInMonth) {
              return const SizedBox.shrink();
            }

            final date = DateTime(
              _focusedMonth.year,
              _focusedMonth.month,
              dayNumber,
            );

            final dayEntries = _entriesForDate(date);
            final isSelected = DateUtils.isSameDay(
              date,
              _selectedDate,
            );
            final isToday = DateUtils.isSameDay(
              date,
              DateTime.now(),
            );

            final moods = dayEntries
                .map((entry) => entry.mood)
                .toSet()
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
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF567C68)
                        : isToday
                            ? const Color(0xFFB6CDBD)
                            : Colors.transparent,
                    width: isSelected || isToday ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$dayNumber',
                      style: TextStyle(
                        fontWeight: isSelected || isToday
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: const Color(0xFF26382E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (moods.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: moods.take(3).map((mood) {
                          return Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 1,
                            ),
                            decoration: BoxDecoration(
                              color: _colorForMood(mood),
                              shape: BoxShape.circle,
                            ),
                          );
                        }).toList(),
                      )
                    else
                      const SizedBox(height: 6),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
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
                color: Color(0xFF68776D),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildSelectedDateEntries() {
    final entries = _entriesForDate(_selectedDate);

    final dateTitle =
        '${_selectedDate.day.toString().padLeft(2, '0')}.'
        '${_selectedDate.month.toString().padLeft(2, '0')}.'
        '${_selectedDate.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Selected day',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF26382E),
                ),
              ),
            ),
            Text(
              dateTitle,
              style: const TextStyle(
                color: Color(0xFF89948C),
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (entries.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE8ECE7)),
            ),
            child: const Column(
              children: [
                Text('📝', style: TextStyle(fontSize: 36)),
                SizedBox(height: 8),
                Text(
                  'No entries for this day',
                  style: TextStyle(
                    color: Color(0xFF89948C),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        else
          ...entries.map(
            (entry) => JournalEntryCard(
              entry: entry,
              onTap: () => _openEntry(entry),
              onFavoriteTap: () async {
                await _database.updateEntry(
                  entry.copyWith(isFavorite: !entry.isFavorite),
                );
                _loadEntries();
              },
              onDeleteTap: () async {
                if (entry.id == null) return;

                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete entry?'),
                    content: const Text(
                      'Are you sure you want to delete this entry?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  await _database.deleteEntry(entry.id!);
                  _loadEntries();
                }
              },
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
        backgroundColor: const Color(0xFFF7F9F6),
        elevation: 0,
        title: const Text(
          'Calendar',
          style: TextStyle(
            color: Color(0xFF26382E),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF567C68),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadEntries,
              color: const Color(0xFF567C68),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFE8ECE7),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildMonthHeader(),
                        const SizedBox(height: 8),
                        _buildCalendarGrid(),
                        const Divider(height: 28),
                        _buildMoodLegend(),
                      ],
                    ),
                  ),
                  _buildSelectedDateEntries(),
                ],
              ),
            ),
    );
  }
}
