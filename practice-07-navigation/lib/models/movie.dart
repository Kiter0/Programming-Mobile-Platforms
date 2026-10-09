
class Movie {
  final String id;
  final String title;
  final String genre;
  final String description;
  final int durationMinutes;
  final double rating;
  final String posterEmoji;

  const Movie({
    required this.id,
    required this.title,
    required this.genre,
    required this.description,
    required this.durationMinutes,
    required this.rating,
    required this.posterEmoji,
  });
}

class MovieSession {
  final String id;
  final String movieId;
  final String time;
  final String hall;
  final double ticketPrice;

  const MovieSession({
    required this.id,
    required this.movieId,
    required this.time,
    required this.hall,
    required this.ticketPrice,
  });
}

class CinemaTicket {
  final String id;
  final String movieId;
  final String sessionId;
  final List<String> seats;
  final DateTime purchasedAt;

  const CinemaTicket({
    required this.id,
    required this.movieId,
    required this.sessionId,
    required this.seats,
    required this.purchasedAt,
  });
}