# 🐰 Expense Splitter — Rabbit World Edition

> *Split bills with your crew. Every human is a rabbit sliding through a different world.*

A cinematic, Disney-inspired expense splitting app built with Flutter. It transforms traditional bill-splitting into a story-driven adventure where each group member becomes an animated rabbit character navigating themed expense worlds.

---

## 📋 Table of Contents

1. [Introduction](#introduction)
2. [App Overview](#app-overview)
3. [Why I Built This](#why-i-built-this)
4. [Branch Strategy](#branch-strategy)
5. [Features](#features)
6. [Architecture & File Structure](#architecture--file-structure)
7. [Tech Stack & Tools](#tech-stack--tools)
8. [Development Phases](#development-phases)
9. [Setup & Installation](#setup--installation)
10. [How to Run](#how-to-run)
11. [App Flow](#app-flow)
12. [Edge Cases & Error Handling](#edge-cases--error-handling)
13. [Challenges Faced](#challenges-faced)
14. [Tricky Decisions](#tricky-decisions)
15. [What I'd Improve With More Time](#what-id-improve-with-more-time)

---

## Introduction

**Expense Splitter — Rabbit World Edition** is a cross-platform app (web + mobile via Expo Go) that helps groups of friends split bills fairly — for meals, trips, or any shared cost. It tracks who paid what, calculates who owes whom, and presents results through an animated, story-like interface.

This project was built as part of a hackathon challenge. I chose to go beyond a plain utility app and gave it a visual identity inspired by *Tsuki Odyssey*, a cozy mobile game about a rabbit exploring different worlds. The result is an app where every user becomes a rabbit, moving through themed expense worlds with cinematic transitions and animated interactions.

---

## App Overview

| | |
|---|---|
| **Framework** | Flutter (Dart) |
| **Platform** | Web (Chrome) + Mobile (Android/iOS via `flutter run`) |
| **Core Function** | Group expense tracking, auto-split, balance calculation |
| **Visual Direction** | Disney/Tsuki Odyssey-inspired animated UI |
| **Branches** | `main` (clean stable logic) · `rabbit-ui` (cinematic animated UI) |

---

## Why I Built This

I was drawn to the Expense Splitter prompt because splitting money is something that genuinely causes friction among friends. It sounds simple — just divide by the number of people — but the real-world messiness (unequal shares, partial payments, multiple payers) makes it surprisingly hard to track.

Beyond the practical utility, I saw it as a design challenge. Finance apps are often cold and corporate. I wanted to ask: *what if splitting money felt fun?* That curiosity led to the rabbit-themed branch — a world where the UI feels like entering a game, not opening a spreadsheet.

The rabbit theme wasn't planned from the start — it came from a coincidence I'm glad I followed. I was playing *Tsuki Odyssey* at the time, a cozy game about a rabbit drifting between peaceful worlds, and something about that quiet unhurried feeling stuck with me. It felt like the exact opposite of how money usually gets talked about. So I borrowed the metaphor: every person in the group becomes a rabbit, every expense category becomes a world, and settling up feels like the end of a shared little adventure rather than an awkward conversation.

---

## Branch Strategy

### `main` — Clean Stable Logic

A straightforward, functional expense splitter. Deliberately minimal and focused — clean logic, clear UI. The reasoning: **prove the core works before making it beautiful**. This is good practice in any project — get the fundamentals solid, then layer on complexity.

**What it includes:**
- Add group members
- Log expenses with a payer and participants
- Auto-calculate who owes whom
- Clean balance summary

### `rabbit-ui` — The Animated Rabbit World

Built on top of the stable core. Inspired by *Tsuki Odyssey*, a game about a rabbit that moves between peaceful worlds.

**The concept:**
- Every user in the group is represented as a **rabbit character** (Lottie animation)
- Expense categories (Food, Transport, Shopping, Accommodation, Trip, Others) are styled as **different worlds**, each with a video background and ambient audio
- Rabbits form animated circle formations around the expense receipt
- The balance screen presents a Disney-style diary book with settlement logic and per-rabbit analytics

---

## Features

### Core (Both Branches)
- ✅ Add / remove group members
- ✅ Add an expense — title, total amount, who paid, who's included
- ✅ Auto-split equally or by custom selection
- ✅ Live balance: *"Alex owes Jamie RM12.50"*
- ✅ Settle up — mark individual debts as paid
- ✅ Debt simplification (greedy net-balance algorithm — minimum transfers)

### Rabbit UI Branch (Additional)
- 🐰 Animated rabbit avatars per member (Lottie)
- 🌍 Six themed expense worlds with video backgrounds and ambient audio
- 🎬 Cinematic PageView carousel with 3D card scaling and rotation
- 🎵 Per-world ambient sound effects
- 📅 Calendar timeline — select a date to begin a story session
- 🏰 Disney castle silhouette UI on the group creation screen
- 🧾 Crumpled receipt ball → tap to unfold → animated receipt form with ink-writing text reveal
- 🎨 Selective Ledger mode — per-rabbit item-by-item expense entry for complex splits
- 📖 Diary book summary — flip animation reveals settlement ledger and spending analytics
- 🏆 Per-rabbit storybook awards based on spending behaviour
- 📸 Receipt image attachment (gallery picker)

---

## Architecture & File Structure

```
expense_splitter/
│
├── lib/
│   ├── main.dart                     # App entry point
│   │
│   ├── features/
│   │   ├── models/
│   │   │   └── rabbit_model.dart     # RabbitModel (name + asset path)
│   │   │
│   │   ├── group/
│   │   │   └── group_creation_page.dart  # Disney castle UI, add/edit/delete rabbit friends
│   │   │
│   │   └── receipt/
│   │       └── receipt_page.dart     # Rabbit circle, receipt unfold, expense form, diary summary
│   │
│   ├── widgets/
│   │   └── rabbit_card.dart          # Reusable Lottie rabbit card with name label
│   │
│   ├── world_home.dart               # Cinematic PageView world selector + scooter rabbit
│   ├── world_scene.dart              # Full-screen world entry with video background
│   └── timeline_page.dart            # Calendar date selector (May 1–31)
│
├── assets/
│   ├── backgrounds/                  # Static fallback images per world
│   ├── videos/                       # Looping world background videos
│   ├── sounds/                       # Ambient audio per world
│   ├── rabbits/                      # Lottie JSON animation files
│   └── images/
│       ├── crumpled_ball.png         # Receipt ball graphic
│       └── receipt.jpg               # Receipt paper texture background
│
├── pubspec.yaml
└── README.md
```

**Key design decisions:**
- **Separate branch strategy** — `rabbit-ui` builds on top of `main` without breaking the stable core
- **RabbitModel over plain strings** — upgrading members from `List<String>` to `List<RabbitModel>` prepares the data layer for animation and character logic without a full rewrite
- **Reusable `RabbitCard` widget** — separates UI from page logic; cleaner and scalable
- **SceneState enum** — `ReceiptPage` uses a state machine (`idleCircle → receiptOpened → summaryView`) to sequence animations safely
- **TickerProviderStateMixin over Single** — used where multiple `AnimationController` instances are needed

---

## Tech Stack & Tools

| Tool | Purpose |
|------|---------|
| Flutter 3.x + Dart | Cross-platform app framework |
| Lottie (`lottie: ^3.1.2`) | Rabbit character animations |
| video_player | Looping world background videos |
| audioplayers | Per-world ambient sound effects |
| google_fonts (Fredoka) | World home screen typography |
| image_picker | Receipt photo attachment |
| Git + GitHub | Version control, branch management (`main` / `rabbit-ui`) |
| VS Code | Primary editor |

> **Note:** The `Caveat` font used throughout the receipt and group creation screens is loaded as a local asset, not via `google_fonts`.

---

## Development Phases

### Phase 1 — Core Split Logic (`main` branch)

**Goal:** Get the fundamental expense splitting working end-to-end.

| Task | Detail |
|------|--------|
| Project initialisation | Set up Flutter project, file structure |
| Expense model | `Expense` class with description, amount, payer, splitAmong |
| Split calculator | Takes expense list → returns simplified debt map |
| Debt simplifier | Greedy net-balance algorithm — minimum transactions |
| Member management | Add / remove members |
| Balance screen | Readable debt sentences |
| Settle up | Mark individual debts as paid |
| Fix: negative balances | Payer was double-counted as both owed and owing — fixed by subtracting their own share |
| Fix: floating point errors | `0.1 + 0.2 = 0.30000000000000004` — fixed with `Math.round(v * 100) / 100` |

---

### Phase 2 — Cinematic World UI (`rabbit-ui` branch)

**Goal:** Build the themed world navigation layer.

| Task | Detail |
|------|--------|
| Branch off `main` | `git checkout -b rabbit-ui` |
| `WorldHome` | PageView carousel with 3D card scaling + rotation, viewportFraction 0.78 |
| Per-world video backgrounds | `video_player` with looping, muted playback; static image fallback during init |
| Ambient audio | `audioplayers` plays per-world `.mp3` on card focus; stops on swipe away |
| Scooter rabbit overlay | `AnimatedPositioned` rabbit that slides across worlds as the page scrolls |
| `WorldScene` | Full-screen entry page with video background and "Open Timeline" button |

---

### Phase 3 — Story Timeline & Group Creation

**Goal:** Build the narrative flow from world entry to group setup.

| Task | Detail |
|------|--------|
| `TimelinePage` | Scrollable May 1–31 calendar; selected day highlighted with rabbit indicator |
| `GroupCreationPage` | Disney castle `CustomPainter` silhouette, floating stars + bubbles via `AnimationController` |
| `RabbitModel` | Upgraded member data from `List<String>` to `List<RabbitModel>` |
| `RabbitCard` widget | Reusable card with Lottie animation + member name |
| Edit / delete members | Inline edit dialog + delete button per card |

---

### Phase 4 — Receipt Interaction & Settlement

**Goal:** Build the core expense interaction and settlement display.

| Task | Detail |
|------|--------|
| Rabbit circle animation | Members animate into a semicircle formation from a central gather, using `cos`/`sin` positioning and `AnimationController` |
| Crumpled receipt ball | Floating, rotating, glowing receipt ball shown before the form opens; tap to reveal |
| Receipt unfold animation | `ScaleTransition` + `RotateTransition` + `FadeTransition` on the receipt card |
| `InkText` widget | Character-by-character text reveal animation on receipt fields |
| Receipt form | Tap-to-edit fields on a receipt paper texture: description, amount, payer, split selection, image upload |
| Selective Ledger mode | Per-rabbit item entry (label, cost, splitWith) for complex unequal splits |
| Settlement algorithm | Greedy creditor/debtor matching — produces minimum transfer list |
| Diary book summary | 3D `rotateY` cover-flip animation reveals two-panel diary: settlement ledger (left) + analytics + awards (right) |
| Per-rabbit awards | Spending behaviour mapped to Disney-style award titles (e.g., "The Kind Payer Award") |

---

###  Completed Milestones Summary

| Phase | What Was Delivered |
|-------|--------------------|
| Phase 1 — Core System | Basic models, `setState` propagation from sub-dialog trees, robust JSON encoding/decoding |
| Phase 2 — World UI | 3D Perspective Carousel replacing standard navigation; boundary scaling crashes fixed with `hasClients && haveDimensions` guards |
| Phase 3 — Unified Sync Layer | Global rabbit overlay inside a `Stack` above the `PageView`; position equations tied directly to `PageController.page` values |
| Phase 4 — Multi-Tier Navigation | Full thematic screen sequence: `WorldHome → WorldScene → TimelinePage → GroupCreationPage → ReceiptPage` |
| Phase 5 — Disney Visual Refactor | Checkbox arrays replaced with amber glow `boxShadow`; `CurvedAnimation(Curves.easeOut)` used to keep opacity strictly within `0.0 → 1.0`; `TickerProviderStateMixin` adopted for multi-controller pages |



### Prerequisites
- Flutter SDK 3.x or higher
- Dart SDK
- Chrome browser (for web testing)
- For mobile: Android Studio or Xcode, or a physical device

### Install

```bash
git clone https://github.com/yourusername/expense-splitter.git
cd expense-splitter/expense_splitter
flutter pub get
```

### Asset setup

Ensure the following folders exist and are declared in `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/backgrounds/
    - assets/videos/
    - assets/sounds/
    - assets/rabbits/
    - assets/images/
```

---

## How to Run

### Run in browser (web)
```bash
flutter run -d chrome
```

For best rendering quality (recommended — matches the production build):
```bash
flutter run -d chrome --web-renderer canvaskit
```

### Deploy publicly (Firebase Hosting)
```bash
flutter build web --web-renderer canvaskit
firebase deploy
```

> **Note on latency:** The app is deployed via Firebase Hosting. Initial load may take a few seconds due to the video and Lottie animation assets. This is a known trade-off of asset-heavy Flutter Web builds — a CDN and proper asset compression would reduce it significantly in a production setup.

### Run on Android / iOS
```bash
flutter run
# Connect a device or start an emulator first
```

### Switch to rabbit-ui branch
```bash
git checkout rabbit-ui
flutter pub get
flutter run -d chrome
```

---

## App Flow

```
WorldHome (swipeable category worlds)
        ↓ Enter World
WorldScene (full-screen video entry)
        ↓ Open Timeline
TimelinePage (calendar — select a date)
        ↓ Start Story
GroupCreationPage (create group name + add rabbit friends)
        ↓ Start Expense Story
ReceiptPage (rabbits form a circle → tap receipt ball → fill expense form → save)
        ↓ Save →
Diary Summary (book-flip animation → settlement ledger + analytics + awards)
        ↓ Back to Home 🏰
WorldHome
```

---

## Edge Cases & Error Handling

| Edge Case | Problem | Solution |
|-----------|---------|----------|
| **Web localization popup error** | `No MaterialLocalizations found` when calling `showDialog` on web | Wrapped routing entry point with an inner `Builder` so dialog context correctly inherits `MaterialApp` localizations |
| **Zero-balance analytics crash** | Division by zero in chart percentage calculations when no expenses exist | Added `total > 0` guard before rendering `PieChart`; clamped `BarChart` `maxY` to minimum `10` for valid sizing |
| **Payer is also a participant** | Payer counted as both owed and owing | Subtract payer's own share from total owed |
| **Floating point arithmetic** | `RM10 / 3 = 3.3333...` causing unbalanced totals | Round all currency to 2dp; use `toStringAsFixed(2)` throughout |
| **1-person group** | App would show "X owes X" | Minimum 2 members required before navigating to ReceiptPage |
| **0-amount expense** | Division by zero in splits | Validate amount > 0 before running settlement |
| **All participants removed** | Expense with no one to split | Defaults to all members if selectedMembers is empty |
| **Selective ledger, no entries** | Settlement skips rabbit with no rows | "Tap Me!" bouncing badge appears on first unconfigured rabbit |
| **Animation overshoot on opacity** | `Curves.easeOutBack` pushed opacity past 1.0 → assertion error | Clamped with `_fadeAnim.value.clamp(0.0, 1.0)` |
| **Multiple AnimationControllers** | `SingleTickerProviderStateMixin` crashed when more than one controller was added | Replaced with `TickerProviderStateMixin` throughout |
| **Positioned outside Stack** | `Incorrect use of ParentDataWidget` crash | Ensured all `Positioned` widgets are direct children of a `Stack` |
| **Dynamic asset paths in Flutter** | `require('../assets/${name}.png')` fails at build time | Pre-declared all assets in `pubspec.yaml`; static references in code |
| **PageController null page** | `_controller.page!` crashed on first frame | Used `_controller.page ?? 0` with `hasClients && haveDimensions` guard |

---

## Challenges Faced

### 1. Rabbit Animation Layout Crash
The rabbit Lottie widget was initially placed inside a `Column` inside `buildWorldCard()`. This caused `Incorrect use of ParentDataWidget` crashes because `Positioned` was used outside a `Stack`.

**Solution:** Moved the rabbit to a global `Stack` overlay above the `PageView`, controlled by `currentPage` tracking. This also fixed the duplicate rabbit issue (rabbit was rendering once per card).

### 2. Fixing One Thing Broke Another
For example: fixing the balance calculation to handle "payer is also a participant" broke the settle-up screen because debt IDs changed structure. Then fixing that broke the history list.

**Solution:** Once this pattern appeared, I stopped making multiple changes at once. Each fix was committed separately, the full user flow tested manually after each change.

### 3. Reanimated / Animation Crashes on Hot Reload
Animation controllers did not always survive hot reload, causing ticker assertion failures.

**Solution:** Always `flutter clean` + `flutter run` (not hot reload) after any `initState` or `AnimationController` change.

### 4. Selective Ledger Mode UX
The selective ledger allows each rabbit to log their own items independently — but it wasn't obvious to users which rabbits still needed entries.

**Solution:** Added a bouncing "Tap Me! 🐾" badge (using `AnimationController` + `Positioned`) above the first unconfigured rabbit whenever selective mode is active and the receipt is open.

### 5. Video Player on Flutter Web
`VideoPlayerController.asset` on web required the video files to be in the correct `assets/` path and declared in `pubspec.yaml`. The static image fallback (`AnimatedOpacity`) hides the black init screen while the video loads.

### 6. Debt Simplification Algorithm
Minimising transactions in a group is non-trivial. A naive approach showing every raw debt becomes overwhelming fast.

**Solution:** Greedy net-balance algorithm — calculate each person's net position, then repeatedly match the largest creditor with the largest debtor. Runs in O(n log n), doesn't always find the absolute minimum but is very close for typical group sizes.

### 7. CanvasKit Font Rendering on Web
Flutter on Chrome occasionally reported missing fallback fonts when rendering emoji or high-order Unicode characters, causing visual glitches in world card titles and receipt labels.

**Solution:** Set `GoogleFonts.fredoka()` as the global fallback inside `ThemeData` so the engine always has a known font to fall back to, regardless of character map.

### 8. RenderFlex Overflow on Receipt Card
Loading the full receipt form inside an unbounded `Column` caused layout overflows, especially on smaller browser viewports.

**Solution:** Wrapped nested action layouts with `MainAxisSize.min` and added `SingleChildScrollView` to the receipt paper layer, keeping it scrollable and reliably sized across varying screen heights.

### 9. Async State Loss from Sub-Dialogs
Adding member names or uploading images from overlay dialogs sometimes failed to update the parent page — the changes were applied inside the dialog's isolated state and never propagated back.

**Solution:** Lifted all mutation operations (add, edit, delete) up to `_GroupCreationPageState` methods. Dialogs call these methods directly rather than managing their own state, so every change immediately reflects in the parent widget tree.



**`RabbitModel` vs plain strings:** Upgrading members from `List<String>` to `List<RabbitModel>` added a small amount of boilerplate but made the entire animation and character system extensible without a later rewrite. The right call.

**Two branches instead of feature flags:** The rabbit UI is a fundamentally different visual direction, not a toggle. Branches keep `main` clean and independently evaluable, while `rabbit-ui` shows the full creative vision.

**`SceneState` enum for `ReceiptPage`:** The receipt page has many sequential states (idle circle → receipt ready → receipt opened → summary view). Using an enum state machine instead of multiple `bool` flags made the transitions readable and predictable.

**Selective vs global split as a toggle:** Rather than two separate screens, the mode is toggled inline on the receipt card. This keeps the user in the same "world" and makes the difference feel like a story choice rather than a navigation detour.

**Diary book for settlement, not a dialog:** Settlement results shown as a book-flip animation rather than a plain `AlertDialog` makes the payoff feel earned — the expense story has a proper ending.

---

## What I'd Improve With More Time

- **Persistence** — currently all state is in-memory and lost on app restart. Migrating to Firebase Firestore or Supabase would give real-time group sync across devices
- **Authentication** — user accounts so groups can be shared and rejoined across sessions
- **More world themes** — the concept scales cleanly; each new world just needs a background video, audio file, and colour palette
- **Rabbit character customisation** — different Lottie animations or colour variants per rabbit to make each member visually distinct
- **Receipt OCR** — use the device camera + an OCR pipeline to auto-fill expense descriptions and amounts from a photo of the bill, removing manual entry entirely
- **Automated tests** — the settlement and debt simplification utilities are pure functions and would be straightforward to cover with Dart unit tests
- **Web performance** — proper asset CDN, video compression, and code splitting for a faster initial load; the current Firebase-hosted build carries noticeable latency from unoptimised video and Lottie bundles

---

## Known Issues

- **Flutter Web lifecycle warning** — `A message on the flutter/lifecycle channel was discarded before it could be handled` may appear on startup. This is a non-blocking web initialisation timing issue; the app runs correctly.
- **Audio on web** — browsers require a user interaction before audio can play. The first world card's ambient sound triggers on the initial swipe, not on page load.
- **`video_player` on web** — `.MOV` files (Shopping World) may have reduced compatibility depending on the browser. `.MP4` files work reliably across all tested browsers.
- **Firebase Hosting initial load latency** — the deployed build is asset-heavy (videos + Lottie JSON files). First load takes a few seconds on average connections. Assets are not yet CDN-optimised or compressed.

---

*Built with curiosity, a love for cozy games, and a healthy fear of unbalanced tabs.*
