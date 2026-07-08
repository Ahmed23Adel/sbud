# sBud — Developer Guide

sBud is a social fitness iOS app where users create and join group activities (running, cycling, gym, hiking, skiing, swimming, yoga, tennis). Participants track live metrics, then review post-session analytics together.

---

## How to open and run

1. Open `sbud.xcodeproj` in Xcode (minimum Xcode 16, iOS 17.6 deployment target).
2. Select a simulator or physical device running iOS 17.6+.
3. Build and run (`⌘R`). No extra setup — all SPM dependencies resolve automatically.
4. **Firebase config** is in `sbud/GoogleService-Info.plist` (already present; do not commit changes to this file).
5. The backend REST API is at `https://sbud-backend.onrender.com/api/v1/` — it is configured at startup in `sbudApp.swift`.

**Tests:** `sbudTests/` target contains 7 XCTest files. Run with `⌘U`.

---

## Source layout

```
sbud/                        ← Xcode project root (contains sbud.xcodeproj)
└── sbud/                    ← Source root
    ├── sbudApp.swift         App entry point + AppDelegate
    ├── ContentView.swift     (unused scaffold)
    ├── Coordination/         Navigation coordinators (16 files)
    ├── Screens/              All UI views + ViewModels (~307 files)
    │   ├── Authentication/
    │   ├── HomeTabs/
    │   ├── AvailbilityEvent/ ← event discovery, creation, details
    │   ├── Profile/          ← own/others profiles, event lists, settings
    │   ├── Session/          ← live session + post-session summary
    │   ├── Messages/
    │   ├── Stories/          ← stories feed, viewer, create flow
    │   ├── Basic/            ← reusable UI primitives + color tokens
    │   └── ...
    ├── BusinessLogic/        Data layer (~53 files)
    │   ├── Authentication/
    │   ├── UserProfile/
    │   ├── Location/
    │   ├── StoriesHelper/    ← StoriesHelperService (groups feed by user)
    │   └── FirebaseDatabase/ ← repository pattern + Firestore wrappers
    ├── LocalDB/              SwiftData model for offline session storage
    ├── Modifiers/            SwiftUI modifiers (glass, popup, input styling)
    ├── Notifications/        FCM token management
    ├── Constants/            @AppStorage keys
    └── lottiefiles/          Lottie JSON animations
sbudTests/                   Unit tests (7 files)
```

---

## Architecture

### MVVM + Coordinator pattern

Every screen follows:

```
Coordinator  →  View  →  ViewModel  →  Repository  →  Firebase / REST
```

