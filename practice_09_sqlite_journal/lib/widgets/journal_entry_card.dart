import 'package:flutter/material.dart';

import '../models/journal_entry.dart';
import 'mood_selector.dart';

class JournalEntryCard extends StatelessWidget {
  final JournalEntry entry;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;
  final VoidCallback onDeleteTap;

  const JournalEntryCard({
    super.key,
    required this.entry,
    required this.onTap,
    required this.onFavoriteTap,
    required this.onDeleteTap,
  });

  String _formatDate(DateTime date) {
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

  @override
  Widget build(BuildContext context) {
    final mood = MoodSelector.moods[entry.mood];

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE8ECE7)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _formatDate(entry.createdAt),
                    style: const TextStyle(
                      color: Color(0xFF8A948D),
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  if (mood != null)
                    Text(
                      mood['emoji'] as String,
                      style: const TextStyle(fontSize: 22),
                    ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_horiz,
                      color: Color(0xFF8A948D),
                    ),
                    onSelected: (value) {
                      if (value == 'favorite') {
                        onFavoriteTap();
                      } else if (value == 'delete') {
                        onDeleteTap();
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'favorite',
                        child: Text(
                          entry.isFavorite
                              ? 'Remove favorite'
                              : 'Add to favorites',
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                entry.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF26382E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                entry.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Color(0xFF68736B),
                ),
              ),
              if (entry.tags.isNotEmpty) ...[
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: entry.tags.map((tag) {
                    final colorValue = int.tryParse(
                      tag.color.replaceFirst('#', ''),
                      radix: 16,
                    );

                    final color = colorValue == null
                        ? const Color(0xFF567C68)
                        : Color(
                            colorValue <= 0xFFFFFF
                                ? 0xFF000000 | colorValue
                                : colorValue,
                          );

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '#${tag.name}',
                        style: TextStyle(
                          fontSize: 12,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.edit_note,
                    size: 17,
                    color: Color(0xFF9AA39C),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${entry.wordCount} words',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9AA39C),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    entry.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: entry.isFavorite
                        ? Colors.redAccent
                        : const Color(0xFF9AA39C),
                    size: 19,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
