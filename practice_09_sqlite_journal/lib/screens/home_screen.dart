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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load entries: $error')));
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

  Future<void> _toggleFavorite(JournalEntry entry) async {
    await _database.updateEntry(entry.copyWith(isFavorite: !entry.isFavorite));

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
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
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

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    }

    final yesterday = now.subtract(const Duration(days: 1));

    if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
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
          style: TextStyle(fontSize: 14, color: Color(0xFF89948C)),
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
          child: Row(
            children: [
              const Expanded(
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
              const SizedBox(width: 8),
              const Text('🌿', style: TextStyle(fontSize: 38)),
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
              style: const TextStyle(color: Color(0xFF89948C), fontSize: 13),
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
                      child: Text(tag.name, overflow: TextOverflow.ellipsis),
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 45),
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
    final dates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

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
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: const Color(0xFF567C68),
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildFilters(),
                    const SizedBox(height: 10),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(child: CircularProgressIndicator()),
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
