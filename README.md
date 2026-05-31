# MoveQuest 📍🏃

Mobilna aplikacja (Flutter) łącząca **fitness i grywalizację**, **questy w terenie oparte na lokalizacji (GPS)** oraz **rywalizację ze znajomymi**. Ruszaj się w realnym świecie, zdobywaj punkty, odblokowuj odznaki i ścigaj się w rankingach.

## Główne filary

- **Dziś** – pulpit dzienny: kroki, dystans, kalorie, dzienny cel i aktywne questy.
- **Mapa** – questy w terenie na mapie (OpenStreetMap), nawigacja do punktów.
- **Wyzwania** – wyzwania grupowe i ranking znajomych.
- **Profil** – poziom, doświadczenie (XP) i odznaki.

## Stos technologiczny

| Obszar | Technologia |
|---|---|
| Framework | Flutter 3.41 / Dart 3.11 |
| Stan | [Riverpod](https://riverpod.dev) (`flutter_riverpod`) |
| Nawigacja | [go_router](https://pub.dev/packages/go_router) (StatefulShellRoute) |
| Mapy | [flutter_map](https://pub.dev/packages/flutter_map) + OpenStreetMap (bez klucza API) |
| Lokalizacja | [geolocator](https://pub.dev/packages/geolocator) |
| Dane lokalne | [shared_preferences](https://pub.dev/packages/shared_preferences) |

## Struktura projektu

```
lib/
├── main.dart                 # punkt wejścia (ProviderScope)
├── app.dart                  # MaterialApp.router + motyw
├── core/
│   ├── theme/                # kolory i motyw Material 3
│   ├── router/               # konfiguracja go_router
│   └── widgets/              # powłoka z dolną nawigacją
└── features/                 # moduły funkcjonalne (feature-first)
    ├── home/                 # ekran „Dziś"
    ├── map/                  # questy na mapie
    ├── challenges/           # wyzwania i ranking
    └── profile/              # profil, poziom, odznaki
```

## Uruchomienie

```bash
flutter pub get        # na tej maszynie: w razie błędu "_temp in use" użyj: flutter pub get --offline
flutter run            # uruchom na podłączonym urządzeniu/emulatorze
flutter analyze        # analiza statyczna
flutter test           # testy
```

## Status

🚧 Wczesny etap — działający szkielet UI z nawigacją i przykładowymi danymi.
Kolejne kroki: realne źródła danych (kroki/GPS), backend, autoryzacja, logika questów.
