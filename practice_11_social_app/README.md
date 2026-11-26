# Практична робота 11 (Частина 3): Комплексний мережевий Flutter додаток

**Тема:** Повна інтеграція REST API, авторизації та real-time функцій  
**Варіант 6:** Соціальна мережа (mini) на базі [DummyJSON API](https://dummyjson.com)

---

## Реалізований функціонал

- **JWT-авторизація та безпека:**
  - Вхід за логіном і паролем (`POST /auth/login`) зі збереженням `accessToken` та `refreshToken` у `flutter_secure_storage`.
  - Автоматичний вхід при запуску додатка та завантаження даних профілю (`GET /auth/me`).
  - Автоматичне оновлення протермінованого токена при отриманні статусу `401 Unauthorized` через `POST /auth/refresh` у `AuthInterceptor`.
- **Робота з постами та коментарями (CRUD):**
  - Стрічка постів (`GET /posts`) із пагінацією при прокручуванні, підтримкою `pull-to-refresh` та локальним перемиканням лайків.
  - Пошук постів за ключовими словами (`GET /posts/search?q=...`).
  - Створення нових постів із тегами (`POST /posts/add`).
  - Екран деталей поста з переглядом та додаванням коментарів (`GET /posts/{id}/comments`, `POST /comments/add`).
  - Профіль користувача зі списком власних публікацій (`GET /posts/user/{userId}`) та виходом із сесії.
- **Offline-режим та кешування:**
  - Кешування відповідей API у локальному сховищі `Hive`.
  - Моніторинг стану інтернет-з'єднання через `connectivity_plus` та відображення інформаційного банера `OfflineBanner` при роботі з кешем.

---

## Технічний стек

- **HTTP-клієнт та Interceptors:** `dio` (`AuthInterceptor`, `LoggingInterceptor`, `RetryInterceptor`)
- **State Management:** `provider` (`AuthProvider`, `PostsProvider`)
- **Локальне кешування:** `hive`, `hive_flutter`
- **Захищене зберігання токенів:** `flutter_secure_storage`
- **Перевірка стану мережі:** `connectivity_plus`

---

## Архітектура проєкту

Проєкт побудовано за принципами Clean Architecture з розділенням на `core`, `features` та `shared`:

```text
lib/
├── core/
│   ├── error/
│   │   └── app_exception.dart              # Уніфікована обробка мережевих винятків
│   ├── network/
│   │   ├── interceptors/
│   │   │   ├── auth_interceptor.dart       # Підстановка Bearer JWT та refresh при 401
│   │   │   ├── logging_interceptor.dart    # Логування HTTP-запитів і відповідей
│   │   │   └── retry_interceptor.dart      # Повторні спроби при тайм-аутах/збоях
│   │   ├── api_endpoints.dart              # Константи ендпоінтів DummyJSON
│   │   └── dio_client.dart                 # Конфігурація Dio з 3 interceptors
│   └── storage/
│       └── cache_service.dart              # Перевірка мережі та кешування в Hive
├── features/
│   ├── auth/
│   │   ├── data/                           # UserModel, AuthRepository
│   │   ├── domain/                         # UserEntity
│   │   └── presentation/                   # AuthProvider, LoginScreen
│   └── posts/
│       ├── data/                           # PostModel, CommentModel, PostsRepository
│       ├── domain/                         # PostEntity, CommentEntity
│       └── presentation/                   # PostsProvider, HomeScreen, FeedTab, SearchTab, ProfileTab, PostDetailScreen, CreatePostScreen
├── shared/
│   └── widgets/
│       └── offline_banner.dart             # Індикатор роботи в offline-режимі
└── main.dart                               # Ініціалізація залежностей та запуск додатка
```

---

## Інструкція із запуску (Setup)

1. Клонувати репозиторій та перейти в директорію практичної роботи:
   ```bash
   git clone [https://github.com/Kiter0/Programming-Mobile-Platforms.git](https://github.com/Kiter0/Programming-Mobile-Platforms.git)
   cd Programming-Mobile-Platforms/practice_11_social_app
   ```
2. Встановити залежності:
   ```bash
   flutter pub get
   ```
3. Запустити додаток на емуляторі або фізичному пристрої:
   ```bash
   flutter run
   ```
4. **Тестові облікові дані DummyJSON для входу:**
   - **Username:** `emilys`
   - **Password:** `emilyspass` *(або натиснути кнопку «Заповнити демо-акаунт» на екрані входу)*

---

## Скріншоти роботи додатка

Розміщенні у папці screenshots

---

## Декларація використання ШІ

Під час виконання практичної роботи використовувався **Google Gemini**.

**Мета використання:** допомога в проєктуванні архітектури Flutter-проєкту, налаштуванні мережевого клієнта з interceptors, реалізації локального кешування, а також усуненні помилок і перевірці коду.

**Приклад використаного промпту:**

«Допоможи спроєктувати архітектуру Flutter-додатка для міні-соціальної мережі на базі DummyJSON API. Реалізуй клієнт Dio з інтерсепторами для JWT-авторизації та refresh-токена, додай кешування відповідей у Hive та перевірку з'єднання через connectivity_plus».

**Використані результати:** окремі фрагменти коду інтерсепторів (`AuthInterceptor`, `LoggingInterceptor`, `RetryInterceptor`), сервісу кешування (`CacheService`), моделей даних (`PostModel`, `CommentModel`, `UserModel`) та базових екранів інтерфейсу.

**Самостійна перевірка:** перевірено роботу JWT-авторизації, оновлення сесії, пагінації стрічки, пошуку, створення постів, додавання коментарів та відображення кешованих даних в offline-режимі. Узгоджено обмеження Dart SDK у `pubspec.yaml`, адаптовано віджет-тест, виконано `flutter analyze` та `flutter test`, а також перевірено запуск застосунку на емуляторі.