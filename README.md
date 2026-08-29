# Ascend

Become stronger every day. A single-user personal self-improvement OS: gym tracking, habits, goals, body metrics, progress photos, journaling, and analytics — built with Swift 6, SwiftUI, SwiftData, CloudKit, and HealthKit.

This repository contains the **complete Swift source tree**, but no `.xcodeproj`. It was generated on Windows, where Xcode isn't available, so the project file itself needs to be created on a Mac (a hand-authored `.xcodeproj` is fragile and risks failing to open — Xcode's own project generator is the reliable path). Setup below takes about 10 minutes.

## 1. Create the Xcode project

1. On a Mac, open Xcode → **File → New → Project → iOS → App**.
2. Product Name: `Ascend`. Interface: **SwiftUI**. Language: **Swift**. Storage: leave as default (we're wiring SwiftData manually) — do **not** check "Host in CloudKit" here, we configure that ourselves below.
3. Save it as a sibling of this folder, e.g. `Ascend-Xcode/`.
4. Set the deployment target to **iOS 18.0** (the code uses the iOS 18 `Tab(...)` TabView API, `@Observable`, and Swift 6 strict concurrency).
5. In the new project, delete the placeholder `ContentView.swift` and the default `Item.swift` (or whatever SwiftData starter model Xcode generated) — this repo replaces them.

## 2. Bring in this source tree

1. In Finder, delete the auto-generated `Assets.xcassets` and `Info.plist` inside the new Xcode project's folder (we bring our own).
2. Drag the `Ascend/App`, `Ascend/Core`, and `Ascend/Features` folders from this repo into the Xcode project navigator, under the `Ascend` group. Choose **"Create groups"** and make sure **"Copy items if needed"** is checked, target `Ascend`.
3. Drag `Ascend/Resources/Assets.xcassets` in the same way.
4. Drag `Ascend/Resources/Info.plist` and `Ascend/Resources/Ascend.entitlements` in — then, in the target's **Build Settings**, set `INFOPLIST_FILE` and `CODE_SIGN_ENTITLEMENTS` to point at their paths if Xcode didn't wire them automatically.
5. Drag the `AscendTests` folder in as a new **Unit Testing Bundle** target (File → New → Target → Unit Testing Bundle, name it `AscendTests`, then add the files) so `swift test`/⌘U picks up `ScoringServiceTests`, `HabitStreakTests`, and `GoalProgressTests`.

## 3. Enable capabilities

In the `Ascend` target → **Signing & Capabilities**:

- **+ Capability → iCloud** → check **CloudKit**, and add/select a container named `iCloud.com.ascend.app` (or update `AppContainer.live()` in [`AppContainer.swift`](Ascend/App/AppContainer.swift) to match whatever container name you choose).
- **+ Capability → HealthKit**. No special entitlement values are needed beyond what's already in `Ascend.entitlements`.
- **+ Capability → Background Modes** is *not* required — Ascend only schedules local notifications, no background fetch or remote push.
- Set your Team and confirm automatic signing resolves.

## 4. First CloudKit schema deploy

The first time you run on a signed-in device/simulator with iCloud, SwiftData will attempt to create the CloudKit schema automatically. To make sure the schema is visible to TestFlight testers (whose devices only see the **Production** CloudKit environment, not Development):

1. Run the app once on your device from Xcode (Development environment) to populate the schema.
2. Go to [CloudKit Dashboard](https://icloud.developer.apple.com/dashboard/) → your `iCloud.com.ascend.app` container → **Schema** → **Deploy Schema to Production**.
3. Re-deploy any time you add/change a `@Model` type.

## 5. Run it

- Build & run on a **real device** for HealthKit (the simulator has no Health data and most HealthKit APIs are unavailable there).
- First launch seeds a few default exercises, starter habits, and one example goal (see [`SeedData.swift`](Ascend/App/SeedData.swift)).

---

## Project structure

```
Ascend/
  App/                     AscendApp entry point, DI container, seed data, root TabView
  Core/
    Models/                SwiftData @Model types (Program, Day, Exercise, Session, Habit, Goal, Journal, BodyMetric, Settings...)
    Services/              HealthKitServicing / NotificationServicing protocols + real & no-op implementations, ScoringService
    DesignSystem/          Colors, typography, spacing tokens, reusable components (card, progress ring, stat tile)
  Features/
    Dashboard/              Command center + widgets (score, streak, habits, workout, weight, goals, weekly activity)
    Workouts/               Programs, days, exercise library, active workout + rest timer, history, analytics
    Habits/                 Habit list, editor, detail (monthly calendar, streaks, success rate)
    Goals/                  Goal list, editor, detail (milestones, progress updates)
    Journal/                Entry list/search/tags, editor with guided prompts, mood trend
    Profile/                Body metrics, progress photos (with comparison slider), preferences, HealthKit & notification settings, data export
AscendTests/                Unit tests for scoring, habit streak, and goal progress logic
```

Architecture: MVVM with `@Observable` `@MainActor` ViewModels, dependency injection via `AppContainer` (passed through the SwiftUI environment), protocol-oriented services (`HealthKitServicing`, `NotificationServicing`) so tests and previews substitute no-op implementations instead of touching real HealthKit/Notifications.

## Known limitations / next steps

- **Written and reviewed, not compiled** — this source was authored without access to Xcode/a Swift compiler. Build it and skim for typos or API drift (Swift Charts / SwiftData APIs shift slightly between Xcode versions) before assuming it's 100% clean; send me any compiler errors and I'll fix the source directly.
- No app icon image has been supplied — `AppIcon.appiconset` has the slot but no image; add a 1024×1024 PNG before archiving for TestFlight/App Store.
- Workout "today" scheduling is rotation-based (next unstarted day in the active program cycles round-robin) rather than tied to specific weekdays — intentional simplification; revisit if you want fixed weekday scheduling.
- No iPad/Mac-specific layouts yet — the SwiftUI views use adaptive stacks/lists so they'll run on iPad/Mac Catalyst, but multi-column layouts optimized for larger screens are a deliberate future step, per the original brief.

---

## TestFlight readiness checklist

- [ ] **Bundle identifier** set and matches an App ID registered in your Apple Developer account, with **HealthKit** and **iCloud (CloudKit)** capabilities enabled on that App ID.
- [ ] **Signing** — automatic signing resolved with your Team, or manual provisioning profile includes the HealthKit + CloudKit entitlements.
- [ ] **Info.plist usage strings** present for `NSHealthShareUsageDescription`, `NSHealthUpdateUsageDescription`, `NSPhotoLibraryUsageDescription`/`NSPhotoLibraryAddUsageDescription` — all four are already in [`Info.plist`](Ascend/Resources/Info.plist); missing ones are an automatic Beta App Review rejection.
- [ ] **CloudKit schema deployed to Production** (see step 4 above) — otherwise TestFlight testers' data silently fails to sync.
- [ ] **App icon** added (1024×1024, no alpha, no transparency) — App Store Connect rejects builds without one.
- [ ] **Version & build number** bumped in the target's General settings before each archive.
- [ ] **Archive** via Product → Archive (only works with a real device or "Any iOS Device" selected as the run destination, not a simulator).
- [ ] **App Store Connect record** created (App Store Connect → My Apps → +) with the same bundle ID, before you can upload a build.
- [ ] **Test on a real device** at least once before distributing — HealthKit doesn't work in Simulator at all, and CloudKit sync behaves differently.
- [ ] **Internal Testing** group (up to 100 testers, your team, no review needed) is the fastest way to get this on your own phone via TestFlight.
- [ ] **External Testing** (public link, unlimited testers) requires a **Beta App Review** pass — usually the same checks as full App Review minus the metadata review, so make sure the app doesn't crash on first launch and permission prompts have real usage descriptions (already covered above).
- [ ] **Export compliance** — you'll be asked whether the app uses encryption; standard HTTPS/CloudKit usage typically qualifies for the standard exemption, but confirm in App Store Connect's prompt.
