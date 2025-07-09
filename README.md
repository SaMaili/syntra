# Syntra

#### Video Demo:  [Click here](https://www.youtube.com/watch?v=n8rUr89IBlM)

#### Description:

Syntra is a modern Flutter application designed to help users elevate their social life and personal
growth through daily challenges, reminders, and progress tracking. The app is built with a focus on
usability, accessibility, and a visually appealing interface. Syntra leverages a variety of Flutter
packages to provide a rich user experience, including notifications, sound effects, persistent
storage, and more.

## Features

- **Daily Challenges:** Users receive daily challenges to encourage social interaction and personal
  development.
- **Reminders & Notifications:** The app can send notifications to remind users about their daily
  tasks and challenges.
- **Dark Mode:** Users can switch between light and dark themes for comfortable viewing in any
  environment.
- **Sound Effects:** Interactive sound effects enhance the user experience.
- **About Page:** Displays up-to-date app information, including the current version, using dynamic
  version fetching.

## File Overview

Below is a summary of every file in the project, each explained in one sentence:

- `lib/main.dart`: The main entry point of the app, responsible for initializing the app, setting up themes, and managing navigation.
- `lib/static.dart`: Defines static constants for colors, text styles, and other design elements used throughout the app.
- `lib/routes/AboutPage.dart`: Implements the About page, displaying app information and version details dynamically.
- `lib/routes/ActiveChallengeScreen.dart`: Handles the workflow and UI for an active challenge, including timers and completion logic.
- `lib/routes/ChallengeDoneScreen.dart`: Shows the results and feedback options after a challenge is completed or aborted.
- `lib/routes/ChallengesScreen.dart`: Displays a list of available challenges and allows users to browse and select them.
- `lib/routes/DailyChallengeScreen.dart`: Presents the daily challenge to the user and manages its acceptance and completion.
- `lib/routes/LogbookDetailPage.dart`: Shows detailed information about a specific logbook entry, including challenge results and notes.
- `lib/routes/LogbookPage.dart`: Lists all completed challenges, allowing users to review their progress in a logbook format.
- `lib/routes/SettingsScreen.dart`: Provides a settings interface for configuring notifications, dark mode, language, and accessing app info.
- `lib/routes/StatisticsScreen.dart`: Displays user statistics, such as XP, streaks, and activity charts.
- `lib/database/database_helper.dart`: Contains helper functions for interacting with the SQLite database for persistent storage.
- `lib/database/logbook_database.dart`: Manages the logbook database, including CRUD operations for challenge entries.
- `lib/database/settings_database.dart`: Handles storage and retrieval of user settings in the database.
- `lib/widgets/ChallengeCard.dart`: Defines the UI for displaying individual challenge cards with adaptive theming.
- `lib/widgets/challenge_info_notification.dart`: Provides dialogs and notifications with information about challenges and user progress.
- `lib/widgets/NotSureWhatToSayDialog.dart`: Implements a dialog to help users if they are unsure what to say during a challenge.
- `lib/widgets/StatsOverviewContainer.dart`: Displays a summary of user statistics in a visually appealing container.
- `lib/widgets/CardSwiper.dart`: Implements a swipeable card interface for browsing challenges.
- `lib/widgets/DebugDbButton.dart`: Adds a debug button for developers to inspect or reset the database.
- `lib/Challenge.dart`: Defines the Challenge model and logic for managing challenge data.
- `lib/ChallengeLogic.dart`: Contains business logic for filtering, shuffling, and managing challenges.
- `lib/DailyChallengeLogic.dart`: Manages the logic for daily challenges, including selection and completion tracking.
- `lib/NotificationService.dart`: Handles scheduling and displaying local notifications to the user.
- `lib/themeModeNotifier.dart`: Provides a notifier for managing and persisting the app's theme mode (light/dark).
- `lib/assets/challenges.json`: Stores the database of available challenges in JSON format.
- `lib/assets/sounds/`: Contains sound files used for interactive feedback and notifications.
- `pubspec.yaml`: Specifies project dependencies, assets, and metadata for the Flutter app.
- `README.md`: This documentation file, describing the project, its structure, and design decisions.

## Design Choices

- **Dynamic Version Display:** The About page uses the `package_info_plus` package to always show
  the current app version, ensuring accuracy even after updates.
- **Persistent Settings:** User preferences (like dark mode) are saved using local storage, so
  settings persist across app restarts.
- **Separation of Concerns:** The codebase is organized into logical folders (routes, widgets,
  database) to keep the project maintainable and scalable.
- **Accessibility:** The app uses clear text, sufficient color contrast, and large touch targets to
  be accessible to a wide range of users.
- **Extensibility:** The modular structure allows for easy addition of new features, such as more
  languages or challenge types.
- **Simplicity in UI:** The user interface was intentionally kept simple and focused to reduce distractions and make the app approachable for everyone. In earlier versions of Syntra, there was a dedicated "Mindset" page where users could view encouraging quotes and mindset guidelines. However, after user feedback and design review, this feature was removed to streamline the experience and keep the main focus on actionable challenges and progress tracking.

## Notable Packages Used

- `package_info_plus`: For retrieving app version and build number.
- `flutter_local_notifications`: For scheduling and displaying notifications.
- `audioplayers`: For playing sound effects.
- `path_provider`: For locating commonly used locations on the filesystem.
- `sqflite`: For SQLite database operations and persistent storage.
- `shared_preferences`: For storing simple key-value pairs and user settings.
- `provider`: For state management and dependency injection.
- `google_fonts`: For custom font support and improved typography.
- `intl`: For date and time formatting and localization.
- `url_launcher`: For opening URLs in the device browser.
- `flutter_svg`: For rendering SVG images and icons.
- `animations`: For advanced and prebuilt animation widgets.
- `flutter_slidable`: For swipeable list tiles and actions.
- `fluttertoast`: For displaying toast notifications.
- `timezone`: For advanced timezone handling with notifications.

## Challenges and Decisions

During development, several design decisions were made to balance user experience and technical
complexity. For example, the choice to use `FutureBuilder` on the About page ensures that version
information is always accurate, but required careful handling of asynchronous data in the UI. The
settings page was designed to be both comprehensive and user-friendly, grouping related options and
providing clear explanations for each setting.

The app's structure was influenced by the need for maintainability and future growth. By separating
widgets, routes, and data logic, the codebase remains clean and easy to navigate. The use of
external packages was carefully considered to avoid unnecessary dependencies while still providing a
rich feature set.

## How to Run

1. Ensure you have Flutter installed and configured on your machine.
2. Run `flutter pub get` to install dependencies.
3. Launch the app using `flutter run` on your preferred device or emulator.

## Conclusion

Syntra is a thoughtfully designed app that combines daily motivation with practical tools for
self-improvement. Its modular architecture, dynamic features, and attention to user experience make
it a solid foundation for further development and customization. For more details, see the in-app
About page or explore the codebase.
