# Ascend

Become stronger every day. A single-user personal self-improvement OS: gym tracking, habits, goals, body metrics, progress photos, journaling, and analytics — built with Swift 6, SwiftUI, SwiftData, CloudKit, and HealthKit.

This repository contains the **complete Swift source tree**, but no `.xcodeproj` — it was generated on Windows, where Xcode isn't available. Instead of a hand-authored (and fragile) `.xcodeproj`, the project file is generated from [`project.yml`](project.yml) using [XcodeGen](https://github.com/yonaskolb/XcodeGen), and a GitHub Actions workflow ([`.github/workflows/ios-ci.yml`](.github/workflows/ios-ci.yml)) builds and tests the app on a real macOS runner in the cloud — so you get compiler feedback without anyone owning a Mac.

## 0. Continuous Integration (no Mac required)

Push this repo to GitHub and the `iOS CI` workflow runs automatically on every push/PR to `main` (or trigger it manually from the Actions tab — "Run workflow"). It:

1. Installs XcodeGen and runs `xcodegen generate` to produce `Ascend.xcodeproj` from `project.yml` (the generated project is gitignored — it's always regenerated fresh, so `project.yml` is the single source of truth).
2. Builds the `Ascend` scheme against a generic iOS Simulator destination (fast compile check, no signing needed).
3. Runs the `AscendTests` unit tests against a booted iPhone 16 simulator.

No Apple Developer account, signing certificate, or physical device is needed for this — `CODE_SIGNING_ALLOWED=NO`/`CODE_SIGNING_REQUIRED=NO` are set explicitly so HealthKit/CloudKit entitlements don't block a simulator build. This gets you real compiler-error feedback on every push; it does **not** replace running on a real device (HealthKit needs one) or the TestFlight archive step below, which does need a Mac (or a paid CI plan with archive/export support) and a real signing identity.

If your GitHub runner's preinstalled Xcode doesn't have an "iPhone 16" simulator (Apple renames default devices periodically), the workflow's "List available iPhone simulators" step prints what's actually available — swap the name in `ios-ci.yml`'s test step to match.

## 1. Open the project on a Mac

1. Install XcodeGen once: `brew install xcodegen`.
2. From the repo root, run:
   ```bash
   xcodegen generate
   open Ascend.xcodeproj
   ```
3. That's it — `Ascend.xcodeproj` (with both the `Ascend` app target and `AscendTests` unit test target already wired up, Info.plist/entitlements already pointed at the right paths) is generated fresh from [`project.yml`](project.yml). It's gitignored, so re-run `xcodegen generate` any time you pull changes to `project.yml` or add/remove source files — no manual dragging files into Xcode required.
4. Deployment target is already set to **iOS 18.0** in `project.yml` (the code uses the iOS 18 `Tab(...)` TabView API, `@Observable`, and Swift 6 strict concurrency).

## 2. Enable capabilities

In the `Ascend` target → **Signing & Capabilities**:

- **+ Capability → iCloud** → check **CloudKit**, and add/select a container named `iCloud.com.ascend.app` (or update `AppContainer.live()` in [`AppContainer.swift`](Ascend/App/AppContainer.swift) to match whatever container name you choose).
- **+ Capability → HealthKit**. No special entitlement values are needed beyond what's already in `Ascend.entitlements`.
- **+ Capability → Background Modes** is *not* required — Ascend only schedules local notifications, no background fetch or remote push.
- Set your Team and confirm automatic signing resolves.

## 3. First CloudKit schema deploy

The first time you run on a signed-in device/simulator with iCloud, SwiftData will attempt to create the CloudKit schema automatically. To make sure the schema is visible to TestFlight testers (whose devices only see the **Production** CloudKit environment, not Development):

1. Run the app once on your device from Xcode (Development environment) to populate the schema.
2. Go to [CloudKit Dashboard](https://icloud.developer.apple.com/dashboard/) → your `iCloud.com.ascend.app` container → **Schema** → **Deploy Schema to Production**.
3. Re-deploy any time you add/change a `@Model` type.

## 4. Run it

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
