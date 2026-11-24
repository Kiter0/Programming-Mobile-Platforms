import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/user.dart';
import '../services/api_service.dart';

class DetailScreen extends StatefulWidget {
  final User user;
  final ApiService apiService;

  const DetailScreen({
    super.key,
    required this.user,
    required this.apiService,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late User user;

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfo(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value.isEmpty ? 'Не вказано' : value,
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openMap() async {
    final lat = double.tryParse(user.address.geo.lat);
    final lng = double.tryParse(user.address.geo.lng);

    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Некоректні географічні координати'),
        ),
      );
      return;
    }

    final uri = Uri.parse(
      'https://www.openstreetmap.org/?mlat=$lat&mlon=$lng#map=15/$lat/$lng',
    );

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Не вдалося відкрити карту'),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Помилка відкриття карти'),
          ),
        );
      }
    }
  }

  Future<void> _deleteUser() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Видалити користувача?'),
        content: Text(
          'Ви дійсно хочете видалити ${user.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Скасувати'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Видалити',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await widget.apiService.deleteUser(user.id);

      if (!mounted) return;

      Navigator.pop(context, {
        'action': 'delete',
        'id': user.id,
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Помилка видалення: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Деталі користувача'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Редагувати',
            onPressed: () async {
              final result = await Navigator.pushNamed(
                context,
                '/edit',
                arguments: user,
              );

              if (result is User && mounted) {
                setState(() {
                  user = result;
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Видалити',
            onPressed: _deleteUser,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 45,
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  user.name.isNotEmpty
                      ? user.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 36,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                user.name,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Center(
              child: Text(
                '@${user.username}',
                style: const TextStyle(color: Colors.grey),
              ),
            ),

            _buildSectionTitle('Контактна інформація'),
            _buildInfo('Email', user.email, Icons.email_outlined),
            _buildInfo('Телефон', user.phone, Icons.phone_outlined),
            _buildInfo('Вебсайт', user.website, Icons.language),

            _buildSectionTitle('Компанія'),
            _buildInfo(
              'Назва',
              user.company.name,
              Icons.business_outlined,
            ),
            _buildInfo(
              'Слоган',
              user.company.catchPhrase,
              Icons.format_quote,
            ),
            _buildInfo(
              'Сфера діяльності',
              user.company.bs,
              Icons.work_outline,
            ),

            _buildSectionTitle('Адреса'),
            _buildInfo('Вулиця', user.address.street, Icons.home),
            _buildInfo('Квартира', user.address.suite, Icons.apartment),
            _buildInfo('Місто', user.address.city, Icons.location_city),
            _buildInfo('Індекс', user.address.zipcode, Icons.markunread_mailbox),

            _buildSectionTitle('Географічні координати'),
            _buildInfo('Широта', user.address.geo.lat, Icons.map_outlined),
            _buildInfo('Довгота', user.address.geo.lng, Icons.map_outlined),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openMap,
                icon: const Icon(Icons.map),
                label: const Text('Відкрити на OpenStreetMap'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
