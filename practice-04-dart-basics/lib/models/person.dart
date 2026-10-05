/// Абстрактний базовий клас для всіх людей в університеті
abstract class Person {
  final String id;
  final String firstName;
  final String lastName;
  final DateTime birthDate;

  Person({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
  });

  String get fullName => '$firstName $lastName';

  int get age {
    final now = DateTime.now();
    int years = now.year - birthDate.year;
    final hadBirthday = now.month > birthDate.month ||
        (now.month == birthDate.month && now.day >= birthDate.day);
    if (!hadBirthday) {
      years--;
    }
    return years;
  }

  /// Абстрактний getter: кожен підклас зобов'язаний його реалізувати
  String get role;
}