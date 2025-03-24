# To-Do List App

A simple and elegant To-Do List application built with Flutter and Provider for state management.

## Features
- Add, edit, and delete tasks
- Persist tasks using Provider
- Supports light and dark themes
- Uses Material 3 design principles
- Smooth scrolling with BouncingScrollPhysics
- Adaptive layout supporting portrait orientations

## Technologies Used
- Flutter
- Provider (State Management)
- Material 3 Design

## Installation
1. Clone the repository:
   ```sh
   git clone https://github.com/KaivanKeren/flutter-todo-list.git
   cd flutter-todo-list
   ```
2. Install dependencies:
   ```sh
   flutter pub get
   ```
3. Run the app:
   ```sh
   flutter run
   ```

## Project Structure
```
android_project/
│── lib/
│   ├── main.dart           # Entry point of the app
│   ├── models/
│   │   ├── save_task.dart  # A model for storing and managing to-do lists.
│   │   ├── task_model.dart  # Model for assignments.
│   ├── screens/
│   │   ├── add_todo.dart   # Page to add new tasks.
│   │   ├── todo_list.dart  # Main screen displaying tasks.
│── pubspec.yaml            # Dependencies and package configurations
│── README.md               # Project documentation
```

## Usage
- Launch the app and view existing tasks.
- Tap the add button to create a new task.
- Tap on an existing task to edit it.
- Swipe to delete a task.

## Contributions
Feel free to fork this repository and submit pull requests for improvements or new features.

## License
This project is licensed under the MIT License.