# Faraway-Frames
## Open a window into the world of Studio Ghibli

### An iOS and iPadOS app for exploring the Studio Ghibli films.

### Features
- Explore all Studio Ghibli films
- Search for films by title
- View details about each film
- Add a film to 'Up Next' and/or 'Watched' queues, which are displayed on the 'Home' tab.
- Supports portrait and landscape on iPhone and iPad

### Targets
- Swift 6.2
- Swift concurrency settings:
  - Approachable Concurrency = Yes
  - Default Actor Isolation = MainActor
- iOS 26 and iPadOS 26
- Xcode 26

### Technical details
- MVVM + Coordinator.
- UIKit app with SwiftUI for collection view cell content.
- Networking with network-first, local fallback strategy:
  - async/await with `URLSession` for network requests.
  - `NSCache` and `URLCache` for caching of network responses.
  - save data from API to `FileManager` to aid offline support, and provide local data in case of any network error.
- Persistence layer uses `CoreData` with `NSFetchedResultsController`, allowing users to keep track of films they want to watch next or have finished watching.
- The testing frameworks used are Swift Testing and XCTest, and the project is built with TDD.
- Includes accessibility support for Dynamic Type and VoiceOver.

### API
- [Studio Ghibli API](https://ghibliapi.vercel.app).
- No auth needed.

### Getting started
1. Clone the repo.
2. Open `Faraway Frames.xcodeproj`.
3. Build and run.

### 🚧 More coming soon as I build out the project.
