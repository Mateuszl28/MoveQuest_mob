# MoveQuest 📍🏃

A Flutter mobile app that blends **fitness & gamification**, **location-based quests in the real world (GPS)**, and **social competition**. Move in the real world, earn points, unlock badges, and climb the leaderboards.

## Core pillars

- **Today** – daily dashboard: steps, distance, calories, daily goal, and active quests.
- **Map** – location-based quests on a map (OpenStreetMap), navigate to points.
- **Challenges** – group challenges and a friends leaderboard.
- **Profile** – level, experience (XP), and badges.

## Tech stack

| Area | Technology |
|---|---|
| Framework | Flutter 3.41 / Dart 3.11 |
| State | [Riverpod](https://riverpod.dev) (`flutter_riverpod`) |
| Navigation | [go_router](https://pub.dev/packages/go_router) (StatefulShellRoute) |
| Maps | [flutter_map](https://pub.dev/packages/flutter_map) + OpenStreetMap (no API key) |
| Location | [geolocator](https://pub.dev/packages/geolocator) |
| Local storage | [shared_preferences](https://pub.dev/packages/shared_preferences) |

## Project structure

```
lib/
├── main.dart                 # entry point (ProviderScope)
├── app.dart                  # MaterialApp.router + theme
├── core/
│   ├── theme/                # colors and Material 3 theme
│   ├── router/               # go_router configuration
│   └── widgets/              # shell with bottom navigation
└── features/                 # feature-first modules
    ├── home/                 # "Today" screen
    ├── map/                  # quests on the map
    ├── challenges/           # challenges and leaderboard
    └── profile/              # profile, level, badges
```

## Getting started

```bash
flutter pub get        # on this machine: if you hit a "_temp in use" error, run: flutter pub get --offline
flutter run            # run on a connected device/emulator
flutter analyze        # static analysis
flutter test           # tests
```

## Status

🚧 Early stage — a working UI skeleton with navigation and sample data.
Next steps: real data sources (steps/GPS), backend, authentication, quest logic.
