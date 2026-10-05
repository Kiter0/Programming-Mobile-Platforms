# Практична робота 4: Основи мови Dart

**Дисципліна:** Програмування для мобільних платформ  
**Автор:** [Ім'я Прізвище]

> Проєкт розташований у папці `practice-04-dart-basics` репозиторію Programming-Mobile-Platforms. Усі практичні роботи курсу зберігаються в одному репозиторії, кожна у власній папці.

## Опис

Набір консольних програм на Dart, що охоплює п'ять завдань практичної роботи: змінні та типи, функції, ООП (система управління університетом), колекції та обробка даних (включно з аналізом CSV), асинхронне програмування та робота з файлами.

## Вимоги та встановлення Dart SDK

- Dart SDK 3.0.0 або новіший (перевірено на 3.13.3)
- Інструкція встановлення: https://dart.dev/get-dart
- Перевірка версії: `dart --version`

## Структура проєкту

```
practice-04-dart-basics/
├── bin/          програми для запуску (task1-task5, калькулятор, аналізатори)
├── lib/
│   ├── models/   Person, Student, Course, University (Professor)
│   └── utils/    Calculator, TextAnalyzer, DataProcessor, CsvLoader,
│                 AsyncFileProcessor, FibonacciCalculator
├── test/         unit-тести та допоміжні функції
├── tool/         coverage_summary.dart, benchmark.dart
├── data/         students.csv (вхідні дані)
├── output/       згенеровані звіти та JSON
├── docs/         UML-діаграма, звіти про покриття та бенчмарки
└── screenshots/  скріншоти виконання
```

## Запуск

З кореня проєкту (`practice-04-dart-basics`):

```bash
dart pub get
```

| Завдання | Команда |
|---|---|
| 1. Змінні та типи | `dart run bin/task1_variables.dart` |
| 2. Функції | `dart run bin/task2_functions.dart` |
| 2.3 Калькулятор | `dart run bin/calculator_app.dart` |
| 2.3 Текстовий аналізатор | `dart run bin/text_analyzer_app.dart` |
| 3. Система університету | `dart run bin/task3_classes.dart` |
| 4. Колекції | `dart run bin/task4_collections.dart` |
| 4.3 Аналізатор CSV | `dart run bin/csv_analyzer_app.dart` |
| 5. Async | `dart run bin/task5_async.dart` |
| 5.2 Async File Processor | `dart run bin/async_file_processor_app.dart` |
| Тести | `dart test` |
| Бенчмарки | `dart run tool/benchmark.dart` |
| Покриття коду | `dart pub global run coverage:test_with_coverage` та `dart run tool/coverage_summary.dart` |

Програма `async_file_processor_app` читає `output/students.json`, який створює `task5_async`, тому спершу запустіть її.

## Приклади використання класів

```dart
final university = University(name: 'Технічний університет');

university.addCourse(Course(
  id: 'C1', name: 'Основи програмування',
  description: 'Вступний курс', credits: 5, instructor: 'Петренко',
));
university.addStudent(Student(
  id: 'S1', firstName: 'Анна', lastName: 'Коваль',
  birthDate: DateTime(2005, 3, 14),
));

university.enrollStudent('S1', 'C1');
university.findStudentById('S1')!.addGrade('C1', 90);

print(university.generateStatistics());

// Поліморфізм: Student і Professor є Person
for (final Person person in university.allPeople) {
  print('${person.role}: ${person.fullName}');
}
```

UML-діаграма класів: [docs/uml_class_diagram.md](docs/uml_class_diagram.md).

## Тести та якість коду

- `dart test`: усі unit-тести проходять
- `dart analyze`: без зауважень
- `dart format .`: код відформатовано
- Покриття коду: [docs/coverage_report.txt](docs/coverage_report.txt)
- Бенчмарки: [docs/benchmark_report.txt](docs/benchmark_report.txt)

## Прийняті рішення та припущення

- `Person` винесено в окремий файл `person.dart`, щоб уникнути циклічного імпорту; `Student` і `Professor` успадковують його.
- До `Student` додано необов'язкове поле `skills` (для `getUniqueSkills`).
- `groupStudentsByYear` групує студентів за роком народження, бо в моделі немає поля «курс навчання».
- Оцінки задано за 100-бальною шкалою, курс вважається складеним при оцінці від 60.
- Формат CSV: навички розділені `;`, оцінки записано як `курс:оцінка` через `;`.

## Матеріали для здачі

Скріншоти виконання програм, тестів, покриття та документації лежать у папці `screenshots/`.