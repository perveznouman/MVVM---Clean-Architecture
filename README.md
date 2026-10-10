# MVVM + Clean Architecture: Users, Favourites & Weather (SwiftUI + Observation + Core Data)

Same app and features as the MVC / MVVM samples, restructured with Clean Architecture.
Open `CleanUsers.xcodeproj`, run on an iPhone simulator (iOS 17+). Run app tests with Cmd+U; run package tests with:

```bash
cd Packages/CleanCore && swift test
```

## The dependency rule, enforced by the compiler
Source dependencies point inward only. The layers are separate Swift package modules, so an illegal import does not compile.

```
Presentation (app target)  ──►  Domain  ◄──  DataLayer
  SwiftUI views                  entities       DTOs + mappers
  @Observable view models        use cases      URLSession, Core Data
                                 repository     repository implementations
                                 PROTOCOLS
              AppContainer (composition root) is the only code that sees all three
```

| Module | Imports | Contains |
|---|---|---|
| `Domain` | Foundation only | Entities (`User`, `Weather`, ...), use cases, repository **protocols** |
| `DataLayer` | Domain, CoreData | DTOs, mappers, `URLSession` client, Core Data store, repository **implementations** |
| App target | Domain (+ DataLayer in `AppContainer` only) | SwiftUI views, view models, composition root |

Verify it yourself: `grep -rh "^import" Packages/CleanCore/Sources/Domain | sort -u` prints only `Foundation`, and `AppContainer.swift` is the only app file that imports `DataLayer`.

## Dependency inversion in one example
The Domain declares what it needs (`protocol FavoritesRepository`). The Data layer implements it (`FavoritesRepositoryImpl`, internal, backed by Core Data). `DataLayer.makeRepositories()` hands it back typed as the Domain protocol, so nothing outside the module can depend on the concrete class.

## What moved compared to MVVM
| MVVM | Clean |
|---|---|
| View model fetched, saved weather for favourites, fell back to cache | `GetWeatherUseCase` owns those rules; the view model only formats the result |
| `toggle` also quietly cached the avatar in the store | `ToggleFavoriteUseCase` states the rule: favouriting also saves the avatar |
| View model chose between saved and downloaded avatar | `LoadAvatarUseCase` |
| `User` was `Codable`, with `lat`/`lng` strings, shaped like the API | `User` is plain Swift with `Coordinate?`; `UserDTO` + mapper absorb the API shape |
| `WeatherReport` mirrored Open-Meteo and WMO codes | `Weather` + `WeatherCondition` enum; code mapping is in the Data layer, wording and SF Symbols in Presentation |
| Persisted weather used the API JSON shape | `WeatherCacheDTO`: its own storage format, independent of the API |
| Observable `revision` counter | `AsyncStream<[User]>` from `ObserveFavoritesUseCase` (Domain has no UI framework, not even Observation) |
| Core Data on the main context | Core Data on a background context |
| View models depend on service/repository protocols | View models depend only on **use case** protocols |

## Tests (48 total)
- `Domain` (12, `swift test`): use cases against fake repositories. No UI, network or database.
- `DataLayer` (13, `swift test`): DTO decoding and mapping, plus the real Core Data repository on an in-memory store.
- App (23, Cmd+U): view models against fake use cases.

## Costs (be honest about them)
- Far more files and indirection than MVVM for the same feature set. Several use cases here are one-line pass-throughs (`FetchUsersUseCase`, `ObserveFavoritesUseCase`). Many teams skip use cases that add no rule and call the repository directly.
- Mapping between DTO, entity and Core Data object is repeated boilerplate. It pays off when the API or storage changes independently of the app.
- `public` access control everywhere in `Domain` is the price of real module boundaries.

## Notes
- SwiftUI reaches view models through `AppContainer` in the environment (service-locator-style access). The view models themselves receive their use cases through constructor injection.
- Forecast dates are calendar days at 00:00 UTC, formatted with a UTC time zone so the weekday matches the forecast location's own day.
