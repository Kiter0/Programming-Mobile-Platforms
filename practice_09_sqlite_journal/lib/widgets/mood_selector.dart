import 'package:flutter/material.dart';

class MoodSelector extends StatelessWidget {
  final String selectedMood;
  final ValueChanged<String> onMoodSelected;

  const MoodSelector({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
  });

  static const Map<String, Map<String, dynamic>> moods = {
    'Happy': {'emoji': '😊', 'color': Color(0xFFFFE6A7), 'label': 'Happy'},
    'Excited': {'emoji': '🤩', 'color': Color(0xFFFFD6C9), 'label': 'Excited'},
    'Calm': {'emoji': '😌', 'color': Color(0xFFD9EBDD), 'label': 'Calm'},
    'Neutral': {'emoji': '😐', 'color': Color(0xFFE5E7EB), 'label': 'Neutral'},
    'Sad': {'emoji': '😔', 'color': Color(0xFFDCE5F5), 'label': 'Sad'},
    'Angry': {'emoji': '😡', 'color': Color(0xFFF5D5D5), 'label': 'Angry'},
  };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: moods.entries.map((entry) {
        final isSelected = selectedMood == entry.key;

        return GestureDetector(
          onTap: () => onMoodSelected(entry.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? entry.value['color'] as Color : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF567C68)
                    : const Color(0xFFE8ECE7),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  entry.value['emoji'] as String,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 6),
                Text(
                  entry.key,
                  style: TextStyle(
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
