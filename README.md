# Faraway-Frames
## Open a window into the world of Studio Ghibli

### An iOS and iPadOS app for exploring the Studio Ghibli films.

### Features
- Explore all Studio Ghibli films
- Search for films by title
- View details about each film
- Supports portrait and landscape on iPhone and iPad

### Targets
- Swift 6
- Swift concurrency settings:
  - Approachable Concurrency = Yes
  - Default Actor Isolation = MainActor
- iOS 26 and iPadOS 26
- Xcode 26

### Technical details
- MVVM + Coordinator.
- UIKit app with a bit of SwiftUI.
- Networking with async/await, `URLSession`, and `NSCache` for image caching.
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
