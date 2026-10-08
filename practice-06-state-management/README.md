# Практична робота 6.1: Базовий State Management у Flutter

**Варіант 1: Лічильник з історією.**

Застосунок із лічильником (кнопки «Плюс», «Мінус», «Скинути», крок 1 / 5 / 10), історією змін на окремому екрані та бейджем із кількістю записів у AppBar обох екранів. Значення не може стати від'ємним: користувач бачить пояснення в SnackBar. Лише Flutter SDK, без сторонніх пакетів.

## Запуск

```bash
cd practice-06-state-management
flutter pub get
flutter run            
flutter run -d chrome  
flutter analyze
```

## Етапи роботи

Робота виконана у два етапи, кожен позначено тегом:

| Тег | Що змінилося |
|---|---|
| `stage-1-lifting` | Спільний стан піднято до `AppShell`, передається конструкторами та колбеками, зміни через `setState` |
| `stage-2-inherited` | Стан винесено в `CounterModel` (`ChangeNotifier`), надається через `CounterScope` (`InheritedNotifier`), передавання через проміжні віджети прибрано |

Переглянути код етапу 1: `git checkout stage-1-lifting`. Повернутися: `git checkout main`.

## Структура `lib/`

```text
lib/
├── main.dart
├── models/history_entry.dart       # незмінний запис історії (const-конструктор)
├── state/
│   ├── counter_model.dart          # ChangeNotifier: значення та історія
│   └── counter_scope.dart          # InheritedNotifier з of(context) і read(context)
├── screens/
│   ├── counter_screen.dart
│   └── history_screen.dart
└── widgets/
    ├── counter_display.dart
    ├── counter_controls.dart
    ├── history_badge.dart
    └── history_list.dart
```

На етапі 1 замість `state/` і частини віджетів був `screens/app_shell.dart`, де жив стан.

## Таблиця стану

| Дані | Етап 1: де живуть | Етап 2: де живуть | Чому саме там |
|---|---|---|---|
| Значення лічильника | `State` у `AppShell` | `CounterModel` | Потрібне обом екранам (лічильнику й, через історію, екрану історії), тому не може жити в одному з екранів. На етапі 1 піднято до спільного предка, на етапі 2 винесено в модель |
| Історія змін | `State` у `AppShell` | `CounterModel` | Потрібна екрану історії та бейджам на обох екранах |
| Обраний крок (1 / 5 / 10) | `State` у `CounterScreen` | `State` у `CounterScreen` | Потрібен лише цьому екрану (ефемерний стан), тому лишається в `setState` на обох етапах |
| Який екран показано | `State` у `AppShell` | `Navigator` | Це навігація, а не дані застосунку |

## Журнал перебудов (етап 2)

У ключових віджетах стоїть `debugPrint('build: <Віджет>')`. Нижче фрагменти консолі після дій.

**Дія 1: натискання «Плюс» на екрані лічильника**

```text
<build: CounterDisplay
build: HistoryBadge>
```

**Дія 2: «Очистити історію» на екрані історії**

```text
<build: HistoryList
build: CounterDisplay
build: HistoryBadge>
```

Висновки:

- Після «Плюс» перебудовуються лише `CounterDisplay` і `HistoryBadge`. `CounterScreen` і `CounterControls` не перебудовуються: вони не підписані на модель (`CounterScreen` не звертається до неї, а `CounterControls` використовує `CounterScope.read`, який не підписується).
- Якщо екран історії відкритий, `HistoryBadge` друкується двічі: маршрут історії лежить у стеку під екраном лічильника, і його бейдж теж підписаний на модель.
- Підписку створює лише `CounterScope.of(context)`. Тому кожен віджет, що показує дані, сам викликає `of` у своєму `build`, а не екран.

## Декларація про використання ШІ

Під час виконання практичної роботи я використовував ШІ-асистента Claude (Anthropic) для пояснення різниці між ефемерним станом і станом застосунку, підготовки коду обох етапів (`AppShell`, `CounterModel`, `CounterScope` та віджетів) та оформлення  README. Код я запускав в емуляторі та в браузері, перевірив `flutter analyze`, а журнал перебудов зроблено з власного запуску застосунку.