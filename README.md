# Syntra

#### Video Demo:  <URL HERE>

#### Description:

Syntra is a modern Flutter application designed to help users elevate their social life and personal growth through daily challenges, reminders, and progress tracking. The app is built with a focus on usability, accessibility, and a visually appealing interface. Syntra leverages a variety of Flutter packages to provide a rich user experience, including notifications, sound effects, persistent storage, and more.

## Features

- **Daily Challenges:** Users receive daily challenges to encourage social interaction and personal development.
- **Reminders & Notifications:** The app can send notifications to remind users about their daily tasks and challenges.
- **Dark Mode:** Users can switch between light and dark themes for comfortable viewing in any environment.
- **Sound Effects:** Interactive sound effects enhance the user experience.
- **Language Selection:** Users can choose their preferred language from a selection of options.
- **About Page:** Displays up-to-date app information, including the current version, using dynamic version fetching.
- **Privacy Policy:** Easy access to the app's privacy policy.

## File Overview

- `lib/main.dart`: The entry point of the application. Sets up the main app widget, theme, and navigation.
- `lib/static.dart`: Contains static values such as color schemes and text styles used throughout the app.
- `lib/routes/Settings.dart`: Implements the settings page, allowing users to configure notifications, dark mode, sound, language, and access the About and Privacy Policy pages.
- `lib/routes/AboutNotePage.dart`: The About page widget. Dynamically fetches and displays the app version and other information using the `package_info_plus` package.
- `lib/Challenge.dart`: Manages the logic and data structures for daily challenges.
- `lib/database/`: Contains database-related files for persistent storage of user data and app settings.
- `lib/widgets/`: Custom reusable widgets used across the app.
- `assets/`: Contains static assets such as the challenge database and sound files.

## Design Choices

- **Dynamic Version Display:** The About page uses the `package_info_plus` package to always show the current app version, ensuring accuracy even after updates.
- **Persistent Settings:** User preferences (like dark mode) are saved using local storage, so settings persist across app restarts.
- **Separation of Concerns:** The codebase is organized into logical folders (routes, widgets, database) to keep the project maintainable and scalable.
- **Accessibility:** The app uses clear text, sufficient color contrast, and large touch targets to be accessible to a wide range of users.
- **Extensibility:** The modular structure allows for easy addition of new features, such as more languages or challenge types.

## Notable Packages Used

- `package_info_plus`: For retrieving app version and build number.
- `flutter_local_notifications`: For scheduling and displaying notifications.
- `audioplayers`: For playing sound effects.
- `path_provider`, `sqflite`, `shared_preferences`: For local data storage and persistence.

## Challenges and Decisions

During development, several design decisions were made to balance user experience and technical complexity. For example, the choice to use `FutureBuilder` on the About page ensures that version information is always accurate, but required careful handling of asynchronous data in the UI. The settings page was designed to be both comprehensive and user-friendly, grouping related options and providing clear explanations for each setting.

The app's structure was influenced by the need for maintainability and future growth. By separating widgets, routes, and data logic, the codebase remains clean and easy to navigate. The use of external packages was carefully considered to avoid unnecessary dependencies while still providing a rich feature set.

## How to Run

1. Ensure you have Flutter installed and configured on your machine.
2. Run `flutter pub get` to install dependencies.
3. Launch the app using `flutter run` on your preferred device or emulator.

## Conclusion

Syntra is a thoughtfully designed app that combines daily motivation with practical tools for self-improvement. Its modular architecture, dynamic features, and attention to user experience make it a solid foundation for further development and customization. For more details, see the in-app About page or explore the codebase.

