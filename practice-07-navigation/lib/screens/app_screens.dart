import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/auth_service.dart';
import '../services/cinema_data.dart';

class CinemaScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const CinemaScaffold({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.movie_outlined),
            selectedIcon: Icon(Icons.movie),
            label: 'Афіша',
          ),
          NavigationDestination(
            icon: Icon(Icons.confirmation_number_outlined),
            selectedIcon: Icon(Icons.confirmation_number),
            label: 'Мої квитки',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Профіль',
          ),
        ],
      ),
    );
  }
}

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({super.key});

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final dateString = GoRouterState.of(context).uri.queryParameters['date'];
    if (dateString != null) {
      final parsedDate = DateTime.tryParse(dateString);
      if (parsedDate != null) {
        _selectedDate = parsedDate;
      }
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }

  String _dateParameter(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  Future<void> _chooseDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      helpText: 'Оберіть дату сеансу',
    );

    if (!mounted || selected == null) return;

    setState(() => _selectedDate = selected);

    context.go(
      Uri(
        path: '/movies',
        queryParameters: {'date': _dateParameter(selected)},
      ).toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Кіноафіша'),
        actions: [
          IconButton(
            onPressed: _chooseDate,
            tooltip: 'Обрати дату',
            icon: const Icon(Icons.calendar_month),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.event),
              title: const Text('Дата сеансів'),
              subtitle: Text(_formatDate(_selectedDate)),
              trailing: const Icon(Icons.edit_calendar),
              onTap: _chooseDate,
            ),
          ),
          const SizedBox(height: 12),
          ...CinemaData.movies.map(
            (movie) => Card(
              clipBehavior: Clip.antiAlias,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: CircleAvatar(
                  radius: 28,
                  child: Text(
                    movie.posterEmoji,
                    style: const TextStyle(fontSize: 26),
                  ),
                ),
                title: Text(
                  movie.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '${movie.genre} • ${movie.durationMinutes} хв\n'
                    'Рейтинг: ${movie.rating}',
                  ),
                ),
                isThreeLine: true,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go(
                  '/movies/${movie.id}?date=${_dateParameter(_selectedDate)}',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MovieDetailScreen extends StatelessWidget {
  final String movieId;
  final AuthService auth;

  const MovieDetailScreen({
    super.key,
    required this.movieId,
    required this.auth,
  });

  @override
  Widget build(BuildContext context) {
    final movie = CinemaData.findMovie(movieId);

    if (movie == null) {
      return const NotFoundScreen();
    }

    final sessions = CinemaData.sessionsForMovie(movieId);

    return Scaffold(
      appBar: AppBar(title: Text(movie.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Text(
              movie.posterEmoji,
              style: const TextStyle(fontSize: 90),
            ),
          ),
          const SizedBox(height: 16),
          Text(movie.title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('${movie.genre} • ${movie.durationMinutes} хв'),
          Text('Рейтинг: ${movie.rating}'),
          const SizedBox(height: 16),
          Text(movie.description),
          const SizedBox(height: 24),
          Text(
            'Розклад сеансів',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          if (sessions.isEmpty)
            const Text('Для цього фільму поки немає сеансів.')
          else
            ...sessions.map(
              (session) => Card(
                child: ListTile(
                  leading: const Icon(Icons.schedule),
                  title: Text('${session.time} • ${session.hall}'),
                  subtitle: Text(
                    '${session.ticketPrice.toStringAsFixed(0)} грн',
                  ),
                  trailing: const Icon(Icons.event_seat),
                  onTap: () async {
                    final seats = await context.push<List<String>>(
                      '/movies/$movieId/session/${session.id}/seats',
                    );

                    if (!context.mounted || seats == null || seats.isEmpty) {
                      return;
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Обрані місця: ${seats.join(', ')}'),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class TicketsScreen extends StatelessWidget {
  const TicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мої квитки')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.confirmation_number_outlined, size: 64),
              SizedBox(height: 16),
              Text(
                'Ваші придбані квитки відображатимуться тут.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  final AuthService auth;

  const ProfileScreen({super.key, required this.auth});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профіль')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CircleAvatar(radius: 42, child: Icon(Icons.person, size: 46)),
          const SizedBox(height: 16),
          Center(
            child: Text(
              auth.isAdmin
                  ? 'Адміністратор'
                  : auth.isLoggedIn
                  ? 'Користувач'
                  : 'Гість',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 24),
          if (!auth.isLoggedIn)
            FilledButton.icon(
              onPressed: () => context.go('/login'),
              icon: const Icon(Icons.login),
              label: const Text('Увійти'),
            )
          else ...[
            if (auth.isAdmin)
              ListTile(
                leading: const Icon(Icons.admin_panel_settings),
                title: const Text('Панель адміністратора'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/admin'),
              ),
            OutlinedButton.icon(
              onPressed: () {
                auth.logout();
                context.go('/profile');
              },
              icon: const Icon(Icons.logout),
              label: const Text('Вийти'),
            ),
          ],
        ],
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  final AuthService auth;

  const LoginScreen({super.key, required this.auth});

  String _destination(BuildContext context) {
    final from = GoRouterState.of(context).uri.queryParameters['from'];

    if (from == null || !from.startsWith('/') || from == '/login') {
      return '/movies';
    }

    if (from.startsWith('/admin') && !auth.isAdmin) {
      return '/movies';
    }

    return from;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Вхід')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.local_movies, size: 72),
                const SizedBox(height: 16),
                Text(
                  'Вітаємо в Cinema!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () {
                    auth.loginAsUser();
                    context.go(_destination(context));
                  },
                  icon: const Icon(Icons.person),
                  label: const Text('Увійти як користувач'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    auth.loginAsAdmin();
                    context.go(_destination(context));
                  },
                  icon: const Icon(Icons.admin_panel_settings),
                  label: const Text('Увійти як адміністратор'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.go('/movies'),
                  child: const Text('Продовжити як гість'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Панель адміністратора'),
        leading: IconButton(
          onPressed: () => context.go('/profile'),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.admin_panel_settings, size: 64),
              SizedBox(height: 16),
              Text('Розділ адміністратора', style: TextStyle(fontSize: 22)),
              SizedBox(height: 8),
              Text(
                'Ця сторінка доступна лише адміністратору.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SeatsScreen extends StatefulWidget {
  final String movieId;
  final String sessionId;
  final AuthService auth;

  const SeatsScreen({
    super.key,
    required this.movieId,
    required this.sessionId,
    required this.auth,
  });

  @override
  State<SeatsScreen> createState() => _SeatsScreenState();
}

class _SeatsScreenState extends State<SeatsScreen> {
  final Set<String> _selectedSeats = {};
  bool _saved = false;

  Future<bool> _confirmLeave() async {
    if (_selectedSeats.isEmpty || _saved) return true;

    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Вийти без збереження?'),
        content: const Text('Ви вибрали місця, але ще не підтвердили їх.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Залишитися'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Вийти'),
          ),
        ],
      ),
    );

    return shouldLeave ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final movie = CinemaData.findMovie(widget.movieId);
    final session = CinemaData.findSession(widget.sessionId);

    if (movie == null || session == null) {
      return const NotFoundScreen();
    }

    return PopScope(
      canPop: _selectedSeats.isEmpty || _saved,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldLeave = await _confirmLeave();

        if (shouldLeave && context.mounted) {
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Вибір місць')),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),
              Text(movie.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text('${session.time} • ${session.hall}'),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'ЕКРАН',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        for (var row = 1; row <= 5; row++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 24,
                                  child: Text(
                                    String.fromCharCode(64 + row),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                for (var number = 1; number <= 6; number++)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 3,
                                    ),
                                    child: _buildSeat(
                                      '${String.fromCharCode(64 + row)}$number',
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Обрані місця: ${_selectedSeats.isEmpty ? 'немає' : (_selectedSeats.toList()..sort()).join(', ')}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'До сплати: ${(_selectedSeats.length * session.ticketPrice).toStringAsFixed(0)} грн',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _selectedSeats.isEmpty
                          ? null
                          : () {
                              final seats = _selectedSeats.toList()..sort();
                              _saved = true;
                              context.pop(seats);
                            },
                      child: const Text('Підтвердити вибір місць'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeat(String seat) {
    final isSelected = _selectedSeats.contains(seat);

    return SizedBox(
      width: 38,
      height: 38,
      child: FilledButton(
        style: FilledButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.secondaryContainer,
          foregroundColor: isSelected
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onSecondaryContainer,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () {
          setState(() {
            if (isSelected) {
              _selectedSeats.remove(seat);
            } else {
              _selectedSeats.add(seat);
            }
          });
        },
        child: Text(seat),
      ),
    );
  }
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Сторінку не знайдено')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off, size: 64),
              const SizedBox(height: 16),
              const Text('Такої сторінки або фільму не існує.'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.go('/movies'),
                child: const Text('Повернутися до афіші'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