- **Views** are pure SwiftUI, hold no business logic, receive data via `@State`/`@Observable` VMs.
- **ViewModels** are `@Observable` classes (iOS 17 macro, newer code) or `ObservableObject` (older screens). They own loading state, call repositories, and expose computed display values.
- **Coordinators** own the `NavigationPath`/route state. Views never push routes themselves — they call coordinator methods (e.g., `coordinator.goToSessionSummary(event:)`).
- **Repositories** implement `IFirebaesRepository` (note the typo — it's spelled that way in the codebase). Each repository is one Firestore collection.

### Coordinator hierarchy

```
MainCoordinator  (@StateObject in SbudApp, @EnvironmentObject everywhere)
│  routes: .loading | .signUp | .signIn | .profileSetup | .home
│          .creatorSession(event, isCreated) | .othersSession(...)
│          .sessionSummary(event)
│
├── AvailabilityAppCoordinator  (Tab 1 — event map + discovery)
│   routes: .moreInfoEvent(eventId) | .addNewEvent | .profile(userId) | .chat(...)
│
├── HomeAppCoordinator           (Tab 2 — minimal scaffold)
│
├── ProfileAppCoordinator        (Tab 3 — profile + event management)
│   root: .myProfile | .othersProfile
│   pushed: .settings | .myEvents | .othersEvents | .myEventDetails(eventId)
│           .othersEventDetails(eventId) | .friendsList | .othersProfile(userId)
│           .scannedProfile | .eventConversations | .sessionSummary(event)
│   sheets: .hosts(eventId) | .qrCode
│
├── StoriesAppCoordinator        (Stories tab — feed + viewer + create)
│   pushed: .friendStories(userId)
│   sheets: .createStory
│   nested sheets: .eventPicker(...)
│
└── (Messages — Tab 4, direct view, no coordinator)
```

`MainCoordinator` is both `AuthCoordinatorDelegate` (child coordinators call `coordinatorDidRequestLogout()` etc.) and `SessionCoordinatorDelegate` (sessions call `sessionDidEnd()`).

When a coordinator is embedded inside another tab's NavigationStack it receives an `onPush` closure; without it, it manages its own `NavigationPath`.

---

## Firebase data model

### Firestore collections

| Collection | Contents |
|---|---|
| `users` | `UserProfile` documents, keyed by Firebase Auth UID |
| `Events` | `EventFullDetails` documents |
| `Events/{eventId}/metrics` | Per-participant activity metrics (one doc per user per session) |
| `OnGoingSession` | Marker docs for active sessions (used to show the join-session button) |
| `joinedEvents` | Records of users who joined an event |
| `friends` | Friend relationships |
| `friendRequests` | Pending friend requests |
| `users/{userId}/hostInvitations` | Host invitation records |
| `Events/{eventId}/hosts` | Host sub-collection |
| `flattenedEvents` | Denormalized event copies for geo-query performance |

Session history is stored as a `sessionHistory` array field directly on the `Events` document (not a subcollection).

### Auth

Firebase Email/Password + Google Sign-In. `AuthenticationManager.shared` wraps `Auth.auth()` and exposes `signIn`, `signUp`, `signOut`, `checkAuthStatus()`. Profile sync runs after login via `ProfileManager.shared.syncProfileAfterLogin()`.

---

## Session summary architecture

The post-session analytics screens are the most complex area. Key concepts:

### Data flow

```
Firebase Events/{id}/metrics
   ↓ ActivityMetricsRepository<Metric>
   ↓ .fetchMetrics(eventId:)  +  .fetchSessionHistory(eventId:)
   ↓
SessionSummaryViewModel protocol (default impl in extension)
   ↓
Activity-specific ViewModel (e.g. ViewModelSessionSummaryRunning)
   — computes participantSummaries: [ParticipantSummary]
   — computes MetricInsights (min/max/avg with holder names + colors)
   ↓
ViewSessionSummaryConditional  (switches on EventFullDetails.activityType)
   ↓
ViewSessionSummaryRunning / Cycling / Hiking / Skiing
ViewSessionSummaryTimeBased<M>  (generic — covers Gym, Swimming, Tennis, Yoga)
```

### Key shared types

- **`SessionMetricsBase`** — protocol all `MetricsCollected*` structs conform to. Required fields: `userId`, `startDateTime`, `endDateTime`, `metricsCreatorType`, `numSession`.
- **`ParticipantSummary`** — fat struct with all activity fields (pace, speed, elevation, splits, track). GPS-only fields default to `0`/`[]` for time-based activities.
- **`DisplaySplit`** — unified split for charts. `chartValue` is pace (min/km) or speed (km/h); `isSpeed: Bool` tells chart how to format the axis.
- **`MetricInsights`** — `{ avg, min: MetricHolder, max: MetricHolder }`. Used by `MetricInsightsCard`.
- **`AvatarKFImage<Fallback>`** — reusable circular avatar backed by Kingfisher with ProgressView while loading and a fallback view on error.

### Share card

`SessionShareCardView` is rendered to a `UIImage` via `ImageRenderer` at 3× scale and shared via `UIActivityViewController`. Before rendering, `MapSnapshotBuilder.snapshot(summaries:)` takes an async `MKMapSnapshotter` snapshot (dark map, no POIs) and draws colored polylines onto it — because `MultiRouteMapView` (a `UIViewRepresentable`) can't be captured by `ImageRenderer`.

---

## Stories feature

Stories are ephemeral user posts (images + optional caption, optional event link) that expire after a period set by the backend. They are separate from the session summary system and use the REST API exclusively — no Firestore.

### Key files

| Path | Purpose |
|---|---|
| `BusinessLogic/FirebaseDatabase/Models/Story.swift` | `Story`, `StoryImage`, `FriendWithStories`, `StoriesFeedResponse`, `CreateStoryResponse` |
| `BusinessLogic/FirebaseDatabase/Repositories/Stories/StoriesRepository.swift` | REST repository — feed, create, view, react, delete |
| `BusinessLogic/FirebaseDatabase/Repositories/Stories/IStoriesRepository.swift` | Repository protocol |
| `BusinessLogic/StoriesHelper/StoriesHelperService.swift` | Groups feed stories by user → `[FriendWithStories]`; injects `myReaction` from reactions dict |
| `Coordination/StoriesCoordinator/StoriesCoordinator.swift` | `ObservableObject` coordinator — push, sheets |
| `Coordination/StoriesCoordinator/StoriesRoute.swift` | `StoriesRoutePushed`, `StoriesSheetType`, `StoriesCreateStorySheet` |
| `Coordination/StoriesCoordinator/StoriesAppCoordinator.swift` | Embeds coordinator in a `NavigationStack` |
| `Screens/Stories/ViewModelStoriesHome.swift` | Home feed VM |
| `Screens/Stories/ViewModelFriendStories.swift` | Viewer VM (progress, reactions, view tracking) |
| `Screens/Stories/ViewModelCreateStory.swift` | Create flow VM, exposes `EventSummary` for event picker |
| `Screens/Stories/Home/` | `ViewStoriesHome`, `FriendStoryAvatar` |
| `Screens/Stories/FriendStories/` | `ViewFriendStories`, `StoryImagePage`, `StoryProgressBar`, `StoryReactionBar` |
| `Screens/Stories/CreateStory/` | `ViewCreateStory` + sub-views (`StoryCaptionFieldView`, `StoryThumbnailStripView`, `StoryMainPreviewView`, `StoryEventFieldView`, `EventPickerRow`, `StoryEventPicker`) |

### Data model

```
Story
  id              String           // "storyId" on the wire
  userId          String
  authorName      String?          // "userName"
  authorProfileImageUrl String?    // "userAvatarUrl"
  eventId/eventName/eventImage/activityType  optional event link
  images          [StoryImage]     // server sends [String] URLs, decoded to indexed StoryImage
  text            String?
  reactions       [String: String] // userId → emoji
  createdAt       Date
  expiresAt       Date?
  myReaction      String?          // set client-side by StoriesHelperService
```

`StoryImage` wraps a URL string with its index so pages and progress bars can be keyed by index.

### REST endpoints (relative to `/api/v1`)

| Method | Path | Purpose |
|---|---|---|
| GET | `/stories/feed?limit=&offset=` | Paginated friend feed |
| POST | `/stories` | Create story (multipart: images + optional eventId/text) |
| POST | `/stories/{id}/view-image` | Mark an image viewed (`{ imageIndex }`) |
| POST | `/stories/{id}/react` | Set/clear emoji reaction (`{ emoji: String? }`) |
| DELETE | `/stories/{id}` | Delete own story |

### Auth for REST

`StoriesRepository` uses `IAuthTokenProvider` / `FirebaseAuthTokenProvider` to attach a `Bearer` JWT to every request. This is the same token pattern used by all other REST calls in the app.

### Coordinator routes

```
StoriesAppCoordinator
  pushed: .friendStories(userId: String)
  sheets: .createStory
  nested sheets (within create flow): .eventPicker(events:isLoading:selectedId:onSelect:)
```

---

## Naming conventions

| Thing | Convention | Example |
|---|---|---|
| View files | `View{Feature}.swift` | `ViewSessionSummaryRunning.swift` |
| ViewModel files | `ViewModel{Feature}.swift` | `ViewModelSessionSummaryRunning.swift` |
| Coordinators | `{Tab}Coordinator.swift` + `{Tab}AppCoordinator.swift` | `ProfileCoordinator.swift` |
| Route enums | `{Tab}Route.swift` / `{Tab}Destination.swift` | `ProfileRoute.swift` |
| Repository protocols | `I{Entity}Repository.swift` | `IMetricsRepository.swift` |
| Repository classes | `{Entity}Repository.swift` | `UserRepository.swift` |
| Model structs | `{EntityName}.swift` | `EventFullDetails.swift` |
| Metrics structs | `MetricsCollected{Sport}.swift` | `MetricsCollectedCycling.swift` |
| Metrics collectors | `MetricsCollector{Sport}.swift` | `MetricsCollectorRun.swift` |

---

## ViewModel pattern

Newer ViewModels (iOS 17+) use `@Observable`:

```swift
@Observable
class ViewModelMyFeature {
    var items: [Item] = []
    var isLoading = false

    func load() async { ... }
}

// In view:
@State private var vm = ViewModelMyFeature()
```

Older ViewModels use `ObservableObject`:

```swift
class ViewModelOldFeature: ObservableObject {
    @Published var items: [Item] = []
}

// In view:
@StateObject private var vm = ViewModelOldFeature()
```

**Do not mix** these approaches in a single new file. Prefer `@Observable` for any new code.

---

## Repository pattern

All repositories conform to `IFirebaesRepository` (note: one 'e' — existing typo, do not fix without updating all conformances):

```swift
protocol IFirebaesRepository {
    associatedtype T
    associatedtype Constants: IRepositoryConstants

    var collectionPath: String { get }
    var firebaseClient: FirebaseClient { get }
    var constants: Constants { get }

    func fetch(query: IQueryBuilder) async throws -> [T]
    func fetchById(_ id: String) async throws -> T?
    func create(_ item: T) async throws -> String
    func update(_ id: String, _ item: T) async throws
    func delete(_ id: String) async throws
    func initQueryBuilderObject() -> IQueryBuilder
}
```

Query building uses `QueryCollectionBuilder` / `QueryCollectionGroupBuilder` with `.appendFilter(Filter(...))` and `.appendOrderBy(OrderByAggregate(...))` chaining.

---

## Color system

There are **two separate color palettes** in this codebase — be aware of which one applies where.

### General UI (`Screens/Basic/ColorExtensions.swift`)
```swift
Color.mainColor       // lime green (213, 255, 95) — primary brand
Color.darkBackground  // dark navy  (30, 30, 37)
Color.blueColor       // cyan       (0, 227, 253)
Color.blackBackground // near-black (0.05, 0.05, 0.05)
Color.backgroundColor // mid-grey
```

### Session/Summary UI (`Screens/Session/subViews/MetricCardView.swift`)
```swift
Color.neonCyan    // (0.0,  0.95, 1.0)  — primary accent in summary screens
Color.neonGreen   // (0.6,  1.0,  0.3)  — positive / max value
Color.neonPink    // (1.0,  0.2,  0.5)  — negative / early-exit / min value
Color.cardBg      // (0.08, 0.09, 0.12) — card background
Color.surfaceBg   // (0.05, 0.06, 0.08) — page background
Color.labelGray   // white 45%          — secondary text
```

Participant colors are assigned by index from a fixed palette in `ParticipantSummary.color`: `[neonCyan, neonGreen, neonPink, gold, purple]`.

---

## Image loading

**Always use `KFImage` (Kingfisher), never `AsyncImage`.** For circular avatars use the shared helper:

```swift
AvatarKFImage(url: someUrlString.flatMap(URL.init), size: 44) {
    fallbackView  // shown while loading AND on error
}
```

`AvatarKFImage` shows a `ProgressView` while fetching and switches to the fallback via `@State var failed` + `.onFailure`.

---

## Activity metrics collection

Each sport has a `MetricsCollector{Sport}` class that:
1. Receives location/sensor updates during the live session.
2. Accumulates a `{Sport}SessionSnapshot` in memory (and writes to SwiftData for crash safety).
3. On session end, uploads a `MetricsCollected{Sport}` document to `Events/{eventId}/metrics`.

`TrackPoint: Codable { timestamp, latitude, longitude }` is the GPS record type shared by all GPS sports.

Time-based activities (Gym, Swimming, Tennis, Yoga) record only start/end timestamps — no GPS or splits.

---

## Singletons to know

| Singleton | Purpose |
|---|---|
| `AuthenticationManager.shared` | Firebase Auth state, sign-in/out |
| `ProfileManager.shared` | Local + remote `UserProfile` CRUD |
| `LocationManager.shared` | `CLLocationManager` wrapper |
| `GeohashService.shared` | Geohash-based proximity indexing |
| `PopUpGenerator.shared` | Global toast/popup display |

---

## SPM dependencies

| Package | Version | Used for |
|---|---|---|
| `firebase-ios-sdk` | ≥ 12.6.0 | Auth, Firestore, Storage, Messaging |
| `GoogleSignIn-iOS` | ≥ 9.0.0 | Google OAuth |
| `Kingfisher` | ≥ 8.6.2 | Remote image caching |
| `lottie-ios` | ≥ 4.5.2 | JSON animations |
| `PhoneNumberKit` | ≥ 4.2.8 | Phone number validation/formatting |
| `QRCode` | ≥ 28.0.2 | QR code generation + scanning |
| `Geohash` | ≥ 1.0.0 | Lat/lon → geohash conversion |
| `Alamofire` | ≥ 5.11.0 | HTTP networking |
| `AdelsonApiCaller` | — | Custom REST client (by project author) |
| `AdelsonAuthManager` | — | Custom auth manager (by project author) |
| `AdelsonValidator` | — | Input validation helpers (by project author) |

---

## Things to know before making changes

- **`IFirebaesRepository`** has a typo (one 'e'). Do not rename it — you'll break all conformances.
- **`myEventDertails`** (with typo) is a property name in both `ViewModelMyEventDetails` and `ViewModelOthersEventDetails`. Leave as-is.
- **`@Observable` classes cannot inherit** from each other (Swift limitation). The `SessionSummaryViewModel` pattern uses a protocol + extension for shared logic rather than a base class.
- **`ImageRenderer` cannot capture `UIViewRepresentable`** content (e.g., `MKMapView`). Use `MapSnapshotBuilder` when you need a map in a rendered image.
- **Preview mocks live in `#if DEBUG`** blocks. `PreviewData.swift` (`Screens/Session/SessionSummary/Shared/`) provides mock participants, sessions, and events. Always pass `userId:` explicitly when constructing `MetricsCollected*` instances in previews — the default value calls `ProfileManager.shared` which may not be available in preview context.
- **`goToSessionSummary(evnet:)`** — the parameter label has a typo (`evnet`). Used in both `ProfileCoordinator` and both event detail views. Leave as-is.
- The **session summary conditional router** (`ViewSessionSummaryConditional.swift`) switches on `EventFullDetails.activityType`. Adding a new sport requires a new case there, a new `ViewModelSessionSummary{Sport}` + `ViewSessionSummary{Sport}`, and a new `MetricsCollected{Sport}` conformance in `SessionMetricsBase.swift`.
- `AccentDivider`, `SectionHeaderView`, `SummaryStatBanner` are session-screen-only components co-located in `Screens/Session/`.
- `BasicFloatingButton` (`Screens/Basic/`) is the standard floating action button used on event detail screens (summary chart, session start).
