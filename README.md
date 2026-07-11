<<<<<<< HEAD

Link to access: https://wonderland-expense-splitter.web.app/

# Expense Splitter 💰

A comprehensive Flutter application for splitting bills and expenses among friends, designed for trips, meals, and shared costs. This app provides real-world expense tracking with advanced features like categories, search, filters, and persistent data storage.

## 📋 Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Development Phases](#development-phases)
- [Problems Faced & Solutions](#problems-faced--solutions)
- [Problem-Solving Approach](#problem-solving-approach)
- [Installation](#installation)
- [Usage](#usage)
- [Screenshots](#screenshots)
- [Future Enhancements](#future-enhancements)
- [Contributing](#contributing)
- [License](#license)

## ✨ Features

### Core Functionality
- **Group Management**: Create, rename, and delete expense groups
- **Member Management**: Add and remove group members with balance tracking
- **Expense Tracking**: Add expenses with detailed information (description, amount, payer, category, date, split among)
- **Balance Calculation**: Automatic calculation of who owes what, with equal splitting
- **Persistence**: All data saved locally using shared_preferences

### Advanced Features
- **Expense Summary**: Quick overview showing total spent, number of expenses, and average per person
- **Categories**: Tag expenses with predefined categories (Food, Transport, Shopping, Accommodation, Other)
- **Search & Filter**: Search expenses by description or payer; filter by category and date ranges
- **Receipt-Style UI**: Modern card-based expense display with all details
- **Settle Up Calculator**: Shows minimum payments needed to balance all accounts
- **Receipt Photo Attachments**: Attach photos to expenses for better record-keeping
- **Spending Analytics & Charts**: Visual insights with pie charts for categories and bar charts for member spending
- **Date Selection**: Choose expense dates with date picker
- **Custom Splitting**: Select exactly who shares each expense

### User Experience
- **Responsive Design**: Works on web (Chrome), mobile, and desktop
- **Material Design**: Clean, intuitive UI following Flutter Material guidelines
- **Real-time Updates**: Balances and summaries update instantly
- **Error Handling**: Validation for inputs, graceful handling of edge cases

## 🛠 Tech Stack

- **Framework**: Flutter 3.11.5
- **Language**: Dart
- **State Management**: StatefulWidget with setState
- **Persistence**: shared_preferences package
- **Localization**: flutter_localizations for web compatibility
- **Image Handling**: image_picker package for photo attachments
- **Charts**: fl_chart package for data visualization
- **Platform**: Cross-platform (Web, Android, iOS, Desktop)

## 🚀 Development Phases

The app was built iteratively in phases, starting from basic functionality and adding complexity step-by-step.

### Phase 1: Basic Group Management
**Objective**: Create the foundation with group creation and navigation.

**Steps**:
1. Set up Flutter project with basic structure
2. Implement Group model class with name and empty lists
3. Create main screen with group list and add group dialog
4. Add group deletion with swipe-to-dismiss
5. Implement group renaming functionality

**Code Changes**:
- Added `Group` class with JSON serialization
- Created `_MyAppState` with group CRUD operations
- Built group list UI with ListView and Dismissible widgets

**Testing**: Verified group creation, deletion, and renaming work correctly.

### Phase 2: Member Management
**Objective**: Add ability to manage group members.

**Steps**:
1. Extend Group model to include members list
2. Create GroupDetailPage for individual group management
3. Add member addition dialog
4. Implement member removal with delete buttons
5. Update group persistence to include members

**Code Changes**:
- Modified `Group` class to include `List<String> members`
- Added `GroupDetailPage` with member list UI
- Implemented `_addMember` and `_removeMember` methods
- Updated JSON serialization for members

**Testing**: Added members, removed them, verified persistence across app restarts.

### Phase 3: Expense Tracking
**Objective**: Implement core expense addition and display.

**Steps**:
1. Create Expense model with description, amount, paidBy, splitAmong
2. Add expense addition dialog with form fields
3. Implement expense list display
4. Add expense deletion functionality
5. Update balance calculation (basic version)

**Code Changes**:
- Added `Expense` class with JSON methods
- Created `_showAddExpenseDialog` with TextFields and Dropdowns
- Built expense list UI with ListTile
- Implemented `_addExpense` and `_removeExpense` methods

**Testing**: Added expenses, verified they appear in list and can be deleted.

### Phase 4: Balance Calculation
**Objective**: Implement accurate balance calculation for splitting.

**Steps**:
1. Develop `_calculateBalances` method with proper logic
2. Display balances in member list (owed/owes amounts)
3. Handle equal splitting among selected members
4. Update UI to show balance colors (green for owed, red for owes)

**Code Changes**:
- Implemented balance calculation: payer gets +amount, splitters get -amount/splitCount
- Added balance display in member ListTiles
- Used TextStyle with colors for visual feedback

**Testing**: Verified balances update correctly when expenses are added/removed.

### Phase 5: Persistence
**Objective**: Save all data locally so it survives app restarts.

**Steps**:
1. Integrate shared_preferences package
2. Implement `_loadGroups` and `_saveGroups` methods
3. Add automatic saving on data changes
4. Handle JSON encoding/decoding for complex objects

**Code Changes**:
- Added shared_preferences dependency
- Created `_loadGroups` with async SharedPreferences access
- Modified all CRUD operations to call `_saveGroups`
- Added error handling for JSON parsing

**Testing**: Restarted app multiple times, verified data persistence.

### Phase 6: Settle Up Calculator** 💸
**Why**: The most requested feature in expense apps - shows minimum payments to zero out balances.
**How**: "Settle Up" button calculates and displays who pays whom and how much.
**Implementation**: Algorithm separates creditors/debtors, matches them to minimize transfers.

**Code Changes**:
- Added `_calculateSettlements()` method with greedy matching algorithm
- Created `_showSettleUpDialog()` with payment suggestions in cards
- Added "Settle Up" button in group details UI

**Testing**: Verified with various balance scenarios (3+ members), confirmed minimum transfers calculated correctly.

**Problems Faced**:
- Algorithm complexity: Initially tried simple pairwise, switched to greedy sorting for minimum transfers
- UI display: Chose card layout for readability, added tip about payment apps
- Edge case: Zero balances show "All settled" message

**Solution**: Greedy algorithm sorts creditors/debtors by amount, matches largest first for optimal transfers.

### Phase 7: Receipt Photo Attachments 📸
**Objective**: Allow users to attach receipt photos to expenses for better record-keeping.

**Steps**:
1. Add image_picker dependency to pubspec.yaml
2. Update Expense model to include imageBase64 field
3. Modify _showAddExpenseDialog to include image picker UI
4. Display image preview in expense list
5. Handle image encoding/decoding for persistence

**Code Changes**:
- Added `image_picker: ^1.0.4` dependency
- Extended `Expense` class with `String? imageBase64` field
- Updated JSON serialization methods
- Added image picker button and preview in add expense dialog
- Added image display in expense cards

**Testing**: Verified image selection, display, and persistence across app restarts.

**Problems Faced**:
- Image encoding: Needed to convert File to base64 for storage
- UI layout: Dialog became too tall, added SingleChildScrollView
- Memory usage: Large images could cause issues, but base64 handles it well

**Solution**: Used base64 encoding for simple persistence, added optional image display.

### Phase 8: Spending Analytics & Charts 📊
**Objective**: Provide visual insights into spending patterns with charts.

**Steps**:
1. Add fl_chart dependency to pubspec.yaml
2. Create _showAnalyticsDialog method
3. Implement category pie chart showing spending breakdown
4. Add member spending bar chart
5. Include analytics button in group details UI

**Code Changes**:
- Added `fl_chart: ^0.66.1` dependency
- Created `_showAnalyticsDialog()` with PieChart and BarChart
- Implemented `_memberSpending()` and `_categoryTotals()` helpers
- Added color coding for categories in charts
- Positioned "Analytics" button next to "Settle Up"

**Testing**: Verified charts display correctly with sample data, tested empty state handling.

**Problems Faced**:
- Chart sizing: Needed fixed heights for proper display in dialog
- Data preparation: Had to aggregate data from expenses for charts
- Color consistency: Created `_getCategoryColor()` for consistent category colors
- Runtime issue: Analytics dialog could throw render exceptions or fail when data was empty
- Exception handling: Division by zero in percentage calculations when total spending is zero
- Render box sizing: Charts failed to render with zero size when data was invalid or empty
- Material context fix: Dialog calls now use a `Builder` context inside `MaterialApp`, preventing web popup localization errors

**Solution**: Used fl_chart for beautiful, responsive charts with proper data aggregation, switched the analytics popup to a `Dialog` with explicit constraints, added zero-data guards to prevent runtime exceptions, and ensured charts only render with valid data and minimum heights.

## 🐛 Problems Faced & Solutions

### Dialog Not Showing on Web
**Problem**: Create Group dialog threw `No MaterialLocalizations found` when running on Chrome.
**Root Cause**: `showDialog` was called with a context that was above `MaterialApp`, so the dialog could not access `MaterialLocalizations`.
**Solution**: Wrapped `MaterialApp.home` in a `Builder` and used the inner context for dialog calls. Also kept `flutter_localizations` configured with `localizationsDelegates` and `supportedLocales`.

### Analytics Dialog Render Error
**Problem**: The analytics popup could fail with chart rendering errors, layout exceptions, or blank dialog behavior.
**Root Cause**: `fl_chart` widgets were rendered inside dialog content without explicit sizing and without guarding against zero total data, which caused layout and render box issues.
**Solution**: Switched analytics to use `Dialog` with a `ConstrainedBox`, fixed heights for charts, and added guards to render charts only when valid expense data exists.

### UI Not Updating After Member Addition
**Problem**: Adding members didn't refresh the UI immediately.
**Root Cause**: setState called in dialog, but not propagated to page level.
**Solution**: Moved setState calls to `_GroupDetailPageState` methods and called them from dialogs.

### Deprecated DropdownButtonFormField API
**Problem**: `value` property deprecated, causing analysis warnings.
**Root Cause**: Using old Flutter API version.
**Solution**: Replaced `value` with `initialValue` in DropdownButtonFormField.

### Expense Constructor Mismatch
**Problem**: Expense creation failed with "not enough positional arguments".
**Root Cause**: Updated Expense class to include category and date, but forgot to update constructor calls.
**Solution**: Modified `_addExpense` method signature and calls to include new parameters.

### Balance Calculation Errors
**Problem**: Balances showed incorrect amounts for complex splits.
**Root Cause**: Initial logic didn't handle custom splitting (only all members).
**Solution**: Updated logic to split only among selected members, not all group members.

### Persistence Data Loss
**Problem**: Data disappeared on app restart despite shared_preferences.
**Root Cause**: JSON encoding/decoding errors for nested objects.
**Solution**: Added proper error handling and validation in `_loadGroups`.

### Flutter Run / Web Launch Error
**Problem**: `flutter run` returned `No pubspec.yaml file found` and the web session would not start correctly.
**Root Cause**: Running Flutter from the wrong shell path instead of the project root `expense_splitter`.
**Solution**: Changed directory to `c:\Users\User\Desktop\expense-splitter\expense_splitter`, ran `flutter pub get`, then launched `flutter run -d chrome` from that root.

### flutter_localizations Dependency Issue
**Problem**: Analyzer reported `package:flutter_localizations/flutter_localizations.dart` not found and `GlobalMaterialLocalizations` undefined.
**Root Cause**: The package dependency was not properly resolved in the current flutter session.
**Solution**: Ensured `flutter_localizations` is listed under `dependencies` in `pubspec.yaml`, ran `flutter pub get`, and configured `localizationsDelegates`/`supportedLocales` in `MaterialApp`.

### Analytics Button Render Box Size Exception
**Problem**: Clicking Analytics button threw "Cannot hit test a render box with no size" and assertion failures.
**Root Cause**: Chart widgets (PieChart/BarChart) were rendered with zero or invalid sizes when data totals were zero, causing Flutter to fail hit testing on non-existent render boxes.
**Solution**: Added total > 0 check to skip PieChart rendering when no spending data exists, and clamped BarChart maxY to minimum 10 to ensure valid sizing.

### Search/Filter Performance
**Problem**: Filtering large expense lists caused UI lag.
**Root Cause**: Re-filtering on every build without optimization.
**Solution**: Cached filtered results and only recalculated when filters changed.

## 🔧 Problem-Solving Approach

### Edge Cases Handled
- **Empty Groups**: UI gracefully handles groups with no members or expenses
- **Invalid Inputs**: Form validation prevents empty descriptions, negative amounts, no payers
- **Date Selection**: Date picker restricted to past dates, defaults to today
- **Member Removal**: Prevents removing members with outstanding balances (shows warning)
- **Expense Splitting**: Validates at least one member selected for splitting
- **Persistence Failures**: Graceful fallback to empty state if data loading fails

### Tricky Decisions
- **Balance Display**: Chose color coding (green/red) over icons for clarity
- **Category System**: Predefined categories vs. custom - chose predefined for simplicity
- **Date Filtering**: Implemented multiple ranges (7 days, 30 days, year) instead of custom date pickers
- **UI Layout**: Single scrollable ListView for group details vs. multiple sections - chose unified scrolling for better UX

### Things That Didn't Go As Planned
- **Initial Balance Logic**: Started with simple equal split, had to refactor for custom splitting
- **Dialog State Management**: Initially used StatefulBuilder, switched to page-level state for better control
- **Category Icons**: Planned emoji icons per category, but used text avatars for consistency
- **Export Feature**: Considered adding CSV export, but prioritized core features first

## ⚠️ Known Issues
- **Web popup dialogs**: `showDialog` must use a context inside `MaterialApp`; otherwise `MaterialLocalizations` errors occur.
- **Analytics dialog rendering**: Chart widgets need explicit sizing and zero-data guards to avoid render-box exceptions.
- **DropdownButtonFormField API**: Older Flutter versions use `value`; current best practice is `initialValue`.

## 📦 Installation

### Prerequisites
- Flutter SDK 3.11.5 or higher
- Dart SDK
- Chrome browser (for web testing)

### Setup
1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd expense-splitter/expense_splitter
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run -d chrome
   ```

## 📖 Usage

### Creating Groups
1. Tap "➕ Create Group"
2. Enter group name
3. Tap "Add"

### Managing Members
1. Open a group
2. Tap "Add Member"
3. Enter member name
4. Use delete button to remove members

### Adding Expenses
1. In group details, tap "Add Expense"
2. Fill description, amount, select payer
3. Choose category and date
4. Select who shares the expense
5. Tap "Add"

### Viewing Balances
- Member balances show in green (owed money) or red (owes money)
- Summary card shows total spent, expense count, and average per person

### Searching & Filtering
- Use search bar to find expenses by description or payer
- Filter by category or date range
- Results update in real-time

## 📸 Screenshots

*(Screenshots would be added here in a real repository)*

- Main screen with group list
- Group details with members and expenses
- Add expense dialog with all options
- Filtered expense list

## 🚀 Future Enhancements

### 🎨 Interactive Diary-Style Enhancements: Rabbit-Themed Expense Diary App
**Headline**: Transform Expense Splitter into a Cute, Animated Diary Game – Rabbit Slides Through Categories, Unfolds Receipts, and Builds Storybook Summaries!

**Workflow Overview**: Homepage features a rabbit sliding on a skateboard across category backgrounds (Food with food icons, Transport with roads, etc.). User selects category → Calendar popup for date selection → Rabbit "arrives" at date → Group creation dialog with rabbits forming a circle (assign names to rabbits/people) → Expense addition with receipt unfolding animation (description, amount, payer, split checkboxes with rabbit names, image upload) → Analytics with animated charts → Settle-up with visual payments → Diary summary as flipped calendar book with expense cards and feedback (e.g., "Smart saver!" or "Oh no, big spender!").

**Functionality**: Solves the problem by making expense tracking engaging and visual, like a game/diary. Core logic (groups, expenses, balances) remains unchanged; adds animations and themes for better UX without breaking features. Works on web/mobile with lightweight assets.

**Code Quality**: Clean, readable additions using Flutter best practices. New classes (`AnimatedHomepage`, `DiarySummaryPage`) are modular. Uses `Lottie` for animations, `Builder` for context fixes. No breaking changes – integrates seamlessly.

**Problem-Solving**: Handles edge cases like zero-data animations (guards in charts), web dialog contexts (Builder wrapper), and performance (lightweight Lottie/Rive). Tricky decisions: Pre-made assets over custom 3D for simplicity; Lottie over Rive for ease. Didn't go as planned: Initially considered full 3D, but stuck to 2D for Flutter compatibility.

**Communication**: Built this to make the app more fun and memorable, like a Disney storybook. Choices: Lottie for smooth rabbit animations, receipt unfolding for intuitive expense entry, calendar flip for diary feel. With more time, I'd add voice narration or haptic feedback for full immersion.

**Implementation Steps**:
1. **Assets**: Add `lottie: ^3.0.0` to `pubspec.yaml`. Download Lottie JSONs (rabbit_walk.json, receipt_unfold.json) from LottieFiles. Add PNG backgrounds (food_bg.png, etc.) from free sources like Unsplash/OpenGameArt.
2. **Homepage Animation**: Replace `Scaffold` body in `_MyAppState.build` (line ~250) with `AnimatedHomepage` class using `AnimatedPositioned` for rabbit sliding and `AnimatedSwitcher` for backgrounds.
3. **Calendar & Group Creation**: Add `_showCalendarDialog` method; enhance `showAddGroupDialog` with Lottie rabbits.
4. **Expense Receipt**: Modify `_showAddExpenseDialog` to use `Dialog` with Lottie unfolding; add rabbit-named checkboxes and image upload.
5. **Analytics & Settle-Up**: Wrap charts in `AnimatedOpacity`; add animations to settlement cards.
6. **Diary Summary**: New `DiarySummaryPage` with `PageView` for book flip, animated cards, and feedback logic.

- **Currency Support**: Multi-currency expenses with conversion
- **Export/Import**: CSV export and import functionality
- **Cloud Sync**: Sync data across devices
- **Notifications**: Reminders for unsettled balances
- **Themes**: Dark mode and custom themes

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

Built with ❤️ using Flutter. Happy splitting!
=======
# Expense-splitter
A trip-based expense splitter app with diary-style 
>>>>>>> bc4e6ef7d9ca9376e708ff06c026e655d236faad
