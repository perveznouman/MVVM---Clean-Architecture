# MVVM + Clean Architecture, the basics (SwiftUI)

A deliberately small app: a **Users** tab (from `jsonplaceholder.typicode.com/users`), a **Favourites** tab, and a **detail screen**.
Tap the star next to a user to favourite them (saved on the device). Tap a row to see everything about that user.

Open `CleanBasic.xcodeproj` (iOS 17+). Run tests with Cmd+U (23 tests).

## Layers (plain folders in one target)

```
Presentation  ──►  Domain  ◄──  Data
```
Arrows mean "knows about". Domain knows nobody.

| Layer | Files | Job |
|---|---|---|
| **Domain** | `User` (+ `Address`), `UserRepository`, `GetUsersUseCase`, `FavoritesRepository`, `FavoritesUseCases` | What the app does: entities, use cases, and the protocols it needs from outside |
| **Data** | `UserDTO`, `RemoteUserRepository`, `StoredUserDTO`, `UserDefaultsFavoritesRepository` | How data is fetched and saved (network, UserDefaults) |
| **Presentation** | `Users/`, `Favorites/`, `Detail/`, `Shared/` | View models (state + formatting) and SwiftUI views |
| **App** | `AppContainer`, `RootView`, `CleanBasicApp` | Connects the layers and shows the two tabs |

## How "tap the star" flows

```
UserRowView (star button)
  → UsersViewModel.toggleFavorite(id:)
    → ToggleFavoriteUseCase            (rule: favourite ⇄ not favourite)
      → FavoritesRepository (protocol)
        ⇠ UserDefaultsFavoritesRepository saves it, then announces the new list
  ← both view models listening to ObserveFavoritesUseCase receive the list and the screens redraw
```

The two tabs never talk to each other. Both just watch the same favourites stream.

## How opening the detail screen works

```
Tap a row  →  NavigationLink(value: user)  →  navigationDestination(for: User.self)
           →  makeDetailViewModel(user)    (a closure given by AppContainer, so views never build view models)
           →  UserDetailViewModel          (formats the fields; reuses ObserveFavorites + ToggleFavorite)
           →  UserDetailView
```

The detail screen needed **no new use case**: showing a user we already have is not a business action, and its star is the same favourite use case as the list. What it did need was a richer `User` entity (phone, website, address, avatar URL), which touched the entity, both DTOs and the mappers: a good example of how one change fans out across layers.

## Why the Data layer has two DTOs
- `UserDTO`: the shape the **API** sends.
- `StoredUserDTO`: the shape saved on the **device**.

Keeping them separate means an API change can never break data already saved on someone's phone.

## Things to try next
- Swap `UserDefaultsFavoritesRepository` for a Core Data version: only the Data layer and `AppContainer` change.
- Save the avatar picture for favourites so the detail screen works fully offline (it uses `AsyncImage` now).
- Add weather for the user's address.
