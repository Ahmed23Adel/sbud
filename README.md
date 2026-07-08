<div align="center">

# sBud — Social Fitness iOS App

**Create group fitness sessions. Track live. Review together.**

*Built in a 3-person Agile team · Feb 2026 – May 2026 · iOS 17.6+ · Swift*

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-17.6+-blue.svg)](https://developer.apple.com/ios/)
[![Firebase](https://img.shields.io/badge/Firebase-12.6+-yellow.svg)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-Academic-lightgrey.svg)]()

</div>

---

## What is sBud?

sBud lets groups of friends create and join fitness sessions — running, cycling, hiking, skiing, gym, swimming, tennis, yoga — and experience them together. During a session, every participant's metrics are tracked live. When it ends, everyone reviews shared analytics: pace splits, elevation profiles, route maps, speed comparisons, and per-participant leaderboards.

It's the kind of app where the social layer *is* the product — not bolted on after.

---

## Screenshots

<table>
  <tr>
    <td align="center" width="33%">
      <img alt="Available events" src="https://github.com/user-attachments/assets/37876b1d-e1c8-4538-81e5-b179bb0bc986" width="240" /><br />
      <sub><b>Available events</b></sub>
    </td>
    <td align="center" width="33%">
      <img alt="Available events" src="https://github.com/user-attachments/assets/6f071930-9fcc-4854-b471-1b011e0ea419" width="240" /><br />
      <sub><b>Available events</b></sub>
    </td>
    <td align="center" width="33%">
      <img alt="Home" src="https://github.com/user-attachments/assets/5fe277fa-ffa4-42ee-89f4-6f130bbe9e18" width="240" /><br />
      <sub><b>Home</b></sub>
    </td>
  </tr>
  <tr>
    <td align="center" width="33%">
      <img alt="Filters" src="https://github.com/user-attachments/assets/c08e06fc-6de5-49d4-a269-23b2009e9ccb" width="240" /><br />
      <sub><b>Filters</b></sub>
    </td>
    <td align="center" width="33%">
      <img alt="Filters" src="https://github.com/user-attachments/assets/b4a46269-3eeb-48b1-91f7-5c178165fd29" width="240" /><br />
      <sub><b>Filters</b></sub>
    </td>
    <td align="center" width="33%">
      <img alt="Event details" src="https://github.com/user-attachments/assets/4cacb805-93fc-4fbc-bc6d-1d464f92e2a1" width="240" /><br />
      <sub><b>Event details</b></sub>
    </td>
  </tr>
  <tr>
    <td align="center" width="33%">
      <img alt="Search" src="https://github.com/user-attachments/assets/09fe0bf3-09a5-4958-b3a8-32faf65a42c5" width="240" /><br />
      <sub><b>Search</b></sub>
    </td>
    <td align="center" width="33%">
      <img alt="Profile" src="https://github.com/user-attachments/assets/8fc941ab-548c-4d4b-8050-3f46f7c1aa53" width="240" /><br />
      <sub><b>Profile</b></sub>
    </td>
    <td align="center" width="33%">
      <img alt="Adding new event" src="https://github.com/user-attachments/assets/47150167-41fa-48aa-bbb3-a5026729e3d8" width="240" /><br />
      <sub><b>Add event</b></sub>
    </td>
  </tr>
  <tr>
    <td align="center" width="33%">
      <img alt="Adding new event" src="https://github.com/user-attachments/assets/d67b8c82-443b-4e2c-bea3-a8c3dee6a4da" width="240" /><br />
      <sub><b>Add event</b></sub>
    </td>
    <td></td>
    <td></td>
  </tr>
</table>
---

## What has been built 

This was a 3-developer team. 

- **Entire MVVM + Coordinator architecture** — designed the 4-tab, 8-coordinator hierarchy from scratch, defined coordinator handoff protocols and delegate contracts between `MainCoordinator` and child coordinators
- **Firestore data model** — collection structure, denormalized `flattenedEvents` for geo-query performance, session history as an array field on the event doc
- **Live session system** — GPS tracking, SwiftData crash-safe buffering, offline metrics retry service with `NWPathMonitor` + 24h fallback logic
- **HealthKit integration** — full `HKWorkoutRoute` for GPS sports (visible as route lines in Apple Fitness), duration-only workouts for time-based sports
- **Session summary pipeline** — generic protocol + extension pattern for sport-specific ViewModels, `ImageRenderer` share card with Core Graphics map compositing via `MapSnapshotBuilder`
- **Universal Links deep linking** — profile and event deep links handled in `MainCoordinator`
- **GitHub Actions CI/CD** — XCTest suite runs on every commit and PR to main
- **Agile/Scrum lead** — sprint planning, PR code reviews, backlog grooming across the team

---

## Technical Highlights

### A coordinator that actually scales

The app has 4 tabs, each with its own coordinator, all wired through `MainCoordinator`. Auth events, session lifecycle, and deep links all route through it cleanly — no `NotificationCenter` hacks, no singletons firing navigation.

```
MainCoordinator  (AuthCoordinatorDelegate + SessionCoordinatorDelegate)
├── AvailabilityAppCoordinator   Tab 1 — event map, discovery, creation
├── HomeAppCoordinator           Tab 2
├── ProfileAppCoordinator        Tab 3 — profile, friends, event management
├── StoriesAppCoordinator        Tab 4 — ephemeral posts with event linking
└── Messages                     Tab 5 — direct messaging
```

Every view gets its coordinator as an `@EnvironmentObject`. Views never push routes — they call coordinator methods. No navigation logic leaks into SwiftUI views.

### Offline-first session uploads

Sessions are the worst time for the app to lose network. Here's how we handle it:

1. During the session, metrics accumulate in **SwiftData** (crash-safe, persisted)
2. At session end, upload is attempted — if it fails, a `PendingMetricsUpload` record stays in SwiftData
3. `MetricsUploadRetryService` drains the queue on: **app foreground**, **network restore** (via `NWPathMonitor`), and every **10 minutes**
4. Participants can't upload until the creator ends the session — so the retry logic reads `finalEndDateTime` from Firestore before uploading, and falls back after 24 hours

This means no data loss even if the user loses signal mid-run.

### Two-phase geohash event discovery

Querying "events near me" at any scale with Firestore requires careful design. We use a two-phase approach:

1. **Phase 1** — query `flattenedEvents` (a denormalized collection) using geohash prefix ranges to get a cheap candidate set
2. **Phase 2** — filter that candidate set by precise Haversine distance on the client

This keeps Firestore read costs low and avoids full-collection scans.

### Session summary analytics

Post-session analytics are the most complex part of the app. Data flows from Firestore → typed repository → generic ViewModel protocol → sport-specific subtype:

```
Firestore Events/{id}/metrics
  → ActivityMetricsRepository<Metric>
  → SessionSummaryViewModel (protocol + default extension — shared logic without class inheritance)
  → ViewModelSessionSummaryRunning / Cycling / Hiking / Skiing / TimeBased<M>
     — ParticipantSummary[] with per-user pace, speed, elevation, splits, track
     — MetricInsights: min / max / avg + who holds each
  → ViewSessionSummaryConditional (switches on activityType)
  → Sport-specific charts: pace trend, split bars, participant comparison, route map
```

Because `@Observable` classes can't inherit in Swift, the shared logic lives in a protocol extension — a deliberate architectural choice to avoid a base class trap.

### Share card with Core Graphics map compositing

The session share card is a `UIImage` rendered at 3× via `ImageRenderer` and exported through `UIActivityViewController`. The problem: `ImageRenderer` can't capture `UIViewRepresentable` content like `MKMapView`.

Solution: `MapSnapshotBuilder` uses `MKMapSnapshotter` to produce a dark-style map bitmap, then draws each participant's GPS polyline on it with Core Graphics before the final compositing step. The result is a fully shareable image that looks identical to the in-app map.

### AVCaptureSession QR code scanner (UIKit bridge)

The QR scanner (`CameraViewController`) uses `AVCaptureSession` + `AVMetadataOutput` in a `UIViewRepresentable`, bridged into SwiftUI. The `Vision` framework validates the scanned payload before it's acted on. Scanning a friend's QR code navigates directly to their profile.

---

## Architecture

### MVVM + Coordinator

```
Coordinator → View → ViewModel → Repository → Firebase / REST API
```

| Layer | Responsibility |
|---|---|
| **Coordinator** | Owns `NavigationPath` + sheets. Handles all routing. |
| **View** | Pure SwiftUI. Zero business logic. Binds to ViewModel. |
| **ViewModel** | `@Observable` (iOS 17). Owns loading state, calls repositories. |
| **Repository** | Typed, protocol-backed. One Firestore collection per repository. |

### Repository pattern

Every repository conforms to a generic `IFirebaesRepository<T>` protocol (typo preserved — it's in 60+ files). Query building uses a composable `QueryCollectionBuilder` / `QueryCollectionGroupBuilder` API — filters and order-bys chain together, keeping all Firestore query logic out of ViewModels.

---

## Full Technology Stack

| Domain | Technology |
|---|---|
| Language | Swift 5.9 |
| UI framework | SwiftUI (primary), UIKit (bridges) |
| State management | `@Observable` (iOS 17), `ObservableObject`, Combine |
| Navigation | Coordinator pattern, `NavigationPath`, sheets |
| Database | Firestore (real-time listeners + repository pattern) |
| Auth | Firebase Auth — Email/Password + Google Sign-In |
| REST | Alamofire + custom `AdelsonApiCaller` |
| Local persistence | SwiftData (`@Model`, `ModelContainer`, `ModelContext`) |
| Health | HealthKit (`HKWorkoutRoute` for GPS, duration workouts for time-based) |
| Maps | MapKit, `MKMapSnapshotter`, `MKPolyline`, `UIViewRepresentable` overlays |
| Charts | Swift Charts (`Chart`, `BarMark`, `LineMark`) |
| Camera / QR | `AVCaptureSession`, `AVMetadataOutput`, `Vision` |
| Push notifications | Firebase Cloud Messaging (FCM), `UNUserNotificationCenter` |
| Analytics | Firebase Analytics |
| Crash reporting | Firebase Crashlytics |
| Deep linking | Universal Links (AASA), `onOpenURL`, `MainCoordinator.handle(universalLink:)` |
| Network monitoring | `NWPathMonitor` (Network framework) |
| Image loading | Kingfisher (async caching, custom `AvatarKFImage` wrapper) |
| Photo picking | `PhotosUI` (`PhotosPicker`) |
| Animations | Lottie |
| Phone validation | PhoneNumberKit |
| QR generation | QRCode (dagronf) |
| Geo indexing | Geohash |
| Logging | `OSLog` / `Logger` |
| CI/CD | GitHub Actions (XCTest on every commit + PR) |
| Dependency management | Swift Package Manager |

---

## Project Scale

| Metric | Count |
|---|---|
| Swift source files | ~467 |
| View + ViewModel files | ~368 |
| Business logic files | ~68 |
| Coordinators | 19 files across 8 coordinators |
| Supported activity types | 8 (Running, Cycling, Hiking, Skiing, Gym, Swimming, Tennis, Yoga) |
| XCTest files | 18 |
| Firestore collections | 10 |
| SPM dependencies | 11 packages |

---

## Running Locally

```bash
git clone <repo>
open sbud.xcodeproj   # Xcode 16+, iOS 17.6+ simulator or device
# Hit ⌘R — SPM packages resolve automatically
# Firebase config (GoogleService-Info.plist) is already included
```

**Tests:** `⌘U` — 18 XCTest files covering coordinators, ViewModels, repositories, and map utilities.

---

## Stories Feature

Stories are ephemeral image posts (24h expiry, server-controlled) with optional captions and event linking. Fully REST-based — no Firestore. Multipart image upload, emoji reactions, and per-image view tracking. A `StoriesHelperService` groups the raw feed response by user and injects the current user's reaction client-side before display.

---

<div align="center">

*Swift · SwiftUI · UIKit · Firebase · HealthKit · MapKit · SwiftData · Combine · GitHub Actions*

</div>
