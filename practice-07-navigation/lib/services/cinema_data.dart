
import '../models/movie.dart';

class CinemaData {
  static const movies = <Movie>[
    Movie(
      id: '1',
      title: 'Інтерстеллар',
      genre: 'Фантастика',
      description:
          'Команда дослідників вирушає за межі Сонячної системи '
          'у пошуках нового дому для людства.',
      durationMinutes: 169,
      rating: 8.7,
      posterEmoji: '🚀',
    ),
    Movie(
      id: '2',
      title: 'Початок',
      genre: 'Трилер',
      description:
          'Команда фахівців проникає у сни людей, щоб впливати '
          'на їхні рішення.',
      durationMinutes: 148,
      rating: 8.8,
      posterEmoji: '🌃',
    ),
    Movie(
      id: '3',
      title: 'Дюна',
      genre: 'Фантастика',
      description:
          'Історія молодого спадкоємця, який опиняється '
          'в центрі боротьби за пустельну планету.',
      durationMinutes: 155,
      rating: 8.0,
      posterEmoji: '🏜️',
    ),
    Movie(
      id: '4',
      title: 'Втеча з Шоушенка',
      genre: 'Драма',
      description:
          'Історія дружби, надії та сили людського духу '
          'у стінах в’язниці.',
      durationMinutes: 142,
      rating: 9.3,
      posterEmoji: '🎬',
    ),
    Movie(
      id: '5',
      title: 'Матриця',
      genre: 'Фантастика',
      description:
          'Програміст відкриває правду про світ, у якому живе.',
      durationMinutes: 136,
      rating: 8.7,
      posterEmoji: '🟢',
    ),
  ];

  static const sessions = <MovieSession>[
    MovieSession(
      id: 's1',
      movieId: '1',
      time: '12:00',
      hall: 'Зал 1',
      ticketPrice: 180,
    ),
    MovieSession(
      id: 's2',
      movieId: '1',
      time: '16:30',
      hall: 'Зал 2',
      ticketPrice: 220,
    ),
    MovieSession(
      id: 's3',
      movieId: '2',
      time: '14:00',
      hall: 'Зал 1',
      ticketPrice: 190,
    ),
    MovieSession(
      id: 's4',
      movieId: '2',
      time: '19:00',
      hall: 'Зал 3',
      ticketPrice: 240,
    ),
    MovieSession(
      id: 's5',
      movieId: '3',
      time: '15:00',
      hall: 'Зал 2',
      ticketPrice: 210,
    ),
    MovieSession(
      id: 's6',
      movieId: '4',
      time: '17:30',
      hall: 'Зал 1',
      ticketPrice: 160,
    ),
    MovieSession(
      id: 's7',
      movieId: '5',
      time: '20:00',
      hall: 'Зал 3',
      ticketPrice: 230,
    ),
  ];

  static Movie? findMovie(String id) {
    for (final movie in movies) {
      if (movie.id == id) return movie;
    }
    return null;
  }

  static MovieSession? findSession(String id) {
    for (final session in sessions) {
      if (session.id == id) return session;
    }
    return null;
  }

  static List<MovieSession> sessionsForMovie(String movieId) {
    return sessions
        .where((session) => session.movieId == movieId)
        .toList();
  }
}