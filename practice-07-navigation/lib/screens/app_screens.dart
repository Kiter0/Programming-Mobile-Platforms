import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/movie.dart';
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
            label: 'Кіноафіша',
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Афіша кінотеатру'),
        actions: [
          IconButton(
            tooltip: 'Обрати дату',
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                lastDate: DateTime.now().add(const Duration(days: 90)),
              );
              if (date != null && mounted) {
                setState(() => _selectedDate = date);
              }
            },
            icon: const Icon(Icons.calendar_month),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.event),
                const SizedBox(width: 8),
                Text('Дата: ${_formatDate(_selectedDate)}'),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: CinemaData.movies.length,
              itemBuilder: (context, index) {
                final movie = CinemaData.movies[index];
                final sessions = CinemaData.sessionsForMovie(movie.id);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Text(
                      movie.posterEmoji,
                      style: const TextStyle(fontSize: 42),
                    ),
                    title: Text(movie.title),
                    subtitle: Text(
                      '${movie.genre} • ${movie.durationMinutes} хв\n'
                      'Рейтинг: ${movie.rating} • '
                      'Сеансів: ${sessions.length}',
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(
                      '/movies/${movie.id}?date=${_formatDate(_selectedDate)}',
                    ),
                  ),
                );
              },
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

    if (movie == null) return const NotFoundScreen();

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
                    '${session.ticketPrice.toStringAsFixed(0)} грн за місце',
                  ),
                  trailing: const Icon(Icons.event_seat),
                  onTap: () {
                    final destination =
                        '/movies/$movieId/session/${session.id}/seats';

                    if (!auth.isLoggedIn) {
                      context.go(
                        Uri(
                          path: '/login',
                          queryParameters: {'from': destination},
                        ).toString(),
                      );
                      return;
                    }

                    context.push<CinemaTicket>(destination).then((ticket) {
                      if (!context.mounted || ticket == null) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Квитки придбано: ${ticket.seats.join(', ')}',
                          ),
                          action: SnackBarAction(
                            label: 'Мої квитки',
                            onPressed: () => context.go('/tickets'),
                          ),
                        ),
                      );
                    });
                  },
                ),
              ),
            ),
        ],
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

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Вийти без збереження?'),
        content: const Text(
          'Ви вибрали місця. Якщо вийти зараз, вибір буде втрачено.',
        ),
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

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final movie = CinemaData.findMovie(widget.movieId);
    final session = CinemaData.findSession(widget.sessionId);

    if (!widget.auth.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('Потрібен вхід')),
        body: Center(
          child: FilledButton(
            onPressed: () {
              final destination =
                  '/movies/${widget.movieId}/session/'
                  '${widget.sessionId}/seats';

              context.go(
                Uri(
                  path: '/login',
                  queryParameters: {'from': destination},
                ).toString(),
              );
            },
            child: const Text('Увійти для придбання квитків'),
          ),
        ),
      );
    }

    if (movie == null || session == null) {
      return const NotFoundScreen();
    }

    return PopScope(
      canPop: _selectedSeats.isEmpty || _saved,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        if (await _confirmLeave() && context.mounted) {
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
                                      '${String.fromCharCode(64 + row)}'
                                      '$number',
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
                      'Обрані місця: '
                      '${_selectedSeats.isEmpty ? 'немає' : (_selectedSeats.toList()..sort()).join(', ')}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'До сплати: '
                      '${(_selectedSeats.length * session.ticketPrice).toStringAsFixed(0)} грн',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _selectedSeats.isEmpty
                          ? null
                          : () {
                              final seats = _selectedSeats.toList()..sort();

                              final ticket = CinemaTicket(
                                id: DateTime.now().microsecondsSinceEpoch
                                    .toString(),
                                movieId: widget.movieId,
                                sessionId: widget.sessionId,
                                seats: seats,
                                purchasedAt: DateTime.now(),
                              );

                              CinemaData.addTicket(ticket);
                              _saved = true;
                              context.pop<CinemaTicket>(ticket);
                            },
                      child: const Text('Придбати квитки'),
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

class TicketsScreen extends StatelessWidget {
  const TicketsScreen({super.key});

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final tickets = CinemaData.purchasedTickets.reversed.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Мої квитки')),
      body: tickets.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.confirmation_number_outlined, size: 72),
                    const SizedBox(height: 16),
                    Text(
                      'У вас поки немає квитків',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Оберіть фільм в афіші та придбайте квитки.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => context.go('/movies'),
                      child: const Text('Перейти до афіші'),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                final ticket = tickets[index];
                final movie = CinemaData.findMovie(ticket.movieId);
                final session = CinemaData.findSession(ticket.sessionId);

                if (movie == null || session == null) {
                  return const SizedBox.shrink();
                }

                final total = ticket.seats.length * session.ticketPrice;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              movie.posterEmoji,
                              style: const TextStyle(fontSize: 36),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                movie.title,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            const Icon(
                              Icons.confirmation_number,
                              color: Colors.green,
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Text('Час сеансу: ${session.time}'),
                        Text('Зал: ${session.hall}'),
                        Text('Місця: ${ticket.seats.join(', ')}'),
                        Text('Придбано: ${_formatDate(ticket.purchasedAt)}'),
                        const SizedBox(height: 8),
                        Text(
                          'Загальна вартість: '
                          '${total.toStringAsFixed(0)} грн',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              },
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
          const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 44)),
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
                onTap: () => context.go('/admin'),
              ),
            ListTile(
              leading: const Icon(Icons.confirmation_number),
              title: const Text('Мої квитки'),
              onTap: () => context.go('/tickets'),
            ),
            FilledButton.icon(
              onPressed: () {
                auth.logout();
                context.go('/profile');
              },
              icon: const Icon(Icons.logout),
              label: const Text('Вийти з облікового запису'),
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

  @override
  Widget build(BuildContext context) {
    final from = GoRouterState.of(context).uri.queryParameters['from'];

    void signIn(bool admin) {
      if (admin) {
        auth.loginAsAdmin();
      } else {
        auth.loginAsUser();
      }

      final destination = Uri.tryParse(from ?? '');
      final path = destination?.path;

      if (path != null &&
          path.startsWith('/') &&
          path != '/login' &&
          (!path.startsWith('/admin') || auth.isAdmin)) {
        context.go(destination.toString());
      } else {
        context.go('/movies');
      }
    }

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
                  'Увійдіть до кінотеатру',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => signIn(false),
                  child: const Text('Увійти як користувач'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => signIn(true),
                  child: const Text('Увійти як адміністратор'),
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
      appBar: AppBar(title: const Text('Панель адміністратора')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Icon(Icons.admin_panel_settings, size: 72),
          const SizedBox(height: 16),
          Text(
            'Панель адміністратора',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'Доступ до цього розділу мають лише адміністратори.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: const Icon(Icons.movie),
              title: const Text('Фільмів у каталозі'),
              trailing: Text('${CinemaData.movies.length}'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Сеансів у розкладі'),
              trailing: Text('${CinemaData.sessions.length}'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.confirmation_number),
              title: const Text('Придбаних квитків'),
              trailing: Text('${CinemaData.purchasedTickets.length}'),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => context.go('/movies'),
            child: const Text('Повернутися до афіші'),
          ),
        ],
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
              const Icon(Icons.search_off, size: 72),
              const SizedBox(height: 16),
              Text(
                'Такої сторінки не існує',
                style: Theme.of(context).textTheme.titleLarge,
              ),
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
